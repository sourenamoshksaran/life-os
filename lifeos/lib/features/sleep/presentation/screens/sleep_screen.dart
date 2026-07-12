import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/sleep_controller.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepAsync = ref.watch(todaySleepLogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logSampleSleep(ref),
        child: const Icon(Icons.add),
      ),
      body: sleepAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (log) {
          if (log == null) {
            return const Center(
              child: Text('No sleep logged for today yet.',
                  style: TextStyle(color: LifeOSColors.textSecondary)),
            );
          }
          final hours = log.duration.inMinutes / 60;
          return Padding(
            padding: const EdgeInsets.all(LifeOSSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(LifeOSSpacing.lg),
              decoration:
                  BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${hours.toStringAsFixed(1)} h',
                      style: const TextStyle(
                          color: LifeOSColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: LifeOSSpacing.xs),
                  Text('Quality: ${log.quality}/10',
                      style: const TextStyle(color: LifeOSColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _logSampleSleep(WidgetRef ref) async {
    final now = DateTime.now();
    await ref.read(todaySleepLogProvider.notifier).logSleep(
          sleepTime: now.subtract(const Duration(hours: 8)),
          wakeTime: now,
          quality: 7,
        );
  }
}
