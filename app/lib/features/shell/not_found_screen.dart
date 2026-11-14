import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    this.message = 'This path leads nowhere on the farm.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost?')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(Routes.farm),
                child: const Text('Back to farm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
