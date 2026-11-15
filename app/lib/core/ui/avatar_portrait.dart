import 'package:material_ui/material_ui.dart';

import '../../domain/avatar.dart';
import 'pixel_art.dart';

/// 16x16 avatar portrait, integer-scaled with crisp pixels.
class AvatarPortrait extends StatelessWidget {
  const AvatarPortrait(this.avatar, {super.key, this.scale = PixelArt.uiScale});

  final Avatar avatar;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      avatar.asset,
      width: 16 * scale,
      height: 16 * scale,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      semanticLabel: '${avatar.animal.name} avatar',
    );
  }
}
