import 'package:cultiva/domain/avatar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every avatar id round-trips', () {
    for (final a in Avatar.all) {
      expect(Avatar.parse(a.id), a);
    }
    expect(Avatar.all, hasLength(24));
  });

  test('the capybara is never a player avatar', () {
    expect(AvatarAnimal.values.map((a) => a.name), isNot(contains('capybara')));
    expect(Avatar.parse('capybara_0'), Avatar.fallback);
  });

  test('bad ids fall back to the default', () {
    for (final bad in [
      null,
      '',
      'fox',
      'fox_3',
      'fox_-1',
      'dragon_0',
      'fox_x',
      'a_b_c',
    ]) {
      expect(Avatar.parse(bad), Avatar.fallback, reason: '$bad');
    }
  });
}
