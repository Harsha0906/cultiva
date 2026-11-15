import 'dart:ui';

import 'package:cultiva/domain/task.dart';
import 'package:cultiva/game/farm_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FarmViewport', () {
    test('uses a whole number of physical px per art px and centres', () {
      // Pixel 7: 411.4 x 700 logical, dpr 2.625 -> 1080 px wide -> 5 px/art px
      final vp = FarmViewport(const Size(411.43, 700), 2.625);
      expect(vp.physicalPerArt, 5);
      expect(vp.scale * 2.625, closeTo(5, 1e-9));
      final worldW = FarmLayout.worldW * vp.scale;
      expect(vp.offset.dx, closeTo((411.43 - worldW) / 2, 1));
    });

    test('height-limited screens scale down by whole steps', () {
      final vp = FarmViewport(const Size(411, 300), 2.625); // 787 px tall
      expect(vp.physicalPerArt, 2); // 787 / 288 = 2.7 -> 2
    });

    test('art <-> screen round-trips', () {
      final vp = FarmViewport(const Size(400, 800), 3);
      const art = Offset(37, 191);
      final back = vp.toArt(vp.toScreen(art));
      expect(back.dx, closeTo(art.dx, 1e-9));
      expect(back.dy, closeTo(art.dy, 1e-9));
    });
  });

  group('hit testing', () {
    final vp = FarmViewport(const Size(384, 576), 1); // exactly 2x, no offset

    Offset at(double x, double y) => vp.toScreen(Offset(x, y));

    test('finds plot cells by slot', () {
      final c = FarmLayout.plantBase(PlotKind.daily, 3);
      expect(
        vp.hitTest(at(c.dx, c.dy - 4)),
        const FarmHit(FarmHitKind.cell, plot: PlotKind.daily, slot: 3),
      );
      final b = FarmLayout.plantBase(PlotKind.todo, 0);
      expect(
        vp.hitTest(at(b.dx, b.dy)),
        const FarmHit(FarmHitKind.cell, plot: PlotKind.todo, slot: 0),
      );
    });

    test('buildings and empty grass', () {
      expect(vp.hitTest(at(40, 40)).kind, FarmHitKind.barn);
      expect(vp.hitTest(at(150, 40)).kind, FarmHitKind.home);
      expect(vp.hitTest(at(100, 86)).kind, FarmHitKind.none);
      expect(
        vp.hitTest(at(118, 270)),
        const FarmHit(FarmHitKind.decoSpot, slot: 1),
      );
    });

    test('capybara wins over what is behind it', () {
      const capy = Offset(181, 150);
      expect(
        vp.hitTest(at(181, 150), capybara: capy).kind,
        FarmHitKind.capybara,
      );
      expect(vp.hitTest(at(181, 150)).kind, FarmHitKind.none);
    });

    test('cells are at least 48dp wide on a phone', () {
      final phone = FarmViewport(const Size(411.43, 700), 2.625);
      expect(FarmLayout.cellW * phone.scale, greaterThanOrEqualTo(48));
    });
  });
}
