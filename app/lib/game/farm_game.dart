import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/farm_service.dart';
import '../domain/plant_engine.dart';
import '../domain/shop.dart';
import '../domain/task.dart';
import 'farm_layout.dart';

/// Crop-strip frame for a stage (strips are seed·sprout·young·ripe·dormant).
int frameForStage(PlantStage stage) => switch (stage) {
  PlantStage.seed || PlantStage.harvested => 0,
  PlantStage.sprout || PlantStage.resting => 1,
  PlantStage.young => 2,
  PlantStage.ripe => 3,
  PlantStage.dormant => 4,
};

/// Draws the farm. Flame owns rendering + the animation clock only; taps and
/// text live in Flutter (see FarmScreen) using the same [FarmViewport].
class FarmGame extends FlameGame {
  FarmGame({this.reduceMotion = false});

  FarmViewport? viewport;
  List<ui.Image>? _details;
  List<PlantView> plants = const [];

  /// Placed decorations: spot index -> ShopItem id.
  Map<int, String> decorations = const {};

  /// Show dashed outlines on empty spots (player owns something unplaced).
  bool showEmptySpots = false;
  bool reduceMotion;

  /// Capybara centre in art px, for Flutter overlays (speech bubble, taps).
  final capyPosition = ValueNotifier<ui.Offset>(
    const ui.Offset(FarmLayout.capyX, 200),
  );

  final _img = <String, ui.Image>{};
  final _cropH = <String, int>{};
  ui.Image? _background;
  final _pixel = ui.Paint()..filterQuality = ui.FilterQuality.none;
  final _rng = math.Random(3);
  double _t = 0;

  // capybara walk state
  double _capyY = 200;
  double _dir = 1;
  double _pause = 1.5;
  @override
  @override
  ui.Color backgroundColor() => const ui.Color(0x00000000);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/';
    Future<void> load(String key, String path) async =>
        _img[key] = await images.load(path);

    const cultiva = 'sprites/cultiva';
    const farm = 'sprites/farm';
    await Future.wait([
      load('home', '$farm/house.png'),
      load('tree', '$farm/tree.png'),
      load('bushF', '$farm/bush.png'),
      load('grass', '$farm/grass.png'),
      load('path', '$farm/path.png'),
      load('water', '$farm/water.png'),
      load('soil', '$farm/soil.png'),
      load('stake', '$cultiva/props/stake.png'),
      load('capy', '$cultiva/npc/capybara.png'),
      load('sparkle', '$cultiva/fx/sparkle.png'),
      load('coin', '$cultiva/fx/coin.png'),
      load('leaf', '$cultiva/fx/leaf.png'),
      load('dust', '$cultiva/fx/dust.png'),
    ]);

