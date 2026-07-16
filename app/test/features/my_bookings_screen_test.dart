import 'package:beauty_hub/data/booking_repository.dart';
import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/features/my_bookings/my_bookings_screen.dart';
import 'package:beauty_hub/features/review/leave_review_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_booking_data_source.dart';
import '../fakes/fake_discovery_data_source.dart';
import '../test_harness.dart';

void main() {
  late FakeBookingDataSource dataSource;
  late BookingRepository repository;

  setUp(() {
    dataSource = FakeBookingDataSource();
    repository = BookingRepository(dataSource);
  });

  Future<void> seedBooking({required String status, bool hasReview = false, bool pastDate = false}) async {
    final row = await dataSource.createBooking({
      'salon_id': 'salon-1',
      'salon_service_id': 'service-1',
      'requested_date': pastDate ? '2020-01-01' : '2027-01-01',
      'requested_time_slot': '10:00:00',
      'total_price_cents': 65000,
      'deposit_amount_cents': 16250,
      'deposit_paid': true,
    });
    row['status'] = status;
    if (hasReview) row['reviews'] = [{'id': 'review-1'}];
  }

  testWidgets('shows an upcoming pending booking under the Upcoming tab', (tester) async {
    await seedBooking(status: 'pending');

    await tester.pumpWidget(wrapWithProviders(
      const MyBookingsScreen(),
      bookingRepository: repository,
      repository: DiscoveryRepository(FakeDiscoveryDataSource()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Awaiting confirmation'), findsOneWidget);
    expect(find.text("Zanele's Braids"), findsOneWidget);
  });

  testWidgets('a declined booking suggests similar nearby stylists', (tester) async {
    await seedBooking(status: 'declined');

    await tester.pumpWidget(wrapWithProviders(
      const MyBookingsScreen(),
      bookingRepository: repository,
      repository: DiscoveryRepository(FakeDiscoveryDataSource()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Declined -- refunded'), findsOneWidget);
    expect(find.text('You might also like'), findsOneWidget);
    expect(find.textContaining("Thando's Braid Bar"), findsOneWidget);
  });

  testWidgets('a completed past booking without a review offers Leave a review', (tester) async {
    await seedBooking(status: 'completed', pastDate: true);

    await tester.pumpWidget(wrapWithProviders(
      const MyBookingsScreen(),
      bookingRepository: repository,
      repository: DiscoveryRepository(FakeDiscoveryDataSource()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();

    expect(find.text('Leave a review'), findsOneWidget);

    await tester.tap(find.text('Leave a review'));
    await tester.pumpAndSettle();

    expect(find.byType(LeaveReviewScreen), findsOneWidget);
  });

  testWidgets('a completed past booking that already has a review shows Reviewed instead', (tester) async {
    await seedBooking(status: 'completed', pastDate: true, hasReview: true);

    await tester.pumpWidget(wrapWithProviders(
      const MyBookingsScreen(),
      bookingRepository: repository,
      repository: DiscoveryRepository(FakeDiscoveryDataSource()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Past'));
    await tester.pumpAndSettle();

    expect(find.text('Reviewed'), findsOneWidget);
    expect(find.text('Leave a review'), findsNothing);
  });

  testWidgets('cancelling within 48 hours warns the deposit will be forfeited', (tester) async {
    final row = await dataSource.createBooking({
      'salon_id': 'salon-1',
      'salon_service_id': 'service-1',
      'requested_date': '2027-01-01',
      'requested_time_slot': '10:00:00',
      'total_price_cents': 65000,
      'deposit_amount_cents': 16250,
      'deposit_paid': true,
    });
    row['status'] = 'confirmed';
    row['cancellation_deadline'] = DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

    await tester.pumpWidget(wrapWithProviders(
      const MyBookingsScreen(),
      bookingRepository: repository,
      repository: DiscoveryRepository(FakeDiscoveryDataSource()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('deposit will be forfeited'), findsOneWidget);

    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();

    expect(dataSource.bookings.first['status'], 'cancelled');
  });
}
