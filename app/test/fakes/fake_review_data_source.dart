import 'package:beauty_hub/data/review_data_source.dart';

class FakeReviewDataSource implements ReviewDataSource {
  final List<Map<String, dynamic>> inserted = [];

  @override
  Future<void> insertReview(Map<String, dynamic> values) async {
    inserted.add(values);
  }
}
