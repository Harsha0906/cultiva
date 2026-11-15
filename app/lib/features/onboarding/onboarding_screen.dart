import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_prefs.dart';
import '../../core/notifications.dart';
import '../../core/router.dart';
import '../../core/sfx.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/avatar_portrait.dart';
import '../../core/ui/coin_fly.dart';
import '../../core/ui/crop_sprite.dart';
import '../../core/ui/pixel_button.dart';
import '../../data/providers.dart';
import '../../data/task_repository.dart';
import '../../domain/avatar.dart';
import '../../domain/crops.dart';
import '../../domain/rewards.dart';
import '../../domain/task.dart';
import '../tasks/task_form_parts.dart';

/// Coins given once, at the end of the practice harvest.
const kWelcomeCoins = 20;
const kWelcomeRef = 'welcome';

/// Length of the guided breathing moment (overridden to seconds in tests).
final onboardingBreathProvider = Provider<Duration>(
  (_) => const Duration(seconds: 60),
);

const _ideas = ['Read', 'Walk', 'Stretch', 'Meditate'];
const _durations = [5, 15, 30];

/// First-launch flow: welcome → you → first task → first harvest → reminder.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.random});

  final Random? random;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 5;
  int _step = 0;
  bool _busy = false;

  final _name = TextEditingController();
  AvatarAnimal _animal = AvatarAnimal.fox;

  String _idea = _ideas.first;
  final _custom = TextEditingController();
  bool _useCustom = false;
  int _minutes = 15;
  late final String _crop =
      kCrops[(widget.random ?? Random()).nextInt(kCrops.length)];
  String? _error;

  int _reminder = 8 * 60 + 30;

  @override
  void dispose() {
    _name.dispose();
    _custom.dispose();
    super.dispose();
  }

  String get _title => _useCustom ? _custom.text.trim() : _idea;

  Future<void> _saveYou() async {
    FocusScope.of(context).unfocus();
    final settings = ref.read(farmServiceProvider).settings;
    await settings.setFarmerName(_name.text);
    await settings.setAvatar(Avatar(_animal, 0));
    setState(() => _step = 2);
  }

  Future<void> _plant() async {
    if (_title.isEmpty) {
      setState(() => _error = 'Give your task a name.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final farm = ref.read(farmServiceProvider);
    try {
      await farm.tasks.plant(
        title: _title,
        plot: PlotKind.daily,
        crop: _crop,
        today: await farm.today(),
        targetMinutes: _minutes,
        repeat: Weekdays.everyDay,
      );
      Sfx.play(SfxName.plant);
      AppFeedback.light().ignore();
      if (mounted) setState(() => _step = 3);
    } on InvalidTaskException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } on PlotFullException {
      // Re-running onboarding on a full farm: keep going without a new task.
      if (mounted) setState(() => _step = 3);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Pays the welcome gift exactly once, even if onboarding is replayed.
  Future<void> _welcomeGift() async {
    final farm = ref.read(farmServiceProvider);
    if ((await farm.progress.rowsFor(kWelcomeRef)).isNotEmpty) return;
    await farm.progress.append(
      kWelcomeCoins,
      LedgerReason.refund,
      day: await farm.today(),
      refId: kWelcomeRef,
    );
  }

  Future<void> _finish({required bool remind}) async {
    setState(() => _busy = true);
    final settings = ref.read(farmServiceProvider).settings;
    if (remind) {
      final notify = ref.read(notificationsProvider);
      final allowed = await notify.requestPermission();
      if (allowed) {
        await settings.setReminderMinutes(_reminder);
        await settings.setReminderEnabled(true);
        await notify.scheduleDailyReminder(_reminder);
      } else if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are off for Cultiva. You can turn the reminder '
              'on later in Profile.',
            ),
          ),
        );
      }
    }
    await settings.setOnboarded(true);
    if (mounted) context.go(Routes.farm);
  }

  Future<void> _skipAll() async {
    await ref.read(farmServiceProvider).settings.setOnboarded(true);
    if (mounted) context.go(Routes.farm);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminder ~/ 60, minute: _reminder % 60),
    );
    if (picked != null) {
      setState(() => _reminder = picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = _step == 1 || _step == 2;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && canGoBack) setState(() => _step--);
      },
      child: Scaffold(
        backgroundColor: CultivaColors.paperDark,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                step: _step,
                steps: _steps,
                onBack: canGoBack ? () => setState(() => _step--) : null,
                onSkip: _step <= 2 ? _skipAll : null,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _body(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) => switch (_step) {
    0 => _StepPage(
      title: 'Grandma left you a little farm.',
      body:
          'Every task you finish grows a crop. Harvest crops for coins and '
          'make the farm yours.',
      art: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CapybaraSprite(scale: 5),
          SizedBox(width: Space.md),
          CropSprite('lettuce', frame: 1, scale: 3),
        ],
      ),
      action: PixelButton(
        label: "Let's go",
        expand: true,
        onPressed: () => setState(() => _step = 1),
      ),
    ),
    1 => _StepPage(
      title: 'What should the capybara call you?',
      content: [
        TextField(
          controller: _name,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'Farmer',
          ),
        ),
        const FieldLabel('Pick your farmer'),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final a in AvatarAnimal.values)
              _AvatarChoice(
                animal: a,
                selected: a == _animal,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _animal = a);
                },
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Text(
          'More colours are waiting in Profile.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      action: PixelButton(label: 'Next', expand: true, onPressed: _saveYou),
    ),
    2 => _StepPage(
      title: "What's one thing you want to do every day?",
      content: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final idea in _ideas)
              ChoicePixel(
                label: idea,
                selected: !_useCustom && idea == _idea,
                onTap: () => setState(() {
                  _idea = idea;
                  _useCustom = false;
                  _error = null;
                }),
              ),
            ChoicePixel(
              label: 'Something else',
              selected: _useCustom,
              onTap: () => setState(() => _useCustom = true),
            ),
          ],
        ),
        if (_useCustom) ...[
          const SizedBox(height: Space.md),
          TextField(
            controller: _custom,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Task name'),
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
        FieldError(_error),
        const FieldLabel('For how long?'),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final m in _durations)
              ChoicePixel(
                label: '$m min',
                semanticLabel: '$m minutes',
                selected: m == _minutes,
                onTap: () => setState(() => _minutes = m),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Row(
          children: [
            CropSprite(_crop, frame: 0, scale: 2),
            const SizedBox(width: Space.md),
            Expanded(
              child: Text(
                'It goes in your Daily plot, every day. A timer grows it '
                'while you do it.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
      action: PixelButton(
        label: 'Plant it',
        expand: true,
        loading: _busy,
        onPressed: _plant,
      ),
    ),
    3 => _FirstHarvest(
      crop: _crop,
      duration: ref.read(onboardingBreathProvider),
      onHarvest: _welcomeGift,
      onNext: () => setState(() => _step = 4),
    ),
    _ => _StepPage(
      title: 'Want one gentle nudge a day?',
      body:
          'The capybara can remind you to tend your farm. One quiet '
          'notification, never more.',
      content: [
        const SizedBox(height: Space.md),
        Center(
          child: PixelButton(
            label: 'At ${_formatTime(_reminder)}',
            variant: PixelButtonVariant.paper,
            onPressed: _pickTime,
          ),
        ),
      ],
      action: Column(
        children: [
          PixelButton(
            label: 'Yes, remind me',
            expand: true,
            loading: _busy,
            onPressed: () => _finish(remind: true),
          ),
          const SizedBox(height: Space.sm),
          PixelButton(
            label: 'Not now',
            variant: PixelButtonVariant.paper,
            expand: true,
            onPressed: _busy ? null : () => _finish(remind: false),
          ),
        ],
      ),
    ),
  };
}

String _formatTime(int minutes) {
  final h = minutes ~/ 60, m = minutes % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.steps,
    required this.onBack,
    required this.onSkip,
  });

  final int step;
  final int steps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm),
      child: SizedBox(
        height: kMinTap,
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Align(
                alignment: Alignment.centerLeft,
                child: onBack == null
                    ? null
                    : TextButton(onPressed: onBack, child: const Text('Back')),
              ),
            ),
            Expanded(
              child: Semantics(
                label: 'Step ${step + 1} of $steps',
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < steps; i++)
                        Container(
                          width: i == step ? 16 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          color: i <= step
                              ? CultivaColors.teal
                              : CultivaColors.line,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 96,
              child: Align(
                alignment: Alignment.centerRight,
                child: onSkip == null
                    ? null
                    : TextButton(onPressed: onSkip, child: const Text('Skip')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrollable step: art, title, body/content, and a bottom action.
class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.title,
    required this.action,
    this.body,
    this.art,
    this.content = const [],
  });

  final String title;
  final String? body;
  final Widget? art;
  final List<Widget> content;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg,
              Space.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (art != null) ...[
                  const SizedBox(height: Space.xl),
                  Center(child: art),
                  const SizedBox(height: Space.xl),
                ],
                Semantics(
                  header: true,
                  child: Text(title, style: t.headlineSmall),
                ),
                if (body != null) ...[
                  const SizedBox(height: Space.md),
                  Text(body!, style: t.bodyLarge),
                ],
                const SizedBox(height: Space.sm),
                ...content,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.lg,
            Space.sm,
            Space.lg,
            Space.lg,
          ),
          child: action,
        ),
      ],
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.animal,
    required this.selected,
    required this.onTap,
  });

  final AvatarAnimal animal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: animal.name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CultivaColors.paper,
            border: Border.all(
              color: selected ? CultivaColors.teal : CultivaColors.line,
              width: selected ? 3 : 2,
            ),
          ),
          child: AvatarPortrait(Avatar(animal, 0), scale: 3),
        ),
      ),
    );
  }
}