    final manifest = jsonDecode(
      await rootBundle.loadString('assets/sprites/pack/manifest.json'),
    ) as Map<String, dynamic>;
    final crops = manifest['crops'] as Map<String, dynamic>;
    for (final MapEntry(:key, :value) in crops.entries) {
      final m = value as Map<String, dynamic>;
      await load('crop:$key', 'sprites/pack/${m['file']}');
      _cropH[key] = m['frameH'] as int;
    }
    // Small grass details: flowers, pebbles and tufts from the farm art.
    final details = [
      for (var i = 0; i < 9; i++) await images.load('$farm/detail_$i.png'),
    ];
    for (final item in kShopCatalogue) {
      await load('deco:${item.id}', 'sprites/pack/${item.sprite}.png');
    }
    _details = details;
    _background = _buildBackground(details);
  }

  // ---------------------------------------------------------------- static layer

  ui.Image _buildBackground(List<ui.Image> details) {
    const w = FarmLayout.worldW;
    final h = FarmLayout.worldH;
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec, ui.Rect.fromLTWH(0, 0, w, h));
    _tile(
      c,
      _img['grass']!,
      const ui.Rect.fromLTWH(0, 0, 32, 32),
      ui.Rect.fromLTWH(0, 0, w, h),
    );

    final blocked = [
      FarmLayout.barn,
      FarmLayout.home,
      ...FarmLayout.paths,
      FarmLayout.plotA.inflate(3),
      FarmLayout.plotB.inflate(3),
      FarmLayout.pond.inflate(2),
    ];
    final rng = math.Random(7);
    for (var i = 0; i < 40 && details.isNotEmpty; i++) {
      final d = details[rng.nextInt(details.length)];
      final at = ui.Offset(
        rng.nextInt((w - d.width).toInt()).toDouble(),
        rng.nextInt((h - d.height).toInt()).toDouble(),
      );
      final r = at & ui.Size(d.width.toDouble(), d.height.toDouble());
      if (blocked.any((b) => b.overlaps(r))) continue;
      c.drawImage(d, at, _pixel);
    }

    for (final p in FarmLayout.paths) {
      _tile(c, _img['path']!, const ui.Rect.fromLTWH(0, 0, 32, 32), p);
    }
    _nineTile(c, _img['soil']!, FarmLayout.plotA);
    _nineTile(c, _img['soil']!, FarmLayout.plotB);
    final pond = FarmLayout.pond;
    _tile(c, _img['water']!, const ui.Rect.fromLTWH(0, 0, 32, 32), pond);
    c.drawRect(
      pond.deflate(0.5),
      ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..color = const ui.Color(0xFF2F5E9E),
    );
    _drawAt(c, 'tree', FarmLayout.treeAt);
    _drawAt(c, 'bushF', FarmLayout.bushAt);
    _drawAt(c, 'home', FarmLayout.home.topLeft);
    return rec.endRecording().toImageSync(w.toInt(), h.toInt());
  }

  void _drawAt(ui.Canvas c, String key, ui.Offset at) {
    final img = _img[key];
    if (img != null) c.drawImage(img, at, _pixel);
  }

  void _tile(ui.Canvas c, ui.Image img, ui.Rect src, ui.Rect dst) {
    if (dst.width <= 0 || dst.height <= 0) return;
    c.save();
    c.clipRect(dst);
    for (var y = dst.top; y < dst.bottom; y += src.height) {
      for (var x = dst.left; x < dst.right; x += src.width) {
        c.drawImageRect(
          img,
          src,
          ui.Rect.fromLTWH(x, y, src.width, src.height),
          _pixel,
        );
      }
    }
    c.restore();
  }

  /// 9-slice with 16px corners; edges and centre are *tiled* (never stretched).
  void _nineTile(ui.Canvas c, ui.Image img, ui.Rect d, {double k = 16}) {
    final w = img.width.toDouble(), h = img.height.toDouble();
    final xs = [
      (0.0, k, d.left, d.left + k),
      (k, w - k, d.left + k, d.right - k),
      (w - k, w, d.right - k, d.right),
    ];
    final ys = [
      (0.0, k, d.top, d.top + k),
      (k, h - k, d.top + k, d.bottom - k),
      (h - k, h, d.bottom - k, d.bottom),
    ];
    for (final (sx0, sx1, dx0, dx1) in xs) {
      for (final (sy0, sy1, dy0, dy1) in ys) {
        _tile(
          c,
          img,
          ui.Rect.fromLTRB(sx0, sy0, sx1, sy1),
          ui.Rect.fromLTRB(dx0, dy0, dx1, dy1),
        );
      }
    }
  }

  // ---------------------------------------------------------------- frame loop

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    for (final p in _parts) {
      p.age += dt;
      p.pos += p.vel * dt;
      p.vel += ui.Offset(0, 70 * dt);
    }
    _parts.removeWhere((p) => p.age >= p.life);
    if (reduceMotion) {
      _capyY = 100;
    } else if (_pause > 0) {
      _pause -= dt;
    } else {
      _capyY += _dir * 12 * dt;
      if (_capyY <= FarmLayout.capyMinY || _capyY >= FarmLayout.capyMaxY) {
        _capyY = _capyY.clamp(FarmLayout.capyMinY, FarmLayout.capyMaxY);
        _dir = -_dir;
        _pause = 2 + _rng.nextDouble() * 3;
      } else if (_rng.nextDouble() < dt * 0.15) {
        _pause = 2 + _rng.nextDouble() * 3;
        if (_rng.nextBool()) _dir = -_dir;
      }
    }
    final p = ui.Offset(FarmLayout.capyX, _capyY.roundToDouble());
    if (p != capyPosition.value) capyPosition.value = p;
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    final vp = viewport;
    var bg = _background;
    if (vp == null || bg == null) return;
    // The screen height changed the farm's height: redraw the static layer.
    if (bg.height != FarmLayout.worldH.toInt() && _details != null) {
      bg = _background = _buildBackground(_details!);
    }
    canvas.save();
    canvas.translate(vp.offset.dx, vp.offset.dy);
    canvas.scale(vp.scale);
    // Grass also fills the side margins (the farm is a whole-pixel width).
    final g = _img['grass'];
    if (g != null) {
      final ox = (vp.offset.dx / vp.scale / 32).ceil() * 32.0;
      _tile(
        canvas,
        g,
        const ui.Rect.fromLTWH(0, 0, 32, 32),
        ui.Rect.fromLTWH(
          -ox,
          0,
          vp.size.width / vp.scale + 2 * ox,
          FarmLayout.worldH,
        ),
      );
    }
    canvas.drawImage(bg, ui.Offset.zero, _pixel);
    _drawPlants(canvas);
    _drawDecorations(canvas);
    _drawCapy(canvas);
    _drawParticles(canvas);
    canvas.restore();
  }

  void _drawPlants(ui.Canvas c) {
    final byCell = {for (final p in plants) (p.task.plot, p.task.slot): p};
    for (final plot in PlotKind.values) {
      for (var slot = 0; slot < kPlotCapacity; slot++) {
        final base = FarmLayout.plantBase(plot, slot);
        final p = byCell[(plot, slot)];
        if (p == null) {
          _emptyMarker(c, base);
          continue;
        }
        final crop = _cropH.containsKey(p.task.crop) ? p.task.crop : 'pepper';
        final img = _img['crop:$crop']!;
        final fh = _cropH[crop]!.toDouble();
        final frame = frameForStage(p.stage);
        final paint = p.stage == PlantStage.resting
            ? (ui.Paint()
                ..filterQuality = ui.FilterQuality.none
                ..color = const ui.Color(0x99FFFFFF))
            : _pixel;
        c.drawImageRect(
          img,
          ui.Rect.fromLTWH(frame * 32.0, 0, 32, fh),
          ui.Rect.fromLTWH(base.dx - 16, base.dy - fh, 32, fh),
          paint,
        );
        _drawAt(c, 'stake', ui.Offset(base.dx + 7, base.dy - 10));
        if (p.stage == PlantStage.ripe) {
          final f = reduceMotion ? 2 : (_t * 6).floor() % 4;
          c.drawImageRect(
            _img['sparkle']!,
            ui.Rect.fromLTWH(f * 9.0, 0, 9, 9),
            ui.Rect.fromLTWH(base.dx + 2, base.dy - fh - 2, 9, 9),
            _pixel,
          );
        } else if (p.stage == PlantStage.harvested) {
          c.drawImageRect(
            _img['coin']!,
            const ui.Rect.fromLTWH(0, 0, 10, 10),
            ui.Rect.fromLTWH(base.dx - 5, base.dy - 16, 10, 10),
            _pixel,
          );
        }
      }
    }
  }

  // ---------------------------------------------------------------- particles

  final _parts = <_Particle>[];

  /// Leaf burst + dust puff at a plant base (art px). No-op under Reduce Motion.
  void burst(ui.Offset base) {
    if (reduceMotion) return;
    for (var i = 0; i < 6; i++) {
      _parts.add(
        _Particle(
          pos: base - const ui.Offset(0, 12),
          vel: ui.Offset(
            (_rng.nextDouble() - 0.5) * 50,
            -35 - _rng.nextDouble() * 30,
          ),
          life: 0.7,
          frame: i % 2,
        ),
      );
    }
    _parts.add(
      _Particle(pos: base - const ui.Offset(0, 4), life: 0.45, dust: true),
    );
  }

  void _drawParticles(ui.Canvas c) {
    final leaf = _img['leaf'], dust = _img['dust'];
    if (leaf == null || dust == null) return;
    for (final p in _parts) {
      final fade = (1 - p.age / p.life).clamp(0.0, 1.0);
      final paint = ui.Paint()
        ..filterQuality = ui.FilterQuality.none
        ..color = ui.Color.fromRGBO(255, 255, 255, fade);
      if (p.dust) {
        final f = (p.age / p.life * 3).floor().clamp(0, 2);
        c.drawImageRect(
          dust,
          ui.Rect.fromLTWH(f * 10.0, 0, 10, 8),
          ui.Rect.fromCenter(center: p.pos, width: 10, height: 8),
          paint,
        );
      } else {
        c.drawImageRect(
          leaf,
          ui.Rect.fromLTWH(p.frame * 5.0, 0, 5, 5),
          ui.Rect.fromCenter(
            center: ui.Offset(
              p.pos.dx.roundToDouble(),
              p.pos.dy.roundToDouble(),
            ),
            width: 5,
            height: 5,
          ),
          paint,
        );
      }
    }
  }

  void _drawDecorations(ui.Canvas c) {
    for (var s = 0; s < FarmLayout.decoSpots.length; s++) {
      final base = FarmLayout.decoSpots[s];
      final id = decorations[s];
      final img = id == null ? null : _img['deco:$id'];
      if (img != null) {
        c.drawImage(
          img,
          ui.Offset(
            (base.dx - img.width / 2).floorToDouble(),
            base.dy - img.height,
          ),
          _pixel,
        );
      } else if (showEmptySpots) {
        final r = FarmLayout.decoRect(s).deflate(4);
        final p = ui.Paint()..color = const ui.Color(0x66FFF6E0);
        for (var x = r.left; x < r.right; x += 4) {
          c.drawRect(ui.Rect.fromLTWH(x, r.bottom - 1, 2, 1), p);
          c.drawRect(ui.Rect.fromLTWH(x, r.bottom - 12, 2, 1), p);
        }
      }
    }
  }

  void _emptyMarker(ui.Canvas c, ui.Offset base) {
    final p = ui.Paint()..color = const ui.Color(0x55FFF6E0);
    final cx = base.dx.floorToDouble(), cy = base.dy - 8;
    c.drawRect(ui.Rect.fromLTWH(cx - 3, cy, 7, 1), p);
    c.drawRect(ui.Rect.fromLTWH(cx, cy - 3, 1, 7), p);
  }

  void _drawCapy(ui.Canvas c) {
    final img = _img['capy'];
    if (img == null) return;
    final pos = capyPosition.value;
    final walking = !reduceMotion && _pause <= 0;
    final int frame;
    if (walking) {
      frame = 2 + (_t * 8).floor() % 4;
    } else {
      frame = (_t % 3.2) < 0.15 ? 1 : 0; // occasional blink
    }
    final facingLeft = walking && _dir < 0;
    final dst = ui.Rect.fromCenter(center: pos, width: 22, height: 16);
    c.save();
    if (facingLeft) {
      c.translate(pos.dx, 0);
      c.scale(-1, 1);
      c.translate(-pos.dx, 0);
    }
    c.drawImageRect(
      img,
      ui.Rect.fromLTWH(frame * 22.0, 0, 22, 16),
      dst,
      _pixel,
    );
    c.restore();
  }
}

class _Particle {
  _Particle({
    required this.pos,
    required this.life,
    this.vel = ui.Offset.zero,
    this.frame = 0,
    this.dust = false,
  });

  ui.Offset pos;
  ui.Offset vel;
  final double life;
  final int frame;
  final bool dust;
  double age = 0;
}
