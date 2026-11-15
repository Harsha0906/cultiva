import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/domain/avatar.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/plant_engine.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/farm/farm_view.dart';
import 'package:cultiva/game/ambience.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final day = FarmDay(2026, 11, 16);

PlantView pv(String title, PlotKind plot, int slot, PlantStage stage) =>
    PlantView(
      task: FarmTask(
        id: '$title$slot',
        title: title,
        plot: plot,
        kind: plot == PlotKind.daily ? TaskKind.timed : TaskKind.check,
        targetMinutes: plot == PlotKind.daily ? 30 : null,
        repeat: plot == PlotKind.daily ? Weekdays.everyDay : Weekdays.none,
        crop: 'pepper',
        slot: slot,
        createdDay: day,
      ),
      stage: stage,
    );

FarmView view(List<PlantView> plants) =>
    FarmView(day: day, plants: plants, balance: 0, avatar: Avatar.fallback);

void main() {
  group('nextUp', () {
    test('Daily before To-Do, dormant first, then slot', () {
      final plants = [
        pv('bill', PlotKind.todo, 0, PlantStage.young),
        pv('read', PlotKind.daily, 2, PlantStage.seed),
        pv('walk', PlotKind.daily, 4, PlantStage.dormant),
        pv('yoga', PlotKind.daily, 1, PlantStage.sprout),
      ];
      expect(nextUp(plants)!.task.title, 'walk');
      plants.removeAt(2);
      expect(nextUp(plants)!.task.title, 'yoga');
    });

    test('skips ripe, harvested and resting; null when nothing is open', () {
      expect(
        nextUp([
          pv('a', PlotKind.daily, 0, PlantStage.ripe),
          pv('b', PlotKind.daily, 1, PlantStage.harvested),
          pv('c', PlotKind.todo, 0, PlantStage.resting),
        ]),
        isNull,
      );
    });
  });

  test('counts exclude resting plants', () {
    final v = view([
      pv('a', PlotKind.daily, 0, PlantStage.ripe),
      pv('b', PlotKind.daily, 1, PlantStage.harvested),
      pv('c', PlotKind.daily, 2, PlantStage.seed),
      pv('d', PlotKind.todo, 0, PlantStage.resting),
    ]);
    expect(
      (v.doneCount, v.dueCount, v.harvestedToday, v.ripeCount),
      (2, 3, 1, 1),
    );
  });

  group('tintFor', () {
    test('boundaries', () {
      expect(tintFor(4), isNotNull); // night
      expect(tintFor(5), isNot(tintFor(4))); // dawn
      expect(tintFor(8), isNull);
      expect(tintFor(16), isNull);
      expect(tintFor(17), isNotNull);
      expect(tintFor(20), tintFor(2));
    });
  });

  group('capyTip', () {
    test('picks the most useful line', () {
      expect(capyTip(view([])), contains('plant your first'));
      expect(
        capyTip(
          view([
            pv('a', PlotKind.daily, 0, PlantStage.ripe),
            pv('b', PlotKind.daily, 1, PlantStage.ripe),
          ]),
        ),
        contains('2 crops are ripe'),
      );
      expect(
        capyTip(view([pv('Read', PlotKind.daily, 0, PlantStage.dormant)])),
        contains('Read plant misses you'),
      );
      expect(
        capyTip(view([pv('a', PlotKind.daily, 0, PlantStage.harvested)])),
        contains('Full basket'),
      );
    });
  });

  test('a harvested one-off to-do still counts as done today', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = CultivaDb(NativeDatabase.memory());
    addTearDown(db.close);
    final farm = FarmService(db, clock: () => DateTime(2026, 11, 16, 9));
    final t = await farm.tasks.plant(
      title: 'Pay bill',
      plot: PlotKind.todo,
      crop: 'pumpkin',
      today: day,
    );
    await farm.complete(t);
    await farm.harvest(t); // one-off to-dos leave the farm when harvested
    final v = await loadFarmView(farm);
    expect(v.plants, isEmpty);
    expect(v.finishedOffFarm, 1);
    expect((v.doneCount, v.dueCount), (1, 1));
  });
}
