import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_icon.dart';
import '../../data/stats_service.dart';
import '../../domain/farm_day.dart';
import 'day_sheet.dart';
import 'progress_view.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Grass tint by tasks done: pale -> rich green.
Color postcardTint(int done) => switch (done) {
  0 => const Color(0xFFE6DCC4),
  1 || 2 => const Color(0xFFC8E0A0),
  3 || 4 => const Color(0xFF96C55F),
  _ => const Color(0xFF5E9E44),
};

const moodColors = [
  Color(0xFF8A7CA8), // rough
  Color(0xFF9AA5B1), // meh
  Color(0xFFE8C46A), // okay
  Color(0xFF7FC08A), // good
  Color(0xFFE58A62), // great
];

/// Month grid of "farm postcards"; tap a day for its details.
class CalendarPostcards extends ConsumerStatefulWidget {
  const CalendarPostcards({super.key, required this.today});
  final FarmDay today;

  @override
  ConsumerState<CalendarPostcards> createState() => _CalendarPostcardsState();
}

class _CalendarPostcardsState extends ConsumerState<CalendarPostcards> {
  late int _year = widget.today.year;
  late int _month = widget.today.month;

  bool get _isCurrent =>
      _year == widget.today.year && _month == widget.today.month;

  void _shift(int delta) {
    setState(() {
      _month += delta;
      if (_month < 1) {
        _month = 12;
        _year--;
      } else if (_month > 12) {
        _month = 1;
        _year++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(monthProvider((_year, _month))).value ?? const [];
    final byDay = {for (final d in days) d.day.day: d};
    final first = FarmDay(_year, _month, 1);
    final blanks = first.weekday - 1;
    final count = DateUtils.getDaysInMonth(_year, _month);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => _shift(-1),
              icon: const PixelIcon(PixelIcons.back, color: CultivaColors.ink),
            ),
            Expanded(
              child: Text(
                '${_months[_month - 1]} $_year',
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: _isCurrent ? null : () => _shift(1),
              icon: Transform.flip(
                flipX: true,
                child: PixelIcon(
                  PixelIcons.back,
                  color: _isCurrent ? CultivaColors.line : CultivaColors.ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.xs),
        Row(
          children: [
            for (final l in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: kPixelFont,
                    color: CultivaColors.inkSoft,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.85,
          children: [
            for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
            for (var d = 1; d <= count; d++)
              _Postcard(
                day: FarmDay(_year, _month, d),
                summary: byDay[d],
                isToday: _isCurrent && d == widget.today.day,
              ),
          ],
        ),
      ],
    );
  }
}

class _Postcard extends StatelessWidget {
  const _Postcard({
    required this.day,
    required this.summary,
    required this.isToday,
  });
  final FarmDay day;
  final DaySummary? summary;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    if (s == null) {
      // Future day: blank, not tappable.
      return Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(
            fontFamily: kPixelFont,
            color: CultivaColors.line,
          ),
        ),
      );
    }
    final label =
        '${formatDay(day)}: ${s.doneCount} done'
        '${s.mood != null ? ', felt ${moodLabels[s.mood! - 1]}' : ''}';
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => showDaySheet(context, s),
        child: Container(
          decoration: BoxDecoration(
            color: postcardTint(s.doneCount),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isToday ? CultivaColors.terracotta : CultivaColors.line,
              width: isToday ? 3 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Stack(
            children: [
              Text(
                '${day.day}',
                style: const TextStyle(
                  fontFamily: kPixelFont,
                  fontSize: 11,
                  color: CultivaColors.ink,
                ),
              ),
              if (s.doneCount > 0)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PixelIcon(
                        PixelIcons.farm,
                        color: CultivaColors.woodDark,
                        scale: 0.75,
                      ),
                      Text(
                        '${s.doneCount}',
                        style: const TextStyle(
                          fontFamily: kPixelFont,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              if (s.mood != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: moodColors[s.mood! - 1],
                      shape: BoxShape.circle,
                      border: Border.all(color: CultivaColors.ink, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
