import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/features/home/home_screen.dart';
import 'package:beauty_hub/features/home/widgets/style_card.dart';
import 'package:beauty_hub/features/style_results/style_results_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_discovery_data_source.dart';
import '../test_harness.dart';

void main() {
  testWidgets('shows category chips and style cards from the repository', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(const HomeScreen(), repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Braids'), findsOneWidget);
    expect(find.text('Nails'), findsOneWidget);
    expect(find.text('Knotless box braids, mid-back'), findsOneWidget);
    expect(find.text('from R650'), findsOneWidget);
  });

  testWidgets('tapping a style card opens the style results screen', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(const HomeScreen(), repository: repo));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(StyleCard));
    await tester.tap(find.byType(StyleCard));
    await tester.pumpAndSettle();

    expect(find.byType(StyleResultsScreen), findsOneWidget);
  });

  testWidgets('shows a widened-radius notice when the nearest search is empty', (tester) async {
    final dataSource = FakeDiscoveryDataSource()..styleFeedRows = [];
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(const HomeScreen(), repository: repo));
    // First frame triggers _load(); pump through the radius-widening retries.
    await tester.pumpAndSettle();

    expect(find.text('No styles nearby yet -- check back soon'), findsOneWidget);
  });
}