/// Step 4: a guided breathing minute that grows the crop, then a harvest.
class _FirstHarvest extends ConsumerStatefulWidget {
  const _FirstHarvest({
    required this.crop,
    required this.duration,
    required this.onHarvest,
    required this.onNext,
  });

  final String crop;
  final Duration duration;
  final Future<void> Function() onHarvest;
  final VoidCallback onNext;

  @override
  ConsumerState<_FirstHarvest> createState() => _FirstHarvestState();
}

class _FirstHarvestState extends ConsumerState<_FirstHarvest>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration)
    ..forward();
  bool _harvested = false;
  final _cropKey = GlobalKey();
  final _coinKey = GlobalKey();
  int _bump = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  int get _frame => switch (_c.value) {
    < 0.25 => 0,
    < 0.5 => 1,
    < 0.75 => 2,
    _ => 3,
  };

  Future<void> _harvest() async {
    setState(() => _harvested = true);
    AppFeedback.medium().ignore();
    Sfx.play(SfxName.harvest);
    await widget.onHarvest();
    if (!mounted) return;
    final reduce = MediaQuery.of(context).disableAnimations;
    final crop = _cropKey.currentContext?.findRenderObject() as RenderBox?;
    final coin = _coinKey.currentContext?.findRenderObject() as RenderBox?;
    if (reduce || crop == null || coin == null) {
      Sfx.play(SfxName.coin);
      setState(() => _bump++);
      return;
    }
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => CoinFly(
        start: crop.localToGlobal(crop.size.center(Offset.zero)),
        end: coin.localToGlobal(coin.size.center(Offset.zero)),
        onDone: () {
          entry.remove();
          Sfx.play(SfxName.coin);
          if (mounted) setState(() => _bump++);
        },
      ),
    );
    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final reduce = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ripe = _c.isCompleted;
        final elapsed = (_c.value * widget.duration.inMilliseconds) ~/ 1000;
        // 4 s in, 4 s out.
        final inhale = (elapsed ~/ 4).isEven;
        final phase =
            ((_c.value * widget.duration.inMilliseconds) % 8000) / 8000;
        final breath = 0.5 - 0.5 * cos(phase * 2 * pi);
        final left = widget.duration.inSeconds - elapsed;
        return _StepPage(
          title: _harvested
              ? "That's how every task works."
              : ripe
              ? 'It grew while you breathed.'
              : 'Take one calm minute. Watch it grow.',
          content: [
            const SizedBox(height: Space.lg),
            Center(
              child: SizedBox.square(
                dimension: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: reduce ? 170 : 120 + 70 * breath,
                      height: reduce ? 170 : 120 + 70 * breath,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CultivaColors.grass.withValues(alpha: 0.25),
                        border: Border.all(
                          color: CultivaColors.grass,
                          width: 3,
                        ),
                      ),
                    ),
                    KeyedSubtree(
                      key: _cropKey,
                      child: CropSprite(
                        widget.crop,
                        frame: _harvested ? 0 : _frame,
                        scale: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.lg),
            Semantics(
              liveRegion: true,
              child: Text(
                _harvested
                    ? 'Do a task, the crop ripens, harvest it for coins. '
                          'Here is a welcome gift from the capybara.'
                    : ripe
                    ? "It's ripe! Tap Harvest."
                    : '${inhale ? 'Breathe in…' : 'Breathe out…'}  '
                          '${left}s',
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ),
            const SizedBox(height: Space.lg),
            Center(
              child: Bump(
                tick: _bump,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg,
                    vertical: Space.sm,
                  ),
                  decoration: BoxDecoration(
                    color: CultivaColors.paper,
                    border: Border.all(color: CultivaColors.woodDark, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        key: _coinKey,
                        'assets/sprites/cultiva/fx/coin.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                        filterQuality: FilterQuality.none,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(width: Space.sm),
                      Flexible(
                        child: Text(
                          _bump > 0
                              ? '+$kWelcomeCoins coins'
                              : 'Welcome gift: $kWelcomeCoins coins',
                          style: t.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          action: _harvested
              ? PixelButton(
                  label: 'Next',
                  expand: true,
                  onPressed: widget.onNext,
                )
              : ripe
              ? PixelButton(
                  label: 'Harvest!',
                  expand: true,
                  onPressed: _harvest,
                )
              : PixelButton(
                  label: 'Skip for now',
                  variant: PixelButtonVariant.paper,
                  expand: true,
                  onPressed: widget.onNext,
                ),
        );
      },
    );
  }
}

/// One frame of the capybara strip (0 idle, 1 blink), with an idle blink.
class CapybaraSprite extends StatefulWidget {
  const CapybaraSprite({super.key, this.scale = 4});
  final double scale;

  @override
  State<CapybaraSprite> createState() => _CapybaraSpriteState();
}

class _CapybaraSpriteState extends State<CapybaraSprite>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = 22 * widget.scale, h = 16 * widget.scale;
    return Semantics(
      label: 'The capybara, your farm helper',
      image: true,
      child: SizedBox(
        width: w,
        height: h,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final frame = _c.value > 0.95 ? 1 : 0;
            return ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: w * 6,
                maxWidth: w * 6,
                minHeight: h,
                maxHeight: h,
                child: Transform.translate(
                  offset: Offset(-frame * w, 0),
                  child: Image.asset(
                    'assets/sprites/cultiva/npc/capybara.png',
                    width: w * 6,
                    height: h,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
