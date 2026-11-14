import 'package:material_ui/material_ui.dart';

import '../shell/not_found_screen.dart';

/// Focus Mode for one Plot A task. Placeholder until Phase 6.
class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key, required this.taskId});

  final String taskId;

  static final _validId = RegExp(r'^[A-Za-z0-9-]{1,64}$');

  @override
  Widget build(BuildContext context) {
    if (!_validId.hasMatch(taskId)) {
      return const NotFoundScreen(message: 'Task not found.');
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: Center(child: Text('Focus timer for task $taskId (Phase 6)')),
    );
  }
}
