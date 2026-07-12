import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engines/session_engine/session.dart';
import '../../tasks/controllers/task_controller.dart' show sessionEngineProvider;
import '../data/in_memory_workout_repository.dart';
import '../domain/exercise.dart';
import '../domain/workout.dart';
import '../domain/workout_repository.dart';
import '../domain/workout_session_use_cases.dart';
import '../domain/workout_set.dart';

// --- Dependency Injection (CLAUDE.md §7) ---
// Reuses the single shared `sessionEngineProvider` from the Task module —
// the Core Session Engine is one instance app-wide (RFC-005 §2), never
// re-instantiated per feature.

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return InMemoryExerciseRepository();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return InMemoryWorkoutRepository();
});

final workoutSetRepositoryProvider = Provider<WorkoutSetRepository>((ref) {
  return InMemoryWorkoutSetRepository();
});

final startWorkoutSessionUseCaseProvider = Provider((ref) {
  return StartWorkoutSessionUseCase(ref.watch(sessionEngineProvider));
});

final logWorkoutSetUseCaseProvider = Provider((ref) {
  return LogWorkoutSetUseCase(ref.watch(workoutSetRepositoryProvider));
});

final finishWorkoutSessionUseCaseProvider = Provider((ref) {
  return FinishWorkoutSessionUseCase(
    ref.watch(sessionEngineProvider),
    ref.watch(workoutSetRepositoryProvider),
  );
});

// --- State ---

final workoutListProvider =
    AsyncNotifierProvider<WorkoutListNotifier, List<Workout>>(WorkoutListNotifier.new);

class WorkoutListNotifier extends AsyncNotifier<List<Workout>> {
  @override
  Future<List<Workout>> build() => ref.watch(workoutRepositoryProvider).getAll();

  Future<void> addWorkout(Workout workout) async {
    await ref.read(workoutRepositoryProvider).save(workout);
    ref.invalidateSelf();
    await future;
  }
}

final exerciseListProvider =
    AsyncNotifierProvider<ExerciseListNotifier, List<Exercise>>(ExerciseListNotifier.new);

class ExerciseListNotifier extends AsyncNotifier<List<Exercise>> {
  @override
  Future<List<Exercise>> build() => ref.watch(exerciseRepositoryProvider).getAll();

  Future<void> addExercise(Exercise exercise) async {
    await ref.read(exerciseRepositoryProvider).save(exercise);
    ref.invalidateSelf();
    await future;
  }
}

/// Sets logged for a given active Session — a family provider keyed by
/// sessionId since multiple sessions may be viewed historically.
final workoutSetsForSessionProvider =
    FutureProvider.family<List<WorkoutSet>, String>((ref, sessionId) {
  return ref.watch(workoutSetRepositoryProvider).getBySession(sessionId);
});

final activeWorkoutSessionProvider = FutureProvider<Session?>((ref) async {
  final session = await ref.watch(sessionEngineProvider).getActiveSession();
  if (session == null || session.sessionType != SessionType.workout) return null;
  return session;
});
