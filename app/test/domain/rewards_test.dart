import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

final day = FarmDay(2026, 11, 16);

FarmTask timed(int minutes, {String id = 't'}) => FarmTask(
  id: id,
  title: 'x',
  plot: PlotKind.daily,
  kind: TaskKind.timed,
  targetMinutes: minutes,
  repeat: Weekdays.everyDay,
  crop: 'pepper',
  slot: 0,
  createdDay: day,
);

final check = FarmTask(
  id: 'c',
  title: 'x',
  plot: PlotKind.todo,
  kind: TaskKind.check,
  repeat: Weekdays.none,
  crop: 'pumpkin',
  slot: 0,
  createdDay: day,
);

void main() {
  group('baseCoins tiers', () {
    test('timed task boundaries', () {
      expect(baseCoins(timed(14), CompletionMethod.focus), 5);
      expect(baseCoins(timed(15), CompletionMethod.focus), 12);
      expect(baseCoins(timed(60), CompletionMethod.focus), 12);
      expect(baseCoins(timed(61), CompletionMethod.focus), 25);
    });
    test('"I already did it" pays half, rounded down', () {
      expect(baseCoins(timed(10), CompletionMethod.manual), 2);
      expect(baseCoins(timed(30), CompletionMethod.manual), 6);
      expect(baseCoins(timed(90), CompletionMethod.manual), 12);
    });
    test('check tasks pay 8', () {
      expect(baseCoins(check, CompletionMethod.check), 8);
    });
  });

  group('payout with daily cap', () {
    test('full payout when there is room', () {
      final p = payout(base: 12, earnedToday: 0, completesFullBasket: false);
      expect((p.base, p.bonus, p.total), (12, 0, 12));
    });
    test('partial at the cap edge, zero after', () {
      expect(
        payout(base: 25, earnedToday: 140, completesFullBasket: false).total,
        10,
      );
      expect(
        payout(base: 25, earnedToday: 150, completesFullBasket: false).total,
        0,
      );
      expect(
        payout(base: 25, earnedToday: 999, completesFullBasket: false).total,
        0,
      );
    });
    test('Full Basket bonus counts toward the cap', () {
      final p = payout(base: 12, earnedToday: 0, completesFullBasket: true);
      expect((p.base, p.bonus), (12, kFullBasketBonus));
      final edge = payout(
        base: 12,
        earnedToday: 130,
        completesFullBasket: true,
      );
      expect((edge.base, edge.bonus), (12, 8));
    });
  });

  group('Full Basket', () {
    final a = timed(30, id: 'a');
    final b = timed(30, id: 'b');
    test('triggers when the last due Daily task is harvested', () {
      expect(
        completesFullBasket(
          dueDaily: [a, b],
          harvestedIds: {'a', 'b'},
          alreadyPaid: false,
        ),
        isTrue,
      );
    });
    test('not before all are harvested, not twice, not with nothing due', () {
      expect(
        completesFullBasket(
          dueDaily: [a, b],
          harvestedIds: {'a'},
          alreadyPaid: false,
        ),
        isFalse,
      );
      expect(
        completesFullBasket(
          dueDaily: [a, b],
          harvestedIds: {'a', 'b'},
          alreadyPaid: true,
        ),
        isFalse,
      );
      expect(
        completesFullBasket(
          dueDaily: const [],
          harvestedIds: const {},
          alreadyPaid: false,
        ),
        isFalse,
      );
    });
  });
}
