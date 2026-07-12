import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engines/session_engine/in_memory_session_repository.dart';
import '../../../core/engines/session_engine/session.dart';
import '../../../core/engines/session_engine/session_engine.dart';
import '../../../core/engines/session_engine/session_repository.dart';
import '../data/in_memory_task_repository.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
import '../domain/task_session_use_cases.dart';

// --- Dependency Injection (CLAUDE.md §7) ---

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return InMemorySessionRepository();
});

final sessionEngineProvider = Provider<SessionEngine>((ref) {
  return SessionEngine(ref.watch(sessionRepositoryProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository();
});

final startTaskSessionUseCaseProvider = Provider((ref) {
  return StartTaskSessionUseCase(
    ref.watch(sessionEngineProvider),
    ref.watch(taskRepositoryProvider),
  );
});

final finishTaskSessionUseCaseProvider = Provider((ref) {
  return FinishTaskSessionUseCase(
    ref.watch(sessionEngineProvider),
    ref.watch(taskRepositoryProvider),
  );
});

// --- State (AsyncNotifier per feature, per CLAUDE.md §5) ---

final taskListProvider =
    AsyncNotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return ref.watch(taskRepositoryProvider).getAll();
  }

  Future<void> addTask(Task task) async {
    await ref.read(taskRepositoryProvider).save(task);
    ref.invalidateSelf();
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// The single active Session, of any sessionType — mirrors the Dashboard
/// Mission Widget's read pattern (RFC-005 §6).
final activeSessionProvider = FutureProvider<Session?>((ref) async {
  return ref.watch(sessionEngineProvider).getActiveSession();
});
