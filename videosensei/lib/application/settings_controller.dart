import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/storage/settings_repository.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.load();
  }

  Future<void> update(AppSettings Function(AppSettings) updater) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = updater(current);
    state = AsyncData(updated);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.save(updated);
  }

  Future<void> completeOnboarding() =>
      update((s) => s.copyWith(onboardingComplete: true));
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
