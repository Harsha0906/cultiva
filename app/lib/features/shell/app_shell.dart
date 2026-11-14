import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom-nav shell: Farm · Tasks · Shop · Progress.
/// Each tab keeps its own navigation history (StatefulShellRoute.indexedStack).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.grass_outlined, active: Icons.grass, label: 'Farm'),
    (icon: Icons.checklist_outlined, active: Icons.checklist, label: 'Tasks'),
    (icon: Icons.storefront_outlined, active: Icons.storefront, label: 'Shop'),
    (icon: Icons.insights_outlined, active: Icons.insights, label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          // Re-tapping the active tab returns it to its root.
          initialLocation: i == shell.currentIndex,
        ),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.active),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
