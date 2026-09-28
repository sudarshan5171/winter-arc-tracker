import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isLarge;

  const StreakBadge({
    super.key,
    required this.streak,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasStreak = streak > 0;

    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasStreak
              ? AppColors.flameOrange.withAlpha((0.12 * 255).round())
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasStreak
                ? AppColors.flameOrange.withAlpha((0.35 * 255).round())
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasStreak ? '🔥' : '❄️',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              '$streak ${streak == 1 ? "day" : "days"}',
              style: TextStyle(
                color: hasStreak
                    ? (isDark ? const Color(0xFFFF9E44) : AppColors.flameOrange)
                    : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Small badge inside goal card
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasStreak
            ? AppColors.flameOrange.withAlpha((0.12 * 255).round())
            : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasStreak
              ? AppColors.flameOrange.withAlpha((0.25 * 255).round())
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: TextStyle(
              color: hasStreak
                  ? (isDark ? const Color(0xFFFF9E44) : AppColors.flameOrange)
                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
