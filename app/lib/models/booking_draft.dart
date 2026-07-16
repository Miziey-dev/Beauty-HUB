import 'package:flutter/material.dart' show TimeOfDay;

import 'salon_profile.dart';

const double depositPercent = 0.25;
const int flatTravelFeeCents = 5000;

/// In-progress state for Screens 5a-5c, carried forward between the three
/// booking screens (docs/consumer-flow.md).
class BookingDraft {
  final SalonServiceRow service;
  final String salonId;
  final String salonName;
  final String? salonAddress;
  final bool salonIsMobile;
  final int? salonAvgResponseMinutes;
  final Map<String, String> salonOperatingHours;
  final bool addHair;
  final String locationType; // 'at_salon' | 'at_customer'
  final String? customerAddress;
  final DateTime? date;
  final TimeOfDay? timeSlot;

  const BookingDraft({
    required this.service,
    required this.salonId,
    required this.salonName,
    required this.salonAddress,
    required this.salonIsMobile,
    required this.salonAvgResponseMinutes,
    required this.salonOperatingHours,
    this.addHair = false,
    this.locationType = 'at_salon',
    this.customerAddress,
    this.date,
    this.timeSlot,
  });

  BookingDraft copyWith({
    bool? addHair,
    String? locationType,
    String? customerAddress,
    DateTime? date,
    TimeOfDay? timeSlot,
  }) {
    return BookingDraft(
      service: service,
      salonId: salonId,
      salonName: salonName,
      salonAddress: salonAddress,
      salonIsMobile: salonIsMobile,
      salonAvgResponseMinutes: salonAvgResponseMinutes,
      salonOperatingHours: salonOperatingHours,
      addHair: addHair ?? this.addHair,
      locationType: locationType ?? this.locationType,
      customerAddress: customerAddress ?? this.customerAddress,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }

  bool get isAtCustomer => locationType == 'at_customer';
  int get travelFeeCents => isAtCustomer ? flatTravelFeeCents : 0;
  int get hairAdjustmentCents => addHair ? service.hairIncludedPriceDeltaCents : 0;
  int get totalPriceCents => service.priceCents + hairAdjustmentCents + travelFeeCents;
  int get depositAmountCents => (totalPriceCents * depositPercent).round();
  int get balanceDueCents => totalPriceCents - depositAmountCents;
}
