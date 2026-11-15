import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/live_query.dart';
import '../../core/notifications.dart';
import '../../core/router.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/avatar_portrait.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../core/ui/pixel_panel.dart';
import '../../data/providers.dart';
import '../../data/settings_repository.dart';
import '../../data/stats_service.dart';
import '../../domain/avatar.dart';

/// Everything the Profile screen shows.
final class ProfileView {
  const ProfileView({
    required this.name,
    required this.avatar,
    required this.lifetime,
    required this.resetHour,
    required this.reminderOn,
    required this.reminderMinutes,
    required this.sound,
    required this.haptics,
    required this.reduceMotion,
  });
  final String name;
  final Avatar avatar;
  final Lifetime lifetime;
  final int resetHour;
  final bool reminderOn;
  final int reminderMinutes;
  final bool sound;
  final bool haptics;
  final bool reduceMotion;
}

final profileViewProvider = StreamProvider<ProfileView>((ref) {
  final db = ref.watch(dbProvider);
  final settings = ref.watch(farmServiceProvider).settings;
  final stats = ref.watch(statsServiceProvider);
  return liveQuery(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.settings,
        db.completions,
        db.coinLedger,
        db.tasks,
      ]),
    ),
    () async => ProfileView(
      name: await settings.farmerName(),
      avatar: await settings.avatar(),
      lifetime: await stats.lifetime(),
      resetHour: await settings.resetHour(),
      reminderOn: await settings.reminderEnabled(),
      reminderMinutes: await settings.reminderMinutes(),
      sound: await settings.sound(),
      haptics: await settings.haptics(),
      reduceMotion: await settings.reduceMotion(),
    ),
  );
});

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _hourLabel(int h) => h == 0 ? 'Midnight' : '$h AM';

String formatMinutesOfDay(int m) {
  final h = m ~/ 60, min = m % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${min.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

/// Profile: who you are on the farm, what you've grown, and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(profileViewProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const PixelIcon(PixelIcons.back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.farm),
        ),
      ),
      body: view == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(view: view),
                  const SizedBox(height: Space.lg),
                  _Stats(lifetime: view.lifetime),
                  const SizedBox(height: Space.xl),
                  _AvatarPicker(selected: view.avatar),
                  const SizedBox(height: Space.xl),
                  _Settings(view: view),
                  const SizedBox(height: Space.xl),
                  const _About(),
                ],
              ),
            ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.view});
  final ProfileView view;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: view.name),
    );
    if (name != null) {
      await ref.read(farmServiceProvider).settings.setFarmerName(name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final first = view.lifetime.firstDay;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            color: const Color(0xFFCFE6B8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CultivaColors.woodDark, width: 3),
          ),
          child: AvatarPortrait(view.avatar, scale: 6),
        ),
        const SizedBox(height: Space.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                view.name,
                style: t.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Space.sm),
            TextButton(
              onPressed: () => _rename(context, ref),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontFamily: kPixelFont,
                  color: CultivaColors.tealDark,
                ),
              ),
            ),
          ],
        ),
        Text(
          first == null
              ? 'A brand-new farmer'
              : 'Farming since ${first.day} ${_months[first.month - 1]} ${first.year}',
          style: t.bodySmall,
        ),
      ],
    );
  }
}

