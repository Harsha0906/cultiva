import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/task.dart';

/// App-facing notification API. The real one is installed in main();
/// widget tests get the no-op default (or a [FakeNotifier]).
abstract class AppNotifier {
  /// Ask for POST_NOTIFICATIONS (Android 13+). Returns whether allowed.
  Future<bool> requestPermission();

  /// Live countdown in the shade + a "ripe" alert at [endsAt] (same id).
  Future<void> focusStarted(FarmTask task, DateTime endsAt);

  /// Removes both (paused, gave up, or finished in-app).
  Future<void> focusStopped(FarmTask task);

  /// One cozy reminder a day at [minutesAfterMidnight] (local time).
  Future<void> scheduleDailyReminder(int minutesAfterMidnight);

  Future<void> cancelDailyReminder();

  /// Routes to open when the player taps a notification while the app runs.
  Stream<String> get taps;
}

/// Stable across app restarts (String.hashCode is not guaranteed to be), so a
/// focus notification posted before a restart can still be cancelled after.
/// 32-bit FNV-1a, kept positive and clear of the fixed reminder id.
int notificationIdFor(FarmTask task) {
  var h = 0x811c9dc5;
  for (final c in task.id.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  final id = h & 0x7fffffff;
  return id == kDailyReminderId ? id + 1 : id;
}

String focusRouteFor(FarmTask task) => '/focus/${task.id}';

/// Fixed id for the daily reminder.
const kDailyReminderId = 990001;

/// Next local occurrence of [minutesAfterMidnight] strictly after [now].
DateTime nextDailyAt(DateTime now, int minutesAfterMidnight) {
  final today = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(Duration(minutes: minutesAfterMidnight));
  return today.isAfter(now) ? today : today.add(const Duration(days: 1));
}

class NoopNotifier implements AppNotifier {
  const NoopNotifier();
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> focusStarted(FarmTask task, DateTime endsAt) async {}
  @override
  Future<void> focusStopped(FarmTask task) async {}
  @override
  Future<void> scheduleDailyReminder(int minutesAfterMidnight) async {}
  @override
  Future<void> cancelDailyReminder() async {}
  @override
  Stream<String> get taps => const Stream.empty();
}

/// Records calls for tests.
class FakeNotifier implements AppNotifier {
  FakeNotifier({this.allowPermission = true});

  final bool allowPermission;
  final log = <String>[];
  final _taps = StreamController<String>.broadcast();
  void tap(String route) => _taps.add(route);

  @override
  Future<bool> requestPermission() async {
    log.add('permission');
    return allowPermission;
  }

  @override
  Future<void> focusStarted(FarmTask task, DateTime endsAt) async =>
      log.add('started:${task.title}');

  @override
  Future<void> focusStopped(FarmTask task) async =>
      log.add('stopped:${task.title}');

  @override
  Future<void> scheduleDailyReminder(int minutesAfterMidnight) async =>
      log.add('reminder:$minutesAfterMidnight');

  @override
  Future<void> cancelDailyReminder() async => log.add('reminder:off');

  @override
  Stream<String> get taps => _taps.stream;
}

final notificationsProvider = Provider<AppNotifier>(
  (_) => const NoopNotifier(),
);

/// flutter_local_notifications-backed implementation (Android first).
class LocalNotifier implements AppNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();

  /// Route to open if the app was launched by tapping a notification.
  String? launchRoute;

  static const _ongoing = AndroidNotificationChannel(
    'focus_timer',
    'Focus timer',
    description: 'Shows your focus countdown while a plant is growing.',
    importance: Importance.low,
  );
  static const _done = AndroidNotificationChannel(
    'focus_done',
    'Ripe crops',
    description: 'Tells you when a focus session has ripened a plant.',
    importance: Importance.high,
  );
  static const _reminder = AndroidNotificationChannel(
    'daily_reminder',
    'Daily reminder',
    description: 'One gentle nudge a day to tend your farm.',
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_sprout'),
      ),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null && route.startsWith('/')) _taps.add(route);
      },
    );
    await _android?.createNotificationChannel(_ongoing);
    await _android?.createNotificationChannel(_done);
    await _android?.createNotificationChannel(_reminder);
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.startsWith('/')) {
      launchRoute = payload;
    }
  }

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> focusStarted(FarmTask task, DateTime endsAt) async {
    final id = notificationIdFor(task);
    final route = focusRouteFor(task);
    try {
      await _plugin.show(
        id: id,
        title: '${task.title} is growing',
        body: 'Stay focused. Your plant ripens when the timer ends.',
        payload: route,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _ongoing.id,
            _ongoing.name,
            channelDescription: _ongoing.description,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showWhen: true,
            when: endsAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
          ),
        ),
      );
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(endsAt.toUtc(), tz.UTC),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: '${task.title} is ripe!',
        body: 'Tap to harvest your coins.',
        payload: route,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _done.id,
            _done.name,
            channelDescription: _done.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      // Notifications are a nicety; the timer works without them.
      debugPrint('focusStarted notification failed: $e');
    }
  }

  @override
  Future<void> focusStopped(FarmTask task) async {
    try {
      await _plugin.cancel(id: notificationIdFor(task));
    } catch (e) {
      debugPrint('focusStopped cancel failed: $e');
    }
  }

  @override
  Future<void> scheduleDailyReminder(int minutesAfterMidnight) async {
    try {
      await _plugin.cancel(id: kDailyReminderId);
      final next = nextDailyAt(DateTime.now(), minutesAfterMidnight);
      await _plugin.zonedSchedule(
        id: kDailyReminderId,
        // Local next occurrence -> UTC instant; repeats daily at that time.
        scheduledDate: tz.TZDateTime.from(next.toUtc(), tz.UTC),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        title: 'Your sprouts are waiting',
        body: 'Plant or tend one thing today.',
        payload: '/farm',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _reminder.id,
            _reminder.name,
            channelDescription: _reminder.description,
          ),
        ),
      );
    } catch (e) {
      debugPrint('scheduleDailyReminder failed: $e');
    }
  }

  @override
  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(id: kDailyReminderId);
    } catch (e) {
      debugPrint('cancelDailyReminder failed: $e');
    }
  }

  @override
  Stream<String> get taps => _taps.stream;
}
