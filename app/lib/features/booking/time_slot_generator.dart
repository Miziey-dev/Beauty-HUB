import 'package:flutter/material.dart' show TimeOfDay;

/// Pure logic for Screen 5b: "time-slot chips sized by service duration (a
/// 6-hr braid job only offers start times that fit before closing)"
/// (docs/consumer-flow.md). Kept dependency-free so it's trivially unit
/// tested without pumping a widget tree.
String operatingHoursKeyForWeekday(int weekday) {
  if (weekday >= DateTime.monday && weekday <= DateTime.friday) return 'mon_fri';
  if (weekday == DateTime.saturday) return 'sat';
  return 'sun';
}

List<TimeOfDay> generateTimeSlots({
  required Map<String, String> operatingHours,
  required DateTime date,
  required int serviceDurationMinutes,
  int slotIntervalMinutes = 30,
}) {
  final range = operatingHours[operatingHoursKeyForWeekday(date.weekday)];
  if (range == null || range.trim().toLowerCase() == 'closed') return [];

  final parts = range.split('-');
  if (parts.length != 2) return [];
  final open = _parseTime(parts[0]);
  final close = _parseTime(parts[1]);
  if (open == null || close == null) return [];

  final openMinutes = open.hour * 60 + open.minute;
  final closeMinutes = close.hour * 60 + close.minute;

  final slots = <TimeOfDay>[];
  for (var cursor = openMinutes; cursor + serviceDurationMinutes <= closeMinutes; cursor += slotIntervalMinutes) {
    slots.add(TimeOfDay(hour: cursor ~/ 60, minute: cursor % 60));
  }
  return slots;
}

TimeOfDay? _parseTime(String value) {
  final parts = value.trim().split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}
