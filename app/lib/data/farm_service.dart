import '../domain/farm_day.dart';
import '../domain/plant_engine.dart';
import '../domain/rewards.dart';
import '../domain/task.dart';
import 'db.dart';
import 'focus_math.dart';
import 'progress_repository.dart';
import 'settings_repository.dart';
import 'task_repository.dart';

/// One plant as the farm screen should show it.
final class PlantView {
  const PlantView({required this.task, required this.stage, this.completion});
  final FarmTask task;
  final PlantStage stage;
  final Completion? completion;
}

class FarmActionException implements Exception {
  const FarmActionException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Orchestrates the pure day/reward engines with the repositories.
/// Every multi-step change runs in a transaction.
class FarmService {
  FarmService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      tasks = TaskRepository(_db, clock: clock),
      progress = ProgressRepository(_db, clock: clock),
      settings = SettingsRepository(_db);

  final CultivaDb _db;
  final DateTime Function() _clock;
  final TaskRepository tasks;
  final ProgressRepository progress;
  final SettingsRepository settings;

  Future<FarmDay> today() async =>
      FarmDay.of(_clock(), resetHour: await settings.resetHour());

  /// All active plants with their stage for [day] (defaults to today).
  Future<List<PlantView>> plants([FarmDay? day]) async {
    final d = day ?? await today();
    final active = await tasks.active();
    final todays = {for (final c in await progress.forDay(d)) c.taskId: c};
    final now = _clock();
    final focusSec = {
      for (final s in await (_db.select(
        _db.focusSessions,
      )..where((f) => f.day.equals(d.key))).get())
        s.taskId: focusElapsed(s, now).$1,
    };
    final views = <PlantView>[];
    for (final t in active) {
      final c = todays[t.id];
      final done = await progress.doneDays(t.id, since: d.addDays(-7));
      done.remove(d);
      final stage = stageFor(
        t,
        d,
        today: DayRecord(
          focusMinutes: c?.minutes ?? ((focusSec[t.id] ?? 0) ~/ 60),
          ripened: c != null,
          harvested: c?.harvestedAt != null,
        ),
        doneDays: done,
      );
      views.add(PlantView(task: t, stage: stage, completion: c));
    }
    return views;
  }

  /// Marks a task complete (ripe) for today.
  Future<Completion> complete(
    FarmTask task, {
    CompletionMethod? method,
    int minutes = 0,
  }) async {
    final day = await today();
    if (!isDue(task, day)) {
      throw const FarmActionException('This plant is resting today.');
    }
    final m =
        method ??
        (task.kind == TaskKind.timed
            ? CompletionMethod.focus
            : CompletionMethod.check);
    if (task.kind == TaskKind.check && m != CompletionMethod.check) {
      throw const FarmActionException('Check tasks are simply checked off.');
    }
    return progress.ripen(
      taskId: task.id,
      day: day,
      method: m,
      // Timed tasks log their planned minutes (also for "I already did it":
      // the journal should show the time really spent; coins still pay half).
      minutes: m != CompletionMethod.check
          ? (minutes > 0 ? minutes : task.targetMinutes ?? 0)
          : minutes,
    );
  }

  /// Harvests a ripe plant: pays coins (capped, plus Full Basket bonus) and
  /// clears finished to-dos from the plot. Returns the coins paid.
  Future<int> harvest(FarmTask task) => _db.transaction(() async {
    final day = await today();
    final c = await progress.forTaskOn(task.id, day);
    if (c == null) throw const FarmActionException('Nothing ripe to harvest.');
    if (c.harvestedAt != null) {
      throw const FarmActionException('Already harvested today.');
    }
    return _harvestOn(task, day, c);
  });

  /// Auto-harvests plants left ripe on earlier farm days, using each day's own
  /// cap and Full Basket rules, so forgetting to tap never loses coins.
  /// Idempotent. Returns the coins paid.
  Future<int> rollover() async {
    final day = await today();
    var paid = 0;
    for (final c in await progress.unharvestedBefore(day)) {
      final task = await tasks.byId(c.taskId);
      if (task == null || task.archived) continue;
      paid += await _db.transaction(
        () => _harvestOn(task, FarmDay.parse(c.day), c),
      );
    }
    return paid;
  }

  Future<int> _harvestOn(FarmTask task, FarmDay day, Completion c) async {
    final method = CompletionMethod.values.byName(c.method);
    final base = baseCoins(task, method);

    final todays = await progress.forDay(day);
    final harvestedIds = {
      for (final x in todays)
        if (x.harvestedAt != null) x.taskId,
      task.id,
    };
    final dueDaily = (await tasks.active()).where(
      (t) => t.plot == PlotKind.daily && isDue(t, day),
    );
    final fullBasket =
        task.plot == PlotKind.daily &&
        completesFullBasket(
          dueDaily: dueDaily,
          harvestedIds: harvestedIds,
          alreadyPaid: await progress.fullBasketPaid(day),
        );
    final p = payout(
      base: base,
      earnedToday: await progress.earnedOn(day),
      completesFullBasket: fullBasket,
    );
    await progress.append(p.base, LedgerReason.harvest, day: day, refId: c.id);
    await progress.append(
      p.bonus,
      LedgerReason.fullBasket,
      day: day,
      refId: c.id,
    );
    await progress.markHarvested(c.id, p.total);
    if (task.isTodo) await tasks.archive(task.id);
    return p.total;
  }

  /// Undoes today's harvest of [task], reversing exactly what it paid.
  Future<void> unharvest(FarmTask task) => _db.transaction(() async {
    final day = await today();
    final c = await progress.forTaskOn(task.id, day);
    if (c == null || c.harvestedAt == null) {
      throw const FarmActionException('Nothing to undo today.');
    }
    final rows = await progress.rowsFor(c.id);
    int net(LedgerReason r) =>
        rows.where((x) => x.reason == r.name).fold(0, (s, x) => s + x.delta);
    final harvestNet = net(LedgerReason.harvest) + net(LedgerReason.unharvest);
    final bonusNet = net(LedgerReason.fullBasket);
    await progress.append(
      -harvestNet,
      LedgerReason.unharvest,
      day: day,
      refId: c.id,
    );
    await progress.append(
      -bonusNet,
      LedgerReason.fullBasket,
      day: day,
      refId: c.id,
    );
    await progress.clearHarvest(c.id);
    if (task.isTodo) await tasks.restore(task.id);
  });

  /// Undoes a completion that hasn't been harvested yet (plant goes back).
  Future<void> uncomplete(FarmTask task) => _db.transaction(() async {
    final day = await today();
    final c = await progress.forTaskOn(task.id, day);
    if (c == null) return;
    if (c.harvestedAt != null) {
      throw const FarmActionException('Undo the harvest first.');
    }
    await progress.deleteCompletion(c.id);
  });
}
