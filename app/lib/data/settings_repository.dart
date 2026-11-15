import '../domain/avatar.dart';
import '../domain/farm_day.dart';
import 'db.dart';

/// Typed key/value settings with safe defaults.
class SettingsRepository {
  SettingsRepository(this._db);

  final CultivaDb _db;

  static const kResetHour = 'reset_hour';
  static const kAvatar = 'avatar';
  static const kFarmerName = 'farmer_name';
  static const kReminderMinutes = 'reminder_minutes';
  static const kSound = 'sound';
  static const kHaptics = 'haptics';
  static const kOnboarded = 'onboarded';

  Future<String?> _get(String key) async => (await (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<int> resetHour() async {
    final h = int.tryParse(await _get(kResetHour) ?? '');
    return (h != null && h >= 0 && h <= 12) ? h : FarmDay.defaultResetHour;
  }

  Future<void> setResetHour(int hour) {
    if (hour < 0 || hour > 12) throw RangeError.range(hour, 0, 12, 'hour');
    return _set(kResetHour, '$hour');
  }

  Future<Avatar> avatar() async => Avatar.parse(await _get(kAvatar));
  Future<void> setAvatar(Avatar a) => _set(kAvatar, a.id);

  Future<String> farmerName() async => (await _get(kFarmerName)) ?? 'Farmer';
  Future<void> setFarmerName(String name) {
    final n = name.trim();
    return _set(kFarmerName, n.isEmpty ? 'Farmer' : n);
  }

  /// Daily reminder time as minutes after midnight (default 8:30).
  Future<int> reminderMinutes() async {
    final m = int.tryParse(await _get(kReminderMinutes) ?? '');
    return (m != null && m >= 0 && m < 1440) ? m : 8 * 60 + 30;
  }

  Future<void> setReminderMinutes(int m) => _set(kReminderMinutes, '$m');

  Future<bool> _flag(String key, bool fallback) async =>
      switch (await _get(key)) {
        'true' => true,
        'false' => false,
        _ => fallback,
      };

  Future<bool> sound() => _flag(kSound, true);
  Future<void> setSound(bool v) => _set(kSound, '$v');
  Future<bool> haptics() => _flag(kHaptics, true);
  Future<void> setHaptics(bool v) => _set(kHaptics, '$v');
  Future<bool> onboarded() => _flag(kOnboarded, false);
  Future<void> setOnboarded(bool v) => _set(kOnboarded, '$v');
}
