import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'goals_provider.dart';
import 'entries_provider.dart';
import 'arc_provider.dart';

class ArcStats {
  final int currentStreak;
  final int longestStreak;
  final double overallCompletionRate; // 0.0 to 100.0
  final int totalActiveDays;
  final Map<String, int> goalStreaks; // goalId -> streak
  final Map<String, double> heatmapRatios; // yyyy-MM-dd -> 0.0 to 1.0

  const ArcStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.overallCompletionRate,
    required this.totalActiveDays,
    required this.goalStreaks,
    required this.heatmapRatios,
  });
}

final statsProvider = Provider<ArcStats>((ref) {
  final goals = ref.watch(goalsProvider);
  final entries = ref.watch(dailyEntriesProvider);
  final arc = ref.watch(arcProvider);

  final dateFormat = DateFormat('yyyy-MM-dd');
  final today = DateTime.now();

  final goalCount = goals.length;
  if (goalCount == 0) {
    return const ArcStats(
      currentStreak: 0,
      longestStreak: 0,
      overallCompletionRate: 0.0,
      totalActiveDays: 0,
      goalStreaks: {},
      heatmapRatios: {},
    );
  }

  // 1. Calculate completion per date
  final dateCompletionCounts = <String, int>{};

  for (final entry in entries.values) {
    if (entry.completed) {
      dateCompletionCounts[entry.date] =
          (dateCompletionCounts[entry.date] ?? 0) + 1;
    }
  }

  // Calculate heatmap ratios
  final heatmapRatios = <String, double>{};
  for (final dateKey in dateCompletionCounts.keys) {
    final completedCount = dateCompletionCounts[dateKey] ?? 0;
    heatmapRatios[dateKey] = (completedCount / goalCount).clamp(0.0, 1.0);
  }

  // Total active days: days where at least 1 goal was completed
  final totalActiveDays = dateCompletionCounts.length;

  // 2. Calculate Current & Longest Streak
  int currentStreak = 0;
  int longestStreak = 0;
  int tempStreak = 0;

  // Iterate from arc startDate to today
  final startDate =
      DateTime(arc.startDate.year, arc.startDate.month, arc.startDate.day);
  final endDate = DateTime(today.year, today.month, today.day);

  // If start is after today, no streak yet
  if (!startDate.isAfter(endDate)) {
    // Check backwards from today for current streak
    DateTime checkDate = endDate;
    final todayHasProgress =
        (dateCompletionCounts[dateFormat.format(checkDate)] ?? 0) > 0;

    // If today has no progress yet, check if yesterday had progress so we don't break streak before today ends
    if (!todayHasProgress) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (!checkDate.isBefore(startDate)) {
      final key = dateFormat.format(checkDate);
      if ((dateCompletionCounts[key] ?? 0) > 0) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate longest streak historically
    DateTime loopDate = startDate;
    while (!loopDate.isAfter(endDate)) {
      final key = dateFormat.format(loopDate);
      if ((dateCompletionCounts[key] ?? 0) > 0) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
      loopDate = loopDate.add(const Duration(days: 1));
    }
  }

  // 3. Overall Completion Rate
  int totalCompletedEntries = 0;
  for (final count in dateCompletionCounts.values) {
    totalCompletedEntries += count;
  }
  final daysElapsed = arc.currentDayNumber;
  final totalPossible = daysElapsed * goalCount;
  final overallRate = totalPossible > 0
      ? (totalCompletedEntries / totalPossible) * 100.0
      : 0.0;

  // 4. Per Goal Streaks
  final goalStreaks = <String, int>{};
  for (final goal in goals) {
    int gStreak = 0;
    DateTime check = endDate;
    final todayDone =
        entries['${dateFormat.format(check)}_${goal.id}']?.completed ?? false;
    if (!todayDone) {
      check = check.subtract(const Duration(days: 1));
    }
    while (!check.isBefore(startDate)) {
      final key = '${dateFormat.format(check)}_${goal.id}';
      if (entries[key]?.completed == true) {
        gStreak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    goalStreaks[goal.id] = gStreak;
  }

  return ArcStats(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    overallCompletionRate: overallRate.clamp(0.0, 100.0),
    totalActiveDays: totalActiveDays,
    goalStreaks: goalStreaks,
    heatmapRatios: heatmapRatios,
  );
});
