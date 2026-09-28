import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/winter_arc_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

final arcProvider =
    NotifierProvider<ArcNotifier, WinterArc>(ArcNotifier.new);

class ArcNotifier extends Notifier<WinterArc> {
  @override
  WinterArc build() {
    return StorageService.getWinterArc() ?? WinterArc.defaultArc();
  }

  Future<void> updateArc({
    required DateTime startDate,
    required DateTime endDate,
    bool isOnboarded = true,
  }) async {
    final updated = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      isOnboarded: isOnboarded,
    );
    state = updated;
    await StorageService.saveWinterArc(updated);
    SyncService.syncArc(updated);
  }

  Future<void> setOnboarded(bool value) async {
    final updated = state.copyWith(isOnboarded: value);
    state = updated;
    await StorageService.saveWinterArc(updated);
    SyncService.syncArc(updated);
  }
}
