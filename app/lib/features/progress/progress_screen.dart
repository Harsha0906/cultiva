import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_panel.dart';
import 'calendar_postcards.dart';
import 'progress_view.dart';
import 'today_card.dart';
import 'week_chart.dart';

enum ProgressView {
  today,
  calendar;

  static ProgressView parse(String? raw) => ProgressView.values.firstWhere(
    (v) => v.name == raw,
    orElse: () => ProgressView.today,
  );
}

/// Progress tab: today's journal card, weekly chart, calendar of postcards.
/// The header's calendar button opens it scrolled to the calendar.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key, this.initialView = ProgressView.today});

  final ProgressView initialView;

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final _calendarKey = GlobalKey();
  bool _scrolled = false;

  @override
  void didUpdateWidget(ProgressScreen old) {
    super.didUpdateWidget(old);
    if (old.initialView != widget.initialView) _scrolled = false;
  }

  void _maybeScroll() {
    if (_scrolled || widget.initialView != ProgressView.calendar) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _calendarKey.currentContext;
      if (ctx == null) return;
      _scrolled = true;
      Scrollable.ensureVisible(
        ctx,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todaySummaryProvider);
    if (todayAsync.hasError) {
      debugPrint(
        'Progress failed: ${todayAsync.error}\n${todayAsync.stackTrace}',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Couldn't load your progress."),
                const SizedBox(height: Space.md),
                TextButton(
                  onPressed: () => ref.invalidate(todaySummaryProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final today = todayAsync.value;
    final week = ref.watch(weekProvider).value;
    final day = ref.watch(todayProvider).value;
    final t = Theme.of(context).textTheme;
    _maybeScroll();
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      // A Column (not a lazy ListView) so the calendar exists to scroll to.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (today != null) TodayCard(summary: today),
            const SizedBox(height: Space.xl),
            Semantics(
              header: true,
              child: Text('This week', style: t.titleMedium),
            ),
            const SizedBox(height: Space.sm),
            if (week != null) WeekChart(week: week),
            const SizedBox(height: Space.xl),
            Semantics(
              header: true,
              child: Text(
                'Farm postcards',
                key: _calendarKey,
                style: t.titleMedium,
              ),
            ),
            const SizedBox(height: Space.sm),
            if (day != null)
              PixelPanel(
                padding: const EdgeInsets.all(Space.sm),
                child: CalendarPostcards(today: day),
              ),
            const SizedBox(height: Space.xxl),
          ],
        ),
      ),
    );
  }
}
