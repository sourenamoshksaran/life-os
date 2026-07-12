import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/models/base_entity.dart';
import '../../../../core/services/date_manager.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/nutrition_controller.dart';
import '../../domain/nutrition.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterLogProvider);
    final mealsAsync = ref.watch(todayNutritionProvider);
    final totalWater =
        waterAsync.valueOrNull?.fold<double>(0, (sum, w) => sum + w.amount) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSampleMeal(ref),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(LifeOSSpacing.md),
            decoration:
                BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Water: ${totalWater.toStringAsFixed(0)} ml',
                    style: const TextStyle(color: LifeOSColors.textPrimary)),
                const SizedBox(height: LifeOSSpacing.sm),
                Wrap(
                  spacing: LifeOSSpacing.sm,
                  children: [250, 500].map((ml) {
                    return OutlinedButton(
                      onPressed: () =>
                          ref.read(todayWaterLogProvider.notifier).quickAdd(ml.toDouble()),
                      child: Text('+${ml}ml'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: LifeOSSpacing.md),
          mealsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (meals) => Column(
              children: meals
                  .map((m) => ListTile(
                        title: Text(m.mealType.name,
                            style: const TextStyle(color: LifeOSColors.textPrimary)),
                        subtitle: Text('${m.calories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(color: LifeOSColors.textSecondary)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleMeal(WidgetRef ref) async {
    final now = DateTime.now();
    const dateManager = DateManager();
    await ref.read(todayNutritionProvider.notifier).addMeal(NutritionEntry(
          id: BaseEntity.newId(),
          createdAt: now,
          updatedAt: now,
          mealType: MealType.lunch,
          localDate: dateManager.today(),
          calories: 550,
        ));
  }
}
