import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/farm_service.dart';
import '../../data/providers.dart';
import '../../data/task_repository.dart';
import '../../domain/plant_engine.dart';
import '../../domain/task.dart';
import 'task_form_parts.dart';

/// Result of the edit sheet so the caller can show the right message.
enum EditOutcome { saved, removed, undone }

Future<EditOutcome?> showEditTaskSheet(BuildContext context, PlantView plant) {
  return showModalBottomSheet<EditOutcome>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: CultivaColors.paperDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      side: BorderSide(color: CultivaColors.woodDark, width: 3),
    ),
    builder: (_) => EditTaskSheet(plant: plant),
  );
}

class EditTaskSheet extends ConsumerStatefulWidget {
  const EditTaskSheet({super.key, required this.plant});
  final PlantView plant;

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  FarmTask get _task => widget.plant.task;
  late final _name = TextEditingController(text: _task.title);
  late String _crop = _task.crop;
  late int? _minutes = _task.targetMinutes;
  late Weekdays _days = _task.repeat;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<EditOutcome> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outcome = await action();
      if (mounted) Navigator.of(context).pop(outcome);
    } on InvalidTaskException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } on FarmActionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on PlotFullException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<EditOutcome> _save() async {
    await ref
        .read(farmServiceProvider)
        .tasks
        .update(
          _task,
          title: _name.text,
          crop: _crop,
          targetMinutes: _task.plot == PlotKind.daily ? _minutes : null,
          repeat: _days,
        );
    return EditOutcome.saved;
  }

  Future<EditOutcome> _undo() async {
    final farm = ref.read(farmServiceProvider);
    if (widget.plant.stage == PlantStage.harvested) {
      await farm.unharvest(_task);
    } else {
      await farm.uncomplete(_task);
    }
    return EditOutcome.undone;
  }

  Future<void> _remove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CultivaColors.paper,
        title: Text('Remove ${_task.title}?'),
        content: const Text(
          'The plant leaves your farm. Its history stays in your journal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() async {
      await ref.read(farmServiceProvider).tasks.archive(_task.id);
      return EditOutcome.removed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stage = widget.plant.stage;
    final canUndo = stage == PlantStage.ripe || stage == PlantStage.harvested;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.md,
          Space.lg,
          Space.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text('Edit task', style: t.headlineSmall)),
                PixelIconButton(
                  semanticLabel: 'Close',
                  icon: PixelIcons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const FieldLabel('Task name'),
            TextField(
              controller: _name,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              style: t.bodyLarge,
              decoration: const InputDecoration(
                filled: true,
                fillColor: CultivaColors.paper,
                border: OutlineInputBorder(),
              ),
            ),
            if (_task.plot == PlotKind.daily) ...[
              const FieldLabel('How long?'),
              DurationPicker(
                minutes: _minutes,
                onChanged: (m) => setState(() => _minutes = m),
              ),
            ],
            if (!_task.isTodo) ...[
              const FieldLabel('Which days?'),
              DayToggles(
                value: _days,
                onChanged: (d) => setState(() => _days = d),
              ),
            ],
            const FieldLabel('Crop'),
            CropPicker(
              value: _crop,
              onChanged: (c) => setState(() => _crop = c),
            ),
            const SizedBox(height: Space.lg),
            if (_error != null) ...[
              FieldError(_error),
              const SizedBox(height: Space.sm),
            ],
            PixelButton(
              label: 'Save',
              expand: true,
              loading: _busy,
              onPressed: () => _run(_save),
            ),
            if (canUndo) ...[
              const SizedBox(height: Space.sm),
              PixelButton(
                label: stage == PlantStage.harvested
                    ? 'Undo today\'s harvest'
                    : 'Undo today\'s completion',
                variant: PixelButtonVariant.wood,
                expand: true,
                onPressed: _busy ? null : () => _run(_undo),
              ),
            ],
            const SizedBox(height: Space.sm),
            PixelButton(
              label: 'Remove from farm',
              variant: PixelButtonVariant.paper,
              expand: true,
              onPressed: _busy ? null : _remove,
            ),
            const SizedBox(height: Space.xs),
            Text(
              'Removing keeps your history.',
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(fontFamily: kBodyFont),
            ),
          ],
        ),
      ),
    );
  }
}
