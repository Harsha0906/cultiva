import '../domain/farm_day.dart';
import 'db.dart';
import 'farm_service.dart';
import 'focus_math.dart';
import 'journal_repository.dart';

/// One completed task on a day (for lists and postcards).
final class DoneTask {
  const DoneTask(this.title, this.crop, {required this.harvested});
  final String title;
  final String crop;
  final bool harvested;
}

/// Everything recorded about one farm day.
final class DaySummary {
  const DaySummary({
    required this.day,
    required this.done,
    required this.focusMinutes,
    required this.coins,
    this.mood,
    this.note,
  });

  final FarmDay day;
  final List<DoneTask> done;
  final int focusMinutes;
  final int coins;
  final int? mood;
  final String? note;

  int get doneCount => done.length;
  int get harvestedCount => done.where((d) => d.harvested).length;
  bool get isEmpty =>
      done.isEmpty && focusMinutes == 0 && mood == null && (note ?? '').isEmpty;
}

/// Read-only aggregates for the Progress tab.
class StatsService {
  StatsService(
    this._db,
    this._farm,
    this._journal, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final CultivaDb _db;
  final FarmService _farm;
  final JournalRepository _journal;
  final DateTime Function() _clock;

  Future<DaySummary> summary(FarmDay day) async {
    final completions = await _farm.progress.forDay(day);
    final done = <DoneTask>[];
    var minutes = 0;
    final completedIds = <String>{};
    for (final c in completions) {
      final task = await _farm.tasks.byId(c.taskId);
      if (task == null) continue;
      completedIds.add(c.taskId);
      minutes += c.minutes;
      done.add(
        DoneTask(task.title, task.crop, harvested: c.harvestedAt != null),
      );
    }
    // Focus time on plants that haven't ripened yet still counts.
    final sessions = await (_db.select(
      _db.focusSessions,
    )..where((f) => f.day.equals(day.key))).get();
    final now = _clock();
    for (final s in sessions) {
      if (!completedIds.contains(s.taskId)) {
        minutes += focusElapsed(s, now).$1 ~/ 60;
      }
    }
    final j = await _journal.get(day);
    return DaySummary(
      day: day,
      done: done,
      focusMinutes: minutes,
      coins: await _farm.progress.earnedOn(day),
      mood: j?.mood,
      note: j?.note,
    );
  }

  /// Seven days ending on [end] (oldest first).
  Future<List<DaySummary>> week(FarmDay end) async => [
    for (var i = 6; i >= 0; i--) await summary(end.addDays(-i)),
  ];

  /// Every day of a month up to [today] (future days are left out).
  Future<List<DaySummary>> month(int year, int month, FarmDay today) async {
    final out = <DaySummary>[];
    for (var d = FarmDay(year, month, 1); d.month == month; d = d.addDays(1)) {
      if (d.isAfter(today)) break;
      out.add(await summary(d));
    }
    return out;
  }
}
