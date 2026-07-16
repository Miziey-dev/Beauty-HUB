import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../l10n/strings.dart';
import '../../../models/style_result_item.dart';

/// Lightweight scatter-plot stand-in for the real map view. Plots real
/// salon coordinates so the pin layout and tap-to-preview interaction work
/// today; swap the body for a GoogleMap widget once a Maps API key is
/// configured (see .env.example) -- the pin/bottom-sheet contract stays
/// the same either way.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    required this.items,
    required this.userLat,
    required this.userLng,
    required this.onViewSalon,
  });

  final List<StyleResultItem> items;
  final double userLat;
  final double userLng;
  final ValueChanged<StyleResultItem> onViewSalon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text(Strings.noSalonsOnMap));
    }

    final lats = [userLat, ...items.map((i) => i.salonLat)];
    final lngs = [userLng, ...items.map((i) => i.salonLng)];
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final latSpan = (maxLat - minLat).abs() < 0.001 ? 0.02 : (maxLat - minLat);
    final lngSpan = (maxLng - minLng).abs() < 0.001 ? 0.02 : (maxLng - minLng);

    Offset project(double lat, double lng, Size size) {
      final dx = (lng - minLng) / lngSpan;
      final dy = 1 - (lat - minLat) / latSpan;
      return Offset(dx * (size.width - 40) + 20, dy * (size.height - 40) + 20);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final userPoint = project(userLat, userLng, size);
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Stack(
            children: [
              Positioned(
                left: userPoint.dx - 8,
                top: userPoint.dy - 8,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 16),
              ),
              for (final item in items)
                Builder(builder: (context) {
                  final point = project(item.salonLat, item.salonLng, size);
                  return Positioned(
                    left: point.dx - 28,
                    top: point.dy - 32,
                    child: _PricePin(
                      item: item,
                      onTap: () => _showMiniCard(context, item),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showMiniCard(BuildContext context, StyleResultItem item) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.salonName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '${formatRandFromCents(item.priceCents)} · ${formatRating(item.ratingAvg, item.ratingCount)} · '
              '${formatDistanceKm(item.distanceKm)}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onViewSalon(item);
                },
                child: const Text(Strings.viewSalon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePin extends StatelessWidget {
  const _PricePin({required this.item, required this.onTap});

  final StyleResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              formatRandFromCents(item.priceCents),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
        ],
      ),
    );
  }
}
