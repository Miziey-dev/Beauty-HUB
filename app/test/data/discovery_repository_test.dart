import 'package:beauty_hub/data/discovery_data_source.dart';
import 'package:beauty_hub/data/discovery_repository.dart';
import 'package:beauty_hub/models/style_result_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_discovery_data_source.dart';

void main() {
  group('DiscoveryRepository', () {
    late FakeDiscoveryDataSource dataSource;
    late DiscoveryRepository repository;

    setUp(() {
      dataSource = FakeDiscoveryDataSource();
      repository = DiscoveryRepository(dataSource);
    });

    test('fetchCategories maps rows to Category models', () async {
      final categories = await repository.fetchCategories();
      expect(categories.map((c) => c.slug), ['braids', 'nails']);
    });

    test('fetchStyleFeed returns items without widening when the first radius has results', () async {
      final result = await repository.fetchStyleFeed(lat: -26.19, lng: 28.03);
      expect(result.items, hasLength(1));
      expect(result.widenedRadius, isFalse);
    });

    test('fetchStyleFeed widens the radius when the nearest search is empty', () async {
      dataSource.styleFeedRows = [];
      // First three radius steps stay empty, the widest one has a result.
      final repo = DiscoveryRepository(_WideningDataSource(dataSource));
      final result = await repo.fetchStyleFeed(lat: -26.19, lng: 28.03);
      expect(result.items, hasLength(1));
      expect(result.widenedRadius, isTrue);
    });

    test('fetchStyleFeed returns an empty result when nothing is found at any radius', () async {
      dataSource.styleFeedRows = [];
      final result = await repository.fetchStyleFeed(lat: -26.19, lng: 28.03);
      expect(result.items, isEmpty);
      expect(result.widenedRadius, isFalse);
    });

    test('fetchStyleResults applies filters via the data source', () async {
      final results = await repository.fetchStyleResults(
        styleId: 'style-1',
        lat: -26.19,
        lng: 28.03,
        mobileOnly: true,
      );
      expect(results, hasLength(1));
      expect(results.first.salonName, "Thando's Braid Bar");
    });

    test('fetchSalonProfile groups services by category and ranks photo reviews first', () async {
      final profile = await repository.fetchSalonProfile('salon-1');
      expect(profile.name, "Zanele's Braids");
      expect(profile.servicesByCategory.keys, contains('braids'));
      expect(profile.reviews.first.hasPhoto, isTrue);
    });
  });

  group('sortResults', () {
    final cheap = _result(priceCents: 30000, distanceKm: 5, rating: 4.0);
    final expensive = _result(priceCents: 90000, distanceKm: 1, rating: 4.9);

    test('cheapest sorts ascending by price', () {
      final sorted = sortResults([expensive, cheap], ResultSort.cheapest);
      expect(sorted.first, cheap);
    });

    test('nearest sorts ascending by distance', () {
      final sorted = sortResults([cheap, expensive], ResultSort.nearest);
      expect(sorted.first, expensive);
    });

    test('topRated sorts descending by rating', () {
      final sorted = sortResults([cheap, expensive], ResultSort.topRated);
      expect(sorted.first, expensive);
    });
  });
}

/// Simulates radius widening: only returns rows once called with a radius
/// >= 20km, mirroring "nothing nearby, then something further out".
class _WideningDataSource implements DiscoveryDataSource {
  _WideningDataSource(this._delegate);
  final FakeDiscoveryDataSource _delegate;

  @override
  Future<List<Map<String, dynamic>>> fetchCategories() => _delegate.fetchCategories();

  @override
  Future<List<Map<String, dynamic>>> fetchStyleFeed({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categorySlug,
  }) async {
    if (radiusKm < 20) return [];
    return [
      {
        'style_id': 'style-1',
        'style_name': 'Knotless box braids, mid-back',
        'category_slug': 'braids',
        'cover_photo_url': null,
        'price_from_cents': 65000,
        'nearest_distance_km': 18.0,
        'best_rating': 4.6,
      },
    ];
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
  }) =>
      _delegate.fetchStyleResults(
        styleId: styleId,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        maxPriceCents: maxPriceCents,
        minRating: minRating,
        mobileOnly: mobileOnly,
        hairIncludedOnly: hairIncludedOnly,
      );

  @override
  Future<Map<String, dynamic>> fetchSalonProfile(String salonId) =>
      _delegate.fetchSalonProfile(salonId);

  @override
  Future<List<Map<String, dynamic>>> searchSalonsByName(String query) =>
      _delegate.searchSalonsByName(query);
}

StyleResultItem _result({
  required int priceCents,
  required double distanceKm,
  required double rating,
}) {
  return StyleResultItem(
    salonServiceId: 'svc',
    salonId: 'salon',
    salonName: 'Test Salon',
    heroPhotoUrl: null,
    priceCents: priceCents,
    durationMinutes: 60,
    hairIncluded: false,
    isMobile: false,
    isVerified: false,
    ratingAvg: rating,
    ratingCount: 10,
    distanceKm: distanceKm,
    salonLat: -26.19,
    salonLng: 28.03,
  );
}
