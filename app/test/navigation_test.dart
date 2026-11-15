import 'package:cultiva/app.dart';
import 'package:cultiva/core/router.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/data/settings_repository.dart';
import 'package:cultiva/features/shell/app_shell.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  String location = Routes.farm,
  bool onboarded = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbProvider.overrideWith((ref) {
          final db = CultivaDb(NativeDatabase.memory());
          SettingsRepository(db).setOnboarded(onboarded).ignore();
          ref.onDispose(db.close);
          return db;
        }),
        farmSceneEnabledProvider.overrideWith((_) => false),
      ],
      child: CultivaApp(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('starts on Farm with 4 labelled tabs', (tester) async {
    await pumpApp(tester);
    expect(find.text('Plant your first task'), findsOneWidget);
    for (final label in ['Farm', 'Tasks', 'Shop', 'Progress']) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('switching tabs shows each tab and comes back', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(find.text('Your plots are empty'), findsOneWidget);

    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(find.text('Your plots are empty'), findsOneWidget);
  });

  testWidgets('calendar button opens Progress calendar view', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Farm postcards'), findsOneWidget);
  });

  testWidgets('avatar opens Profile and back returns to Farm', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your avatar'), findsOneWidget);
    expect(find.byType(PixelNavBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Plant your first task'), findsOneWidget);
  });

  testWidgets('invalid focus id shows not-found with a way home', (
    tester,
  ) async {
    await pumpApp(tester, location: '/focus/bad%20id!');
    expect(find.text('Task not found.'), findsOneWidget);
    await tester.tap(find.text('Back to farm'));
    await tester.pumpAndSettle();
    expect(find.text('Plant your first task'), findsOneWidget);
  });

  testWidgets('first launch redirects to onboarding', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester, onboarded: false);
    expect(find.text('Grandma left you a little farm.'), findsOneWidget);
    expect(find.byType(PixelNavBar), findsNothing);
  });

  testWidgets('unknown route shows not-found', (tester) async {
    await pumpApp(tester, location: '/nowhere');
    expect(find.text('Back to farm'), findsOneWidget);
  });
}
