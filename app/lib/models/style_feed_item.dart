/// One card in the Home style feed. Maps 1:1 to the `style_feed` RPC row
/// (supabase/migrations/0002_discovery_rpcs.sql).
class StyleFeedItem {
  final String styleId;
  final String styleName;
  final String categorySlug;
  final String? coverPhotoUrl;
  final int priceFromCents;
  final double nearestDistanceKm;
  final double bestRating;

  const StyleFeedItem({
    required this.styleId,
    required this.styleName,
    required this.categorySlug,
    required this.coverPhotoUrl,
    required this.priceFromCents,
    required this.nearestDistanceKm,
    required this.bestRating,
  });

  factory StyleFeedItem.fromJson(Map<String, dynamic> json) => StyleFeedItem(
        styleId: json['style_id'] as String,
        styleName: json['style_name'] as String,
        categorySlug: json['category_slug'] as String,
        coverPhotoUrl: json['cover_photo_url'] as String?,
        priceFromCents: json['price_from_cents'] as int,
        nearestDistanceKm: (json['nearest_distance_km'] as num).toDouble(),
        bestRating: (json['best_rating'] as num).toDouble(),
      );
}
