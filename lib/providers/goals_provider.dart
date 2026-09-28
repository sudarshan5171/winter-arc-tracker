import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

final goalsProvider =
    NotifierProvider<GoalsNotifier, List<Goal>>(GoalsNotifier.new);

class GoalsNotifier extends Notifier<List<Goal>> {
  @override
  List<Goal> build() {
    return StorageService.getGoals();
  }

  Future<void> addGoal(Goal goal) async {
    final updated = [...state, goal.copyWith(order: state.length)];
    state = updated;
    await StorageService.saveGoal(goal);
    SyncService.syncGoals(updated);
  }

  Future<void> addMultipleGoals(List<Goal> goals) async {
    final list = List<Goal>.from(state);
    for (int i = 0; i < goals.length; i++) {
      list.add(goals[i].copyWith(order: list.length));
    }
    state = list;
    await StorageService.saveGoals(list);
    SyncService.syncGoals(list);
  }

  Future<void> updateGoal(Goal goal) async {
    final updated = state.map((g) => g.id == goal.id ? goal : g).toList();
    state = updated;
    await StorageService.saveGoal(goal);
    SyncService.syncGoals(updated);
  }

  Future<void> deleteGoal(String goalId) async {
    final updated = state.where((g) => g.id != goalId).toList();
    // Re-index orders
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i);
    }
    state = updated;
    await StorageService.deleteGoal(goalId);
    await StorageService.saveGoals(updated);
    SyncService.syncGoals(updated);
  }

  Future<void> reorderGoals(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final list = List<Goal>.from(state);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    state = list;
    await StorageService.saveGoals(list);
    SyncService.syncGoals(list);
  }
}
