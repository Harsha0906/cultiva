import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/shop_service.dart';

/// Coins + owned decorations, live.
final class ShopView {
  const ShopView({required this.balance, required this.owned});
  final int balance;
  final List<OwnedItem> owned;

  OwnedItem? ownedItem(String id) {
    for (final o in owned) {
      if (o.item.id == id) return o;
    }
    return null;
  }
}

final shopViewProvider = StreamProvider<ShopView>((ref) async* {
  final db = ref.watch(dbProvider);
  final shop = ref.watch(shopServiceProvider);
  final farm = ref.watch(farmServiceProvider);
  Future<ShopView> load() async => ShopView(
    balance: await farm.progress.balance(),
    owned: await shop.owned(),
  );
  yield await load();
  await for (final _ in db.tableUpdates(
    TableUpdateQuery.onAllTables([db.inventory, db.coinLedger]),
  )) {
    yield await load();
  }
});
