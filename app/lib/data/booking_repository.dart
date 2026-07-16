import 'package:flutter/material.dart' show TimeOfDay;

import '../models/booking_draft.dart';
import '../models/my_booking.dart';
import 'booking_data_source.dart';

String formatTimeOfDayForDb(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

String formatDateForDb(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class BookingRepository {
  BookingRepository(this._dataSource);

  final BookingDataSource _dataSource;

  Future<MyBooking> createBooking({
    required BookingDraft draft,
    required String customerId,
    required String? paystackReference,
  }) async {
    final row = await _dataSource.createBooking({
      'customer_id': customerId,
      'salon_id': draft.salonId,
      'salon_service_id': draft.service.id,
      'location_type': draft.locationType,
      'customer_address': draft.customerAddress,
      'requested_date': formatDateForDb(draft.date!),
      'requested_time_slot': formatTimeOfDayForDb(draft.timeSlot!),
      'service_price_cents': draft.service.priceCents,
      'hair_included': draft.addHair,
      'travel_fee_cents': draft.travelFeeCents,
      'total_price_cents': draft.totalPriceCents,
      'deposit_percent': depositPercent,
      'deposit_amount_cents': draft.depositAmountCents,
      'deposit_paid': paystackReference != null,
      'deposit_paid_at': paystackReference != null ? DateTime.now().toUtc().toIso8601String() : null,
      'paystack_reference': paystackReference,
    });
    return MyBooking.fromJson(row);
  }

  Future<List<MyBooking>> fetchMyBookings() async {
    final rows = await _dataSource.fetchMyBookings();
    return rows.map(MyBooking.fromJson).toList();
  }

  Future<void> cancelBooking(String bookingId) => _dataSource.updateBookingStatus(bookingId, 'cancelled');

  Future<void> rescheduleBooking(String bookingId, {required DateTime date, required TimeOfDay timeSlot}) =>
      _dataSource.rescheduleBooking(bookingId, date: date, timeSlot: formatTimeOfDayForDb(timeSlot));
}
