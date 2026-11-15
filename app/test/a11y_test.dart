import 'package:cultiva/app.dart';
import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/core/router.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/features/dev/demo_seed.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Step 10.3: accessibility guidelines + large text on every main screen.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  final now = DateTime(2026, 11, 16, 9);

  setUp(() async {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
  });
  tearDown(() => db.close());

  Future<void> pumpAt(
    WidgetTester tester,
    Future<String> Function() route, {
    double textScale = 1,
    bool onboarded = true,
  }) async {
    // A typical small phone: 360 x 780 dp.
    tester.view.physicalSize = const Size(945, 2048);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    });
    var location = Routes.farm;
    await tester.runAsync(() async {
      await seedDemoFarm(farm);
      await farm.settings.setOnboarded(onboarded);
      location = await route();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          notificationsProvider.overrideWithValue(FakeNotifier()),
          farmSceneEnabledProvider.overrideWith((_) => false),
        ],
        child: CultivaApp(initialLocation: location),
      ),
    );
    await tester.pumpAndSettle();
    // Decode the 9-slice button/panel art so the contrast check sees real
    // backgrounds (test images otherwise stay blank).
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      for (final name in [
        for (final v in ['paper', 'primary', 'teal', 'wood']) ...[
          'btn_$v',
          'btn_${v}_pressed',
        ],
        'panel_paper',
        'panel_wood',
      ]) {
        await precacheImage(AssetImage('assets/ui/$name.png'), ctx);
      }
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await tester.pumpAndSettle();
  }

  Future<String> focusRoute() async {
    final tasks = await farm.tasks.active();
    return Routes.focus(tasks.firstWhere((t) => t.title == 'Meditate').id);
  }

  final screens = <String, Future<String> Function()>{
    'Farm': () async => Routes.farm,
    'Tasks': () async => Routes.tasks,
    'Shop': () async => Routes.shop,
    'Progress': () async => Routes.progress,
    'Calendar': () async => Routes.calendar,
    'Profile': () async => Routes.profile,
    'Focus': () => focusRoute(),
    'Onboarding': () async => Routes.onboarding,
  };

  for (final MapEntry(key: name, value: route) in screens.entries) {
    testWidgets('$name meets tap-target, label and contrast guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpAt(tester, route);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('$name has no overflow at 2x text on a 360dp phone', (
      tester,
    ) async {
      await pumpAt(tester, route, textScale: 2);
      // Any RenderFlex overflow is reported by the framework and fails here.
      expect(find.byType(Scaffold), findsWidgets);
    });
  }
}
