import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_settings_repository.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return InMemorySettingsRepository();
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Thrown when a toggle would leave zero active Life Score components —
/// see docs/rfc/RFC-014_Settings.md §7.
class ModuleToggleBlockedException implements Exception {
  @override
  String toString() =>
      'At least one module must remain active for Life Score to be meaningful.';
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.watch(settingsRepositoryProvider).getSettings();

  Future<void> toggleModule(String moduleName, bool enabled) async {
    final current = await future;
    final updatedToggles = {...current.moduleToggles, moduleName: enabled};

    if (!enabled && updatedToggles.values.every((v) => !v)) {
      throw ModuleToggleBlockedException();
    }

    final updated = AppSettings(
      language: current.language,
      theme: current.theme,
      notificationSound: current.notificationSound,
      gracePeriodMinutes: current.gracePeriodMinutes,
      moduleToggles: updatedToggles,
      encryptionEnabled: current.encryptionEnabled,
    );
    await ref.read(settingsRepositoryProvider).saveSettings(updated);
    ref.invalidateSelf();
    await future;
  }
}

final dailyGoalsProvider =
    AsyncNotifierProvider<DailyGoalsNotifier, DailyGoals>(DailyGoalsNotifier.new);

class DailyGoalsNotifier extends AsyncNotifier<DailyGoals> {
  @override
  Future<DailyGoals> build() => ref.watch(settingsRepositoryProvider).getDailyGoals();

  Future<void> updateGoals(DailyGoals goals) async {
    await ref.read(settingsRepositoryProvider).saveDailyGoals(goals);
    ref.invalidateSelf();
    await future;
  }
}

final currentUserProvider = FutureProvider<AppUser?>((ref) {
  return ref.watch(settingsRepositoryProvider).getUser();
});
