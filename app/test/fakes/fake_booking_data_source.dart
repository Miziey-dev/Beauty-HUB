import 'package:beauty_hub/data/booking_data_source.dart';

class FakeBookingDataSource implements BookingDataSource {
  final List<Map<String, dynamic>> bookings = [];
  int _idCounter = 0;

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> values) async {
    final id = 'booking-${_idCounter++}';
    final row = {
      'id': id,
      'status': 'pending',
      'cancellation_deadline': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'salons': {
        'name': "Zanele's Braids",
        'address_line': '12 Jorissen St',
        'is_mobile': false,
        'whatsapp': '+27821234567',
      },
      'salon_services': {
        'id': values['salon_service_id'],
        'duration_minutes': 360,
        'styles': {'id': 'style-1', 'name': 'Knotless box braids, mid-back'},
      },
      'reviews': <dynamic>[],
      ...values,
    };
    bookings.add(row);
    return row;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMyBookings() async => bookings;

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    booking['status'] = status;
  }

  @override
  Future<void> rescheduleBooking(String bookingId, {required DateTime date, required String timeSlot}) async {
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    booking['requested_date'] = date.toIso8601String().split('T').first;
    booking['requested_time_slot'] = timeSlot;
    booking['status'] = 'pending';
  }
}
