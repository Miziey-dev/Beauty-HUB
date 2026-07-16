/// Screen 6 (My Bookings): a booking joined with the salon and service it's
/// for (docs/consumer-flow.md).
class MyBooking {
  final String id;
  final String status;
  final DateTime requestedDate;
  final String requestedTimeSlot;
  final String salonId;
  final String salonName;
  final String? salonAddress;
  final bool salonIsMobile;
  final String? salonWhatsapp;
  final String styleId;
  final String styleName;
  final int durationMinutes;
  final int totalPriceCents;
  final int depositAmountCents;
  final bool depositPaid;
  final DateTime? cancellationDeadline;
  final bool hasReview;

  const MyBooking({
    required this.id,
    required this.status,
    required this.requestedDate,
    required this.requestedTimeSlot,
    required this.salonId,
    required this.salonName,
    required this.salonAddress,
    required this.salonIsMobile,
    required this.salonWhatsapp,
    required this.styleId,
    required this.styleName,
    required this.durationMinutes,
    required this.totalPriceCents,
    required this.depositAmountCents,
    required this.depositPaid,
    required this.cancellationDeadline,
    required this.hasReview,
  });

  factory MyBooking.fromJson(Map<String, dynamic> json) {
    final salon = json['salons'] as Map<String, dynamic>;
    final service = json['salon_services'] as Map<String, dynamic>;
    final style = service['styles'] as Map<String, dynamic>;
    final reviews = json['reviews'] as List<dynamic>? ?? [];
    return MyBooking(
      id: json['id'] as String,
      status: json['status'] as String,
      requestedDate: DateTime.parse(json['requested_date'] as String),
      requestedTimeSlot: json['requested_time_slot'] as String,
      salonId: json['salon_id'] as String,
      salonName: salon['name'] as String,
      salonAddress: salon['address_line'] as String?,
      salonIsMobile: salon['is_mobile'] as bool,
      salonWhatsapp: salon['whatsapp'] as String?,
      styleId: style['id'] as String,
      styleName: style['name'] as String,
      durationMinutes: service['duration_minutes'] as int,
      totalPriceCents: json['total_price_cents'] as int,
      depositAmountCents: json['deposit_amount_cents'] as int,
      depositPaid: json['deposit_paid'] as bool,
      cancellationDeadline: json['cancellation_deadline'] != null
          ? DateTime.parse(json['cancellation_deadline'] as String)
          : null,
      hasReview: reviews.isNotEmpty,
    );
  }

  // "Declined or expired requests ... suggest 3 similar nearby stylists" lives
  // on the Upcoming card (docs/consumer-flow.md, Screen 6), so only a truly
  // completed appointment moves to Past.
  bool get isUpcoming => status != 'completed';

  bool isCancellableFreely(DateTime now) =>
      cancellationDeadline == null || now.isBefore(cancellationDeadline!);
}
