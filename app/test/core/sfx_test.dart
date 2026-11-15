import 'dart:io';

import 'package:cultiva/core/sfx.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingPlayer implements SfxPlayer {
  @override
  Future<void> play(SfxName name) async => throw StateError('no audio');
}

void main() {
  tearDown(() {
    Sfx.enabled = true;
    Sfx.player = const SilentSfxPlayer();
  });

  test('plays when sound is on, stays silent when off', () {
    final fake = FakeSfxPlayer();
    Sfx.player = fake;
    Sfx.play(SfxName.coin);
    Sfx.enabled = false;
    Sfx.play(SfxName.harvest);
    expect(fake.played, [SfxName.coin]);
  });

  test('a failing player never throws to the caller', () async {
    Sfx.player = _ThrowingPlayer();
    expect(() => Sfx.play(SfxName.buy), returnsNormally);
    await Future<void>.delayed(Duration.zero);
  });

  test('every sound has a bundled wav', () {
    for (final s in SfxName.values) {
      expect(
        File('assets/sfx/${s.name}.wav').existsSync(),
        isTrue,
        reason: s.name,
      );
    }
  });
}
