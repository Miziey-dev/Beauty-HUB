import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/components.dart';
import '../theme/tokens.dart';

/// Showcases every design token and component. Not part of the product
/// flow -- a living reference for the design system built in
/// theme/tokens.dart, theme/app_theme.dart, and theme/components.dart.
class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  final Set<String> _selectedChips = {'Braids'};

  static const _swatches = [
    ('inkPlum', BhColors.inkPlum),
    ('porcelain', BhColors.porcelain),
    ('hibiscus', BhColors.hibiscus),
    ('hibiscusSoft', BhColors.hibiscusSoft),
    ('gold', BhColors.gold),
    ('confirmGreen', BhColors.confirmGreen),
    ('mauve', BhColors.mauve),
    ('line', BhColors.line),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beauty HuB -- Style Guide')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: BhSpacing.screenHorizontal,
          vertical: BhSpacing.lg,
        ),
        children: [
          _SectionTitle('Colors'),
          const SizedBox(height: BhSpacing.sm),
          Wrap(
            spacing: BhSpacing.sm,
            runSpacing: BhSpacing.sm,
            children: [for (final (name, color) in _swatches) _ColorSwatch(name: name, color: color)],
          ),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Type'),
          const SizedBox(height: BhSpacing.sm),
          _TypeCard(),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Buttons'),
          const SizedBox(height: BhSpacing.sm),
          BhPrimaryButton(label: 'Book now', onPressed: () {}),
          const SizedBox(height: BhSpacing.sm),
          BhGhostButton(label: 'Not now', onPressed: () {}),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Chips'),
          const SizedBox(height: BhSpacing.sm),
          Wrap(
            spacing: BhSpacing.xs,
            runSpacing: BhSpacing.xs,
            children: [
              for (final label in const ['Braids', 'Installs/Weaves', 'Nails', 'Lashes', 'Makeup', 'Barber'])
                BhChip(
                  label: label,
                  selected: _selectedChips.contains(label),
                  onTap: () => setState(() {
                    if (!_selectedChips.remove(label)) _selectedChips.add(label);
                  }),
                ),
            ],
          ),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Badges'),
          const SizedBox(height: BhSpacing.sm),
          const Wrap(
            spacing: BhSpacing.xs,
            runSpacing: BhSpacing.xs,
            children: [
              BhBadge(label: 'Verified', tone: BhBadgeTone.success, icon: Icons.verified),
              BhBadge(label: 'Mobile', icon: Icons.directions_car),
              BhBadge(label: 'Top rated', tone: BhBadgeTone.gold, icon: Icons.star),
            ],
          ),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Rating stars'),
          const SizedBox(height: BhSpacing.sm),
          Row(
            children: [
              const BhRatingStars(rating: 4.5),
              const SizedBox(width: BhSpacing.sm),
              Text('4.5 (112)', style: BhTextStyles.body),
            ],
          ),
          const SizedBox(height: BhSpacing.xl),
          _SectionTitle('Card'),
          const SizedBox(height: BhSpacing.sm),
          Container(
            padding: const EdgeInsets.all(BhSpacing.md),
            decoration: BoxDecoration(
              color: BhColors.white,
              borderRadius: BorderRadius.circular(BhRadii.card),
              boxShadow: BhShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knotless box braids', style: BhTextStyles.title),
                const SizedBox(height: BhSpacing.unit),
                Text('from R650 · 1.2 km away', style: BhTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: BhSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(label, style: BhTextStyles.display);
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final needsBorder = color == BhColors.white || color == BhColors.porcelain;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(BhRadii.imageTile),
            border: needsBorder ? Border.all(color: BhColors.line) : null,
          ),
        ),
        const SizedBox(height: BhSpacing.unit),
        Text(name, style: BhTextStyles.caption),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display 26 / Fraunces 600', style: BhTextStyles.display),
        const SizedBox(height: BhSpacing.xs),
        Text('Title 19 / Fraunces 600', style: BhTextStyles.title),
        const SizedBox(height: BhSpacing.xs),
        Text('Body 13.5 / Karla 400', style: BhTextStyles.body),
        const SizedBox(height: BhSpacing.xs),
        Text('Caption 11.5 / Karla 400', style: BhTextStyles.caption),
      ],
    );
  }
}
