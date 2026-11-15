import 'package:cultiva/app.dart';
import 'package:cultiva/core/router.dart';
import 'package:cultiva/features/shell/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  String location = Routes.farm,
}) async {
  await tester.pumpWidget(
    ProviderScope(child: CultivaApp(initialLocation: location)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on Farm with 4 labelled tabs', (tester) async {
    await pumpApp(tester);
    expect(find.text('Farm scene arrives in Phase 4'), findsOneWidget);
    for (final label in ['Farm', 'Tasks', 'Shop', 'Progress']) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('tab state survives switching tabs', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('taps: 0'));
    await tester.pumpAndSettle();
    expect(find.textContaining('taps: 1'), findsOneWidget);

    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('taps: 1'), findsOneWidget);
  });

  testWidgets('calendar button opens Progress calendar view', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Calendar view (Phase 8)'), findsOneWidget);
  });

  testWidgets('avatar opens Profile and back returns to Farm', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.textContaining('animal avatars'), findsOneWidget);
    expect(find.byType(PixelNavBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Farm scene arrives in Phase 4'), findsOneWidget);
  });

  testWidgets('invalid focus id shows not-found with a way home', (
    tester,
  ) async {
    await pumpApp(tester, location: '/focus/bad%20id!');
    expect(find.text('Task not found.'), findsOneWidget);
    await tester.tap(find.text('Back to farm'));
    await tester.pumpAndSettle();
    expect(find.text('Farm scene arrives in Phase 4'), findsOneWidget);
  });

  testWidgets('unknown route shows not-found', (tester) async {
    await pumpApp(tester, location: '/nowhere');
    expect(find.text('Back to farm'), findsOneWidget);
  });
}
