import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../core/services/date_manager.dart';
import '../../controllers/task_controller.dart';
import '../../domain/task.dart';

/// Demonstrates the full pattern mandated by CLAUDE.md/MASTER_PROMPT.md:
/// a feature screen that reads AsyncNotifier state, starts/finishes a
/// Task's Session exclusively through the Core Session Engine, and never
/// implements its own timer.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    final activeSessionAsync = ref.watch(activeSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.barbell),
            tooltip: 'Workout',
            onPressed: () => context.go('/tasks/workout'),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.graduationCap),
            tooltip: 'Learning',
            onPressed: () => context.go('/tasks/learning'),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.forkKnife),
            tooltip: 'Nutrition',
            onPressed: () => context.go('/tasks/nutrition'),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.pill),
            tooltip: 'Medicine',
            onPressed: () => context.go('/tasks/medicine'),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.moonStars),
            tooltip: 'Sleep',
            onPressed: () => context.go('/tasks/sleep'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSampleTask(ref),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet — tap + to add one.',
                style: TextStyle(color: LifeOSColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(LifeOSSpacing.md),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: LifeOSSpacing.sm),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final activeSession = activeSessionAsync.valueOrNull;
              final isThisTaskRunning =
                  activeSession != null && activeSession.contextId == task.id;
              return _TaskCard(
                task: task,
                isRunning: isThisTaskRunning,
                hasAnyActiveSession: activeSession != null,
                onStart: () => _startSession(context, ref, task),
                onFinish: isThisTaskRunning
                    ? () => _finishSession(context, ref, activeSession, task)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addSampleTask(WidgetRef ref) async {
    final now = DateTime.now();
    const dateManager = DateManager();
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
      title: 'New Task',
      status: TaskStatus.planned,
      priority: TaskPriority.medium,
      localDate: dateManager.today(),
    );
    await ref.read(taskListProvider.notifier).addTask(task);
  }

  Future<void> _startSession(
      BuildContext context, WidgetRef ref, Task task) async {
    try {
      await ref.read(startTaskSessionUseCaseProvider).call(task);
      ref.invalidate(activeSessionProvider);
      await ref.read(taskListProvider.notifier).refresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _finishSession(BuildContext context, WidgetRef ref,
      dynamic activeSession, Task task) async {
    await ref.read(finishTaskSessionUseCaseProvider).call(
          sessionId: activeSession.id,
          task: task,
          focusScore: 7,
          energyScore: 7,
          difficultyScore: 5,
        );
    ref.invalidate(activeSessionProvider);
    await ref.read(taskListProvider.notifier).refresh();
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.isRunning,
    required this.hasAnyActiveSession,
    required this.onStart,
    required this.onFinish,
  });

  final Task task;
  final bool isRunning;
  final bool hasAnyActiveSession;
  final VoidCallback onStart;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LifeOSSpacing.md),
      decoration: BoxDecoration(
        color: LifeOSColors.card,
        borderRadius: BorderRadius.circular(16),
        border: isRunning
            ? Border.all(color: LifeOSColors.primary, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        color: LifeOSColors.textPrimary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: LifeOSSpacing.xs),
                Text(task.status.name,
                    style: const TextStyle(color: LifeOSColors.textSecondary)),
              ],
            ),
          ),
          if (isRunning)
            TextButton.icon(
              onPressed: onFinish,
              icon: const Icon(PhosphorIconsRegular.checkCircle),
              label: const Text('Finish'),
            )
          else
            IconButton(
              onPressed: hasAnyActiveSession ? null : onStart,
              icon: const Icon(PhosphorIconsRegular.play),
              tooltip: hasAnyActiveSession
                  ? 'Another session is already active'
                  : 'Start session',
            ),
        ],
      ),
    );
  }
}
