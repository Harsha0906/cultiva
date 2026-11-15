import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/data/shop_service.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/domain/shop.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/barn/barn_screen.dart';
import 'package:cultiva/features/barn/spot_picker.dart';
import 'package:cultiva/features/shop/shop_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  late ShopService shop;
  final now = DateTime(2026, 11, 16, 9);
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
    shop = ShopService(db, farm);
  });
  tearDown(() => db.close());

  Widget host(Widget child) => ProviderScope(
    overrides: [
      dbProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => now),
    ],
    child: MaterialApp(theme: buildCultivaTheme(), home: child),
  );

  testWidgets('shop shows Buy, Owned and Need-more states; buying works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await farm.progress.append(100, LedgerReason.harvest, day: mon);
    await shop.buy('mushroom_small'); // 30 -> balance 70
    await tester.pumpWidget(host(const ShopScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Owned'), findsOneWidget);
    expect(find.text('Need 130 more'), findsOneWidget); // well 200
    // Crates (70) is affordable: buy it through the confirm sheet.
    final crates = find.ancestor(
      of: find.text('Crates'),
      matching: find.byType(Container),
    );
    await tester.tap(
      find.descendant(of: crates.first, matching: find.text('Buy')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buy Crates for 70 coins?'), findsOneWidget);
    await tester.tap(find.text('Buy').last);
    await tester.pumpAndSettle();
    expect(await farm.progress.balance(), 0);
    expect(find.text('Owned'), findsNWidgets(2));
  });

  testWidgets("barn lists today's harvest and owned decorations", (
    tester,
  ) async {
    final t = await farm.tasks.plant(
      title: 'Pay bill',
      plot: PlotKind.todo,
      crop: 'pumpkin',
      today: mon,
    );
    await farm.complete(t);
    await farm.harvest(t);
    await farm.progress.append(100, LedgerReason.harvest, day: mon);
    await shop.buy('stump');
    await shop.place('stump', 0);
    await tester.pumpWidget(host(const BarnScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Pay bill'), findsOneWidget);
    expect(find.text('+8'), findsOneWidget);
    expect(find.text('Old stump'), findsOneWidget);
    expect(find.text('On the farm · spot 1'), findsOneWidget);
  });

  testWidgets('spot picker places, swaps out, and takes back', (tester) async {
    await farm.progress.append(300, LedgerReason.harvest, day: mon);
    await shop.buy('stump');
    await shop.buy('mushroom_small');
    await shop.place('mushroom_small', 1);
    final stump = kShopCatalogue.firstWhere((i) => i.id == 'stump');
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showSpotPicker(context, stump),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    Future<void> open() async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    await open();
    expect(find.text('Spot 1\nempty'), findsOneWidget);
    // Placing on the mushroom's spot sends the mushroom back to storage.
    await tester.tap(find.textContaining('Spot 2'));
    await tester.pumpAndSettle();
    var placed = await shop.placed();
    expect(placed[1]?.id, 'stump');
    expect(placed.values.any((i) => i.id == 'mushroom_small'), isFalse);

    await open();
    expect(find.text('Spot 2\nhere'), findsOneWidget);
    await tester.tap(find.text('Take back to storage'));
    await tester.pumpAndSettle();
    placed = await shop.placed();
    expect(placed, isEmpty);
  });
}
