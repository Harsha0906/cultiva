/// Crops players can plant (cosmetic). Frame heights match the generated strips
/// in assets/sprites/pack/crops/ (see tools/art/build_pack_assets.py).
const kCropFrameHeights = <String, int>{
  'pepper': 32,
  'pumpkin': 29,
  'grape': 39,
  'wheat': 30,
  'squash': 31,
  'cauliflower': 19,
  'peas': 36,
  'lettuce': 18,
  'bean': 39,
};

List<String> get kCrops => kCropFrameHeights.keys.toList();

String cropLabel(String crop) =>
    crop.isEmpty ? crop : crop[0].toUpperCase() + crop.substring(1);
