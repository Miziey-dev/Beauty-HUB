import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/formatting.dart';
import '../../../data/discovery_repository.dart';
import '../../../location/location_controller.dart';
import '../../../models/style_result_item.dart';
import '../../salon_profile/salon_profile_screen.dart';

/// "Declined or expired requests ... suggest 3 similar nearby stylists"
/// (docs/consumer-flow.md, Screen 6).
class SimilarStylistsRow extends StatefulWidget {
  const SimilarStylistsRow({super.key, required this.styleId, required this.excludeSalonId});

  final String styleId;
  final String excludeSalonId;

  @override
  State<SimilarStylistsRow> createState() => _SimilarStylistsRowState();
}

class _SimilarStylistsRowState extends State<SimilarStylistsRow> {
  List<StyleResultItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final location = context.read<LocationController>();
    if (!location.isResolved) return;
    final results = await context.read<DiscoveryRepository>().fetchStyleResults(
          styleId: widget.styleId,
          lat: location.lat!,
          lng: location.lng!,
        );
    if (!mounted) return;
    setState(() {
      _items = results.where((item) => item.salonId != widget.excludeSalonId).take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ActionChip(
            label: Text('${item.salonName} · ${formatRandFromCents(item.priceCents)}'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SalonProfileScreen(salonId: item.salonId)),
            ),
          );
        },
      ),
    );
  }
}
