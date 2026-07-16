import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/discovery_repository.dart';
import '../../l10n/strings.dart';
import '../../location/location_controller.dart';
import '../../models/style_result_item.dart';
import '../salon_profile/salon_profile_screen.dart';
import 'widgets/filters_sheet.dart';
import 'widgets/map_placeholder.dart';
import 'widgets/salon_result_card.dart';

/// Screen 3 -- Style results (list <-> map) (docs/consumer-flow.md).
class StyleResultsScreen extends StatefulWidget {
  const StyleResultsScreen({
    super.key,
    required this.styleId,
    required this.styleName,
    this.coverPhotoUrl,
  });

  final String styleId;
  final String styleName;
  final String? coverPhotoUrl;

  @override
  State<StyleResultsScreen> createState() => _StyleResultsScreenState();
}

class _StyleResultsScreenState extends State<StyleResultsScreen> {
  bool _mapView = false;
  bool _loading = true;
  List<StyleResultItem> _items = [];
  ResultSort _sort = ResultSort.recommended;
  StyleResultsFilters _filters = const StyleResultsFilters();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = context.read<DiscoveryRepository>();
    final location = context.read<LocationController>();
    final items = await repo.fetchStyleResults(
      styleId: widget.styleId,
      lat: location.lat!,
      lng: location.lng!,
      maxPriceCents: _filters.maxPriceCents,
      minRating: _filters.minRating,
      mobileOnly: _filters.mobileOnly,
      hairIncludedOnly: _filters.hairIncludedOnly,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _openSalon(StyleResultItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SalonProfileScreen(salonId: item.salonId)),
    );
  }

  bool get _hasActiveFilters =>
      _filters.maxPriceCents != null ||
      _filters.minRating != null ||
      _filters.mobileOnly ||
      _filters.hairIncludedOnly;

  void _clearFilters() {
    setState(() => _filters = const StyleResultsFilters());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationController>();
    final sortedItems = sortResults(_items, _sort);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.styleName),
        actions: [
          IconButton(
            icon: Icon(_mapView ? Icons.view_list : Icons.map_outlined),
            tooltip: _mapView ? Strings.listView : Strings.mapView,
            onPressed: () => setState(() => _mapView = !_mapView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text(Strings.filters),
                  onPressed: () async {
                    final result = await showFiltersSheet(context, _filters);
                    if (result != null) {
                      setState(() => _filters = result);
                      _load();
                    }
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<ResultSort>(
                  value: _sort,
                  items: [
                    for (final sort in ResultSort.values)
                      DropdownMenuItem(value: sort, child: Text(sort.label)),
                  ],
                  onChanged: (value) => setState(() => _sort = value ?? _sort),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : sortedItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(Strings.noSalonsMatchFilters),
                            if (_hasActiveFilters) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(onPressed: _clearFilters, child: const Text(Strings.clear)),
                            ],
                          ],
                        ),
                      )
                    : _mapView
                        ? MapPlaceholder(
                            items: sortedItems,
                            userLat: location.lat!,
                            userLng: location.lng!,
                            onViewSalon: _openSalon,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: sortedItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = sortedItems[index];
                              return SalonResultCard(item: item, onTap: () => _openSalon(item));
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
