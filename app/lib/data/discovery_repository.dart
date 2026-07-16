import '../models/category.dart';
import '../models/salon_profile.dart';
import '../models/salon_search_result.dart';
import '../models/style_feed_item.dart';
import '../models/style_result_item.dart';
import 'discovery_data_source.dart';

/// Widens the search radius when a query comes back empty, per
/// docs/consumer-flow.md's "never show a blank screen" rule.
const List<double> _radiusStepsKm = [5, 10, 20, 40];

class DiscoveryRepository {
  DiscoveryRepository(this._dataSource);

  final DiscoveryDataSource _dataSource;

  Future<List<Category>> fetchCategories() async {
    final rows = await _dataSource.fetchCategories();
    return rows.map(Category.fromJson).toList();
  }

  /// Returns the style feed plus whether results came from a widened radius,
  /// so the UI can show "a bit further out".
  Future<StyleFeedResult> fetchStyleFeed({
    required double lat,
    required double lng,
    String? categorySlug,
  }) async {
    for (final radiusKm in _radiusStepsKm) {
      final rows = await _dataSource.fetchStyleFeed(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        categorySlug: categorySlug,
      );
      if (rows.isNotEmpty) {
        return StyleFeedResult(
          items: rows.map(StyleFeedItem.fromJson).toList(),
          widenedRadius: radiusKm != _radiusStepsKm.first,
        );
      }
    }
    return const StyleFeedResult(items: [], widenedRadius: false);
  }

  Future<List<StyleResultItem>> fetchStyleResults({
    required String styleId,
    required double lat,
    required double lng,
    double radiusKm = 20,
    int? maxPriceCents,
    double? minRating,
    bool mobileOnly = false,
    bool hairIncludedOnly = false,
  }) async {
    final rows = await _dataSource.fetchStyleResults(
      styleId: styleId,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      maxPriceCents: maxPriceCents,
      minRating: minRating,
      mobileOnly: mobileOnly,
      hairIncludedOnly: hairIncludedOnly,
    );
    return rows.map(StyleResultItem.fromJson).toList();
  }

  Future<SalonProfile> fetchSalonProfile(String salonId) async {
    final row = await _dataSource.fetchSalonProfile(salonId);
    return SalonProfile.fromJson(row);
  }

  Future<List<SalonSearchResult>> searchSalonsByName(String query) async {
    if (query.trim().isEmpty) return [];
    final rows = await _dataSource.searchSalonsByName(query.trim());
    return rows.map(SalonSearchResult.fromJson).toList();
  }
}

class StyleFeedResult {
  final List<StyleFeedItem> items;
  final bool widenedRadius;

  const StyleFeedResult({required this.items, required this.widenedRadius});
}
