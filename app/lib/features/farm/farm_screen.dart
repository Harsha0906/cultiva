import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router.dart';
import '../../core/theme/tokens.dart';

/// Farm (home). Placeholder until Phase 4 adds the Flame scene.
class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CultivaColors.grass,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FarmHeader(),
            Expanded(
              child: Center(
                child: Text(
                  'Farm scene arrives in Phase 4',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header: avatar (→ Profile) · coins/progress pill · calendar (→ Progress calendar).
class FarmHeader extends StatelessWidget {
  const FarmHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CultivaColors.tealDark,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      child: Row(
        children: [
          _HeaderButton(
            semanticLabel: 'Profile',
            onTap: () => context.push(Routes.profile),
            child: const Icon(Icons.pets, color: CultivaColors.woodDark),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: Space.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '● 0   |   0/0 today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          _HeaderButton(
            semanticLabel: 'Calendar',
            onTap: () => context.go(Routes.calendar),
            child: const Icon(
              Icons.calendar_month,
              color: CultivaColors.terracotta,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: CultivaColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: CultivaColors.woodDark, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox.square(
            dimension: kMinTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
