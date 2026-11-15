import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/journal_repository.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/progress/progress_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('today card saves mood and note; week + postcards render', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 5200);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    final db = CultivaDb(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 11, 16, 9);
    final mon = FarmDay(2026, 11, 16);
    final farm = FarmService(db, clock: () => now);
    final t = await farm.tasks.plant(
      title: 'Pay bill',
      plot: PlotKind.todo,
      crop: 'pumpkin',
      today: mon,
    );
    await farm.complete(t);
    await farm.harvest(t);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: buildCultivaTheme(),
          home: const ProgressScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today · Mon 16 Nov'), findsOneWidget);
    expect(find.text('1 harvested · 0 focus min · 8 coins'), findsOneWidget);
    expect(find.textContaining('This week: 1 done'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);

    await tester.tap(find.text('Good').first);
    await tester.pumpAndSettle();
    final journal = JournalRepository(db, clock: () => now);
    expect((await journal.get(mon))!.mood, 4);

    await tester.enterText(find.byType(TextField).first, 'Paid it early');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect((await journal.get(mon))!.note, 'Paid it early');

    // Tap today's postcard -> day sheet with the task.
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Mon 16 Nov: 1 done')));
    await tester.pumpAndSettle();
    expect(find.text('Pay bill'), findsOneWidget);
    expect(find.text('Harvested'), findsOneWidget);
  });
}
