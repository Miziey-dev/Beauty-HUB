import 'package:beauty_hub/data/discovery_data_source.dart';

/// Canned JSON shaped exactly like the Postgrest/RPC responses described in
/// supabase/migrations, so repository + widget tests never touch a real
/// Supabase project.
class FakeDiscoveryDataSource implements DiscoveryDataSource {
  List<Map<String, dynamic>> categories = [
    {'slug': 'braids', 'label': 'Braids'},
    {'slug': 'nails', 'label': 'Nails'},
  ];

  List<Map<String, dynamic>> styleFeedRows = [
    {
      'style_id': 'style-1',
      'style_name': 'Knotless box braids, mid-back',
      'category_slug': 'braids',
      'cover_photo_url': 'https://example.com/braids.jpg',
      'price_from_cents': 65000,
      'nearest_distance_km': 1.2,
      'best_rating': 4.6,
    },
  ];

  List<Map<String, dynamic>> styleResultRows = [
    {
      'salon_service_id': 'service-1',
      'salon_id': 'salon-1',
      'salon_name': "Zanele's Braids",
      'hero_photo_url': 'https://example.com/hero.jpg',
      'price_cents': 65000,
      'duration_minutes': 360,
      'hair_included': false,
      'is_mobile': false,
      'is_verified': true,
      'rating_avg': 4.6,
      'rating_count': 112,
      'distance_km': 1.2,
      'salon_lat': -26.19,
      'salon_lng': 28.03,
    },
    {
      'salon_service_id': 'service-2',
      'salon_id': 'salon-2',
      'salon_name': "Thando's Braid Bar",
      'hero_photo_url': null,
      'price_cents': 55000,
      'duration_minutes': 300,
      'hair_included': true,
      'is_mobile': true,
      'is_verified': false,
      'rating_avg': 4.9,
      'rating_count': 40,
      'distance_km': 2.5,
      'salon_lat': -26.18,
      'salon_lng': 28.02,
    },
  ];

  Map<String, dynamic> salonProfileRow = {
    'id': 'salon-1',
    'name': "Zanele's Braids",
    'is_claimed': true,
    'is_verified': true,
    'is_mobile': false,
    'address_line': '12 Jorissen St',
    'suburb': 'Braamfontein',
    'avg_response_minutes': 60,
    'rating_avg': 4.6,
    'rating_count': 2,
    'whatsapp': '+27821234567',
    'salon_services': [
      {
        'id': 'service-1',
        'price_cents': 65000,
        'duration_minutes': 360,
        'hair_included': false,
        'is_active': true,
        'styles': {'name': 'Knotless box braids, mid-back', 'category_slug': 'braids'},
      },
    ],
    'salon_photos': [
      {'photo_url': 'https://example.com/hero.jpg', 'is_hero': true},
    ],
    'reviews': [
      {
        'id': 'review-1',
        'rating': 5,
        'body': 'Amazing work!',
        'photo_urls': ['https://example.com/result.jpg'],
        'created_at': '2026-06-01T10:00:00Z',
      },
      {
        'id': 'review-2',
        'rating': 4,
        'body': 'Great experience',
        'photo_urls': <String>[],
        'created_at': '2026-05-01T10:00:00Z',
      },
    ],
  };

  List<Map<String, dynamic>> salonSearchRows = [];

  @override
  Future<List<Map<String, dynamic>>> fetchCategories() async => categories;

  @override
  Future<List<Map<String, dynamic>>> fetchStyleFeed({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categorySlug,
  }) async {
    if (categorySlug == null) return styleFeedRows;
    return styleFeedRows.where((row) => row['category_slug'] == categorySlug).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStyleResults({
    required String styleId,
    required double lat,
    required double lng,
    required double radiusKm,
    int? maxPriceCents,
    double? minRating,
    bool mobileOnly = false,
    bool hairIncludedOnly = false,
  }) async {
    return styleResultRows.where((row) {
      if (maxPriceCents != null && (row['price_cents'] as int) > maxPriceCents) return false;
      if (minRating != null && (row['rating_avg'] as num) < minRating) return false;
      if (mobileOnly && row['is_mobile'] != true) return false;
      if (hairIncludedOnly && row['hair_included'] != true) return false;
      return true;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchSalonProfile(String salonId) async => salonProfileRow;

  @override
  Future<List<Map<String, dynamic>>> searchSalonsByName(String query) async => salonSearchRows;
}
