import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/features/salon_profile/salon_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_discovery_data_source.dart';
import '../test_harness.dart';

void main() {
  testWidgets('shows salon name, services grouped by category, and reviews', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(
      wrapWithProviders(const SalonProfileScreen(salonId: 'salon-1'), repository: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text("Zanele's Braids"), findsOneWidget);
    expect(find.text('Braids'), findsOneWidget);
    expect(find.text('Knotless box braids, mid-back'), findsOneWidget);
    expect(find.text('Book now'), findsOneWidget);
    expect(find.text('Amazing work!'), findsOneWidget);
  });

  testWidgets('unclaimed salons show the claim-it banner instead of Book now', (tester) async {
    final dataSource = FakeDiscoveryDataSource();
    dataSource.salonProfileRow = {
      ...dataSource.salonProfileRow,
      'is_claimed': false,
    };
    final repo = DiscoveryRepository(dataSource);

    await tester.pumpWidget(
      wrapWithProviders(const SalonProfileScreen(salonId: 'salon-1'), repository: repo),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Claim it'), findsOneWidget);
    expect(find.text('Book now'), findsNothing);
    expect(find.text('Contact via WhatsApp'), findsOneWidget);
  });
}
