import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/plant_engine.dart';
import 'package:cultiva/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

final mon = FarmDay(2026, 11, 16);
final tue = mon.addDays(1);
final wed = mon.addDays(2);
final thu = mon.addDays(3);

FarmTask daily({
  String id = 'a',
  int minutes = 30,
  Weekdays repeat = Weekdays.everyDay,
  FarmDay? created,
  int slot = 0,
}) => FarmTask(
  id: id,
  title: 'Read',
  plot: PlotKind.daily,
  kind: TaskKind.timed,
  targetMinutes: minutes,
  repeat: repeat,
  crop: 'pepper',
  slot: slot,
  createdDay: created ?? mon,
);

FarmTask todo({String id = 'b', FarmDay? created, int slot = 0}) => FarmTask(
  id: id,
  title: 'Pay bill',
  plot: PlotKind.todo,
  kind: TaskKind.check,
  repeat: Weekdays.none,
  crop: 'pumpkin',
  slot: slot,
  createdDay: created ?? mon,
);

FarmTask habit({Weekdays repeat = Weekdays.everyDay, FarmDay? created}) =>
    FarmTask(
      id: 'h',
      title: 'Drink water',
      plot: PlotKind.todo,
      kind: TaskKind.check,
      repeat: repeat,
      crop: 'lettuce',
      slot: 1,
      createdDay: created ?? mon,
    );

void main() {
  group('Weekdays', () {
    test('mask membership', () {
      final w = Weekdays.of([DateTime.monday, DateTime.wednesday]);
      expect(w.has(DateTime.monday), isTrue);
      expect(w.has(DateTime.tuesday), isFalse);
      expect(Weekdays.none.isEmpty, isTrue);
      expect(Weekdays.everyDay.days, hasLength(7));
    });
  });

  group('FarmTask.validate', () {
    test('daily tasks are timed, 1-240 min, with repeat days', () {
      expect(daily().problems, isEmpty);
      expect(daily(minutes: 0).problems, isNotEmpty);
      expect(daily(minutes: 241).problems, isNotEmpty);
      expect(daily(repeat: Weekdays.none).problems, isNotEmpty);
    });
    test('to-do/habit tasks are check tasks without a duration', () {
      expect(todo().problems, isEmpty);
      expect(habit().problems, isEmpty);
    });
    test('blank title and bad slot are rejected', () {
      expect(daily().copyWith(title: '  ').problems, isNotEmpty);
      expect(daily(slot: 6).problems, isNotEmpty);
    });
  });

  group('isDue', () {
    test('repeating task follows its weekdays', () {
      final t = daily(
        repeat: Weekdays.of([DateTime.monday, DateTime.wednesday]),
      );
      expect(isDue(t, mon), isTrue);
      expect(isDue(t, tue), isFalse);
      expect(isDue(t, wed), isTrue);
    });
    test('nothing is due before it was planted', () {
      expect(isDue(daily(created: wed), tue), isFalse);
    });
    test('to-do is due every day until done', () {
      expect(isDue(todo(), thu), isTrue);
    });
  });

  group('stageFor: timed daily', () {
    test('seed -> sprout -> young -> ripe -> harvested', () {
      final t = daily(minutes: 30);
      expect(stageFor(t, mon), PlantStage.seed);
      expect(
        stageFor(t, mon, today: const DayRecord(focusMinutes: 5)),
        PlantStage.sprout,
      );
      expect(
        stageFor(t, mon, today: const DayRecord(focusMinutes: 15)),
        PlantStage.young,
      );
      expect(
        stageFor(
          t,
          mon,
          today: const DayRecord(focusMinutes: 30, ripened: true),
        ),
        PlantStage.ripe,
      );
      expect(
        stageFor(
          t,
          mon,
          today: const DayRecord(
            focusMinutes: 30,
            ripened: true,
            harvested: true,
          ),
        ),
        PlantStage.harvested,
      );
    });

    test('not due today -> resting', () {
      final t = daily(repeat: Weekdays.of([DateTime.monday]));
      expect(stageFor(t, tue), PlantStage.resting);
    });

    test('missed previous due day -> dormant, revived by any progress', () {
      final t = daily();
      expect(stageFor(t, tue), PlantStage.dormant);
      expect(
        stageFor(t, tue, today: const DayRecord(focusMinutes: 1)),
        PlantStage.sprout,
      );
      expect(stageFor(t, tue, doneDays: {mon}), PlantStage.seed);
    });

    test(
      'dormancy looks back to the previous *due* day, skipping rest days',
      () {
        final t = daily(
          repeat: Weekdays.of([DateTime.monday, DateTime.thursday]),
        );
        expect(stageFor(t, thu, doneDays: {mon}), PlantStage.seed);
        expect(stageFor(t, thu), PlantStage.dormant);
      },
    );

    test('a newly planted task is never dormant', () {
      expect(stageFor(daily(created: wed), wed), PlantStage.seed);
    });

    test('previousDueDay never goes before the planting day', () {
      expect(previousDueDay(daily(created: tue), tue), isNull);
      expect(previousDueDay(daily(), wed), tue);
    });
  });

  group('stageFor: check tasks', () {
    test('pending -> young, complete -> ripe -> harvested', () {
      expect(stageFor(todo(), mon), PlantStage.young);
      expect(
        stageFor(todo(), mon, today: const DayRecord(ripened: true)),
        PlantStage.ripe,
      );
      expect(
        stageFor(
          habit(),
          mon,
          today: const DayRecord(ripened: true, harvested: true),
        ),
        PlantStage.harvested,
      );
    });
    test('a to-do carried over from an earlier day is dormant until done', () {
      expect(stageFor(todo(), wed), PlantStage.dormant);
      expect(
        stageFor(todo(), wed, today: const DayRecord(ripened: true)),
        PlantStage.ripe,
      );
    });
    test('a habit missed yesterday is dormant', () {
      expect(stageFor(habit(), tue), PlantStage.dormant);
      expect(stageFor(habit(), tue, doneDays: {mon}), PlantStage.young);
    });
  });

  group('plot capacity', () {
    test('lowest free slot, null when full', () {
      expect(freeSlot([]), 0);
      expect(freeSlot([daily(slot: 0), daily(slot: 2)]), 1);
      expect(
        freeSlot([for (var s = 0; s < kPlotCapacity; s++) daily(slot: s)]),
        isNull,
      );
    });
  });
}
