import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/avatar_portrait.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/farm_service.dart';
import '../../data/providers.dart';
import '../../domain/avatar.dart';
import '../../domain/plant_engine.dart';
import '../../domain/task.dart';
import '../../game/ambience.dart';
import '../../game/farm_game.dart';
import '../../game/farm_layout.dart';
import 'farm_view.dart';

const kGrass = Color(0xFF96C55F);

/// Farm (home): Flame scene + Flutter overlays (labels, taps, bubble, Next up).
class FarmScreen extends ConsumerStatefulWidget {
  const FarmScreen({super.key, this.sceneBuilder});

  /// Test seam: replaces the Flame scene.
  final Widget Function(FarmGame game)? sceneBuilder;

  @override
  ConsumerState<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends ConsumerState<FarmScreen> {
  late final FarmGame _game = FarmGame();
  Timer? _tick;
  Timer? _bubbleTimer;
  String? _bubble;
  int _tipRotation = 0;

  @override
  void initState() {
    super.initState();
    // Re-evaluate the farm day and tint every minute (day rollover at reset hour).
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      ref.invalidate(farmViewProvider);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  void _toast(String message) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?.hideCurrentSnackBar();
    m?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // Float above the Next up button instead of covering it.
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
        backgroundColor: CultivaColors.ink,
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
      ),
    );
  }

  void _say(String text) {
    _bubbleTimer?.cancel();
    setState(() => _bubble = text);
    _bubbleTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _bubble = null);
    });
  }

  Future<void> _cellTap(FarmView view, PlotKind plot, int slot) async {
    final p = view.at(plot, slot);
    final farm = ref.read(farmServiceProvider);
    if (p == null) {
      _toast('Planting opens in the next update.');
      return;
    }
    try {
      switch (p.stage) {
        case PlantStage.ripe:
          final coins = await farm.harvest(p.task);
          unawaited(HapticFeedback.mediumImpact());
          _toast(
            coins > 0
                ? '+$coins coins from ${p.task.title}'
                : 'Harvested! (Daily coin cap reached.)',
          );
        case PlantStage.harvested:
          _toast('${p.task.title} is harvested for today.');
        case PlantStage.resting:
          _toast('${p.task.title} is resting today.');
        case PlantStage.seed ||
            PlantStage.sprout ||
            PlantStage.young ||
            PlantStage.dormant:
          if (p.task.plot == PlotKind.daily) {
            if (mounted) await context.push(Routes.focus(p.task.id));
          } else {
            await farm.complete(p.task);
            unawaited(HapticFeedback.lightImpact());
            _toast('${p.task.title} is ripe. Tap it to harvest!');
          }
      }
    } on FarmActionException catch (e) {
      _toast(e.message);
    }
  }

  void _onTap(Offset pos, FarmViewport vp, FarmView? view) {
    if (view == null) return;
    final hit = vp.hitTest(pos, capybara: _game.capyPosition.value);
    switch (hit.kind) {
      case FarmHitKind.cell:
        unawaited(_cellTap(view, hit.plot!, hit.slot!));
      case FarmHitKind.capybara || FarmHitKind.home:
        _say(capyTip(view, rotation: _tipRotation++));
      case FarmHitKind.barn:
        _toast(
          'Storage opens soon. ${view.harvestedToday} crops harvested today.',
        );
      case FarmHitKind.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(farmViewProvider).value;
    final sceneOn = ref.watch(farmSceneEnabledProvider);
    _game
      ..reduceMotion = MediaQuery.disableAnimationsOf(context)
      ..plants = view?.plants ?? const [];
    final tint = tintFor(DateTime.now().hour);

    return Scaffold(
      backgroundColor: kGrass,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FarmHeader(
              coins: view?.balance ?? 0,
              done: view?.doneCount ?? 0,
              total: view?.dueCount ?? 0,
              avatar: AvatarPortrait(view?.avatar ?? Avatar.fallback),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final vp = FarmViewport(
                    c.biggest,
                    MediaQuery.devicePixelRatioOf(context),
                  );
                  _game.viewport = vp;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child:
                            widget.sceneBuilder?.call(_game) ??
                            (sceneOn
                                ? GameWidget(game: _game)
                                : const SizedBox.expand()),
                      ),
                      if (tint != null)
                        Positioned.fill(
                          child: IgnorePointer(child: ColoredBox(color: tint)),
                        ),
                      if (view != null) ..._labels(vp, view),
                      if (view != null) ..._a11yCells(vp, view),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: (d) => _onTap(d.localPosition, vp, view),
                        ),
                      ),
                      if (_bubble != null) _bubbleOverlay(vp),
                    ],
                  );
                },
              ),
            ),
            _nextUpBar(view),
          ],
        ),
      ),
    );
  }

  List<Widget> _labels(FarmViewport vp, FarmView view) {
    Widget sign(PlotKind plot, String name) {
      final inPlot = view.inPlot(plot);
      final done = inPlot
          .where(
            (p) =>
                p.stage == PlantStage.ripe || p.stage == PlantStage.harvested,
          )
          .length;
      final at = vp.toScreen(FarmLayout.signAnchor(plot));
      return Positioned(
        left: at.dx,
        top: at.dy,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: CultivaColors.wood,
              border: Border.all(color: CultivaColors.woodDark, width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$name $done/${inPlot.length}',
              style: const TextStyle(
                fontFamily: kPixelFont,
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final badge = vp.toScreen(
      Offset(FarmLayout.barn.right - 10, FarmLayout.barn.top + 4),
    );
    return [
      sign(PlotKind.daily, 'DAILY'),
      sign(PlotKind.todo, 'TO-DO & HABITS'),
      if (view.harvestedToday > 0)
        Positioned(
          left: badge.dx,
          top: badge.dy,
          child: IgnorePointer(
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CultivaColors.terracotta,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '${view.harvestedToday}',
                style: const TextStyle(
                  fontFamily: kPixelFont,
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  /// Invisible, screen-reader-only buttons over each plant (Flame isn't accessible).
  List<Widget> _a11yCells(FarmViewport vp, FarmView view) => [
    for (final plot in PlotKind.values)
      for (var s = 0; s < kPlotCapacity; s++)
        Positioned.fromRect(
          rect: vp.rectToScreen(FarmLayout.cell(plot, s)),
          child: Semantics(
            button: true,
            label: _cellLabel(view.at(plot, s)),
            onTap: () => _cellTap(view, plot, s),
            child: const SizedBox.expand(),
          ),
        ),
  ];

  String _cellLabel(PlantView? p) {
    if (p == null) return 'Empty soil. Plant a task.';
    final what = switch (p.stage) {
      PlantStage.ripe => 'ripe, tap to harvest',
      PlantStage.harvested => 'harvested today',
      PlantStage.resting => 'resting today',
      PlantStage.dormant => 'dormant, do it to revive',
      _ => 'growing',
    };
    return '${p.task.title}, $what';
  }

  Widget _bubbleOverlay(FarmViewport vp) {
    return ValueListenableBuilder<Offset>(
      valueListenable: _game.capyPosition,
      builder: (context, capy, _) {
        final at = vp.toScreen(capy);
        const width = 200.0;
        final left = (at.dx - width + 24).clamp(8.0, vp.size.width - width - 8);
        return Positioned(
          left: left,
          top: (at.dy - 70).clamp(4.0, vp.size.height - 80),
          width: width,
          child: IgnorePointer(
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CultivaColors.woodDark, width: 2),
                ),
                child: Text(
                  _bubble!,
                  style: const TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CultivaColors.ink,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _nextUpBar(FarmView? view) {
    final Widget button;
    if (view == null) {
      button = const SizedBox(height: kMinTap);
    } else if (view.plants.isEmpty) {
      button = PixelButton(
        label: 'Plant your first task',
        icon: PixelIcons.plus,
        expand: true,
        onPressed: () => _toast('Planting opens in the next update.'),
      );
    } else if (view.next case final n?) {
      final timed = n.task.kind == TaskKind.timed;
      button = PixelButton(
        label: timed
            ? 'Next up: ${n.task.title} · ${n.task.targetMinutes} min'
            : 'Next up: ${n.task.title}',
        icon: timed ? PixelIcons.play : PixelIcons.check,
        expand: true,
        onPressed: () => _cellTap(view, n.task.plot, n.task.slot),
      );
    } else {
      button = PixelButton(
        label: "Everything's harvested!",
        variant: PixelButtonVariant.paper,
        expand: true,
        onPressed: () => _say(capyTip(view, rotation: _tipRotation++)),
      );
    }
    return ColoredBox(
      color: kGrass,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.md,
          Space.xs,
          Space.md,
          Space.sm,
        ),
        child: button,
      ),
    );
  }
}

/// Header: avatar (→ Profile) · coins/progress pill · calendar (→ Progress calendar).
class FarmHeader extends StatelessWidget {
  const FarmHeader({
    super.key,
    this.coins = 0,
    this.done = 0,
    this.total = 0,
    this.avatar,
  });

  final int coins;
  final int done;
  final int total;

  /// Player avatar portrait; falls back to a neutral icon until one is chosen.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().day;
    return Container(
      color: CultivaColors.tealDark,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      child: Row(
        children: [
          PixelIconButton(
            semanticLabel: 'Profile',
            onPressed: () => context.push(Routes.profile),
            child: avatar ?? const AvatarPortrait(Avatar.fallback),
          ),
          const Spacer(),
          Semantics(
            label: '$coins coins, $done of $total tasks done today',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/sprites/cultiva/fx/coin.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(width: Space.xs),
                  Text('$coins', style: _pill),
                  const SizedBox(width: Space.md),
                  Text('$done/$total today', style: _pill),
                ],
              ),
            ),
          ),
          const Spacer(),
          PixelIconButton(
            semanticLabel: 'Calendar',
            onPressed: () => context.go(Routes.calendar),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _months[DateTime.now().month - 1],
                  style: const TextStyle(
                    fontFamily: kPixelFont,
                    fontSize: 9,
                    color: CultivaColors.terracotta,
                    height: 1,
                  ),
                ),
                Text(
                  '$day',
                  style: const TextStyle(
                    fontFamily: kPixelFont,
                    fontSize: 18,
                    color: CultivaColors.ink,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _pill = TextStyle(
    fontFamily: kPixelFont,
    fontSize: 15,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
}
