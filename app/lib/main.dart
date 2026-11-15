import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/notifications.dart';
import 'core/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifier = LocalNotifier();
  try {
    await notifier.init();
  } catch (e) {
    debugPrint('Notifications unavailable: $e');
  }
  runApp(
    ProviderScope(
      overrides: [notificationsProvider.overrideWithValue(notifier)],
      child: CultivaApp(initialLocation: notifier.launchRoute ?? Routes.farm),
    ),
  );
}
