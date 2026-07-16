import '../models/salon_search_result.dart';
import '../models/user_profile.dart';
import 'profile_data_source.dart';

class ProfileRepository {
  ProfileRepository(this._dataSource);

  final ProfileDataSource _dataSource;

  Future<UserProfile> fetchProfile(String userId) async {
    final row = await _dataSource.fetchProfile(userId);
    return UserProfile.fromJson(row);
  }

  Future<void> updateName(String userId, String fullName) =>
      _dataSource.updateProfile(userId, {'full_name': fullName});

  Future<void> updateSavedAddresses(String userId, List<String> addresses) =>
      _dataSource.updateProfile(userId, {'saved_addresses': addresses});

  Future<void> updatePushNotificationsEnabled(String userId, bool enabled) =>
      _dataSource.updateProfile(userId, {'push_notifications_enabled': enabled});

  Future<List<SalonSearchResult>> fetchFavourites(String userId) async {
    final rows = await _dataSource.fetchFavourites(userId);
    return rows
        .map((row) => SalonSearchResult.fromJson(row['salons'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavourite(String userId, String salonId) => _dataSource.addFavourite(userId, salonId);

  Future<void> removeFavourite(String userId, String salonId) =>
      _dataSource.removeFavourite(userId, salonId);
}
