import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BookingDataSource {
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> values);
  Future<List<Map<String, dynamic>>> fetchMyBookings();
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> rescheduleBooking(String bookingId, {required DateTime date, required String timeSlot});
}

class SupabaseBookingDataSource implements BookingDataSource {
  SupabaseBookingDataSource(this._client);

  final SupabaseClient _client;

  static const _selectWithJoins =
      '*, salons(name, address_line, is_mobile, whatsapp), '
      'salon_services(id, duration_minutes, styles(id, name)), reviews(id)';

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> values) async {
    final row = await _client.from('bookings').insert(values).select(_selectWithJoins).single();
    return Map<String, dynamic>.from(row);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMyBookings() async {
    final rows = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .order('requested_date', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) =>
      _client.from('bookings').update({'status': status}).eq('id', bookingId);

  @override
  Future<void> rescheduleBooking(String bookingId, {required DateTime date, required String timeSlot}) =>
      _client.from('bookings').update({
        'requested_date': date.toIso8601String().split('T').first,
        'requested_time_slot': timeSlot,
        'status': 'pending',
      }).eq('id', bookingId);
}
