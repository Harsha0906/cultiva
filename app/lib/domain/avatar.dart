/// Player avatar choices. The capybara is Cultiva's mascot and is deliberately
/// NOT in this list — players can never pick it (docs/04-decisions.md).
enum AvatarAnimal { fox, rabbit, cat, dog, frog, bear, duck, owl }

/// An animal + colour variant (0–2), stored as an id like `fox_0`.
final class Avatar {
  const Avatar(this.animal, this.variant)
    : assert(variant >= 0 && variant < variants);

  static const variants = 3;
  static const fallback = Avatar(AvatarAnimal.fox, 0);

  final AvatarAnimal animal;
  final int variant;

  String get id => '${animal.name}_$variant';
  String get asset => 'assets/sprites/cultiva/avatars/$id.png';

  /// Parses an id; anything unknown (including `capybara_*`) falls back safely.
  static Avatar parse(String? id) {
    if (id == null) return fallback;
    final parts = id.split('_');
    if (parts.length != 2) return fallback;
    final animal = AvatarAnimal.values
        .where((a) => a.name == parts[0])
        .firstOrNull;
    final variant = int.tryParse(parts[1]);
    if (animal == null ||
        variant == null ||
        variant < 0 ||
        variant >= variants) {
      return fallback;
    }
    return Avatar(animal, variant);
  }

  static List<Avatar> get all => [
    for (final a in AvatarAnimal.values)
      for (var v = 0; v < variants; v++) Avatar(a, v),
  ];

  @override
  bool operator ==(Object other) =>
      other is Avatar && other.animal == animal && other.variant == variant;

  @override
  int get hashCode => Object.hash(animal, variant);

  @override
  String toString() => 'Avatar($id)';
}
