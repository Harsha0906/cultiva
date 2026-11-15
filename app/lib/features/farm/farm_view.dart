import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/farm_service.dart';
import '../../data/providers.dart';
import '../../domain/avatar.dart';
import '../../domain/farm_day.dart';
import '../../domain/plant_engine.dart';
import '../../domain/task.dart';

/// Everything the Farm screen shows, for one farm day.
final class FarmView {
  const FarmView({
    required this.day,
    required this.plants,
    required this.balance,
    required this.avatar,
  });

  final FarmDay day;
  final List<PlantView> plants;
  final int balance;
  final Avatar avatar;

  Iterable<PlantView> get due =>
      plants.where((p) => p.stage != PlantStage.resting);
  int get dueCount => due.length;
  int get doneCount => due
      .where(
        (p) => p.stage == PlantStage.ripe || p.stage == PlantStage.harvested,
      )
      .length;
  int get harvestedToday =>
      plants.where((p) => p.stage == PlantStage.harvested).length;
  int get ripeCount => plants.where((p) => p.stage == PlantStage.ripe).length;

  List<PlantView> inPlot(PlotKind plot) =>
      plants.where((p) => p.task.plot == plot).toList();

  PlantView? at(PlotKind plot, int slot) {
    for (final p in plants) {
      if (p.task.plot == plot && p.task.slot == slot) return p;
    }
    return null;
  }

  PlantView? get next => nextUp(plants);
}

const _unfinished = {
  PlantStage.seed,
  PlantStage.sprout,
  PlantStage.young,
  PlantStage.dormant,
};

/// The task "Next up" should offer: Daily before To-Do, dormant first
/// (bring it back), then by slot.
PlantView? nextUp(Iterable<PlantView> plants) {
  final open = plants.where((p) => _unfinished.contains(p.stage)).toList()
    ..sort((a, b) {
      final plot = a.task.plot.index.compareTo(b.task.plot.index);
      if (plot != 0) return plot;
      final dormant = (b.stage == PlantStage.dormant ? 1 : 0).compareTo(
        a.stage == PlantStage.dormant ? 1 : 0,
      );
      if (dormant != 0) return dormant;
      return a.task.slot.compareTo(b.task.slot);
    });
  return open.isEmpty ? null : open.first;
}

Future<FarmView> loadFarmView(FarmService farm) async {
  await farm.rollover();
  final day = await farm.today();
  return FarmView(
    day: day,
    plants: await farm.plants(day),
    balance: await farm.progress.balance(),
    avatar: await farm.settings.avatar(),
  );
}

/// Live farm state; re-computed whenever farm tables change.
final farmViewProvider = StreamProvider<FarmView>((ref) async* {
  final farm = ref.watch(farmServiceProvider);
  final db = ref.watch(dbProvider);
  yield await loadFarmView(farm);
  final changes = db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.tasks,
      db.completions,
      db.coinLedger,
      db.settings,
    ]),
  );
  await for (final _ in changes) {
    yield await loadFarmView(farm);
  }
});
