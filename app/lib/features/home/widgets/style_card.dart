import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../l10n/strings.dart';
import '../../../models/style_feed_item.dart';

class StyleCard extends StatelessWidget {
  const StyleCard({super.key, required this.item, required this.onTap});

  final StyleFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: item.coverPhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.coverPhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(color: Color(0x11000000)),
                      errorWidget: (_, _, _) => const ColoredBox(color: Color(0x11000000)),
                    )
                  : const ColoredBox(color: Color(0x11000000)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.styleName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(Strings.priceFrom(formatRandFromCents(item.priceFromCents))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        formatDistanceKm(item.nearestDistanceKm),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        formatRatingBadge(item.bestRating),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
