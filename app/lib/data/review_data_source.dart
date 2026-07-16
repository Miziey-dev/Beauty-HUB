import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReviewDataSource {
  Future<void> insertReview(Map<String, dynamic> values);
}

class SupabaseReviewDataSource implements ReviewDataSource {
  SupabaseReviewDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<void> insertReview(Map<String, dynamic> values) => _client.from('reviews').insert(values);
}
