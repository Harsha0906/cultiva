import 'package:drift/drift.dart';

import '../domain/rewards.dart';
import '../domain/shop.dart';
import 'db.dart';
import 'farm_service.dart';

class ShopException implements Exception {
  const ShopException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// An owned decoration and where it sits (null = in storage).
final class OwnedItem {
  const OwnedItem(this.item, this.spot);
  final ShopItem item;
  final int? spot;
}

class ShopService {
  ShopService(this._db, this._farm);

  final CultivaDb _db;
  final FarmService _farm;

  Future<List<OwnedItem>> owned() async {
    final rows = await _db.select(_db.inventory).get();
    return [
      for (final r in rows)
        if (shopItem(r.itemId) case final item?) OwnedItem(item, r.placedSpot),
    ]..sort((a, b) => a.item.price.compareTo(b.item.price));
  }

  Future<Map<int, ShopItem>> placed() async => {
    for (final o in await owned())
      if (o.spot != null) o.spot!: o.item,
  };

  Future<bool> owns(String itemId) async =>
      await (_db.select(
        _db.inventory,
      )..where((i) => i.itemId.equals(itemId))).getSingleOrNull() !=
      null;

  /// Buys [itemId] with coins. Throws [ShopException] if owned or too pricey.
  Future<void> buy(String itemId) => _db.transaction(() async {
    final item = shopItem(itemId);
    if (item == null) throw const ShopException('That item isn’t sold here.');
    if (await owns(itemId)) {
      throw const ShopException('You already have this.');
    }
    final balance = await _farm.progress.balance();
    if (balance < item.price) {
      throw ShopException('Need ${item.price - balance} more coins.');
    }
    await _db
        .into(_db.inventory)
        .insert(InventoryCompanion.insert(itemId: itemId));
    await _farm.progress.append(
      -item.price,
      LedgerReason.purchase,
      day: await _farm.today(),
      refId: itemId,
    );
  });

  /// Puts an owned item in [spot] (0–2). Whatever was there goes to storage.
  Future<void> place(String itemId, int spot) => _db.transaction(() async {
    if (spot < 0 || spot >= kDecoSpots) {
      throw const ShopException('There’s no such spot.');
    }
    if (!await owns(itemId)) {
      throw const ShopException('Buy it in the shop first.');
    }
    if (shopItem(itemId)?.animal ?? false) {
      throw const ShopException('Animals live in the pen.');
    }
    await (_db.update(_db.inventory)..where((i) => i.placedSpot.equals(spot)))
        .write(const InventoryCompanion(placedSpot: Value(null)));
    await (_db.update(_db.inventory)..where((i) => i.itemId.equals(itemId)))
        .write(InventoryCompanion(placedSpot: Value(spot)));
  });

  Future<void> takeBack(String itemId) =>
      (_db.update(_db.inventory)..where((i) => i.itemId.equals(itemId))).write(
        const InventoryCompanion(placedSpot: Value(null)),
      );
}
