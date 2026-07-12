import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final goalsAsync = ref.watch(dailyGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(LifeOSSpacing.md),
          children: [
            const Text('Life Score Components',
                style: TextStyle(color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: LifeOSSpacing.sm),
            ...settings.moduleToggles.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key, style: const TextStyle(color: LifeOSColors.textPrimary)),
                value: entry.value,
                onChanged: (value) async {
                  try {
                    await ref.read(settingsProvider.notifier).toggleModule(entry.key, value);
                  } on ModuleToggleBlockedException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
              );
            }),
            const Divider(color: LifeOSColors.textSecondary),
            const Text('Daily Goals',
                style: TextStyle(color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: LifeOSSpacing.sm),
            goalsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (goals) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Water: ${goals.dailyWaterGoalMl.toStringAsFixed(0)} ml',
                      style: const TextStyle(color: LifeOSColors.textSecondary)),
                  Text('Sleep: ${goals.sleepGoalHours.toStringAsFixed(1)} h',
                      style: const TextStyle(color: LifeOSColors.textSecondary)),
                  Text('Calories: ${goals.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                      style: const TextStyle(color: LifeOSColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
