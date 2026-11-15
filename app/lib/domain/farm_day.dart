/// A farm day: runs from the reset hour (default 4:00) to the next reset,
/// so a late-night session still counts for "today". Stored as `YYYY-MM-DD`.
final class FarmDay implements Comparable<FarmDay> {
  factory FarmDay(int year, int month, int day) {
    final d = DateTime.utc(year, month, day);
    return FarmDay._(d.year, d.month, d.day);
  }

  const FarmDay._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static const defaultResetHour = 4;

  /// The farm day that the local wall-clock time [local] belongs to.
  static FarmDay of(DateTime local, {int resetHour = defaultResetHour}) {
    final d = FarmDay(local.year, local.month, local.day);
    return local.hour < resetHour ? d.addDays(-1) : d;
  }

  static final _key = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static FarmDay parse(String key) {
    final m = _key.firstMatch(key);
    if (m == null) throw FormatException('Not a farm day key', key);
    final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
    final parsed = FarmDay(y, mo, d);
    if (parsed.year != y || parsed.month != mo || parsed.day != d) {
      throw FormatException('Invalid date', key);
    }
    return parsed;
  }

  DateTime get _utc => DateTime.utc(year, month, day);

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  FarmDay addDays(int n) {
    final d = _utc.add(Duration(days: n));
    return FarmDay._(d.year, d.month, d.day);
  }

  int daysSince(FarmDay other) => _utc.difference(other._utc).inDays;

  bool isBefore(FarmDay other) => compareTo(other) < 0;
  bool isAfter(FarmDay other) => compareTo(other) > 0;
  bool operator <(FarmDay other) => isBefore(other);
  bool operator >(FarmDay other) => isAfter(other);

  @override
  int compareTo(FarmDay other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is FarmDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}
