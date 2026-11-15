import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../data/providers.dart';
import '../../domain/farm_day.dart';
import 'progress_view.dart';

/// Mood chips + one-line note for a day. Saves immediately (mood) or on
/// Done / leaving the field (note). Used by the Today card and the day sheet.
class MoodAndNote extends ConsumerStatefulWidget {
  const MoodAndNote({
    super.key,
    required this.day,
    required this.mood,
    required this.note,
  });

  final FarmDay day;
  final int? mood;
  final String? note;

  @override
  ConsumerState<MoodAndNote> createState() => _MoodAndNoteState();
}

class _MoodAndNoteState extends ConsumerState<MoodAndNote> {
  late final _note = TextEditingController(text: widget.note ?? '');
  final _focus = FocusNode();
  bool _saved = false;
  late int? _mood = widget.mood;

  @override
  void didUpdateWidget(MoodAndNote old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _mood = widget.mood;
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _saveNote();
    });
  }

  @override
  void dispose() {
    _note.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final text = _note.text.trim();
    if (text == (widget.note ?? '')) return;
    await ref.read(journalRepositoryProvider).upsert(widget.day, note: text);
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _setMood(int mood) async {
    final repo = ref.read(journalRepositoryProvider);
    final clearing = _mood == mood;
    setState(() => _mood = clearing ? null : mood);
    if (clearing) {
      await repo.clearMood(widget.day); // tap the selected mood again to clear
    } else {
      await repo.upsert(widget.day, mood: mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('How did it feel?', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            for (var i = 0; i < moodLabels.length; i++)
              Semantics(
                selected: _mood == i + 1,
                child: PixelButton(
                  label: moodLabels[i],
                  variant: _mood == i + 1
                      ? PixelButtonVariant.teal
                      : PixelButtonVariant.paper,
                  onPressed: () => _setMood(i + 1),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        TextField(
          controller: _note,
          focusNode: _focus,
          maxLength: 140,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveNote(),
          onChanged: (_) {
            if (_saved) setState(() => _saved = false);
          },
          style: const TextStyle(fontFamily: kBodyFont, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'One line about the day',
            hintText: 'How did today go?',
            filled: true,
            fillColor: CultivaColors.paper,
            border: const OutlineInputBorder(),
            helperText: _saved ? 'Saved' : null,
          ),
        ),
      ],
    );
  }
}
