import 'package:material_ui/material_ui.dart';

enum ProgressView {
  today,
  calendar;

  static ProgressView parse(String? raw) => ProgressView.values.firstWhere(
    (v) => v.name == raw,
    orElse: () => ProgressView.today,
  );
}

/// Progress tab (journal, charts, calendar). Placeholder until Phase 8.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, this.initialView = ProgressView.today});

  final ProgressView initialView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Center(
        child: Text(
          initialView == ProgressView.calendar
              ? 'Calendar view (Phase 8)'
              : 'Today & weekly progress (Phase 8)',
        ),
      ),
    );
  }
}
