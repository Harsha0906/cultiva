import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/providers.dart';
import '../../data/task_repository.dart';
import '../../domain/crops.dart';
import '../../domain/farm_day.dart';
import '../../domain/plant_engine.dart';
import '../../domain/task.dart';
import 'task_form_parts.dart';

/// Opens the "Plant a task" sheet. Returns the planted task, or null if dismissed.
Future<FarmTask?> showPlantTaskSheet(
  BuildContext context, {
  PlotKind? plot,
}) async {
  final task = await showModalBottomSheet<FarmTask>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: CultivaColors.paperDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      side: BorderSide(color: CultivaColors.woodDark, width: 3),
    ),
    builder: (_) => PlantTaskSheet(initialPlot: plot),
  );
  if (task != null && context.mounted) {
    await HapticFeedback.lightImpact();
    if (!context.mounted) return task;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
        backgroundColor: CultivaColors.ink,
        content: Text(
          '${task.title} planted in ${task.plot == PlotKind.daily ? 'Daily' : 'To-do & Habits'}',
          style: const TextStyle(fontFamily: kBodyFont, color: Colors.white),
        ),
      ),
    );
  }
  return task;
}

enum _BType { todo, habit }

class PlantTaskSheet extends ConsumerStatefulWidget {
  const PlantTaskSheet({super.key, this.initialPlot});
  final PlotKind? initialPlot;

  @override
  ConsumerState<PlantTaskSheet> createState() => _PlantTaskSheetState();
}

class _PlantTaskSheetState extends ConsumerState<PlantTaskSheet> {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  late PlotKind _plot = widget.initialPlot ?? PlotKind.daily;
  int? _minutes = 30;
  Weekdays _days = Weekdays.everyDay;
  _BType _bType = _BType.todo;
  String _crop = kCrops[Random().nextInt(kCrops.length)];

