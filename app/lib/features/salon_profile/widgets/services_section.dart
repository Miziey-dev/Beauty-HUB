import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../l10n/strings.dart';
import '../../../models/category.dart';
import '../../../models/salon_profile.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({
    super.key,
    required this.servicesByCategory,
    required this.categories,
    required this.onBook,
  });

  final Map<String, List<SalonServiceRow>> servicesByCategory;
  final List<Category> categories;
  final ValueChanged<SalonServiceRow> onBook;

  String _categoryLabel(String slug) {
    final match = categories.where((c) => c.slug == slug);
    return match.isEmpty ? slug : match.first.label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in servicesByCategory.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(_categoryLabel(entry.key), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final service in entry.value)
            ListTile(
              title: Text(service.styleName),
              subtitle: Text(
                '${formatRandFromCents(service.priceCents)} · ${formatDuration(service.durationMinutes)}'
                '${service.hairIncluded ? ' · ${Strings.hairIncludedBadge}' : ''}',
              ),
              trailing: FilledButton(
                onPressed: () => onBook(service),
                child: const Text(Strings.book),
              ),
            ),
        ],
      ],
    );
  }
}