/// Owns its controller so it lives until the dialog's closing animation ends
/// (disposing it right after `showDialog` returned crashed the fade-out).
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});
  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CultivaColors.paper,
      title: const Text('Your farmer name'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLength: 24,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.lifetime});
  final Lifetime lifetime;

  @override
  Widget build(BuildContext context) {
    final hours = (lifetime.focusMinutes / 60).toStringAsFixed(1);
    final tiles = [
      ('${lifetime.daysFarmed}', 'days farmed'),
      ('${lifetime.harvested}', 'crops harvested'),
      ('${hours}h', 'focus time'),
      ('${lifetime.bestDayCount}', 'best day'),
    ];
    Widget tile((String, String) t) => Expanded(
      child: Semantics(
        label: '${t.$1} ${t.$2}',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.md,
            vertical: Space.sm,
          ),
          decoration: BoxDecoration(
            color: CultivaColors.paper,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: CultivaColors.line, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.$1,
                style: const TextStyle(
                  fontFamily: kPixelFont,
                  fontSize: 22,
                  color: CultivaColors.tealDark,
                ),
              ),
              Text(t.$2, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
    // Rows that grow with their text (a fixed-ratio grid overflowed with
    // large system text).
    return PixelPanel(
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(tiles[0]),
                const SizedBox(width: Space.sm),
                tile(tiles[1]),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(tiles[2]),
                const SizedBox(width: Space.sm),
                tile(tiles[3]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends ConsumerWidget {
  const _AvatarPicker({required this.selected});
  final Avatar selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Choose your avatar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final a in Avatar.all)
              Semantics(
                button: true,
                selected: a == selected,
                label: '${a.animal.name} avatar, colour ${a.variant + 1}',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () =>
                      ref.read(farmServiceProvider).settings.setAvatar(a),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CultivaColors.paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: a == selected
                            ? CultivaColors.teal
                            : CultivaColors.line,
                        width: a == selected ? 3 : 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AvatarPortrait(a),
                        if (a == selected)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(
                              Icons.check_circle,
                              size: 14,
                              color: CultivaColors.teal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Settings extends ConsumerWidget {
  const _Settings({required this.view});
  final ProfileView view;

  SettingsRepository _s(WidgetRef ref) =>
      ref.read(farmServiceProvider).settings;

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    bool on,
  ) async {
    final notify = ref.read(notificationsProvider);
    if (!on) {
      await _s(ref).setReminderEnabled(false);
      await notify.cancelDailyReminder();
      return;
    }
    final allowed = await notify.requestPermission();
    if (!allowed) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are off for Cultiva. You can allow them in '
              'Android settings.',
            ),
          ),
        );
      }
      return;
    }
    await _s(ref).setReminderEnabled(true);
    await notify.scheduleDailyReminder(view.reminderMinutes);
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: view.reminderMinutes ~/ 60,
        minute: view.reminderMinutes % 60,
      ),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    await _s(ref).setReminderMinutes(minutes);
    if (view.reminderOn) {
      await ref.read(notificationsProvider).scheduleDailyReminder(minutes);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    Widget toggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
    ) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: CultivaColors.teal,
      title: Text(title, style: t.bodyLarge),
      subtitle: Text(subtitle, style: t.bodySmall),
      value: value,
      onChanged: onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text('Settings', style: t.titleMedium)),
        const SizedBox(height: Space.sm),
        Text('Day resets at', style: t.bodyLarge),
        Text(
          'Late nights still count for "today" until this time.',
          style: t.bodySmall,
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            for (final h in const [0, 2, 3, 4, 5, 6])
              Semantics(
                selected: view.resetHour == h,
                child: PixelButton(
                  label: _hourLabel(h),
                  variant: view.resetHour == h
                      ? PixelButtonVariant.teal
                      : PixelButtonVariant.paper,
                  onPressed: () => _s(ref).setResetHour(h),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        toggle(
          'Daily reminder',
          'One gentle nudge a day.',
          view.reminderOn,
          (v) => _toggleReminder(context, ref, v),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: PixelButton(
            label: 'Remind me at ${formatMinutesOfDay(view.reminderMinutes)}',
            variant: PixelButtonVariant.paper,
            onPressed: () => _pickTime(context, ref),
          ),
        ),
        const SizedBox(height: Space.sm),
        toggle(
          'Sound',
          'Soft farm sounds.',
          view.sound,
          (v) => _s(ref).setSound(v),
        ),
        toggle(
          'Haptics',
          'Little vibrations when you plant and harvest.',
          view.haptics,
          (v) => _s(ref).setHaptics(v),
        ),
        toggle(
          'Reduce motion',
          'Fewer animations (the capybara stays put).',
          view.reduceMotion,
          (v) => _s(ref).setReduceMotion(v),
        ),
      ],
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Art: CraftPix.net (free license) · Fonts: Pixelify Sans & Nunito '
      '(SIL Open Font License) · Made with Flutter',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
