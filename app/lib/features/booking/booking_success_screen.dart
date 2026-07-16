import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../models/my_booking.dart';
import '../my_bookings/my_bookings_screen.dart';

/// Success screen at the end of Screen 5c (docs/consumer-flow.md).
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final MyBooking booking;

  Future<void> _addToCalendar(BuildContext context) async {
    final start = DateTime(
      booking.requestedDate.year,
      booking.requestedDate.month,
      booking.requestedDate.day,
      int.parse(booking.requestedTimeSlot.split(':')[0]),
      int.parse(booking.requestedTimeSlot.split(':')[1]),
    );
    final event = Event(
      title: '${booking.styleName} at ${booking.salonName}',
      location: booking.salonAddress,
      startDate: start,
      endDate: start.add(Duration(minutes: booking.durationMinutes)),
    );
    try {
      await Add2Calendar.addEvent2Cal(event);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open calendar on this device')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Request sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Booking reference: ${booking.id.substring(0, 8).toUpperCase()}'),
              const SizedBox(height: 8),
              Text(
                "You'll get a notification when ${booking.salonName} confirms.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _addToCalendar(context),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Add to calendar'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  (route) => route.isFirst,
                ),
                child: const Text('View my bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
