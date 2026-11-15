import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/focus/focus_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('Start shows the countdown and schedules notifications; '
      'Pause cancels them', (tester) async {
    final db = CultivaDb(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 11, 16, 9);
    final farm = FarmService(db, clock: () => now);
    final fake = FakeNotifier();
    final task = await tester.runAsync(
      () => farm.tasks.plant(
        title: 'Read',
        plot: PlotKind.daily,
        crop: 'pepper',
        today: FarmDay(2026, 11, 16),
        targetMinutes: 30,
        repeat: Weekdays.everyDay,
      ),
    );

    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump();
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          notificationsProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          theme: buildCultivaTheme(),
          home: FocusScreen(taskId: task!.id),
        ),
      ),
    );
    await settle();
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await settle();
    await settle();
    expect(fake.log, containsAll(['permission', 'started:Read']));
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await settle();
    await settle();
    expect(fake.log, contains('stopped:Read'));
    expect(find.text('Resume'), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // dispose the screen's timer
  });

  testWidgets('unknown task id shows Task not found', (tester) async {
    final db = CultivaDb(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildCultivaTheme(),
          home: const FocusScreen(taskId: 'nope'),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump();
    expect(find.text('Task not found.'), findsOneWidget);
  });
}
