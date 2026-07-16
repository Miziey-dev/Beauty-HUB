import 'package:beauty_hub/features/booking/time_slot_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hours = {'mon_fri': '09:00-18:00', 'sat': '08:00-16:00', 'sun': 'closed'};

  test('a 6-hour service on a weekday only offers start times that finish before closing', () {
    final monday = DateTime(2026, 7, 20); // a Monday
    final slots = generateTimeSlots(operatingHours: hours, date: monday, serviceDurationMinutes: 360);

    expect(slots.first, const TimeOfDay(hour: 9, minute: 0));
    expect(slots.last, const TimeOfDay(hour: 12, minute: 0));
    for (final slot in slots) {
      final endMinutes = slot.hour * 60 + slot.minute + 360;
      expect(endMinutes, lessThanOrEqualTo(18 * 60));
    }
  });

  test('returns no slots on a day the salon is closed', () {
    final sunday = DateTime(2026, 7, 19);
    expect(generateTimeSlots(operatingHours: hours, date: sunday, serviceDurationMinutes: 60), isEmpty);
  });

  test('a short service on Saturday offers more, earlier-closing slots', () {
    final saturday = DateTime(2026, 7, 18);
    final slots = generateTimeSlots(operatingHours: hours, date: saturday, serviceDurationMinutes: 30);

    expect(slots.first, const TimeOfDay(hour: 8, minute: 0));
    expect(slots.last, const TimeOfDay(hour: 15, minute: 30));
  });

  test('returns no slots when the operating hours key is missing', () {
    final monday = DateTime(2026, 7, 20);
    expect(generateTimeSlots(operatingHours: const {}, date: monday, serviceDurationMinutes: 60), isEmpty);
  });
}
