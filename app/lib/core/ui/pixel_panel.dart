import 'package:material_ui/material_ui.dart';

import 'pixel_art.dart';

enum PanelStyle { paper, wood }

/// Kraft-paper (or wood) 9-slice surface with a stitched border.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.style = PanelStyle.paper,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final PanelStyle style;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('${PixelArt.ui}/panel_${style.name}.png'),
          centerSlice: const Rect.fromLTWH(8, 8, 8, 8),
          scale: 1 / PixelArt.uiScale,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
