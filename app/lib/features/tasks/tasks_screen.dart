import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_prefs.dart';
import '../../core/router.dart';
import '../../core/sfx.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/crop_sprite.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/farm_service.dart';
import '../../data/providers.dart';
import '../../domain/plant_engine.dart';
import '../../domain/task.dart';
import '../farm/farm_view.dart';
import 'edit_task_sheet.dart';
import 'plant_task_sheet.dart';
import 'task_form_parts.dart';

/// Tasks tab: today's tasks grouped by plot, with one visible action per row.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(farmViewProvider).value;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Space.md),
            child: PixelIconButton(
              semanticLabel: 'Plant a task',
              icon: PixelIcons.plus,
              variant: PixelButtonVariant.primary,
              onPressed: () => showPlantTaskSheet(context),
            ),
          ),
        ],
      ),
      body: view == null
          ? const SizedBox.shrink()
          : view.plants.isEmpty
          ? _Empty(onPlant: () => showPlantTaskSheet(context))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.md,
                Space.lg,
                Space.xxl,
              ),
              children: [
                for (final plot in PlotKind.values) ...[
                  _SectionHeader(view: view, plot: plot),
                  for (final p in view.inPlot(
                    plot,
                  )..sort((a, b) => a.task.slot.compareTo(b.task.slot)))
                    _TaskRow(plant: p),
                  if (view.inPlot(plot).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.sm),
                      child: Text(
                        plot == PlotKind.daily
                            ? 'No daily tasks yet.'
                            : 'No to-dos or habits yet.',
                        style: t.bodySmall,
                      ),
                    ),
                  const SizedBox(height: Space.lg),
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.view, required this.plot});
  final FarmView view;
  final PlotKind plot;

  @override
  Widget build(BuildContext context) {
    final count = view.inPlot(plot).length;
    final name = plot == PlotKind.daily ? 'Daily' : 'To-do & Habits';
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      // Wraps the button under the title at large text sizes.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              '$name  $count/$kPlotCapacity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (count < kPlotCapacity)
            TextButton(
              onPressed: () => showPlantTaskSheet(context, plot: plot),
              child: const Text(
                '+ Plant here',
                style: TextStyle(
                  fontFamily: kPixelFont,
                  color: CultivaColors.tealDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.plant});
  final PlantView plant;

  String get _subtitle {
    final t = plant.task;
    final base = t.plot == PlotKind.daily
        ? '${t.targetMinutes} min · ${describeRepeat(t.repeat)}'
        : (t.isTodo ? 'To-do' : 'Habit · ${describeRepeat(t.repeat)}');
    final status = switch (plant.stage) {
      PlantStage.dormant => ' · Dormant',
      PlantStage.resting => ' · Resting today',
      PlantStage.ripe => ' · Ripe',
      PlantStage.harvested => ' · Harvested',
      _ => '',
    };
    return base + status;
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultivaColors.ink,
        duration: const Duration(seconds: 2),
        content: Text(
          msg,
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _act(BuildContext context, WidgetRef ref) async {
    final farm = ref.read(farmServiceProvider);
    final task = plant.task;
    try {
      switch (plant.stage) {
        case PlantStage.ripe:
          final coins = await farm.harvest(task);
          unawaited(AppFeedback.medium());
          Sfx.play(SfxName.harvest);
          if (context.mounted) {
            _toast(context, '+$coins coins from ${task.title}');
          }
        case PlantStage.seed ||
            PlantStage.sprout ||
            PlantStage.young ||
            PlantStage.dormant:
          if (task.plot == PlotKind.daily) {
            await context.push(Routes.focus(task.id));
          } else {
            await farm.complete(task);
            unawaited(AppFeedback.light());
            Sfx.play(SfxName.ripen);
          }
        case PlantStage.harvested || PlantStage.resting:
          break;
      }
    } on FarmActionException catch (e) {
      if (context.mounted) _toast(context, e.message);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final outcome = await showEditTaskSheet(context, plant);
    if (!context.mounted || outcome != EditOutcome.removed) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final farm = ref.read(farmServiceProvider);
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CultivaColors.ink,
        content: Text(
          '${plant.task.title} removed',
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: CultivaColors.gold,
          onPressed: () => farm.tasks.restore(plant.task.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final action = switch (plant.stage) {
      PlantStage.ripe => ('Harvest', PixelButtonVariant.primary, null),
      PlantStage.harvested => (
        null,
        PixelButtonVariant.paper,
        PixelIcons.check,
      ),
      PlantStage.resting => ('Rest day', PixelButtonVariant.paper, null),
      _ =>
        plant.task.plot == PlotKind.daily
            ? ('Start', PixelButtonVariant.teal, PixelIcons.play)
            : ('Done', PixelButtonVariant.teal, PixelIcons.check),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Material(
        color: CultivaColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: CultivaColors.line, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _edit(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 60,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: plant.stage == PlantStage.resting ? 0.6 : 1,
                      child: CropSprite(
                        plant.task.crop,
                        frame: cropFrame(plant.stage),
                        scale: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Semantics(
                    hint: 'Double tap to edit',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.task.title,
                          style: t.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(_subtitle, style: t.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                if (action.$1 == null)
                  const Padding(
                    padding: EdgeInsets.all(Space.sm),
                    child: PixelIcon(
                      PixelIcons.check,
                      color: CultivaColors.teal,
                      semanticLabel: 'Harvested',
                    ),
                  )
                else
                  // Capped so the task name keeps room at large text sizes
                  // (the label wraps inside the button instead).
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 132),
                    child: PixelButton(
                      label: action.$1!,
                      icon: action.$3,
                      variant: action.$2,
                      onPressed: plant.stage == PlantStage.resting
                          ? null
                          : () => _act(context, ref),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onPlant});
  final VoidCallback onPlant;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CropSprite('pepper', frame: 1, scale: 3),
            const SizedBox(height: Space.lg),
            Text('Your plots are empty', style: t.titleLarge),
            const SizedBox(height: Space.xs),
            Text(
              'Plant a task to start growing.',
              style: t.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.lg),
            PixelButton(
              label: 'Plant a task',
              icon: PixelIcons.plus,
              onPressed: onPlant,
            ),
          ],
        ),
      ),
    );
  }
}
