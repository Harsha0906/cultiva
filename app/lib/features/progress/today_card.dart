import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_panel.dart';
import '../../data/stats_service.dart';
import 'mood_and_note.dart';
import 'progress_view.dart';

/// Today's auto-log + mood + note.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.summary});
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nothing = summary.done.isEmpty && summary.focusMinutes == 0;
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Today · ${formatDay(summary.day)}',
              style: t.titleLarge,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            nothing
                ? 'Nothing logged yet. Your first harvest will show up here.'
                : autoLogLine(summary),
            style: t.bodyMedium,
          ),
          const SizedBox(height: Space.md),
          MoodAndNote(
            key: ValueKey('mood-${summary.day.key}'),
            day: summary.day,
            mood: summary.mood,
            note: summary.note,
          ),
        ],
      ),
    );
  }
}
