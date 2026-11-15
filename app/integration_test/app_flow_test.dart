import 'package:cultiva/app.dart';
import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/core/sfx.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/data/shop_service.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/features/onboarding/onboarding_screen.dart';
import 'package:cultiva/features/shell/app_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

/// Step 11.1: the main flows on a real Android runtime, with the Flame farm
/// scene, real audio and a fresh (in-memory) database.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch to harvest, shop, progress and profile', (
    tester,
  ) async {
    final db = CultivaDb(NativeDatabase.memory());
    addTearDown(db.close);
    final farm = FarmService(db);
    Sfx.player = AudioSfxPlayer();

    // The farm scene animates forever, so wait for frames instead of settling.
    Future<void> wait([int ms = 600]) async {
      for (var t = 0; t < ms; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await wait(200);
      await tester.tap(f);
      await wait();
    }

    Future<void> hideKeyboard() async {
      FocusManager.instance.primaryFocus?.unfocus();
      await wait(800);
    }

    Future<int> balance() async =>
        (await tester.runAsync(() => farm.progress.balance()))!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          notificationsProvider.overrideWithValue(FakeNotifier()),
          onboardingBreathProvider.overrideWithValue(
            const Duration(seconds: 3),
          ),
        ],
        child: const CultivaApp(),
      ),
    );
    await wait(1500);

    // --- Onboarding ---------------------------------------------------------
    expect(find.text('Grandma left you a little farm.'), findsOneWidget);
    await tap(find.text("Let's go"));
    await tester.enterText(find.byType(TextField), 'Tester');
    await hideKeyboard();
    await tap(find.bySemanticsLabel('cat'));
    await tap(find.text('Next'));
    await tap(find.text('Meditate'));
    await tap(find.text('5 min'));
    await tap(find.text('Plant it'));
    await wait(4000); // breathing moment
    await tap(find.text('Harvest!'));
    await wait(1500); // coin flight
    expect(find.text('+$kWelcomeCoins coins'), findsOneWidget);
    expect(await balance(), kWelcomeCoins);
    await tap(find.text('Next'));
    await tap(find.text('Not now'));
    await wait(1500);
    expect(find.byType(PixelNavBar), findsOneWidget);
    expect(find.textContaining('Next up: Meditate'), findsOneWidget);

    // --- To-do loop: plant, done, harvest -----------------------------------
    await tap(find.text('Tasks').last);
    await tap(find.text('+ Plant here').last);
    await tester.enterText(find.byType(TextField).first, 'Water plants');
    await hideKeyboard();
    await tap(find.text('Plant it'));
    await wait(1000);
    expect(find.text('Plant a task'), findsNothing); // sheet closed
    expect(find.text('Water plants'), findsOneWidget);
    await tap(find.text('Done'));
    await wait(1000);
    await tap(find.text('Harvest'));
    await wait(1500);
    final afterHarvest = await balance();
    expect(afterHarvest, greaterThan(kWelcomeCoins));

    // --- Shop: buy one decoration -------------------------------------------
    await tester.runAsync(
      () async => farm.progress.append(
        200,
        LedgerReason.refund,
        day: await farm.today(),
        refId: 'it',
      ),
    );
    await tap(find.text('Shop').last);
    await tap(find.text('Buy').first);
    await tap(find.text('Buy').last); // confirm sheet
    await wait(1000);
    final owned = await tester.runAsync(() => ShopService(db, farm).owned());
    expect(owned, isNotEmpty);

    // --- Progress shows today's harvest --------------------------------------
    await tap(find.text('Progress').last);
    await wait(1000);
    expect(find.textContaining('Nothing logged yet'), findsNothing);

    // --- Profile rename -------------------------------------------------------
    await tap(find.text('Farm').last);
    await tap(find.bySemanticsLabel('Profile'));
    await wait(1000);
    expect(find.text('Tester'), findsOneWidget);
    await tap(find.text('Edit'));
    await tester.enterText(find.byType(TextField), 'Harsha');
    await hideKeyboard();
    await tap(find.text('Save'));
    await wait(1000);
    expect(find.text('Harsha'), findsOneWidget);
  });
}
