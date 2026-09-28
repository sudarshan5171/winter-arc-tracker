import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_entry_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

final dailyEntriesProvider =
    NotifierProvider<DailyEntriesNotifier, Map<String, DailyEntry>>(
        DailyEntriesNotifier.new);

class DailyEntriesNotifier extends Notifier<Map<String, DailyEntry>> {
  @override
  Map<String, DailyEntry> build() {
    return StorageService.getDailyEntries();
  }

  DailyEntry? getEntry(String date, String goalId) {
    return state['${date}_$goalId'];
  }

  Future<void> toggleCompletion(String date, String goalId,
      {int? targetValue}) async {
    final key = '${date}_$goalId';
    final existing = state[key];
    final isCurrentlyCompleted = existing?.completed ?? false;
    final nextCompleted = !isCurrentlyCompleted;

    int? nextValue = existing?.value;
    if (targetValue != null) {
      if (nextCompleted) {
        nextValue = targetValue;
      } else {
        nextValue = 0;
      }
    }

    final entry = DailyEntry(
      date: date,
      goalId: goalId,
      completed: nextCompleted,
      value: nextValue,
    );

    final updated = Map<String, DailyEntry>.from(state);
    updated[key] = entry;
    state = updated;

    await StorageService.saveDailyEntry(entry);
    SyncService.syncDailyEntry(entry);
  }

  Future<void> updateValue(
    String date,
    String goalId,
    int? value, {
    int? targetValue,
  }) async {
    final key = '${date}_$goalId';
    final existing = state[key];

    // If target value is present, complete when value >= targetValue
    bool isCompleted = existing?.completed ?? false;
    if (targetValue != null && value != null) {
      isCompleted = value >= targetValue;
    }

    final entry = DailyEntry(
      date: date,
      goalId: goalId,
      completed: isCompleted,
      value: value,
    );

    final updated = Map<String, DailyEntry>.from(state);
    updated[key] = entry;
    state = updated;

    await StorageService.saveDailyEntry(entry);
    SyncService.syncDailyEntry(entry);
  }

  Future<void> clearAll() async {
    state = {};
    await StorageService.clearAllEntries();
  }
}
