import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileDataSource {
  Future<Map<String, dynamic>> fetchProfile(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> values);
  Future<List<Map<String, dynamic>>> fetchFavourites(String userId);
  Future<void> addFavourite(String userId, String salonId);
  Future<void> removeFavourite(String userId, String salonId);
}

class SupabaseProfileDataSource implements ProfileDataSource {
  SupabaseProfileDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final row = await _client.from('profiles').select().eq('id', userId).single();
    return Map<String, dynamic>.from(row);
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> values) =>
      _client.from('profiles').update(values).eq('id', userId);

  @override
  Future<List<Map<String, dynamic>>> fetchFavourites(String userId) async {
    final rows =
        await _client.from('favourites').select('salon_id, salons(id, name)').eq('user_id', userId);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> addFavourite(String userId, String salonId) =>
      _client.from('favourites').insert({'user_id': userId, 'salon_id': salonId});

  @override
  Future<void> removeFavourite(String userId, String salonId) =>
      _client.from('favourites').delete().eq('user_id', userId).eq('salon_id', salonId);
}
