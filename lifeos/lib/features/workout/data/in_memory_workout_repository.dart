import '../domain/exercise.dart';
import '../domain/workout.dart';
import '../domain/workout_repository.dart';
import '../domain/workout_set.dart';

/// TODO(implementation): replace with IsarExerciseRepository once Isar
/// collections are generated (see session_engine's TODO for the pattern —
/// this interface requires zero changes at the call sites when swapped).
class InMemoryExerciseRepository implements ExerciseRepository {
  final Map<String, Exercise> _store = {};

  @override
  Future<List<Exercise>> getAll() async =>
      _store.values.where((e) => !e.isDeleted).toList();

  @override
  Future<Exercise?> getById(String id) async => _store[id];

  @override
  Future<void> save(Exercise exercise) async => _store[exercise.id] = exercise;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

/// TODO(implementation): replace with IsarWorkoutRepository.
class InMemoryWorkoutRepository implements WorkoutRepository {
  final Map<String, Workout> _store = {};

  @override
  Future<List<Workout>> getAll({bool includeArchived = false}) async {
    return _store.values
        .where((w) => includeArchived || !w.isArchived)
        .where((w) => !w.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Workout?> getById(String id) async => _store[id];

  @override
  Future<void> save(Workout workout) async => _store[workout.id] = workout;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

/// TODO(implementation): replace with IsarWorkoutSetRepository.
class InMemoryWorkoutSetRepository implements WorkoutSetRepository {
  final Map<String, WorkoutSet> _store = {};

  @override
  Future<List<WorkoutSet>> getBySession(String sessionId) async {
    return _store.values.where((s) => s.sessionId == sessionId).toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
  }

  @override
  Future<void> save(WorkoutSet set) async => _store[set.id] = set;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}
