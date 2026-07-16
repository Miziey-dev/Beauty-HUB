import 'package:flutter/material.dart';

import '../../../models/category.dart';

class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category.slug;
          return ChoiceChip(
            label: Text(category.label),
            selected: isSelected,
            onSelected: (_) => onSelected(isSelected ? null : category.slug),
          );
        },
      ),
    );
  }
}
