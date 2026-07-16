import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the raw Supabase calls the discovery screens need.
/// Kept separate from [DiscoveryRepository] so tests can swap in a fake
/// that returns canned JSON instead of hitting a real Supabase project.
abstract class DiscoveryDataSource {
  Future<List<Map<String, dynamic>>> fetchCategories();

  Future<List<Map<String, dynamic>>> fetchStyleFeed({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categorySlug,
  });

  Future<List<Map<String, dynamic>>> fetchStyleResults({
    required String styleId,
    required double lat,
    required double lng,
    required double radiusKm,
    int? maxPriceCents,
    double? minRating,
    bool mobileOnly = false,
    bool hairIncludedOnly = false,
  });

  Future<Map<String, dynamic>> fetchSalonProfile(String salonId);

  Future<List<Map<String, dynamic>>> searchSalonsByName(String query);
}

class SupabaseDiscoveryDataSource implements DiscoveryDataSource {
  SupabaseDiscoveryDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final rows = await _client.from('categories').select().order('sort_order');
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStyleFeed({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categorySlug,
  }) async {
    final rows = await _client.rpc('style_feed', params: {
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm,
      'filter_category': categorySlug,
    });
    return List<Map<String, dynamic>>.from(rows as List);
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
    final rows = await _client.rpc('style_results', params: {
      'p_style_id': styleId,
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm,
      'max_price_cents': maxPriceCents,
      'min_rating': minRating,
      'mobile_only': mobileOnly,
      'hair_included_only': hairIncludedOnly,
    });
    return List<Map<String, dynamic>>.from(rows as List);
  }

  @override
  Future<Map<String, dynamic>> fetchSalonProfile(String salonId) async {
    final row = await _client
        .from('salons')
        .select(
          '*, salon_services(id, price_cents, duration_minutes, hair_included, hair_included_price_delta_cents, is_active, styles(name, category_slug)), '
          'salon_photos(photo_url, is_hero), reviews(id, rating, body, photo_urls, created_at)',
        )
        .eq('id', salonId)
        .single();
    return Map<String, dynamic>.from(row);
  }

  @override
  Future<List<Map<String, dynamic>>> searchSalonsByName(String query) async {
    final rows = await _client
        .from('salons')
        .select('id, name')
        .ilike('name', '%$query%')
        .limit(10);
    return List<Map<String, dynamic>>.from(rows);
  }
}
