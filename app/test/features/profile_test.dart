import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/providers.dart';
import 'package:cultiva/domain/avatar.dart';
import 'package:cultiva/features/profile/profile_screen.dart';
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

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, AppNotifier notifier) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          notificationsProvider.overrideWithValue(notifier),
        ],
        child: MaterialApp(
          theme: buildCultivaTheme(),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('picking an avatar saves it; capybara is not offered', (
    tester,
  ) async {
    await pump(tester, FakeNotifier());
    expect(find.bySemanticsLabel(RegExp('capybara avatar')), findsNothing);
    await tester.tap(find.bySemanticsLabel('owl avatar, colour 3'));
    await tester.pumpAndSettle();
    expect(await farm.settings.avatar(), const Avatar(AvatarAnimal.owl, 2));
  });

  testWidgets('rename saves the trimmed name', (tester) async {
    await pump(tester, FakeNotifier());
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Harsha  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(await farm.settings.farmerName(), 'Harsha');
    expect(find.text('Harsha'), findsOneWidget);
  });

  testWidgets('reminder: on asks permission and schedules; off cancels', (
    tester,
  ) async {
    final fake = FakeNotifier();
    await pump(tester, fake);
    await tester.tap(find.text('Daily reminder'));
    await tester.pumpAndSettle();
    expect(fake.log, ['permission', 'reminder:510']); // default 8:30
    expect(await farm.settings.reminderEnabled(), isTrue);
    await tester.tap(find.text('Daily reminder'));
    await tester.pumpAndSettle();
    expect(fake.log.last, 'reminder:off');
    expect(await farm.settings.reminderEnabled(), isFalse);
  });

  testWidgets('denied permission keeps the reminder off', (tester) async {
    final fake = FakeNotifier(allowPermission: false);
    await pump(tester, fake);
    await tester.tap(find.text('Daily reminder'));
    await tester.pumpAndSettle();
    expect(await farm.settings.reminderEnabled(), isFalse);
    expect(find.textContaining('Notifications are off'), findsOneWidget);
  });

  testWidgets('changing the reset hour saves', (tester) async {
    await pump(tester, FakeNotifier());
    await tester.tap(find.text('6 AM'));
    await tester.pumpAndSettle();
    expect(await farm.settings.resetHour(), 6);
  });

  test('nextDailyAt picks today or tomorrow', () {
    final t = DateTime(2026, 11, 16, 9);
    expect(nextDailyAt(t, 10 * 60), DateTime(2026, 11, 16, 10));
    expect(nextDailyAt(t, 8 * 60), DateTime(2026, 11, 17, 8));
  });
}
