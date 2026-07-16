import '../l10n/strings.dart';

/// One list/map card in Screen 3 (style results). Maps 1:1 to the
/// `style_results` RPC row.
class StyleResultItem {
  final String salonServiceId;
  final String salonId;
  final String salonName;
  final String? heroPhotoUrl;
  final int priceCents;
  final int durationMinutes;
  final bool hairIncluded;
  final bool isMobile;
  final bool isVerified;
  final double ratingAvg;
  final int ratingCount;
  final double distanceKm;
  final double salonLat;
  final double salonLng;

  const StyleResultItem({
    required this.salonServiceId,
    required this.salonId,
    required this.salonName,
    required this.heroPhotoUrl,
    required this.priceCents,
    required this.durationMinutes,
    required this.hairIncluded,
    required this.isMobile,
    required this.isVerified,
    required this.ratingAvg,
    required this.ratingCount,
    required this.distanceKm,
    required this.salonLat,
    required this.salonLng,
  });

  factory StyleResultItem.fromJson(Map<String, dynamic> json) => StyleResultItem(
        salonServiceId: json['salon_service_id'] as String,
        salonId: json['salon_id'] as String,
        salonName: json['salon_name'] as String,
        heroPhotoUrl: json['hero_photo_url'] as String?,
        priceCents: json['price_cents'] as int,
        durationMinutes: json['duration_minutes'] as int,
        hairIncluded: json['hair_included'] as bool,
        isMobile: json['is_mobile'] as bool,
        isVerified: json['is_verified'] as bool,
        ratingAvg: (json['rating_avg'] as num).toDouble(),
        ratingCount: json['rating_count'] as int,
        distanceKm: (json['distance_km'] as num).toDouble(),
        salonLat: (json['salon_lat'] as num).toDouble(),
        salonLng: (json['salon_lng'] as num).toDouble(),
      );
}

enum ResultSort { recommended, nearest, cheapest, topRated }

extension ResultSortLabel on ResultSort {
  String get label => switch (this) {
        ResultSort.recommended => Strings.sortRecommended,
        ResultSort.nearest => Strings.sortNearest,
        ResultSort.cheapest => Strings.sortCheapest,
        ResultSort.topRated => Strings.sortTopRated,
      };
}

List<StyleResultItem> sortResults(List<StyleResultItem> items, ResultSort sort) {
  final sorted = List<StyleResultItem>.from(items);
  switch (sort) {
    case ResultSort.nearest:
      sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    case ResultSort.cheapest:
      sorted.sort((a, b) => a.priceCents.compareTo(b.priceCents));
    case ResultSort.topRated:
      sorted.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    case ResultSort.recommended:
      // Rating x distance blend: higher rating and lower distance both help.
      sorted.sort((a, b) {
        final scoreA = a.ratingAvg - (a.distanceKm * 0.15);
        final scoreB = b.ratingAvg - (b.distanceKm * 0.15);
        return scoreB.compareTo(scoreA);
      });
  }
  return sorted;
}
