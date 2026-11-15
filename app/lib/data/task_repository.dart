import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/farm_day.dart';
import '../domain/plant_engine.dart';
import '../domain/task.dart';
import 'db.dart';

class PlotFullException implements Exception {
  const PlotFullException(this.plot);
  final PlotKind plot;
  @override
  String toString() => 'Plot ${plot.name} already has $kPlotCapacity plants.';
}

class InvalidTaskException implements Exception {
  const InvalidTaskException(this.problems);
  final List<String> problems;
  @override
  String toString() => problems.join(' ');
}

FarmTask taskFromRow(Task r) => FarmTask(
  id: r.id,
  title: r.title,
  plot: PlotKind.values.byName(r.plot),
  kind: TaskKind.values.byName(r.kind),
  targetMinutes: r.targetMinutes,
  repeat: Weekdays(r.repeatMask),
  crop: r.crop,
  slot: r.slot,
  createdDay: FarmDay.parse(r.createdDay),
  archived: r.archivedAt != null,
);

class TaskRepository {
  TaskRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CultivaDb _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  SimpleSelectStatement<$TasksTable, Task> _active() =>
      _db.select(_db.tasks)..where((t) => t.archivedAt.isNull());

  Stream<List<FarmTask>> watchActive() =>
      (_active()..orderBy([(t) => OrderingTerm.asc(t.slot)])).watch().map(
        (rows) => rows.map(taskFromRow).toList(),
      );

  Future<List<FarmTask>> active() async =>
      (await _active().get()).map(taskFromRow).toList();

  Future<FarmTask?> byId(String id) async {
    final row = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : taskFromRow(row);
  }

  /// Plants a new task in the lowest free slot of its plot.
  /// Throws [PlotFullException] or [InvalidTaskException].
  Future<FarmTask> plant({
    required String title,
    required PlotKind plot,
    required String crop,
    required FarmDay today,
    int? targetMinutes,
    Weekdays repeat = Weekdays.none,
  }) {
    return _db.transaction(() async {
      final inPlot = (await active()).where((t) => t.plot == plot);
      final slot = freeSlot(inPlot);
      if (slot == null) throw PlotFullException(plot);
      final task = FarmTask(
        id: _uuid.v4(),
        title: title.trim(),
        plot: plot,
        kind: plot == PlotKind.daily ? TaskKind.timed : TaskKind.check,
        targetMinutes: targetMinutes,
        repeat: repeat,
        crop: crop,
        slot: slot,
        createdDay: today,
      );
      if (task.problems.isNotEmpty) throw InvalidTaskException(task.problems);
      await _db
          .into(_db.tasks)
          .insert(
            TasksCompanion.insert(
              id: task.id,
              title: task.title,
              plot: task.plot.name,
              kind: task.kind.name,
              targetMinutes: Value(task.targetMinutes),
              repeatMask: Value(task.repeat.mask),
              crop: task.crop,
              slot: task.slot,
              createdDay: today.key,
              createdAt: _clock(),
            ),
          );
      return task;
    });
  }

  /// Removes a task from its plot (frees the slot). History is kept.
  Future<void> archive(String id) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(archivedAt: Value(_clock())),
      );

  /// Puts an archived task back, keeping its slot if free, else the lowest
  /// free one. Throws [PlotFullException] if the plot has no room.
  Future<void> restore(String id) => _db.transaction(() async {
    final task = await byId(id);
    if (task == null || !task.archived) return;
    final inPlot = (await active()).where((t) => t.plot == task.plot).toList();
    final taken = inPlot.any((t) => t.slot == task.slot);
    final slot = taken ? freeSlot(inPlot) : task.slot;
    if (slot == null) throw PlotFullException(task.plot);
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(archivedAt: const Value(null), slot: Value(slot)),
    );
  });

  /// Edits name/crop/duration/days. Plot and kind never change.
  /// Throws [InvalidTaskException] when the result would be invalid.
  Future<FarmTask> update(
    FarmTask task, {
    String? title,
    String? crop,
    int? targetMinutes,
    Weekdays? repeat,
  }) async {
    final next = task.copyWith(
      title: title?.trim(),
      crop: crop,
      targetMinutes: targetMinutes,
      repeat: task.isTodo ? null : repeat,
    );
    if (next.problems.isNotEmpty) throw InvalidTaskException(next.problems);
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(
        title: Value(next.title),
        crop: Value(next.crop),
        targetMinutes: Value(next.targetMinutes),
        repeatMask: Value(next.repeat.mask),
      ),
    );
    return next;
  }
}
