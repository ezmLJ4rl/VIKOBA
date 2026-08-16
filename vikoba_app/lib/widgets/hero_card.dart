import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A small supporting stat shown as a pill chip on the [HeroCard].
class HeroChip {
  const HeroChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

/// The money-first hero card that leads every screen.
///
/// Shows the single most important number for that screen in large Fraunces
/// serif type on a dark forest gradient (or gold gradient for the share-out
/// screen), with 2–3 supporting stats as pill chips below.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.title,
    required this.value,
    this.chips = const [],
    this.gold = false,
    this.valueColor,
  });

  final String title;
  final String value;
  final List<HeroChip> chips;

  /// Gold-gradient variant (share-out screen).
  final bool gold;

  /// Optional override for the hero number colour.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final onHero = gold ? AppColors.forestDeep : Colors.white;
    final gradient = gold
        ? [AppColors.gold, AppColors.goldDeep]
        : [AppColors.forest, AppColors.forestDeep];
    final chipBg = gold ? Colors.white : Colors.white.withValues(alpha: 0.16);
    final chipFg = gold ? AppColors.forestDeep : Colors.white;

    return Semantics(
      header: true,
      label: '$title, $value',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.body(13, FontWeight.w500,
                  color: gold ? AppColors.forestDeep.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.displayFont(
                31,
                FontWeight.w600,
                color: valueColor ?? onHero,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chip in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(chip.icon, size: 13, color: chipFg),
                          const SizedBox(width: 5),
                          Text(
                            '${chip.value}  ${chip.label}',
                            style: AppFonts.body(11.5, FontWeight.w600,
                                color: chipFg),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}