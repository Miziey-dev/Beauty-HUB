import 'package:beauty_hub/screens/style_guide_screen.dart';
import 'package:beauty_hub/theme/app_theme.dart';
import 'package:beauty_hub/theme/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap() => MaterialApp(theme: bhTheme, home: const StyleGuideScreen());

  // The style guide is a long scrolling page; give the test surface enough
  // height that every section is built (not just what a phone-sized
  // viewport would lazily realize), so byType/text finders can see it all.
  Future<void> useTallSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders every token/component section', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Colors'), findsOneWidget);
    expect(find.text('inkPlum'), findsOneWidget);
    expect(find.text('porcelain'), findsOneWidget);
    expect(find.text('hibiscus'), findsOneWidget);
    expect(find.text('hibiscusSoft'), findsOneWidget);
    expect(find.text('gold'), findsOneWidget);
    expect(find.text('confirmGreen'), findsOneWidget);
    expect(find.text('mauve'), findsOneWidget);
    expect(find.text('line'), findsOneWidget);

    expect(find.byType(BhPrimaryButton), findsOneWidget);
    expect(find.byType(BhGhostButton), findsOneWidget);
    expect(find.byType(BhChip), findsNWidgets(6));
    expect(find.byType(BhBadge), findsNWidgets(3));
    expect(find.byType(BhRatingStars), findsOneWidget);
  });

  testWidgets('tapping a chip toggles its selected state', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    BhChip chipNamed(String label) =>
        tester.widgetList<BhChip>(find.byType(BhChip)).firstWhere((c) => c.label == label);

    expect(chipNamed('Braids').selected, isTrue);
    expect(chipNamed('Nails').selected, isFalse);

    await tester.tap(find.text('Nails'));
    await tester.pumpAndSettle();

    expect(chipNamed('Nails').selected, isTrue);

    await tester.tap(find.text('Braids'));
    await tester.pumpAndSettle();

    expect(chipNamed('Braids').selected, isFalse);
  });
}
