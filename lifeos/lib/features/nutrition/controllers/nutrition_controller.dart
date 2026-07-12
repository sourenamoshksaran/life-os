import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/base_entity.dart';
import '../../../core/services/date_manager.dart';
import '../data/in_memory_nutrition_repository.dart';
import '../domain/nutrition.dart';
import '../domain/nutrition_repository.dart';

const _dateManager = DateManager();

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return InMemoryNutritionRepository();
});

final todayWaterLogProvider =
    AsyncNotifierProvider<TodayWaterLogNotifier, List<WaterLog>>(TodayWaterLogNotifier.new);

class TodayWaterLogNotifier extends AsyncNotifier<List<WaterLog>> {
  @override
  Future<List<WaterLog>> build() =>
      ref.watch(nutritionRepositoryProvider).getWaterByDate(_dateManager.today());

  /// Quick water-add (e.g. +250ml) — RFC-010 §6/§12, must never take
  /// more than 3 taps.
  Future<void> quickAdd(double amountMl) async {
    final now = DateTime.now();
    await ref.read(nutritionRepositoryProvider).saveWater(WaterLog(
          id: BaseEntity.newId(),
          createdAt: now,
          updatedAt: now,
          amount: amountMl,
          time: now,
          localDate: _dateManager.today(),
        ));
    ref.invalidateSelf();
    await future;
  }
}

final todayNutritionProvider =
    AsyncNotifierProvider<TodayNutritionNotifier, List<NutritionEntry>>(
        TodayNutritionNotifier.new);

class TodayNutritionNotifier extends AsyncNotifier<List<NutritionEntry>> {
  @override
  Future<List<NutritionEntry>> build() =>
      ref.watch(nutritionRepositoryProvider).getByDate(_dateManager.today());

  Future<void> addMeal(NutritionEntry entry) async {
    await ref.read(nutritionRepositoryProvider).saveEntry(entry);
    ref.invalidateSelf();
    await future;
  }
}
