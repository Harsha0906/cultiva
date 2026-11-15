import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/text.dart';
import '../../core/theme/tokens.dart';
import '../../core/ui/pixel_art.dart';
import '../../core/ui/pixel_icon.dart';

/// Bottom-nav shell: Farm · Tasks · Shop · Progress.
/// Each tab keeps its own navigation history (StatefulShellRoute.indexedStack).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: PixelNavBar(
        currentIndex: shell.currentIndex,
        onSelect: (i) => shell.goBranch(
          i,
          // Re-tapping the active tab returns it to its root.
          initialLocation: i == shell.currentIndex,
        ),
      ),
    );
  }
}

class PixelNavBar extends StatelessWidget {
  const PixelNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const tabs = [
    (icon: PixelIcons.farm, label: 'Farm'),
    (icon: PixelIcons.tasks, label: 'Tasks'),
    (icon: PixelIcons.shop, label: 'Shop'),
    (icon: PixelIcons.progress, label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CultivaColors.woodDark,
        border: Border(
          top: BorderSide(
            color: Color(0xFF46332A),
            width: 2 * PixelArt.uiScale,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.xs,
            vertical: Space.sm,
          ),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: tabs[i].icon,
                    label: tabs[i].label,
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final PixelIcons icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _cream = Color(0xFFE9D7B5);

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : _cream;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label tab',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 34,
                alignment: Alignment.center,
                decoration: selected
                    ? const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('${PixelArt.ui}/btn_primary.png'),
                          centerSlice: Rect.fromLTWH(8, 8, 8, 8),
                          scale: 1 / PixelArt.uiScale,
                          filterQuality: FilterQuality.none,
                        ),
                      )
                    : null,
                child: Padding(
                  padding: EdgeInsets.only(bottom: selected ? 4 : 0),
                  child: PixelIcon(icon, color: fg, scale: 1.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: kPixelFont,
                  fontSize: 13,
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
