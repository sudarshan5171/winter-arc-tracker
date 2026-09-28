import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/goal_model.dart';
import '../../../models/daily_entry_model.dart';
import '../../../providers/entries_provider.dart';
import '../../modals/add_edit_goal_sheet.dart';
import 'streak_badge.dart';

class GoalCard extends ConsumerWidget {
  final Goal goal;
  final String date;
  final int streak;

  const GoalCard({
    super.key,
    required this.goal,
    required this.date,
    required this.streak,
  });

  void _showNumericAdjustDialog(BuildContext context, WidgetRef ref, DailyEntry? entry) {
    final currentValue = entry?.value ?? 0;
    final targetValue = goal.targetValue ?? 100;
    final controller = TextEditingController(text: currentValue > 0 ? '$currentValue' : '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        title: Text(
          'Update ${goal.title}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target: $targetValue ${goal.unit ?? ""}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                suffixText: goal.unit,
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim()) ?? 0;
              ref.read(dailyEntriesProvider.notifier).updateValue(
                    date,
                    goal.id,
                    val,
                    targetValue: goal.targetValue,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(dailyEntriesProvider);
    final entry = entries['${date}_${goal.id}'];
    final isCompleted = entry?.completed ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final currentValue = entry?.value ?? 0;
    final targetValue = goal.targetValue;
    final isNumeric = goal.isNumeric;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withAlpha((0.5 * 255).round())
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isCompleted ? 1.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
        child: InkWell(
          onTap: () {
            if (isNumeric) {
              _showNumericAdjustDialog(context, ref, entry);
            } else {
              ref.read(dailyEntriesProvider.notifier).toggleCompletion(
                    date,
                    goal.id,
                    targetValue: goal.targetValue,
                  );
            }
          },
          onLongPress: () {
            AddEditGoalSheet.show(context, goal: goal);
          },
          borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Goal Emoji Icon in container
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isDark
                            ? AppColors.primarySubtleDark
                            : AppColors.primarySubtleLight)
                        : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primary.withAlpha((0.4 * 255).round())
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    goal.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle / Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textMutedLight,
                                color: isCompleted
                                    ? (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight)
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          StreakBadge(streak: streak),
                        ],
                      ),
                      if (isNumeric && targetValue != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$currentValue / $targetValue ${goal.unit ?? ""}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isCompleted
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Stepper / Quick Action for Numeric goals OR Checkbox circle
                if (isNumeric) ...[
                  // Numeric inline decrement/increment buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepButton(
                        icon: Icons.remove,
                        onTap: () {
                          final nextVal = (currentValue - 1).clamp(0, 999999);
                          ref.read(dailyEntriesProvider.notifier).updateValue(
                                date,
                                goal.id,
                                nextVal,
                                targetValue: goal.targetValue,
                              );
                        },
                      ),
                      const SizedBox(width: 4),
                      _StepButton(
                        icon: Icons.add,
                        onTap: () {
                          final nextVal = currentValue + 1;
                          ref.read(dailyEntriesProvider.notifier).updateValue(
                                date,
                                goal.id,
                                nextVal,
                                targetValue: goal.targetValue,
                              );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                ],

                // Checkbox / Tap-to-complete target (min 48x48 tap zone)
                SizedBox(
                  width: AppDefaults.minTapTarget,
                  height: AppDefaults.minTapTarget,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    onPressed: () {
                      ref.read(dailyEntriesProvider.notifier).toggleCompletion(
                            date,
                            goal.id,
                            targetValue: goal.targetValue,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
