import 'farm_day.dart';
import 'task.dart';

const kPlotCapacity = 6;

enum PlantStage { resting, seed, sprout, young, ripe, harvested, dormant }

/// What happened to one task on one farm day.
final class DayRecord {
  const DayRecord({
    this.focusMinutes = 0,
    this.ripened = false,
    this.harvested = false,
  });

  static const empty = DayRecord();

  final int focusMinutes;
  final bool ripened;
  final bool harvested;
}

bool isDue(FarmTask task, FarmDay day) {
  if (day.isBefore(task.createdDay)) return false;
  if (task.isTodo) return true;
  return task.repeat.has(day.weekday);
}

/// The most recent due day strictly before [day] (up to a week back), or null
/// if there is none since the task was planted.
FarmDay? previousDueDay(FarmTask task, FarmDay day) {
  for (var i = 1; i <= 7; i++) {
    final d = day.addDays(-i);
    if (d.isBefore(task.createdDay)) return null;
    if (task.repeat.has(d.weekday)) return d;
  }
  return null;
}

/// Visual/interaction stage of [task] on [day].
///
/// [doneDays] are earlier days on which the task was completed (ripened or
/// harvested) — used to decide dormancy. Plants never die; progress revives.
PlantStage stageFor(
  FarmTask task,
  FarmDay day, {
  DayRecord today = DayRecord.empty,
  Set<FarmDay> doneDays = const {},
}) {
  if (today.harvested) return PlantStage.harvested;
  if (today.ripened) return PlantStage.ripe;
  if (!isDue(task, day)) return PlantStage.resting;

  final timed = task.kind == TaskKind.timed;
  final progress = timed ? today.focusMinutes / task.targetMinutes! : 0.0;

  final bool missed;
  if (task.isTodo) {
    missed = task.createdDay.isBefore(day);
  } else {
    final prev = previousDueDay(task, day);
    missed = prev != null && !doneDays.contains(prev);
  }
  if (missed && progress == 0) return PlantStage.dormant;

  if (!timed) return PlantStage.young;
  if (progress == 0) return PlantStage.seed;
  if (progress < 0.5) return PlantStage.sprout;
  return PlantStage.young;
}

/// Lowest free slot (0–5) among a plot's active tasks, or null when full.
int? freeSlot(Iterable<FarmTask> activeInPlot) {
  final used = {for (final t in activeInPlot) t.slot};
  for (var s = 0; s < kPlotCapacity; s++) {
    if (!used.contains(s)) return s;
  }
  return null;
}
