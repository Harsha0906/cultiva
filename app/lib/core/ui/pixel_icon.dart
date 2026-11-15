import 'package:material_ui/material_ui.dart';

import 'pixel_art.dart';

/// Names of the 16x16 tintable icons in assets/ui/icons/.
enum PixelIcons {
  farm,
  tasks,
  shop,
  progress,
  calendar,
  plus,
  play,
  check,
  timer,
  gear,
  lock,
  close,
  back,
}

/// A white pixel silhouette tinted to [color], drawn at an integer scale.
class PixelIcon extends StatelessWidget {
  const PixelIcon(
    this.icon, {
    super.key,
    this.color,
    this.scale = PixelArt.uiScale,
    this.semanticLabel,
  });

  final PixelIcons icon;
  final Color? color;
  final double scale;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? Colors.white;
    final size = 16 * scale;
    final image = Image.asset(
      '${PixelArt.icons}/${icon.name}.png',
      width: size,
      height: size,
      // Default fit is scaleDown, which never enlarges pixel art.
      fit: BoxFit.fill,
      color: tint,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.none,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
    );
    return image;
  }
}
