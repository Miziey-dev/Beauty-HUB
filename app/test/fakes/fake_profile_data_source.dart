import 'package:beauty_hub/data/profile_data_source.dart';

class FakeProfileDataSource implements ProfileDataSource {
  Map<String, dynamic> profile = {
    'id': 'test-user-1',
    'full_name': 'Thandi M',
    'phone': '+27821234567',
    'saved_addresses': <String>['12 Jorissen St, Braamfontein'],
    'push_notifications_enabled': true,
  };

  List<Map<String, dynamic>> favourites = [
    {
      'salon_id': 'salon-1',
      'salons': {'id': 'salon-1', 'name': "Zanele's Braids"},
    },
  ];

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) async => profile;

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> values) async {
    profile = {...profile, ...values};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFavourites(String userId) async => favourites;

  @override
  Future<void> addFavourite(String userId, String salonId) async {
    favourites.add({
      'salon_id': salonId,
      'salons': {'id': salonId, 'name': 'New Salon'},
    });
  }

  @override
  Future<void> removeFavourite(String userId, String salonId) async {
    favourites.removeWhere((f) => f['salon_id'] == salonId);
  }
}
