import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/task.dart';
import 'package:cultiva/features/tasks/plant_task_sheet.dart';
import 'package:cultiva/features/tasks/tasks_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  final now = DateTime(2026, 11, 16, 9);
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
  });
  tearDown(() => db.close());

  Widget host(Widget child) => ProviderScope(
    overrides: [
      dbProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => now),
    ],
    child: MaterialApp(
      theme: buildCultivaTheme(),
      home: Scaffold(body: child),
    ),
  );

  Future<void> openSheet(WidgetTester tester, {PlotKind? plot}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showPlantTaskSheet(context, plot: plot),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPlant(WidgetTester tester) async {
    final button = find.text('Plant it');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('Plant a task sheet', () {
    testWidgets('empty name shows an error and plants nothing', (tester) async {
      await openSheet(tester);
      await tapPlant(tester);
      expect(find.text('Give the task a name.'), findsOneWidget);
      expect(await farm.tasks.active(), isEmpty);
    });

    testWidgets('Daily with no days shows an error', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextField).first, 'Read');
      for (final day in ['M', 'T', 'W', 'F', 'S']) {
        for (final f in find.text(day).evaluate().toList()) {
          await tester.ensureVisible(find.byWidget(f.widget).first);
          await tester.tap(find.byWidget(f.widget).first);
          await tester.pump();
        }
      }
      await tapPlant(tester);
      expect(find.textContaining('Pick at least one day'), findsOneWidget);
      expect(await farm.tasks.active(), isEmpty);
    });

    testWidgets('valid Daily plants with chosen minutes', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextField).first, 'Read');
      await tester.tap(find.text('45 min'));
      await tester.pump();
      await tapPlant(tester);
      final t = (await farm.tasks.active()).single;
      expect(
        (t.title, t.plot, t.targetMinutes, t.repeat.mask),
        ('Read', PlotKind.daily, 45, Weekdays.everyDay.mask),
      );
      expect(find.text('Plant a task'), findsNothing); // sheet closed
    });

    testWidgets('to-do and habit plant into Plot B', (tester) async {
      await openSheet(tester, plot: PlotKind.todo);
      await tester.enterText(find.byType(TextField).first, 'Pay bill');
      await tapPlant(tester);
      final todo = (await farm.tasks.active()).single;
      expect((todo.plot, todo.isTodo), (PlotKind.todo, true));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Water');
      await tester.tap(find.text('Habit (repeats)'));
      await tester.pump();
      await tapPlant(tester);
      final habit = (await farm.tasks.active()).firstWhere(
        (t) => t.title == 'Water',
      );
      expect((habit.plot, habit.isTodo), (PlotKind.todo, false));
    });

    testWidgets('double tap plants exactly one task', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextField).first, 'Once');
      final button = find.text('Plant it');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(await farm.tasks.active(), hasLength(1));
    });

    testWidgets('a full plot is marked and the other is preselected', (
      tester,
    ) async {
      for (var i = 0; i < 6; i++) {
        await farm.tasks.plant(
          title: 'd$i',
          plot: PlotKind.daily,
          crop: 'pepper',
          today: mon,
          targetMinutes: 10,
          repeat: Weekdays.everyDay,
        );
      }
      await openSheet(tester, plot: PlotKind.daily);
      expect(find.text('Daily · full'), findsOneWidget);
      expect(find.text('To-do (once)'), findsOneWidget); // switched to Plot B
    });
  });

  group('Tasks tab', () {
    testWidgets('lists rows; Done ripens, Harvest pays', (tester) async {
      await farm.tasks.plant(
        title: 'Pay bill',
        plot: PlotKind.todo,
        crop: 'pumpkin',
        today: mon,
      );
      await farm.tasks.plant(
        title: 'Read',
        plot: PlotKind.daily,
        crop: 'pepper',
        today: mon,
        targetMinutes: 30,
        repeat: Weekdays.everyDay,
      );
      await tester.pumpWidget(host(const TasksScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('30 min · Every day'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Harvest'), findsOneWidget);
      await tester.tap(find.text('Harvest'));
      await tester.pumpAndSettle();
      expect(await farm.progress.balance(), 8);
    });

    testWidgets('remove asks first, then undo restores', (tester) async {
      await farm.tasks.plant(
        title: 'Walk',
        plot: PlotKind.daily,
        crop: 'pepper',
        today: mon,
        targetMinutes: 20,
        repeat: Weekdays.everyDay,
      );
      await tester.pumpWidget(host(const TasksScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Walk'));
      await tester.pumpAndSettle();
      final remove = find.text('Remove from farm');
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(await farm.tasks.active(), hasLength(1));

      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(await farm.tasks.active(), isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect((await farm.tasks.active()).single.title, 'Walk');
    });
  });
}
