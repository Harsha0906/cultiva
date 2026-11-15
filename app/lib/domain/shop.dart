/// Cosmetic decorations bought with coins. Sprites come from the CraftPix
/// house pack (assets/sprites/pack/props|trees). All fit a 36px-wide spot.
final class ShopItem {
  const ShopItem(this.id, this.name, this.price, this.sprite);
  final String id;
  final String name;
  final int price;

  /// Path under assets/sprites/pack/ (without .png).
  final String sprite;

  String get asset => 'assets/sprites/pack/$sprite.png';
}

const kShopCatalogue = [
  ShopItem('mushroom_small', 'Little mushroom', 30, 'props/mushroom_small'),
  ShopItem('log_short', 'Log seat', 35, 'props/log_short'),
  ShopItem('mushrooms', 'Mushroom patch', 45, 'props/mushrooms'),
  ShopItem('bush_round', 'Round bush', 50, 'props/bush_round'),
  ShopItem('stump', 'Old stump', 50, 'props/stump'),
  ShopItem('crates', 'Crates', 70, 'props/crates'),
  ShopItem('bush_dark_small', 'Evergreen shrub', 70, 'props/bush_dark_small'),
  ShopItem('rock_mossy', 'Mossy rock', 80, 'props/rock_mossy'),
  ShopItem('pine_dark_a', 'Mini pine', 90, 'trees/pine_dark_a'),
  ShopItem('mushroom_big', 'Giant toadstool', 110, 'props/mushroom_big'),
  ShopItem('apple_bush', 'Apple bush', 130, 'props/apple_bush'),
  ShopItem('well', 'Wishing well', 200, 'props/well'),
];

ShopItem? shopItem(String id) {
  for (final i in kShopCatalogue) {
    if (i.id == id) return i;
  }
  return null;
}

/// Number of decoration spots on the farm.
const kDecoSpots = 3;
