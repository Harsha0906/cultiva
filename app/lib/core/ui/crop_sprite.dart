import 'package:material_ui/material_ui.dart';

import '../../domain/crops.dart';
import '../../domain/plant_engine.dart';

/// Strip frame for a stage (strips are seed·sprout·young·ripe·dormant).
int cropFrame(PlantStage stage) => switch (stage) {
  PlantStage.seed || PlantStage.harvested => 0,
  PlantStage.sprout || PlantStage.resting => 1,
  PlantStage.young => 2,
  PlantStage.ripe => 3,
  PlantStage.dormant => 4,
};

/// One frame of a crop strip, integer-scaled with crisp pixels.
class CropSprite extends StatelessWidget {
  const CropSprite(this.crop, {super.key, this.frame = 3, this.scale = 1.5});

  final String crop;
  final int frame;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final h = (kCropFrameHeights[crop] ?? 32) * scale;
    final w = 32 * scale;
    return SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: w * 5,
          maxWidth: w * 5,
          minHeight: h,
          maxHeight: h,
          child: Transform.translate(
            offset: Offset(-frame * w, 0),
            child: Image.asset(
              'assets/sprites/pack/crops/$crop.png',
              width: w * 5,
              height: h,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
