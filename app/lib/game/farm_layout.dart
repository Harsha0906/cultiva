import 'dart:math' as math;
import 'dart:ui';

import '../domain/task.dart';

/// Single source of truth for where things are on the farm, in art pixels
/// (192 x 288 world). Used by the Flame renderer *and* Flutter overlays/taps.
abstract final class FarmLayout {
  static const worldW = 192.0;
  static const worldH = 288.0;

  static const barn = Rect.fromLTWH(6, 8, 72, 72);
  static const home = Rect.fromLTWH(106, 4, 80, 80);

  /// Cobble path: from the cottage door down, right, then down the right edge.
  static const paths = [
    Rect.fromLTWH(138, 78, 16, 28),
    Rect.fromLTWH(138, 92, 52, 14),
    Rect.fromLTWH(172, 92, 18, 196),
  ];

  static const plotA = Rect.fromLTWH(6, 112, 160, 48);
  static const plotB = Rect.fromLTWH(6, 188, 160, 48);
  static const pond = Rect.fromLTWH(8, 246, 56, 36);

  /// Bottom-centre of each decoration spot (between the pond and the path).
  static const decoSpots = [
    Offset(82, 286),
    Offset(118, 286),
    Offset(154, 286),
  ];

  /// Tap/outline area of a decoration spot.
  static Rect decoRect(int spot) =>
      Rect.fromLTWH(decoSpots[spot].dx - 18, decoSpots[spot].dy - 40, 36, 40);

  static const cellW = 26.0;
  static const cellsX0 = 8.0;

  /// Capybara walks the right-hand path between these y values.
  static const capyX = 181.0;
  static const capyMinY = 104.0;
  static const capyMaxY = 280.0;
  static const capySize = Size(22, 16);

  static Rect bed(PlotKind plot) => plot == PlotKind.daily ? plotA : plotB;

  /// Tap area for a slot: the bed column plus room above it for tall plants.
  static Rect cell(PlotKind plot, int slot) {
    final b = bed(plot);
    return Rect.fromLTWH(
      cellsX0 + slot * cellW,
      b.top - 22,
      cellW,
      b.height + 22,
    );
  }

  /// Bottom-centre point where a plant sprite stands.
  static Offset plantBase(PlotKind plot, int slot) =>
      Offset(cellsX0 + slot * cellW + cellW / 2, bed(plot).top + 38);

  /// Where the plot's sign label sits (top-left, just above the bed).
  static Offset signAnchor(PlotKind plot) => Offset(8, bed(plot).top - 15);

  static Rect capyRect(Offset capyCentre) => Rect.fromCenter(
    center: capyCentre,
    width: capySize.width + 6,
    height: capySize.height + 6,
  );
}

enum FarmHitKind { cell, barn, home, capybara, decoSpot, none }

final class FarmHit {
  const FarmHit(this.kind, {this.plot, this.slot});
  static const none = FarmHit(FarmHitKind.none);
  final FarmHitKind kind;
  final PlotKind? plot;
  final int? slot;

  @override
  bool operator ==(Object other) =>
      other is FarmHit &&
      other.kind == kind &&
      other.plot == plot &&
      other.slot == slot;

  @override
  int get hashCode => Object.hash(kind, plot, slot);

  @override
  String toString() => 'FarmHit($kind, $plot, $slot)';
}

/// Maps the art world onto a widget of [size] (logical px) at a whole number
/// of *physical* pixels per art pixel, centred — so pixels stay crisp.
final class FarmViewport {
  factory FarmViewport(Size size, double devicePixelRatio) {
    final physW = size.width * devicePixelRatio;
    final physH = size.height * devicePixelRatio;
    final s = math.max(
      1,
      math.min(
        (physW / FarmLayout.worldW).floor(),
        (physH / FarmLayout.worldH).floor(),
      ),
    );
    final scale = s / devicePixelRatio;
    final offset = Offset(
      ((size.width - FarmLayout.worldW * scale) / 2).floorToDouble(),
      math.max(
        0,
        ((size.height - FarmLayout.worldH * scale) / 2).floorToDouble(),
      ),
    );
    return FarmViewport._(size, scale, offset, s);
  }

  const FarmViewport._(this.size, this.scale, this.offset, this.physicalPerArt);

  final Size size;

  /// Logical px per art px.
  final double scale;
  final Offset offset;

  /// Whole physical px per art px.
  final int physicalPerArt;

  Offset toScreen(Offset art) => offset + art * scale;
  Offset toArt(Offset screen) => (screen - offset) / scale;
  Rect rectToScreen(Rect art) =>
      Rect.fromPoints(toScreen(art.topLeft), toScreen(art.bottomRight));

  FarmHit hitTest(Offset screen, {Offset? capybara}) {
    final p = toArt(screen);
    if (capybara != null && FarmLayout.capyRect(capybara).contains(p)) {
      return const FarmHit(FarmHitKind.capybara);
    }
    for (final plot in PlotKind.values) {
      for (var s = 0; s < 6; s++) {
        if (FarmLayout.cell(plot, s).contains(p)) {
          return FarmHit(FarmHitKind.cell, plot: plot, slot: s);
        }
      }
    }
    for (var s = 0; s < FarmLayout.decoSpots.length; s++) {
      if (FarmLayout.decoRect(s).contains(p)) {
        return FarmHit(FarmHitKind.decoSpot, slot: s);
      }
    }
    if (FarmLayout.barn.contains(p)) return const FarmHit(FarmHitKind.barn);
    if (FarmLayout.home.contains(p)) return const FarmHit(FarmHitKind.home);
    return FarmHit.none;
  }
}
