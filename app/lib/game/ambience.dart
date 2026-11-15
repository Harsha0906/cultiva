import 'dart:ui';

import '../domain/plant_engine.dart';
import '../features/farm/farm_view.dart';

/// Colour wash for the time of day, or null for none (daytime).
Color? tintFor(int hour) {
  if (hour >= 5 && hour < 8) return const Color(0x14FF9A3C); // dawn ~8%
  if (hour >= 8 && hour < 17) return null;
  if (hour >= 17 && hour < 20) return const Color(0x24FF7A5A); // evening ~14%
  return const Color(0x47203A78); // night ~28%
}

const _cozy = [
  'The soil smells like rain today.',
  'Small farm, focused day.',
  'One plant at a time. You got this.',
  'I tidied the path for you!',
  'Water, sun, and a little patience.',
];

/// What the capybara says, based on the farm right now.
/// [rotation] picks among cozy lines so taps don't repeat.
String capyTip(FarmView view, {int rotation = 0}) {
  if (view.plants.isEmpty) return 'Tap the soil to plant your first task.';
  final ripe = view.ripeCount;
  if (ripe > 0) {
    return ripe == 1
        ? 'A crop is ripe. Go harvest!'
        : '$ripe crops are ripe. Go harvest!';
  }
  final dormant = view.plants
      .where((p) => p.stage == PlantStage.dormant)
      .firstOrNull;
  if (dormant != null) {
    return 'Your ${dormant.task.title} plant misses you. Even 5 minutes helps.';
  }
  if (view.dueCount > 0 && view.doneCount == view.dueCount) {
    return 'Full basket! Rest those paws.';
  }
  return _cozy[rotation % _cozy.length];
}
