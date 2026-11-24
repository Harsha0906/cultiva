import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/shop_service.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/features/farm/farm_view.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  late ShopService shop;
  final now = DateTime(2026, 11, 16, 9);
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
    shop = ShopService(db, farm);
  });
  tearDown(() => db.close());

  Future<void> earn(int coins) =>
      farm.progress.append(coins, LedgerReason.harvest, day: mon);

  test('buying deducts coins and stores the item', () async {
    await earn(100);
    await shop.buy('crates'); // 70
    expect(await farm.progress.balance(), 30);
    expect((await shop.owned()).single.item.id, 'crates');
    expect((await shop.owned()).single.spot, isNull);
  });

  test('animals: bought into the pen, never placed on a spot', () async {
    await earn(200);
    await shop.buy('chicken'); // 60
    expect(await farm.progress.balance(), 140);
    await expectLater(
      shop.place('chicken', 0),
      throwsA(isA<ShopException>()),
    );
    final view = await loadFarmView(farm, shop);
    expect(view.animals, ['chicken']);
    expect(view.hasUnplaced, isFalse); // no "place it" nudge for animals
  });

  test('not enough coins: refused, nothing changes', () async {
    await earn(50);
    await expectLater(
      shop.buy('well'),
      throwsA(
        isA<ShopException>().having((e) => e.message, 'msg', contains('150')),
      ),
    );
    expect(await farm.progress.balance(), 50);
    expect(await shop.owned(), isEmpty);
  });

  test('cannot buy the same item twice', () async {
    await earn(200);
    await shop.buy('stump');
    expect(() => shop.buy('stump'), throwsA(isA<ShopException>()));
  });

  test('spending leaves earnedOn untouched', () async {
    await earn(140);
    await shop.buy('apple_bush');
    expect(await farm.progress.earnedOn(mon), 140);
  });

  group('placing', () {
    setUp(() async {
      await earn(500);
      await shop.buy('well');
      await shop.buy('stump');
    });

    test('place, swap, take back', () async {
      await shop.place('well', 1);
      expect((await shop.placed())[1]!.id, 'well');
      await shop.place('stump', 1); // swap: well goes to storage
      final placed = await shop.placed();
      expect(placed[1]!.id, 'stump');
      expect(placed.values.map((i) => i.id), isNot(contains('well')));
      await shop.place('stump', 2); // moving keeps one spot per item
      expect((await shop.placed()).keys, [2]);
      await shop.takeBack('stump');
      expect(await shop.placed(), isEmpty);
    });

    test('unowned items and bad spots are refused', () async {
      expect(
        () => shop.place('mushroom_big', 0),
        throwsA(isA<ShopException>()),
      );
      expect(() => shop.place('well', 3), throwsA(isA<ShopException>()));
    });
  });
}
