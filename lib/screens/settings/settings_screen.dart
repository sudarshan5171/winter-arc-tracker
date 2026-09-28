import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/arc_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/entries_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/notification_service.dart';
import '../modals/add_edit_goal_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final arc = ref.read(arcProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(
        start: arc.startDate,
        end: arc.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surfaceDark,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: AppColors.surfaceLight,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(arcProvider.notifier).updateArc(
            startDate: picked.start,
            endDate: picked.end,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Winter Arc dates updated')),
        );
      }
    }
  }

  void _confirmResetStreaks(BuildContext context, WidgetRef ref) {
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
        title: const Text('Reset All Streak Data?'),
        content: const Text(
          'This will permanently clear all daily progress and habit entries for this Winter Arc. Your goals will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              await ref.read(dailyEntriesProvider.notifier).clearAll();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All streak data has been reset')),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arc = ref.watch(arcProvider);
    final goals = ref.watch(goalsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final reminder = ref.watch(reminderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final dateFormat = DateFormat('MMM d, yyyy');
    final startDateStr = dateFormat.format(arc.startDate);
    final endDateStr = dateFormat.format(arc.endDate);

    final cardBg = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final reminderHour = reminder.hour;
    final reminderMinute = reminder.minute;
    final reminderTimeOfDay = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    final reminderTimeString = reminderTimeOfDay.format(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES & CHALLENGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Settings',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1: Winter Arc Timeline
                    _SectionHeader(title: 'Winter Arc Timeline'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListTile(
                        onTap: () => _pickDateRange(context, ref),
                        leading: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('📅', style: TextStyle(fontSize: 18)),
                        ),
                        title: const Text('Duration & Dates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('$startDateStr — $endDateStr (${arc.totalDays} days)', style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: Appearance & Theme
                    _SectionHeader(title: 'Appearance'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: SwitchListTile(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                        secondary: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(themeMode == ThemeMode.dark ? '🌙' : '☀️', style: const TextStyle(fontSize: 18)),
                        ),
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          themeMode == ThemeMode.dark ? 'Near-black theme' : 'Crisp white theme',
                          style: const TextStyle(fontSize: 12),
                        ),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: Daily Reminders
                    _SectionHeader(title: 'Daily Reminders'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: reminder.isEnabled,
                            onChanged: (val) {
                              ref.read(reminderProvider.notifier).setEnabled(val);
                            },
                            secondary: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🔔', style: TextStyle(fontSize: 18)),
                            ),
                            title: const Text('Daily Habit Reminder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              reminder.isEnabled
                                  ? 'Notifying daily at $reminderTimeString'
                                  : 'Reminders are turned off',
                              style: const TextStyle(fontSize: 12),
                            ),
                            activeThumbColor: AppColors.primary,
                          ),
                          if (reminder.isEnabled) ...[
                            const Divider(height: 1),
                            ListTile(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: reminderTimeOfDay,
                                  builder: (context, child) {
                                    return Theme(
                                      data: isDark
                                          ? ThemeData.dark().copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: AppColors.primary,
                                                surface: AppColors.surfaceDark,
                                              ),
                                            )
                                          : ThemeData.light().copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: AppColors.primary,
                                                surface: AppColors.surfaceLight,
                                              ),
                                            ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  ref
                                      .read(reminderProvider.notifier)
                                      .setTime(picked.hour, picked.minute);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Daily reminder set for ${picked.format(context)}'),
                                      ),
                                    );
                                  }
                                }
                              },
                              leading: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('⏰', style: TextStyle(fontSize: 18)),
                              ),
                              title: const Text('Reminder Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(reminderTimeString, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              onTap: () async {
                                await NotificationService.showTestNotification();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Test notification sent!')),
                                  );
                                }
                              },
                              leading: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('✨', style: TextStyle(fontSize: 18)),
                              ),
                              title: const Text('Send Test Notification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: const Text('Verify that alerts appear properly', style: TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: Manage & Reorder Goals Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionHeader(title: 'Manage Goals (${goals.length})'),
                        TextButton.icon(
                          onPressed: () => AddEditGoalSheet.show(context),
                          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                          label: const Text('Add Goal', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Reorderable Goals List
            if (goals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text('No goals added yet', style: theme.textTheme.bodyMedium),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverReorderableList(
                  itemCount: goals.length,
                  onReorder: (oldIdx, newIdx) {
                    ref.read(goalsProvider.notifier).reorderGoals(oldIdx, newIdx);
                  },
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(goal.id),
                      index: index,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                          border: Border.all(color: borderColor),
                        ),
                        child: ListTile(
                          onTap: () => AddEditGoalSheet.show(context, goal: goal),
                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(goal.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: goal.isNumeric && goal.targetValue != null
                              ? Text('Target: ${goal.targetValue} ${goal.unit ?? ""}', style: const TextStyle(fontSize: 12))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.dangerRed),
                                onPressed: () {
                                  ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                                },
                              ),
                              const Icon(Icons.drag_handle, size: 20, color: AppColors.textMutedLight),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // SECTION 4: Danger Zone
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Data & Reset'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppDefaults.borderRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListTile(
                        onTap: () => _confirmResetStreaks(context, ref),
                        leading: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.refresh, color: AppColors.dangerRed, size: 20),
                        ),
                        title: const Text(
                          'Reset Streak Data',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.dangerRed,
                          ),
                        ),
                        subtitle: const Text(
                          'Clear progress while keeping active goals',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}
