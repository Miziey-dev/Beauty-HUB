import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/features/salon_profile/salon_profile_screen.dart';
import 'package:beauty_hub/features/style_results/style_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_discovery_data_source.dart';
import '../test_harness.dart';

void main() {
  testWidgets('lists salon cards sorted by the Recommended blend by default', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(
      wrapWithProviders(
        const StyleResultsScreen(styleId: 'style-1', styleName: 'Knotless box braids, mid-back'),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Zanele's Braids"), findsOneWidget);
    expect(find.text("Thando's Braid Bar"), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Hair included'), findsOneWidget);
  });

  testWidgets('toggling map view swaps the list for the map placeholder', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(
      wrapWithProviders(
        const StyleResultsScreen(styleId: 'style-1', styleName: 'Knotless box braids, mid-back'),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.byTooltip('Map view'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_on), findsWidgets);
  });

  testWidgets('tapping a result card opens the salon profile', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(
      wrapWithProviders(
        const StyleResultsScreen(styleId: 'style-1', styleName: 'Knotless box braids, mid-back'),
        repository: repo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Zanele's Braids"));
    await tester.pumpAndSettle();

    expect(find.byType(SalonProfileScreen), findsOneWidget);
  });
}
