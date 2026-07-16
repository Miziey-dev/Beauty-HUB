import 'package:flutter/material.dart';

import '../../../core/formatting.dart';

class StyleResultsFilters {
  final int? maxPriceCents;
  final double? minRating;
  final bool mobileOnly;
  final bool hairIncludedOnly;

  const StyleResultsFilters({
    this.maxPriceCents,
    this.minRating,
    this.mobileOnly = false,
    this.hairIncludedOnly = false,
  });

  StyleResultsFilters copyWith({
    int? maxPriceCents,
    bool clearMaxPrice = false,
    double? minRating,
    bool clearMinRating = false,
    bool? mobileOnly,
    bool? hairIncludedOnly,
  }) {
    return StyleResultsFilters(
      maxPriceCents: clearMaxPrice ? null : (maxPriceCents ?? this.maxPriceCents),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      mobileOnly: mobileOnly ?? this.mobileOnly,
      hairIncludedOnly: hairIncludedOnly ?? this.hairIncludedOnly,
    );
  }
}

Future<StyleResultsFilters?> showFiltersSheet(
  BuildContext context,
  StyleResultsFilters current,
) {
  return showModalBottomSheet<StyleResultsFilters>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FiltersSheetContent(initial: current),
  );
}

class _FiltersSheetContent extends StatefulWidget {
  const _FiltersSheetContent({required this.initial});

  final StyleResultsFilters initial;

  @override
  State<_FiltersSheetContent> createState() => _FiltersSheetContentState();
}

class _FiltersSheetContentState extends State<_FiltersSheetContent> {
  late double _maxPriceRand;
  late double _minRating;
  late bool _mobileOnly;
  late bool _hairIncludedOnly;

  static const double _priceCeilingRand = 2500;

  @override
  void initState() {
    super.initState();
    _maxPriceRand = widget.initial.maxPriceCents != null
        ? widget.initial.maxPriceCents! / 100
        : _priceCeilingRand;
    _minRating = widget.initial.minRating ?? 0;
    _mobileOnly = widget.initial.mobileOnly;
    _hairIncludedOnly = widget.initial.hairIncludedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Price up to R${_maxPriceRand.round()}'),
          Slider(
            value: _maxPriceRand,
            min: 50,
            max: _priceCeilingRand,
            divisions: 49,
            label: 'R${_maxPriceRand.round()}',
            onChanged: (value) => setState(() => _maxPriceRand = value),
          ),
          Text('Minimum rating: ${_minRating == 0 ? 'Any' : formatRatingBadge(_minRating)}'),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            label: _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(1),
            onChanged: (value) => setState(() => _minRating = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Comes to you'),
            value: _mobileOnly,
            onChanged: (value) => setState(() => _mobileOnly = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hair included'),
            value: _hairIncludedOnly,
            onChanged: (value) => setState(() => _hairIncludedOnly = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(const StyleResultsFilters()),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    StyleResultsFilters(
                      maxPriceCents:
                          _maxPriceRand >= _priceCeilingRand ? null : (_maxPriceRand * 100).round(),
                      minRating: _minRating == 0 ? null : _minRating,
                      mobileOnly: _mobileOnly,
                      hairIncludedOnly: _hairIncludedOnly,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
