import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/crop_sprite.dart';
import '../../core/ui/pixel_button.dart';
import '../../domain/crops.dart';
import '../../domain/task.dart';

/// Shared pieces of the plant/edit task forms.

const kErrorInk = Color(0xFF8A3A20);

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Space.lg, bottom: Space.sm),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key});
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Space.xs),
      child: Semantics(
        liveRegion: true,
        child: Text(
          '! $text',
          style: const TextStyle(
            fontFamily: kBodyFont,
            fontWeight: FontWeight.w700,
            color: kErrorInk,
          ),
        ),
      ),
    );
  }
}

/// A selectable pixel chip (teal when selected).
class ChoicePixel extends StatelessWidget {
  const ChoicePixel({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    inMutuallyExclusiveGroup: true,
    child: PixelButton(
      label: semanticLabel == null ? label : label,
      variant: selected ? PixelButtonVariant.teal : PixelButtonVariant.paper,
      onPressed: onTap,
    ),
  );
}

const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class DayToggles extends StatelessWidget {
  const DayToggles({super.key, required this.value, required this.onChanged});

  final Weekdays value;
  final ValueChanged<Weekdays> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              label: dayNames[i],
              selected: value.has(i + 1),
              button: true,
              excludeSemantics: true,
              child: PixelButton(
                label: _dayLetters[i],
                variant: value.has(i + 1)
                    ? PixelButtonVariant.teal
                    : PixelButtonVariant.paper,
                onPressed: () => onChanged(Weekdays(value.mask ^ (1 << i))),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String describeRepeat(Weekdays w) {
  if (w.isEmpty) return 'Once';
  if (w.mask == Weekdays.everyDay.mask) return 'Every day';
  if (w.mask == 0x1f) return 'Weekdays';
  if (w.mask == 0x60) return 'Weekends';
  const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return w.days.map((d) => short[d - 1]).join(' · ');
}

class CropPicker extends StatelessWidget {
  const CropPicker({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final crop in kCrops)
          Semantics(
            button: true,
            selected: crop == value,
            label: cropLabel(crop),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onChanged(crop),
              child: Container(
                width: 64,
                height: 72,
                decoration: BoxDecoration(
                  color: CultivaColors.paper,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: crop == value
                        ? CultivaColors.teal
                        : CultivaColors.line,
                    width: crop == value ? 3 : 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: CropSprite(crop, scale: 1.5),
                      ),
                    ),
                    if (crop == value)
                      const Positioned(
                        right: 2,
                        top: 2,
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: CultivaColors.teal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const durationChoices = [5, 15, 30, 45, 60];

class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  final int? minutes;
  final ValueChanged<int?> onChanged;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late bool _custom =
      widget.minutes != null && !durationChoices.contains(widget.minutes);
  late final _ctrl = TextEditingController(
    text: _custom ? '${widget.minutes}' : '',
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final m in durationChoices)
              ChoicePixel(
                label: '$m min',
                selected: !_custom && widget.minutes == m,
                onTap: () {
                  setState(() => _custom = false);
                  widget.onChanged(m);
                },
              ),
            ChoicePixel(
              label: 'Custom',
              selected: _custom,
              onTap: () {
                setState(() => _custom = true);
                widget.onChanged(int.tryParse(_ctrl.text));
              },
            ),
          ],
        ),
        if (_custom)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: SizedBox(
              width: 180,
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Minutes (1–240)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => widget.onChanged(int.tryParse(v.trim())),
              ),
            ),
          ),
      ],
    );
  }
}
