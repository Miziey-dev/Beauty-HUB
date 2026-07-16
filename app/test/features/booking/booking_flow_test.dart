import 'package:beauty_hub/data/booking_repository.dart';
import 'package:beauty_hub/features/auth/phone_auth_screen.dart';
import 'package:beauty_hub/features/booking/deposit_confirm_screen.dart';
import 'package:beauty_hub/features/booking/service_options_screen.dart';
import 'package:beauty_hub/models/booking_draft.dart';
import 'package:beauty_hub/models/salon_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_data_source.dart';
import '../../fakes/fake_booking_data_source.dart';
import '../../fakes/fake_payment_gateway.dart';
import '../../test_harness.dart';

BookingDraft _draftWithHairAddOn() {
  const service = SalonServiceRow(
    id: 'service-1',
    styleName: 'Knotless box braids, mid-back',
    categorySlug: 'braids',
    priceCents: 65000,
    durationMinutes: 360,
    hairIncluded: false,
    hairIncludedPriceDeltaCents: 9750,
  );
  return const BookingDraft(
    service: service,
    salonId: 'salon-1',
    salonName: "Zanele's Braids",
    salonAddress: '12 Jorissen St',
    salonIsMobile: true,
    salonAvgResponseMinutes: 60,
    salonOperatingHours: {'mon_fri': '09:00-18:00', 'sat': '08:00-16:00', 'sun': 'closed'},
  );
}

/// The fixture's operating hours are closed on Sundays -- if the suite
/// happens to run on a Sunday, nudge the date picker to tomorrow first so
/// there's always at least one time slot to select.
Future<void> _selectAnAvailableSlot(WidgetTester tester) async {
  if (DateTime.now().weekday == DateTime.sunday) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.tap(find.text('${tomorrow.day}/${tomorrow.month}'));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byType(ChoiceChip).last);
  await tester.pumpAndSettle();
}

void main() {
  group('ServiceOptionsScreen (5a)', () {
    testWidgets('offers a hair add-on and a mobile location choice, computing the total', (tester) async {
      await tester.pumpWidget(wrapWithProviders(ServiceOptionsScreen(draft: _draftWithHairAddOn())));
      await tester.pumpAndSettle();

      expect(find.textContaining('R650'), findsWidgets);
      expect(find.text('Total: R650'), findsOneWidget);

      await tester.tap(find.text('Add hair'));
      await tester.pumpAndSettle();
      expect(find.text('Total: R748'), findsOneWidget); // 650 + 97.50, rounded

      await tester.tap(find.text('At my place (+R50 travel fee)'));
      await tester.pumpAndSettle();
      expect(find.text('Total: R798'), findsOneWidget); // + R50 travel fee

      // Continue is disabled until an address is entered for at-customer bookings.
      final continueButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
      expect(continueButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), '1 Test St');
      await tester.pumpAndSettle();
      final enabledContinue = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
      expect(enabledContinue.onPressed, isNotNull);
    });
  });

  group('End-to-end booking flow (5a -> 5c)', () {
    testWidgets('signed-in user can pick a slot, pay, and land on the success screen', (tester) async {
      final bookingDataSource = FakeBookingDataSource();
      final bookingRepository = BookingRepository(bookingDataSource);
      final authDataSource = FakeAuthDataSource(signedIn: true);
      final paymentGateway = FakePaymentGateway(shouldSucceed: true);

      await tester.pumpWidget(wrapWithProviders(
        ServiceOptionsScreen(draft: _draftWithHairAddOn()),
        authDataSource: authDataSource,
        bookingRepository: bookingRepository,
        paymentGateway: paymentGateway,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 5b: pick the first available time slot chip, then continue.
      await _selectAnAvailableSlot(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Auth gate should not interrupt an already-signed-in user.
      expect(find.byType(PhoneAuthScreen), findsNothing);
      expect(find.byType(DepositConfirmScreen), findsOneWidget);

      await tester.tap(find.textContaining('Pay R'));
      await tester.pumpAndSettle();

      expect(find.text('Request sent!'), findsOneWidget);
      expect(bookingDataSource.bookings, hasLength(1));
      expect(bookingDataSource.bookings.first['deposit_paid'], isTrue);
    });

    testWidgets('an unsigned-in user is sent through the phone auth gate before paying', (tester) async {
      final authDataSource = FakeAuthDataSource(signedIn: false);

      await tester.pumpWidget(wrapWithProviders(
        ServiceOptionsScreen(draft: _draftWithHairAddOn()),
        authDataSource: authDataSource,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await _selectAnAvailableSlot(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneAuthScreen), findsOneWidget);
      expect(find.byType(DepositConfirmScreen), findsNothing);

      await tester.enterText(find.byType(TextField).first, '+27821234567');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.byType(DepositConfirmScreen), findsOneWidget);
    });

    testWidgets('shows an error and stays put when the payment fails', (tester) async {
      final paymentGateway = FakePaymentGateway(shouldSucceed: false);
      final draft = _draftWithHairAddOn().copyWith(
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: const TimeOfDay(hour: 10, minute: 0),
      );

      await tester.pumpWidget(wrapWithProviders(
        DepositConfirmScreen(draft: draft),
        paymentGateway: paymentGateway,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Pay R'));
      await tester.pumpAndSettle();

      expect(find.text('Card declined'), findsOneWidget);
      expect(find.byType(DepositConfirmScreen), findsOneWidget);
    });
  });
}
