import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../models/style_result_item.dart';

class SalonResultCard extends StatelessWidget {
  const SalonResultCard({super.key, required this.item, required this.onTap});

  final StyleResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: item.heroPhotoUrl != null
                      ? CachedNetworkImage(imageUrl: item.heroPhotoUrl!, fit: BoxFit.cover)
                      : const ColoredBox(color: Color(0x11000000)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.salonName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${formatRandFromCents(item.priceCents)} · ${formatDuration(item.durationMinutes)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatRating(item.ratingAvg, item.ratingCount)} · ${formatDistanceKm(item.distanceKm)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (item.isVerified) const _Badge(label: 'Verified', icon: Icons.verified),
                        if (item.isMobile) const _Badge(label: 'Mobile', icon: Icons.directions_car),
                        if (item.hairIncluded) const _Badge(label: 'Hair included', icon: Icons.check_circle),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
