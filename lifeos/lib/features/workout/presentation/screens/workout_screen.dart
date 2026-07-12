import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/workout_controller.dart';
import '../../domain/workout_session_use_cases.dart';

/// Demonstrates the Golden Rule of RFC-008 §12: Workout is just a Session
/// with sets attached — timing is delegated entirely to the Core Session
/// Engine (via `activeWorkoutSessionProvider`, which reads the same
/// single shared engine instance as Task).
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeWorkoutSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (activeSession) {
          if (activeSession == null) {
            return _StartWorkoutView(onStart: () => _start(context, ref));
          }
          return _ActiveWorkoutView(sessionId: activeSession.id);
        },
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(startWorkoutSessionUseCaseProvider).call();
      ref.invalidate(activeWorkoutSessionProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _StartWorkoutView extends StatelessWidget {
  const _StartWorkoutView({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LifeOSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.barbell,
                size: 48, color: LifeOSColors.textSecondary),
            const SizedBox(height: LifeOSSpacing.md),
            const Text(
              'No active workout. Start a freeform session and log sets as you go.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LifeOSColors.textSecondary),
            ),
            const SizedBox(height: LifeOSSpacing.lg),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(PhosphorIconsRegular.play),
              label: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveWorkoutView extends ConsumerWidget {
  const _ActiveWorkoutView({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(workoutSetsForSessionProvider(sessionId));

    return Column(
      children: [
        Expanded(
          child: setsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
            data: (sets) {
              if (sets.isEmpty) {
                return const Center(
                  child: Text('No sets logged yet.',
                      style: TextStyle(color: LifeOSColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(LifeOSSpacing.md),
                itemCount: sets.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: LifeOSSpacing.sm),
                itemBuilder: (context, index) {
                  final set = sets[index];
                  return Card(
                    color: LifeOSColors.card,
                    child: ListTile(
                      title: Text(
                        'Set ${set.setNumber} · ${set.repetitions} reps @ ${set.weight}kg',
                        style: const TextStyle(color: LifeOSColors.textPrimary),
                      ),
                      subtitle: set.rpe != null
                          ? Text('RPE ${set.rpe}',
                              style: const TextStyle(
                                  color: LifeOSColors.textSecondary))
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(LifeOSSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _logSet(ref, setsAsync.valueOrNull?.length ?? 0),
                  icon: const Icon(PhosphorIconsRegular.plus),
                  label: const Text('Log Set'),
                ),
              ),
              const SizedBox(width: LifeOSSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _finish(context, ref),
                  icon: const Icon(PhosphorIconsRegular.checkCircle),
                  label: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _logSet(WidgetRef ref, int currentCount) async {
    await ref.read(logWorkoutSetUseCaseProvider).call(
          sessionId: sessionId,
          exerciseId: 'freeform',
          setNumber: currentCount + 1,
          repetitions: 10,
          weight: 20,
        );
    ref.invalidate(workoutSetsForSessionProvider(sessionId));
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(finishWorkoutSessionUseCaseProvider).call(
            sessionId: sessionId,
            focusScore: 7,
            energyScore: 7,
            difficultyScore: 6,
            painLevel: 1,
          );
      ref.invalidate(activeWorkoutSessionProvider);
    } on NoSetsLoggedException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
