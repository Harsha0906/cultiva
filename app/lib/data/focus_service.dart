import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/farm_day.dart';
import '../domain/plant_engine.dart';
import '../domain/rewards.dart';
import '../domain/task.dart';
import 'db.dart';
import 'farm_service.dart';
import 'focus_math.dart';

enum FocusStatus { idle, running, paused, abandoned, ripe, harvested }

/// What the Focus screen shows for one task right now.
final class FocusSnapshot {
  const FocusSnapshot({
    required this.task,
    required this.status,
    required this.elapsedSec,
    required this.plannedSec,
    this.suspicious = false,
    this.endsAt,
  });

  final FarmTask task;
  final FocusStatus status;
  final int elapsedSec;
  final int plannedSec;
  final bool suspicious;

  /// Wall-clock time the timer will finish (running only).
  final DateTime? endsAt;

  int get remainingSec => max(0, plannedSec - elapsedSec);
  double get progress =>
      plannedSec == 0 ? 0 : (elapsedSec / plannedSec).clamp(0.0, 1.0);

  /// The plant stage this progress shows (matches the farm).
  PlantStage get stage => switch (status) {
    FocusStatus.ripe => PlantStage.ripe,
    FocusStatus.harvested => PlantStage.harvested,
    _ when elapsedSec == 0 => PlantStage.seed,
    _ when progress < 0.5 => PlantStage.sprout,
    _ => PlantStage.young,
  };
}

class FocusException implements Exception {
  const FocusException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Timestamp-based focus timer: one session row per task per farm day.
/// Nothing ticks in the background; elapsed time is always computed.
class FocusService {
  FocusService(this._db, this._farm, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CultivaDb _db;
  final FarmService _farm;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  Future<FocusSession?> _row(String taskId, FarmDay day) =>
      (_db.select(_db.focusSessions)
            ..where((f) => f.taskId.equals(taskId) & f.day.equals(day.key)))
          .getSingleOrNull();

  Future<void> _write(String id, FocusSessionsCompanion c) =>
      (_db.update(_db.focusSessions)..where((f) => f.id.equals(id))).write(c);

  void _checkTimed(FarmTask task) {
    if (task.kind != TaskKind.timed) {
      throw const FocusException('Only Daily tasks use the focus timer.');
    }
  }

  /// Current state; finishes the session if its time is up.
  Future<FocusSnapshot> load(FarmTask task) async {
    _checkTimed(task);
    final day = await _farm.today();
    final done = await _farm.progress.forTaskOn(task.id, day);
    final planned = task.targetMinutes! * 60;
    if (done != null) {
      return FocusSnapshot(
        task: task,
        status: done.harvestedAt != null
            ? FocusStatus.harvested
            : FocusStatus.ripe,
        elapsedSec: planned,
        plannedSec: planned,
      );
    }
    var row = await _row(task.id, day);
    if (row == null) {
      return FocusSnapshot(
        task: task,
        status: FocusStatus.idle,
        elapsedSec: 0,
        plannedSec: planned,
      );
    }
    final now = _clock();
    final (elapsed, clockWrong) = focusElapsed(row, now);
    if (clockWrong && !row.suspicious) {
      // Re-anchor so a backwards clock can't be farmed, and remember the doubt.
      await _write(
        row.id,
        FocusSessionsCompanion(
          suspicious: const Value(true),
          accumulatedSec: Value(elapsed),
          startedAt: Value(now),
        ),
      );
      row = (await _row(task.id, day))!;
    }
    if (row.status == FocusRowStatus.running && elapsed >= row.plannedSec) {
      return _finish(task, row, day);
    }
    return _snapshot(task, row, now, elapsed);
  }

  FocusSnapshot _snapshot(
    FarmTask task,
    FocusSession row,
    DateTime now,
    int elapsed,
  ) {
    final status = switch (row.status) {
      FocusRowStatus.running => FocusStatus.running,
      FocusRowStatus.paused => FocusStatus.paused,
      FocusRowStatus.abandoned => FocusStatus.abandoned,
      _ => FocusStatus.ripe,
    };
    return FocusSnapshot(
      task: task,
      status: status,
      elapsedSec: elapsed,
      plannedSec: row.plannedSec,
      suspicious: row.suspicious,
      endsAt: status == FocusStatus.running
          ? now.add(Duration(seconds: row.plannedSec - elapsed))
          : null,
    );
  }

  Future<FocusSnapshot> start(FarmTask task) async {
    _checkTimed(task);
    final day = await _farm.today();
    if (!isDue(task, day)) {
      throw const FocusException('This plant is resting today.');
    }
    if (await _farm.progress.forTaskOn(task.id, day) != null) {
      return load(task);
    }
    final now = _clock();
    final row = await _row(task.id, day);
    if (row == null) {
      await _db
          .into(_db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              id: _uuid.v4(),
              taskId: task.id,
              day: day.key,
              startedAt: now,
              plannedSec: task.targetMinutes! * 60,
              status: FocusRowStatus.running,
            ),
          );
    } else if (row.status != FocusRowStatus.running) {
      await _write(
        row.id,
        FocusSessionsCompanion(
          status: const Value(FocusRowStatus.running),
          startedAt: Value(now),
        ),
      );
    }
    return load(task);
  }

  Future<FocusSnapshot> pause(FarmTask task) =>
      _stop(task, FocusRowStatus.paused);

  /// Stops for today; growth so far stays on the plant.
  Future<FocusSnapshot> giveUp(FarmTask task) =>
      _stop(task, FocusRowStatus.abandoned);

  Future<FocusSnapshot> _stop(FarmTask task, String status) async {
    final day = await _farm.today();
    final row = await _row(task.id, day);
    if (row == null || row.status != FocusRowStatus.running) return load(task);
    final now = _clock();
    final (elapsed, clockWrong) = focusElapsed(row, now);
    await _write(
      row.id,
      FocusSessionsCompanion(
        status: Value(status),
        accumulatedSec: Value(elapsed),
        suspicious: Value(row.suspicious || clockWrong),
      ),
    );
    return load(task);
  }

  /// Called by the screen when its own monotonic stopwatch disagrees with the
  /// wall clock by more than [kStopwatchDriftSec].
  Future<void> flagClockDrift(FarmTask task) async {
    final row = await _row(task.id, await _farm.today());
    if (row != null && !row.suspicious) {
      await _write(
        row.id,
        const FocusSessionsCompanion(suspicious: Value(true)),
      );
    }
  }

  Future<FocusSnapshot> _finish(
    FarmTask task,
    FocusSession row,
    FarmDay day,
  ) async {
    await _write(
      row.id,
      FocusSessionsCompanion(
        status: const Value(FocusRowStatus.done),
        accumulatedSec: Value(row.plannedSec),
        endedAt: Value(_clock()),
      ),
    );
    await _farm.complete(
      task,
      method: row.suspicious ? CompletionMethod.manual : CompletionMethod.focus,
      minutes: task.targetMinutes!,
    );
    return FocusSnapshot(
      task: task,
      status: FocusStatus.ripe,
      elapsedSec: row.plannedSec,
      plannedSec: row.plannedSec,
      suspicious: row.suspicious,
    );
  }
}

const kStopwatchDriftSec = 90;
