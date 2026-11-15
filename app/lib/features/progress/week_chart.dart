import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../data/stats_service.dart';

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String weekSummaryText(List<DaySummary> week) {
  final total = week.fold<int>(0, (s, d) => s + d.doneCount);
  final farmed = week.where((d) => d.doneCount > 0).length;
  if (total == 0) return 'This week: nothing done yet. Plant something small.';
  final best = week.reduce((a, b) => b.doneCount > a.doneCount ? b : a);
  return 'This week: $total done · best day ${_dayNames[best.day.weekday - 1]} '
      '(${best.doneCount}) · $farmed of 7 days farmed';
}

/// Tasks done per day for the last 7 days; today (last bar) in terracotta.
class WeekChart extends StatelessWidget {
  const WeekChart({super.key, required this.week});
  final List<DaySummary> week;

  @override
  Widget build(BuildContext context) {
    final summary = weekSummaryText(week);
    final maxY = week.fold<int>(0, (m, d) => d.doneCount > m ? d.doneCount : m);
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const label = TextStyle(
      fontFamily: kPixelFont,
      fontSize: 12,
      color: CultivaColors.inkSoft,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(summary, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Space.md),
        Semantics(
          label: summary,
          excludeSemantics: true,
          child: SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: (maxY < 4 ? 4 : maxY + 1).toDouble(),
                barTouchData: const BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: CultivaColors.line, width: 2),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= week.length) {
                          return const SizedBox.shrink();
                        }
                        return Text('${week[i].doneCount}', style: label);
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= week.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = i == week.length - 1;
                        return Text(
                          letters[week[i].day.weekday - 1],
                          style: label.copyWith(
                            color: isToday
                                ? CultivaColors.terracotta
                                : CultivaColors.inkSoft,
                            fontWeight: isToday ? FontWeight.w700 : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < week.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: week[i].doneCount.toDouble(),
                          width: 22,
                          color: i == week.length - 1
                              ? CultivaColors.terracotta
                              : CultivaColors.teal,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
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
