import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/strings.dart';
import '../../../models/review.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.ratingAvg,
    required this.ratingCount,
  });

  final List<Review> reviews;
  final double ratingAvg;
  final int ratingCount;

  Map<int, int> get _breakdown {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(Strings.noReviewsYet),
      );
    }
    final breakdown = _breakdown;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ratingAvg.toStringAsFixed(1)} · $ratingCount reviews',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (var stars = 5; stars >= 1; stars--)
            Row(
              children: [
                Text('$stars★', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: reviews.isEmpty ? 0 : (breakdown[stars] ?? 0) / reviews.length,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          for (final review in reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < review.rating; i++)
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                    ],
                  ),
                  if (review.body != null) Text(review.body!),
                  if (review.hasPhoto)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: review.photoUrls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: review.photoUrls[index],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
