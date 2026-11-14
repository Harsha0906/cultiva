import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';

class CultivaApp extends StatefulWidget {
  const CultivaApp({super.key, this.initialLocation = Routes.farm});

  final String initialLocation;

  @override
  State<CultivaApp> createState() => _CultivaAppState();
}

class _CultivaAppState extends State<CultivaApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cultiva',
      debugShowCheckedModeBanner: false,
      theme: buildCultivaTheme(),
      routerConfig: _router,
    );
  }
}
