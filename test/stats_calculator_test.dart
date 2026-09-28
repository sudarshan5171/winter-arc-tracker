import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wa_tracker/models/winter_arc_model.dart';
import 'package:wa_tracker/models/goal_model.dart';
import 'package:wa_tracker/providers/arc_provider.dart';
import 'package:wa_tracker/providers/goals_provider.dart';
import 'package:wa_tracker/providers/entries_provider.dart';
import 'package:wa_tracker/providers/stats_provider.dart';

class TestArcNotifier extends ArcNotifier {
  final WinterArc initial;
  TestArcNotifier(this.initial);

  @override
  WinterArc build() => initial;
}

void main() {
  group('WinterArc Models and Stats Calculation Tests', () {
    test('WinterArc date calculations', () {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 89));

      final arc = WinterArc(startDate: start, endDate: end);
      expect(arc.totalDays, 90);
      expect(arc.currentDayNumber, 1);
      expect(arc.daysRemaining, 89);
    });

    test('Stats calculation with goals and entries', () {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2));
      final end = start.add(const Duration(days: 89));
      final testArc = WinterArc(startDate: start, endDate: end, isOnboarded: true);

      final container = ProviderContainer(
        overrides: [
          arcProvider.overrideWith(() => TestArcNotifier(testArc)),
        ],
      );

      final dateFormat = DateFormat('yyyy-MM-dd');
      final todayStr = dateFormat.format(now);
      final yesterdayStr = dateFormat.format(now.subtract(const Duration(days: 1)));

      final goal1 = Goal(
        id: 'g1',
        title: 'Workout',
        icon: '🏋️',
        createdAt: now,
      );
      final goal2 = Goal(
        id: 'g2',
        title: 'Water Intake',
        icon: '💧',
        targetValue: 3000,
        unit: 'ml',
        createdAt: now,
      );

      container.read(goalsProvider.notifier).addMultipleGoals([goal1, goal2]);

      // Complete goals yesterday and today
      container.read(dailyEntriesProvider.notifier).toggleCompletion(yesterdayStr, 'g1');
      container.read(dailyEntriesProvider.notifier).toggleCompletion(yesterdayStr, 'g2');
      container.read(dailyEntriesProvider.notifier).toggleCompletion(todayStr, 'g1');

      final stats = container.read(statsProvider);

      expect(stats.currentStreak >= 2, true);
      expect(stats.totalActiveDays, 2);
      expect(stats.heatmapRatios[yesterdayStr], 1.0);
      expect(stats.heatmapRatios[todayStr], 0.5);
    });
  });
}
