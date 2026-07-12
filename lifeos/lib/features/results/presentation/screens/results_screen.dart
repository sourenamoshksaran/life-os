import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/results_controller.dart';
import '../../domain/result.dart';

/// See docs/rfc/RFC-012_Results.md §6: Results never lies about being
/// final — Provisional vs. Finalized is always visibly distinguished.
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(todayResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (result) => ListView(
          padding: const EdgeInsets.all(LifeOSSpacing.md),
          children: [
            _LifeScoreCard(result: result),
            const SizedBox(height: LifeOSSpacing.md),
            _ComponentBreakdown(result: result),
            const SizedBox(height: LifeOSSpacing.lg),
            if (result.isProvisional)
              FilledButton(
                onPressed: () async {
                  await ref.read(finalizeDailyResultUseCaseProvider).call(result);
                  ref.invalidate(todayResultProvider);
                },
                child: const Text('Finalize Today (Daily Closing)'),
              )
            else
              const Text('Finalized',
                  style: TextStyle(color: LifeOSColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _LifeScoreCard extends StatelessWidget {
  const _LifeScoreCard({required this.result});
  final Result result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LifeOSSpacing.lg),
      decoration: BoxDecoration(
        color: LifeOSColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(result.isProvisional ? 'Life Score (Live)' : 'Life Score',
              style: const TextStyle(color: LifeOSColors.textSecondary)),
          const SizedBox(height: LifeOSSpacing.sm),
          Text('${result.lifeScore}',
              style: const TextStyle(
                  color: LifeOSColors.primary, fontSize: 48, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ComponentBreakdown extends StatelessWidget {
  const _ComponentBreakdown({required this.result});
  final Result result;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, int)>[
      ('Task', result.taskScore),
      ('Session Quality', result.sessionQualityScore),
      ('Workout', result.workoutScore),
      ('Learning', result.learningScore),
      ('Sleep', result.sleepScore),
      ('Nutrition', result.nutritionScore),
      ('Consistency', result.consistencyScore),
    ];
    return Column(
      children: rows
          .map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: LifeOSSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1, style: const TextStyle(color: LifeOSColors.textPrimary)),
                    Text('${r.$2}', style: const TextStyle(color: LifeOSColors.textSecondary)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
