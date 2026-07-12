import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../results/controllers/results_controller.dart';
import '../../../tasks/controllers/task_controller.dart';

/// Dashboard. Command Center is Section 03 here, NOT a separate screen —
/// see docs/rfc/RFC-001_Dashboard.md §5 and docs/05_UI_UX_Specification.md
/// amendment. Mission Widget reads the single active Session from the
/// Core Session Engine regardless of its sessionType (RFC-005 §6).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(todayResultProvider);
    final activeSessionAsync = ref.watch(activeSessionProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        children: [
          // Section 01 — Life Score
          resultAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (result) => Container(
              padding: const EdgeInsets.all(LifeOSSpacing.lg),
              decoration:
                  BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(20)),
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
            ),
          ),
          const SizedBox(height: LifeOSSpacing.md),

          // Section 03 — Command Center / Mission Widget (RFC-001 §5)
          Container(
            padding: const EdgeInsets.all(LifeOSSpacing.md),
            decoration: BoxDecoration(
              color: LifeOSColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LifeOSColors.primary.withOpacity(0.4)),
            ),
            child: activeSessionAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (session) {
                if (session == null) {
                  return const Text('No active mission — start a Task, Workout, or Learning session.',
                      style: TextStyle(color: LifeOSColors.textSecondary));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Mission: ${session.sessionType.name}',
                        style: const TextStyle(
                            color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: LifeOSSpacing.xs),
                    Text('Status: ${session.status.name}',
                        style: const TextStyle(color: LifeOSColors.textSecondary)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: LifeOSSpacing.md),

          // Today's Tasks preview
          const Text('Today\'s Tasks',
              style: TextStyle(color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: LifeOSSpacing.sm),
          tasksAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (tasks) => Column(
              children: tasks
                  .take(5)
                  .map((t) => ListTile(
                        title: Text(t.title, style: const TextStyle(color: LifeOSColors.textPrimary)),
                        subtitle: Text(t.status.name,
                            style: const TextStyle(color: LifeOSColors.textSecondary)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
