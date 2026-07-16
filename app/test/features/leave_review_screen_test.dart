import 'package:beauty_hub/data/review_repository.dart';
import 'package:beauty_hub/features/review/leave_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_review_data_source.dart';
import '../test_harness.dart';

void main() {
  testWidgets('defaults to 5 stars and submits rating, body, and no photos', (tester) async {
    final dataSource = FakeReviewDataSource();
    final repository = ReviewRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(
      const LeaveReviewScreen(bookingId: 'booking-1', salonId: 'salon-1'),
      reviewRepository: repository,
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsNWidgets(5));

    await tester.enterText(find.byType(TextField), 'Amazing braids!');
    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();

    expect(dataSource.inserted, hasLength(1));
    final submitted = dataSource.inserted.first;
    expect(submitted['booking_id'], 'booking-1');
    expect(submitted['salon_id'], 'salon-1');
    expect(submitted['rating'], 5);
    expect(submitted['body'], 'Amazing braids!');
    expect(submitted['photo_urls'], isEmpty);
  });

  testWidgets('tapping a lower star changes the submitted rating', (tester) async {
    final dataSource = FakeReviewDataSource();
    final repository = ReviewRepository(dataSource);

    await tester.pumpWidget(wrapWithProviders(
      const LeaveReviewScreen(bookingId: 'booking-1', salonId: 'salon-1'),
      reviewRepository: repository,
    ));
    await tester.pumpAndSettle();

    // Tap the 3rd star icon to set a 3-star rating.
    await tester.tap(find.byIcon(Icons.star).at(2));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));

    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();

    expect(dataSource.inserted.first['rating'], 3);
  });
}
