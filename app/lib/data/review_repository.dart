import 'review_data_source.dart';

class ReviewRepository {
  ReviewRepository(this._dataSource);

  final ReviewDataSource _dataSource;

  Future<void> submitReview({
    required String bookingId,
    required String salonId,
    required String customerId,
    required int rating,
    required String? body,
    required List<String> photoUrls,
  }) {
    return _dataSource.insertReview({
      'booking_id': bookingId,
      'salon_id': salonId,
      'customer_id': customerId,
      'rating': rating,
      'body': body,
      'photo_urls': photoUrls,
    });
  }
}
