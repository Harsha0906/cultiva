import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/barn/barn_screen.dart';
import '../features/dev/kit_gallery_screen.dart';
import '../features/farm/farm_screen.dart';
import '../features/focus/focus_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/not_found_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/tasks/tasks_screen.dart';

/// Central route paths. Build paths with these helpers, never with string literals.
abstract final class Routes {
  static const farm = '/farm';
  static const tasks = '/tasks';
  static const shop = '/shop';
  static const progress = '/progress';
  static const profile = '/profile';
  static const calendar = '/progress?view=calendar';
  static String focus(String taskId) => '/focus/${Uri.encodeComponent(taskId)}';
  static const devKit = '/dev/kit';
  static const barn = '/barn';
  static const onboarding = '/onboarding';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// [onboarded] reports whether first-launch onboarding is done; while it is
/// not, every route (except debug tools) redirects to [Routes.onboarding].
GoRouter buildRouter({
  String initialLocation = Routes.farm,
  Future<bool> Function()? onboarded,
}) {
  var known = onboarded == null;
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: initialLocation,
    redirect: (context, state) async {
      if (known) return null;
      final path = state.uri.path;
      if (path == Routes.onboarding || path.startsWith('/dev')) return null;
      known = await onboarded!();
      return known ? null : Routes.onboarding;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.farm, builder: (_, _) => const FarmScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tasks,
                builder: (_, _) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (_, state) => ProgressScreen(
                  initialView: ProgressView.parse(
                    state.uri.queryParameters['view'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(
          path: Routes.devKit,
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const KitGalleryScreen(),
        ),
      GoRoute(
        path: Routes.barn,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BarnScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/focus/:taskId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            FocusScreen(taskId: state.pathParameters['taskId'] ?? ''),
      ),
      GoRoute(
        path: Routes.onboarding,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const OnboardingScreen(),
      ),
    ],
  );
}
