import 'review.dart';

class SalonServiceRow {
  final String id;
  final String styleName;
  final String categorySlug;
  final int priceCents;
  final int durationMinutes;
  final bool hairIncluded;

  const SalonServiceRow({
    required this.id,
    required this.styleName,
    required this.categorySlug,
    required this.priceCents,
    required this.durationMinutes,
    required this.hairIncluded,
  });

  factory SalonServiceRow.fromJson(Map<String, dynamic> json) {
    final style = json['styles'] as Map<String, dynamic>;
    return SalonServiceRow(
      id: json['id'] as String,
      styleName: style['name'] as String,
      categorySlug: style['category_slug'] as String,
      priceCents: json['price_cents'] as int,
      durationMinutes: json['duration_minutes'] as int,
      hairIncluded: json['hair_included'] as bool,
    );
  }
}

class SalonPhotoRow {
  final String photoUrl;
  final bool isHero;

  const SalonPhotoRow({required this.photoUrl, required this.isHero});

  factory SalonPhotoRow.fromJson(Map<String, dynamic> json) => SalonPhotoRow(
        photoUrl: json['photo_url'] as String,
        isHero: json['is_hero'] as bool,
      );
}

/// Screen 4 (Salon / Stylist profile): the salon row plus its embedded
/// services, portfolio photos, and reviews.
class SalonProfile {
  final String id;
  final String name;
  final bool isClaimed;
  final bool isVerified;
  final bool isMobile;
  final String? addressLine;
  final String suburb;
  final int? avgResponseMinutes;
  final double ratingAvg;
  final int ratingCount;
  final String? whatsapp;
  final List<SalonServiceRow> services;
  final List<SalonPhotoRow> photos;
  final List<Review> reviews;

  const SalonProfile({
    required this.id,
    required this.name,
    required this.isClaimed,
    required this.isVerified,
    required this.isMobile,
    required this.addressLine,
    required this.suburb,
    required this.avgResponseMinutes,
    required this.ratingAvg,
    required this.ratingCount,
    required this.whatsapp,
    required this.services,
    required this.photos,
    required this.reviews,
  });

  factory SalonProfile.fromJson(Map<String, dynamic> json) => SalonProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        isClaimed: json['is_claimed'] as bool,
        isVerified: json['is_verified'] as bool,
        isMobile: json['is_mobile'] as bool,
        addressLine: json['address_line'] as String?,
        suburb: json['suburb'] as String,
        avgResponseMinutes: json['avg_response_minutes'] as int?,
        ratingAvg: (json['rating_avg'] as num).toDouble(),
        ratingCount: json['rating_count'] as int,
        whatsapp: json['whatsapp'] as String?,
        services: (json['salon_services'] as List<dynamic>? ?? [])
            .map((e) => SalonServiceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        photos: (json['salon_photos'] as List<dynamic>? ?? [])
            .map((e) => SalonPhotoRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        reviews: (json['reviews'] as List<dynamic>? ?? [])
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList()
            // photo reviews first -- these sell the booking (docs/consumer-flow.md, Screen 4)
            ..sort((a, b) => (b.hasPhoto ? 1 : 0) - (a.hasPhoto ? 1 : 0)),
      );

  Map<String, List<SalonServiceRow>> get servicesByCategory {
    final map = <String, List<SalonServiceRow>>{};
    for (final service in services) {
      map.putIfAbsent(service.categorySlug, () => []).add(service);
    }
    return map;
  }

  String? get heroPhotoUrl {
    final hero = photos.where((p) => p.isHero).toList();
    if (hero.isNotEmpty) return hero.first.photoUrl;
    return photos.isNotEmpty ? photos.first.photoUrl : null;
  }
}
