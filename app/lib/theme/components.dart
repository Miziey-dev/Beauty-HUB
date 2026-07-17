import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'tokens.dart';

/// Full-width primary CTA: hibiscus background, white 800-weight label,
/// subtle hibiscus glow shadow.
class BhPrimaryButton extends StatelessWidget {
  const BhPrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BhRadii.button),
        boxShadow: onPressed == null ? null : BhShadows.primaryButtonGlow,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BhColors.hibiscus,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.button)),
        ),
        child: Text(label, style: BhTextStyles.buttonLabel),
      ),
    );
  }
}

/// Low-emphasis secondary action: transparent background, inkPlum label,
/// hairline border -- for actions that shouldn't compete with a primary
/// button on the same screen.
class BhGhostButton extends StatelessWidget {
  const BhGhostButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: BhColors.inkPlum,
          side: const BorderSide(color: BhColors.line),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.button)),
        ),
        child: Text(label, style: BhTextStyles.bodyBold.copyWith(color: BhColors.inkPlum)),
      ),
    );
  }
}

/// Selectable pill chip -- category filters, toggles.
class BhChip extends StatelessWidget {
  const BhChip({super.key, required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BhRadii.chip),
      child: AnimatedContainer(
        duration: BhDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: BhSpacing.md, vertical: BhSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? BhColors.hibiscusSoft : BhColors.white,
          borderRadius: BorderRadius.circular(BhRadii.chip),
          border: Border.all(color: selected ? BhColors.hibiscus : BhColors.line),
        ),
        child: Text(
          label,
          style: BhTextStyles.bodyBold.copyWith(
            color: selected ? BhColors.hibiscus : BhColors.inkPlum,
          ),
        ),
      ),
    );
  }
}

/// Small status label -- e.g. "Verified", "Mobile", "Hair included".
enum BhBadgeTone { neutral, success, gold }

class BhBadge extends StatelessWidget {
  const BhBadge({super.key, required this.label, this.tone = BhBadgeTone.neutral, this.icon});

  final String label;
  final BhBadgeTone tone;
  final IconData? icon;

  Color get _foreground => switch (tone) {
        BhBadgeTone.success => BhColors.confirmGreen,
        BhBadgeTone.gold => BhColors.gold,
        BhBadgeTone.neutral => BhColors.mauve,
      };

  Color get _background => switch (tone) {
        BhBadgeTone.success => BhColors.confirmGreen.withValues(alpha: 0.12),
        BhBadgeTone.gold => BhColors.gold.withValues(alpha: 0.14),
        BhBadgeTone.neutral => BhColors.hibiscusSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BhSpacing.xs, vertical: BhSpacing.unit),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(BhRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: BhFontSize.caption, color: _foreground),
            const SizedBox(width: BhSpacing.unit),
          ],
          Text(label, style: BhTextStyles.caption.copyWith(color: _foreground, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Star rating display, gold fill up to [rating] (out of [max], default 5).
class BhRatingStars extends StatelessWidget {
  const BhRatingStars({super.key, required this.rating, this.max = 5, this.size = 16});

  final double rating;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final filled = rating >= index + 1;
        final half = !filled && rating > index && rating < index + 1;
        return Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          size: size,
          color: BhColors.gold,
        );
      }),
    );
  }
}
