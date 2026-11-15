import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router.dart';
import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_button.dart';
import '../../core/ui/pixel_icon.dart';

/// Farm (home). Placeholder until Phase 4 adds the Flame scene.
class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF96C55F),
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
  const FarmHeader({
    super.key,
    this.coins = 0,
    this.done = 0,
    this.total = 0,
    this.avatar,
  });

  final int coins;
  final int done;
  final int total;

  /// Player avatar portrait; falls back to a neutral icon until one is chosen.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().day;
    return Container(
      color: CultivaColors.tealDark,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      child: Row(
        children: [
          PixelIconButton(
            semanticLabel: 'Profile',
            onPressed: () => context.push(Routes.profile),
            child:
                avatar ??
                const PixelIcon(PixelIcons.gear, color: CultivaColors.woodDark),
          ),
          const Spacer(),
          Semantics(
            label: '$coins coins, $done of $total tasks done today',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/sprites/cultiva/fx/coin.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    filterQuality: FilterQuality.none,
                  ),
                  const SizedBox(width: Space.xs),
                  Text('$coins', style: _pill),
                  const SizedBox(width: Space.md),
                  Text('$done/$total today', style: _pill),
                ],
              ),
            ),
          ),
          const Spacer(),
          PixelIconButton(
            semanticLabel: 'Calendar',
            onPressed: () => context.go(Routes.calendar),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _months[DateTime.now().month - 1],
                  style: const TextStyle(
                    fontFamily: kPixelFont,
                    fontSize: 9,
                    color: CultivaColors.terracotta,
                    height: 1,
                  ),
                ),
                Text(
                  '$day',
                  style: const TextStyle(
                    fontFamily: kPixelFont,
                    fontSize: 18,
                    color: CultivaColors.ink,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _pill = TextStyle(
    fontFamily: kPixelFont,
    fontSize: 15,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
}
