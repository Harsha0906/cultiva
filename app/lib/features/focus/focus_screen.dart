import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/notifications.dart';
import '../../core/router.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/crop_sprite.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/farm_service.dart';
import '../../data/focus_service.dart';
import '../../data/providers.dart';
import '../../domain/crops.dart';
import '../../domain/plant_engine.dart';
import '../../domain/rewards.dart';
import '../../domain/task.dart';
import '../shell/not_found_screen.dart';

const _bgTop = Color(0xFF1F3A40);
const _bgBottom = Color(0xFF2E5B5E);

/// Focus Mode for one Daily (timed) task. The timer is timestamp-based
/// (FocusService), so this screen only *displays* time; leaving it is safe.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, required this.taskId});

  final String taskId;

  static final _validId = RegExp(r'^[A-Za-z0-9-]{1,64}$');

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with WidgetsBindingObserver {
  FarmTask? _task;
  FocusSnapshot? _snap;
  bool _missing = false;
  bool _busy = false;
  Timer? _timer;
  final _watch = Stopwatch();
  DateTime? _wallAtWatch;
  int _watchElapsedAtStart = 0;

  FocusService get _focus => ref.read(focusServiceProvider);
  FarmService get _farm => ref.read(farmServiceProvider);
  AppNotifier get _notify => ref.read(notificationsProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    } else {
      // In the background the scheduled "ripe" alert takes over. Stop ticking,
      // or a late tick would decide the timer finished in-app and cancel it.
      _timer?.cancel();
    }
  }

  Future<void> _load() async {
    if (!FocusScreen._validId.hasMatch(widget.taskId)) {
      setState(() => _missing = true);
      return;
    }
    final task = await _farm.tasks.byId(widget.taskId);
    if (!mounted) return;
    if (task == null || task.archived || task.kind != TaskKind.timed) {
      setState(() => _missing = true);
      return;
    }
    final snap = await _focus.load(task);
    if (!mounted) return;
    // The player is looking at the result, so the shade doesn't need it.
    if (snap.status == FocusStatus.ripe) unawaited(_notify.focusStopped(task));
    _apply(task, snap);
  }

  void _apply(FarmTask task, FocusSnapshot snap) {
    setState(() {
      _task = task;
      _snap = snap;
    });
    _timer?.cancel();
    if (snap.status == FocusStatus.running) {
      _watch
        ..reset()
        ..start();
      _wallAtWatch = _now();
      _watchElapsedAtStart = snap.elapsedSec;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else {
      _watch.stop();
    }
  }

  Future<void> _tick() async {
    final task = _task, snap = _snap;
    if (!mounted || task == null || snap == null) return;
    // Monotonic stopwatch vs wall clock: a big gap means the clock was changed.
    final wall = _now().difference(_wallAtWatch ?? _now()).inSeconds;
    if ((wall - _watch.elapsed.inSeconds).abs() > kStopwatchDriftSec) {
      await _focus.flagClockDrift(task);
      _wallAtWatch = _now();
      _watch
        ..reset()
        ..start();
    }
    final shown = _watchElapsedAtStart + _watch.elapsed.inSeconds;
    if (shown >= snap.plannedSec) {
      final next = await _focus.load(task);
      if (!mounted) return;
      if (next.status == FocusStatus.ripe) {
        unawaited(HapticFeedback.mediumImpact());
        unawaited(_notify.focusStopped(task));
      }
      _apply(task, next);
    } else {
      setState(() {});
    }
  }

  int get _elapsedShown {
    final s = _snap;
    if (s == null) return 0;
    if (s.status != FocusStatus.running) return s.elapsedSec;
    return (_watchElapsedAtStart + _watch.elapsed.inSeconds).clamp(
      0,
      s.plannedSec,
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on FocusException catch (e) {
      _toast(e.message);
    } on FarmActionException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultivaColors.ink,
        content: Text(
          msg,
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
      ),
    );
  }

  Future<bool> _confirm(String title, String body, String yes) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: CultivaColors.paper,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(yes),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _start() => _guard(() async {
    final task = _task!;
    // Ask before showing the countdown, or Android drops it.
    await _notify.requestPermission();
    final snap = await _focus.start(task);
    if (snap.endsAt != null) {
      unawaited(_notify.focusStarted(task, snap.endsAt!));
    }
    if (mounted) _apply(task, snap);
  });

  Future<void> _pause() => _guard(() async {
    final task = _task!;
    final snap = await _focus.pause(task);
    unawaited(_notify.focusStopped(task));
    if (mounted) _apply(task, snap);
  });

  Future<void> _giveUp() async {
    final ok = await _confirm(
      'Stop for today?',
      'Your plant keeps the growth from this session.',
      'Stop',
    );
    if (!ok) return;
    await _guard(() async {
      final task = _task!;
      final snap = await _focus.giveUp(task);
      unawaited(_notify.focusStopped(task));
      if (mounted) _apply(task, snap);
    });
  }

  Future<void> _alreadyDid() async {
    final ok = await _confirm(
      'Already did it?',
      'Log ${_task!.title} without the timer. Logged tasks earn half coins.',
      'Log it',
    );
    if (!ok) return;
    await _guard(() async {
      final task = _task!;
      await _focus.giveUp(task);
      await _farm.complete(task, method: CompletionMethod.manual);
      unawaited(_notify.focusStopped(task));
      final snap = await _focus.load(task);
      if (mounted) _apply(task, snap);
    });
  }

  Future<void> _harvest() => _guard(() async {
    final task = _task!;
    final coins = await _farm.harvest(task);
    unawaited(HapticFeedback.mediumImpact());
    unawaited(_notify.focusStopped(task));
    _toast('+$coins coins from ${task.title}');
    if (mounted) context.go(Routes.farm);
  });

  @override
  Widget build(BuildContext context) {
    if (_missing) return const NotFoundScreen(message: 'Task not found.');
    final task = _task, snap = _snap;
    return Scaffold(
      backgroundColor: _bgTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          task == null ? '' : 'DAILY · ${cropLabel(task.crop).toUpperCase()}',
          style: const TextStyle(
            fontFamily: kPixelFont,
            fontSize: 14,
            color: Color(0xCCFFFFFF),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Space.md),
            child: PixelIconButton(
              semanticLabel: 'Back to farm',
              icon: PixelIcons.close,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.farm),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          top: false,
          child: task == null || snap == null
              ? const SizedBox.expand()
              : _body(task, snap),
        ),
      ),
    );
  }

  Widget _body(FarmTask task, FocusSnapshot snap) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final elapsed = _elapsedShown;
    final remaining = (snap.plannedSec - elapsed).clamp(0, snap.plannedSec);
    final progress = snap.plannedSec == 0 ? 0.0 : elapsed / snap.plannedSec;
    final stage = switch (snap.status) {
      FocusStatus.ripe => PlantStage.ripe,
      FocusStatus.harvested => PlantStage.harvested,
      _ when elapsed == 0 => PlantStage.seed,
      _ when progress < 0.5 => PlantStage.sprout,
      _ => PlantStage.young,
    };
    final stageNo = switch (stage) {
      PlantStage.seed => 1,
      PlantStage.sprout => 2,
      PlantStage.young => 3,
      _ => 4,
    };
    final white = Theme.of(context).textTheme.headlineMedium!
        .copyWith(color: Colors.white);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(task.title, style: white, textAlign: TextAlign.center),
                const SizedBox(height: Space.xl),
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 200,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF73432F),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF3D2420),
                            width: 3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          child: CropSprite(
                            task.crop,
                            key: ValueKey(stage),
                            frame: cropFrame(stage),
                            scale: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.lg),
                if (snap.status == FocusStatus.ripe ||
                    snap.status == FocusStatus.harvested)
                  Text(
                    snap.status == FocusStatus.ripe
                        ? 'Ready to harvest!'
                        : 'Harvested today',
                    style: white,
                  )
                else ...[
                  Semantics(
                    label: '${_spoken(remaining)} left',
                    excludeSemantics: true,
                    child: Text(
                      _clock(remaining),
                      style: const TextStyle(
                        fontFamily: kPixelFont,
                        fontSize: 64,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  _ProgressBar(value: progress),
                  const SizedBox(height: Space.sm),
                  Text(
                    snap.status == FocusStatus.paused
                        ? 'Paused · stage $stageNo of 4'
                        : snap.status == FocusStatus.abandoned
                        ? 'Stopped · growth kept'
                        : 'Stage $stageNo of 4',
                    style: const TextStyle(
                      fontFamily: kBodyFont,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                ],
                const SizedBox(height: Space.xl),
                ..._actions(snap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(FocusSnapshot snap) {
    final link = TextStyle(
      fontFamily: kBodyFont,
      color: Colors.white.withValues(alpha: 0.85),
      decoration: TextDecoration.underline,
      decorationColor: Colors.white70,
    );
    switch (snap.status) {
      case FocusStatus.idle || FocusStatus.abandoned:
        return [
          PixelButton(
            label: snap.status == FocusStatus.idle ? 'Start' : 'Start again',
            icon: PixelIcons.play,
            expand: true,
            loading: _busy,
            onPressed: _start,
          ),
          const SizedBox(height: Space.md),
          TextButton(
            onPressed: _busy ? null : _alreadyDid,
            child: Text('I already did it (half coins)', style: link),
          ),
        ];
      case FocusStatus.running:
        return [
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  label: 'Pause',
                  variant: PixelButtonVariant.teal,
                  onPressed: _busy ? null : _pause,
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: PixelButton(
                  label: 'Give up',
                  variant: PixelButtonVariant.paper,
                  onPressed: _busy ? null : _giveUp,
                ),
              ),
            ],
          ),
        ];
      case FocusStatus.paused:
        return [
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  label: 'Resume',
                  icon: PixelIcons.play,
                  loading: _busy,
                  onPressed: _start,
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: PixelButton(
                  label: 'Give up',
                  variant: PixelButtonVariant.paper,
                  onPressed: _busy ? null : _giveUp,
                ),
              ),
            ],
          ),
        ];
      case FocusStatus.ripe:
        return [
          PixelButton(
            label: 'Harvest',
            expand: true,
            loading: _busy,
            onPressed: _harvest,
          ),
        ];
      case FocusStatus.harvested:
        return [
          PixelButton(
            label: 'Back to farm',
            variant: PixelButtonVariant.paper,
            expand: true,
            onPressed: () => context.go(Routes.farm),
          ),
        ];
    }
  }

  static String _clock(int sec) {
    final h = sec ~/ 3600, m = (sec % 3600) ~/ 60, s = sec % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  static String _spoken(int sec) {
    final m = sec ~/ 60, s = sec % 60;
    return m > 0 ? '$m minutes $s seconds' : '$s seconds';
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) => Semantics(
    value: '${(value * 100).round()} percent',
    child: Container(
      height: 14,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFF173036), width: 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: const ColoredBox(color: Color(0xFF7FBDE3)),
      ),
    ),
  );
}
