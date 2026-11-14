import 'package:material_ui/material_ui.dart';

/// Tasks tab. Placeholder until Phase 5.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _taps = 0; // proves tab state survives tab switches

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Center(
        child: TextButton(
          onPressed: () => setState(() => _taps++),
          child: Text('Tasks list arrives in Phase 5 · taps: $_taps'),
        ),
      ),
    );
  }
}
