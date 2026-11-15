import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import 'live_query.dart';

/// Player preferences that change how the whole app behaves.
final class AppPrefs {
  const AppPrefs({
    this.haptics = true,
    this.sound = true,
    this.reduceMotion = false,
  });
  final bool haptics;
  final bool sound;
  final bool reduceMotion;
}

final appPrefsProvider = StreamProvider<AppPrefs>((ref) {
  final db = ref.watch(dbProvider);
  final settings = ref.watch(farmServiceProvider).settings;
  return liveQuery(
    db.tableUpdates(TableUpdateQuery.onAllTables([db.settings])),
    () async => AppPrefs(
      haptics: await settings.haptics(),
      sound: await settings.sound(),
      reduceMotion: await settings.reduceMotion(),
    ),
  );
});

/// All vibrations go through here so the Haptics setting is respected.
abstract final class AppFeedback {
  static bool hapticsOn = true;

  static Future<void> light() async {
    if (hapticsOn) await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (hapticsOn) await HapticFeedback.mediumImpact();
  }
}
