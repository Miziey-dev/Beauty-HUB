class Review {
  final String id;
  final int rating;
  final String? body;
  final List<String> photoUrls;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.rating,
    required this.body,
    required this.photoUrls,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        rating: json['rating'] as int,
        body: json['body'] as String?,
        photoUrls: (json['photo_urls'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool get hasPhoto => photoUrls.isNotEmpty;
}
