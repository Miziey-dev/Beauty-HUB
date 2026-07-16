import 'package:beauty_hub/data/profile_repository.dart';
import 'package:beauty_hub/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_profile_data_source.dart';
import '../test_harness.dart';

void main() {
  testWidgets('shows the phone number, saved address, and favourite salon', (tester) async {
    final dataSource = FakeProfileDataSource();
    final repository = ProfileRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(
      const ProfileScreen(),
      profileRepository: repository,
    ));
    await tester.pumpAndSettle();

    expect(find.text('+27821234567'), findsOneWidget);
    expect(find.text('12 Jorissen St, Braamfontein'), findsOneWidget);
    expect(find.text("Zanele's Braids"), findsOneWidget);
  });

  testWidgets('adding an address persists it via the repository', (tester) async {
    final dataSource = FakeProfileDataSource();
    final repository = ProfileRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(
      const ProfileScreen(),
      profileRepository: repository,
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '5 New Address Rd');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(dataSource.profile['saved_addresses'], contains('5 New Address Rd'));
    expect(find.text('5 New Address Rd'), findsOneWidget);
  });

  testWidgets('toggling push notifications off updates the repository', (tester) async {
    final dataSource = FakeProfileDataSource();
    final repository = ProfileRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(
      const ProfileScreen(),
      profileRepository: repository,
    ));
    await tester.pumpAndSettle();

    expect(dataSource.profile['push_notifications_enabled'], isTrue);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(dataSource.profile['push_notifications_enabled'], isFalse);
  });
}
