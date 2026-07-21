import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storage/history_repository.dart';

class HistoryController extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() async {
    final repo = ref.watch(historyRepositoryProvider);
    return repo.getAll();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.deleteById(id);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.clearAll();
    ref.invalidateSelf();
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<HistoryEntry>>(
  HistoryController.new,
);
