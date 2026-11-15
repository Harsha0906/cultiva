import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/ui/crop_sprite.dart';
import '../../data/stats_service.dart';
import 'mood_and_note.dart';
import 'progress_view.dart';

/// Details of one past (or today's) day, with editable mood + note.
Future<void> showDaySheet(BuildContext context, DaySummary s) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: CultivaColors.paperDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      side: BorderSide(color: CultivaColors.woodDark, width: 3),
    ),
    builder: (context) {
      final t = Theme.of(context).textTheme;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formatDay(s.day), style: t.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(autoLogLine(s), style: t.bodyMedium),
              const SizedBox(height: Space.md),
              if (s.done.isEmpty)
                Text('No tasks completed this day.', style: t.bodySmall)
              else
                for (final d in s.done)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 48,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: CropSprite(d.crop, frame: 3, scale: 1),
                          ),
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(child: Text(d.title, style: t.bodyLarge)),
                        Text(
                          d.harvested ? 'Harvested' : 'Ripe',
                          style: t.bodySmall,
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: Space.md),
              MoodAndNote(day: s.day, mood: s.mood, note: s.note),
            ],
          ),
        ),
      );
    },
  );
}
