import 'dart:ui' show Tristate;

import 'package:cultiva/core/theme/app_theme.dart';
import 'package:cultiva/core/ui/pixel_button.dart';
import 'package:cultiva/core/ui/pixel_icon.dart';
import 'package:cultiva/features/shell/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget wrap(Widget child) => MaterialApp(
  theme: buildCultivaTheme(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('PixelButton fires once per tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(PixelButton(label: 'Plant it', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Plant it'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('disabled and loading buttons ignore taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            const PixelButton(label: 'Off', onPressed: null),
            PixelButton(label: 'Busy', loading: true, onPressed: () => taps++),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Off'));
    await tester.tap(find.text('Working…'));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('buttons are at least 48dp tall and expose a label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        PixelIconButton(
          semanticLabel: 'Calendar',
          icon: PixelIcons.calendar,
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(PixelIconButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.bySemanticsLabel('Calendar'), findsOneWidget);
    // Icons draw at 2 logical px per art px: 16 art px -> 32dp.
    expect(tester.getSize(find.byType(PixelIcon)), const Size(32, 32));
    handle.dispose();
  });

  testWidgets('nav bar marks the selected tab for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var picked = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCultivaTheme(),
        home: Scaffold(
          bottomNavigationBar: PixelNavBar(
            currentIndex: 2,
            onSelect: (i) => picked = i,
          ),
        ),
      ),
    );
    final shop = tester.getSemantics(find.bySemanticsLabel('Shop tab'));
    expect(shop.flagsCollection.isSelected, Tristate.isTrue);
    await tester.tap(find.text('Progress'));
    expect(picked, 3);
    handle.dispose();
  });
}
