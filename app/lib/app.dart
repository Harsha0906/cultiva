import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/app_prefs.dart';
import 'core/notifications.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';

class CultivaApp extends ConsumerStatefulWidget {
  const CultivaApp({super.key, this.initialLocation = Routes.farm});

  final String initialLocation;

  @override
  ConsumerState<CultivaApp> createState() => _CultivaAppState();
}

class _CultivaAppState extends ConsumerState<CultivaApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    // Notification tapped while the app is running -> open that screen.
    _taps = ref.read(notificationsProvider).taps.listen(_router.push);
    // Keep the daily reminder scheduled across reinstalls/updates.
    Future(() async {
      final settings = ref.read(farmServiceProvider).settings;
      if (await settings.reminderEnabled()) {
        await ref
            .read(notificationsProvider)
            .scheduleDailyReminder(await settings.reminderMinutes());
      }
    }).ignore();
  }

  @override
  void dispose() {
    _taps?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    AppFeedback.hapticsOn = prefs.haptics;
    return MaterialApp.router(
      title: 'Cultiva',
      debugShowCheckedModeBanner: false,
      theme: buildCultivaTheme(),
      routerConfig: _router,
      // The app's own Reduce motion switch adds to the system setting.
      builder: (context, child) {
        if (!prefs.reduceMotion) return child!;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        );
      },
    );
  }
}
