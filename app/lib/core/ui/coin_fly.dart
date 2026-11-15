import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Five coins arcing from [start] to [end] (global coords), then [onDone].
/// Used in an OverlayEntry after a harvest. Callers skip it under Reduce Motion.
class CoinFly extends StatefulWidget {
  const CoinFly({
    super.key,
    required this.start,
    required this.end,
    required this.onDone,
    this.coins = 5,
  });

  final Offset start;
  final Offset end;
  final VoidCallback onDone;
  final int coins;

  @override
  State<CoinFly> createState() => _CoinFlyState();
}

class _CoinFlyState extends State<CoinFly> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward().whenComplete(() => widget.onDone());

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Offset _bezier(Offset a, Offset ctrl, Offset b, double t) {
    final u = 1 - t;
    return a * (u * u) + ctrl * (2 * u * t) + b * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final children = <Widget>[];
          for (var i = 0; i < widget.coins; i++) {
            final raw = ((_c.value - i * 0.08) / 0.6).clamp(0.0, 1.0);
            if (raw <= 0 || raw >= 1) continue;
            final t = Curves.easeInOutCubic.transform(raw);
            final s = widget.start + Offset((i - widget.coins / 2) * 8, 0);
            final ctrl = Offset(
              (s.dx + widget.end.dx) / 2,
              math.min(s.dy, widget.end.dy) - 120,
            );
            final p = _bezier(s, ctrl, widget.end, t);
            final frame = (raw * 8).floor() % 4;
            children.add(
              Positioned(
                left: p.dx - 10,
                top: p.dy - 10,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: 80,
                      maxWidth: 80,
                      minHeight: 20,
                      maxHeight: 20,
                      child: Transform.translate(
                        offset: Offset(-frame * 20.0, 0),
                        child: Image.asset(
                          'assets/sprites/cultiva/fx/coin.png',
                          width: 80,
                          height: 20,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Stack(children: children);
        },
      ),
    );
  }
}

/// Plays a quick 1 → 1.15 → 1 bump whenever [tick] changes.
class Bump extends StatefulWidget {
  const Bump({super.key, required this.tick, required this.child});
  final int tick;
  final Widget child;

  @override
  State<Bump> createState() => _BumpState();
}

class _BumpState extends State<Bump> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void didUpdateWidget(Bump old) {
    super.didUpdateWidget(old);
    if (old.tick != widget.tick) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform.scale(
      scale: 1 + 0.15 * math.sin(math.pi * _c.value),
      child: child,
    ),
    child: widget.child,
  );
}
