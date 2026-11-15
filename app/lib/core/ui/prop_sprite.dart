import 'package:material_ui/material_ui.dart';

/// A whole pack sprite (decoration) drawn crisply at an integer scale.
class PropSprite extends StatelessWidget {
  const PropSprite(this.asset, {super.key, this.scale = 2});

  final String asset;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      scale: 1 / scale,
      filterQuality: FilterQuality.none,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => const SizedBox(width: 32, height: 32),
    );
  }
}