  bool _busy = false;
  Map<String, String> _errors = const {};
  String? _formError;
  Map<PlotKind, int> _counts = const {};

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final active = await ref.read(farmServiceProvider).tasks.active();
    if (!mounted) return;
    final counts = {
      for (final p in PlotKind.values)
        p: active.where((t) => t.plot == p).length,
    };
    setState(() {
      _counts = counts;
      // If the preselected plot is full, switch to the other one when it has room.
      if ((counts[_plot] ?? 0) >= kPlotCapacity) {
        final other = PlotKind.values.firstWhere((p) => p != _plot);
        if ((counts[other] ?? 0) < kPlotCapacity) _plot = other;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Weekdays get _repeat => _plot == PlotKind.daily
      ? _days
      : (_bType == _BType.habit ? _days : Weekdays.none);

  /// Field errors from the same rules the database enforces.
  Map<String, String> _validate() {
    final draft = FarmTask(
      id: 'draft',
      title: _name.text,
      plot: _plot,
      kind: _plot == PlotKind.daily ? TaskKind.timed : TaskKind.check,
      targetMinutes: _plot == PlotKind.daily ? (_minutes ?? 0) : null,
      repeat: _repeat,
      crop: _crop,
      slot: 0,
      createdDay: FarmDay(2026, 1, 1),
    );
    final errors = <String, String>{};
    for (final p in draft.problems) {
      if (p.contains('name')) {
        errors['name'] = p;
      } else if (p.contains('duration')) {
        errors['duration'] = p;
      } else if (p.contains('day')) {
        errors['days'] = p;
      } else {
        errors['form'] = p;
      }
    }
    if (_name.text.trim().length > 40) {
      errors['name'] = 'Keep it under 40 letters.';
    }
    if (_plot == PlotKind.todo && _bType == _BType.habit && _days.isEmpty) {
      errors['days'] = 'Pick at least one day.';
    }
    return errors;
  }

  Future<void> _submit() async {
    if (_busy) return;
    // Guard is taken synchronously, before any await: double taps plant once.
    setState(() {
      _busy = true;
      _formError = null;
    });
    final errors = _validate();
    if (errors.isNotEmpty) {
      setState(() {
        _busy = false;
        _errors = errors;
      });
      if (errors.containsKey('name')) _nameFocus.requestFocus();
      return;
    }
    try {
      final farm = ref.read(farmServiceProvider);
      final today = await farm.today();
      final task = await farm.tasks.plant(
        title: _name.text,
        plot: _plot,
        crop: _crop,
        today: today,
        targetMinutes: _plot == PlotKind.daily ? _minutes : null,
        repeat: _repeat,
      );
      if (!mounted) return;
      Navigator.of(context).pop(task);
    } on PlotFullException {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = 'That plot just filled up. Pick the other plot or remove a plant first.';
      });
      await _loadCounts();
    } on InvalidTaskException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
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
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: CultivaColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Expanded(child: Text('Plant a task', style: t.headlineSmall)),
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
              focusNode: _nameFocus,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              style: t.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g. Read, Walk, Pay the bill',
                filled: true,
                fillColor: CultivaColors.paper,
                border: const OutlineInputBorder(),
                errorText: _errors['name'],
              ),
              onChanged: (_) {
                if (_errors.containsKey('name')) {
                  setState(() => _errors = Map.of(_errors)..remove('name'));
                }
              },
            ),
            const FieldLabel('Plot'),
            Row(
              children: [
                for (final p in PlotKind.values) ...[
                  if (p != PlotKind.daily) const SizedBox(width: Space.sm),
                  Expanded(child: _plotChoice(p)),
                ],
              ],
            ),
            if (PlotKind.values.any((p) => (_counts[p] ?? 0) >= kPlotCapacity))
              const Padding(
                padding: EdgeInsets.only(top: Space.xs),
                child: Text(
                  'A full plot holds 6 plants. Remove one to plant more there.',
                  style: TextStyle(fontFamily: kBodyFont, fontSize: 13),
                ),
              ),
            if (_plot == PlotKind.daily) ...[
              const FieldLabel('How long?'),
              DurationPicker(
                minutes: _minutes,
                onChanged: (m) => setState(() {
                  _minutes = m;
                  _errors = Map.of(_errors)..remove('duration');
                }),
              ),
              FieldError(_errors['duration']),
              const FieldLabel('Which days?'),
              DayToggles(
                value: _days,
                onChanged: (d) => setState(() {
                  _days = d;
                  _errors = Map.of(_errors)..remove('days');
                }),
              ),
              FieldError(_errors['days']),
            ] else ...[
              const FieldLabel('Type'),
              Row(
                children: [
                  Expanded(
                    child: ChoicePixel(
                      label: 'To-do (once)',
                      selected: _bType == _BType.todo,
                      onTap: () => setState(() => _bType = _BType.todo),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: ChoicePixel(
                      label: 'Habit (repeats)',
                      selected: _bType == _BType.habit,
                      onTap: () => setState(() => _bType = _BType.habit),
                    ),
                  ),
                ],
              ),
              if (_bType == _BType.habit) ...[
                const FieldLabel('Which days?'),
                DayToggles(
                  value: _days,
                  onChanged: (d) => setState(() {
                    _days = d;
                    _errors = Map.of(_errors)..remove('days');
                  }),
                ),
                FieldError(_errors['days']),
              ],
            ],
            const FieldLabel('Crop'),
            CropPicker(
              value: _crop,
              onChanged: (c) => setState(() => _crop = c),
            ),
            const SizedBox(height: Space.lg),
            if (_formError != null) ...[
              FieldError(_formError),
              const SizedBox(height: Space.sm),
            ],
            PixelButton(
              label: 'Plant it',
              icon: PixelIcons.plus,
              expand: true,
              loading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _plotChoice(PlotKind p) {
    final count = _counts[p] ?? 0;
    final full = count >= kPlotCapacity;
    final name = p == PlotKind.daily ? 'Daily' : 'To-do / Habit';
    return ChoicePixel(
      label: full ? '$name · full' : '$name · $count/6',
      selected: _plot == p,
      onTap: full
          ? null
          : () => setState(() {
              _plot = p;
              _errors = const {};
            }),
    );
  }
}
