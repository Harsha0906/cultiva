import 'package:cultiva/app.dart';
import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/core/sfx.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/domain/avatar.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/onboarding/onboarding_screen.dart';
import 'package:cultiva/features/shell/app_shell.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  late FakeSfxPlayer sfx;
  final now = DateTime(2026, 11, 16, 9);

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
    sfx = FakeSfxPlayer();
    Sfx.player = sfx;
    Sfx.enabled = true;
  });
  tearDown(() async {
    Sfx.player = const SilentSfxPlayer();
    await db.close();
  });

  Future<void> pump(WidgetTester tester, AppNotifier notifier) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    // Reduce motion: no idle blink loop, no coin flight (deterministic).
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          notificationsProvider.overrideWithValue(notifier),
          farmSceneEnabledProvider.overrideWith((_) => false),
          onboardingBreathProvider.overrideWithValue(
            const Duration(seconds: 2),
          ),
        ],
        child: const CultivaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('full walk: plants task, pays welcome once, lands on farm', (
    tester,
  ) async {
    final notifier = FakeNotifier();
    await pump(tester, notifier);
    expect(find.text('Grandma left you a little farm.'), findsOneWidget);
    await tapText(tester, "Let's go");

    await tester.enterText(find.byType(TextField), '  Harsha ');
    await tester.tap(find.bySemanticsLabel('owl'));
    await tester.pump();
    await tapText(tester, 'Next');
    expect(await farm.settings.farmerName(), 'Harsha');
    expect(await farm.settings.avatar(), const Avatar(AvatarAnimal.owl, 0));

    await tapText(tester, 'Walk');
    await tapText(tester, '30 min');
    await tapText(tester, 'Plant it');
    final tasks = await farm.tasks.active();
    expect(tasks.single.title, 'Walk');
    expect(tasks.single.plot, PlotKind.daily);
    expect(tasks.single.targetMinutes, 30);
    expect(tasks.single.repeat, Weekdays.everyDay);

    // Breathing minute (2 s in tests) ripens the crop.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tapText(tester, 'Harvest!');
    expect(await farm.progress.balance(), kWelcomeCoins);
    expect(find.text('+$kWelcomeCoins coins'), findsOneWidget);
    expect(sfx.played, containsAllInOrder([SfxName.plant, SfxName.harvest]));
    // The practice harvest does not complete the real task.
    expect(await farm.progress.forDay(await farm.today()), isEmpty);

    await tapText(tester, 'Next');
    await tapText(tester, 'Yes, remind me');
    expect(notifier.log, ['permission', 'reminder:510']);
    expect(await farm.settings.reminderEnabled(), isTrue);
    expect(await farm.settings.onboarded(), isTrue);
    expect(find.byType(PixelNavBar), findsOneWidget); // on the farm now
  });

  testWidgets('skip on the welcome step finishes with nothing planted', (
    tester,
  ) async {
    await pump(tester, FakeNotifier());
    await tapText(tester, 'Skip');
    expect(await farm.settings.onboarded(), isTrue);
    expect(await farm.tasks.active(), isEmpty);
    expect(await farm.progress.balance(), 0);
    expect(find.text('Plant your first task'), findsOneWidget);
  });

  testWidgets('welcome gift is paid only once on replay', (tester) async {
    await farm.progress.append(
      kWelcomeCoins,
      LedgerReason.refund,
      day: await farm.today(),
      refId: kWelcomeRef,
    );
    await pump(tester, FakeNotifier());
    await tapText(tester, "Let's go");
    await tapText(tester, 'Next');
    await tapText(tester, 'Plant it');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tapText(tester, 'Harvest!');
    expect(await farm.progress.balance(), kWelcomeCoins);
  });
}
