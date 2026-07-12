import 'exercise.dart';
import 'workout.dart';
import 'workout_set.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getAll();
  Future<Exercise?> getById(String id);
  Future<void> save(Exercise exercise);
  Future<void> delete(String id);
}

abstract class WorkoutRepository {
  Future<List<Workout>> getAll({bool includeArchived = false});
  Future<Workout?> getById(String id);
  Future<void> save(Workout workout);
  Future<void> delete(String id);
}

abstract class WorkoutSetRepository {
  Future<List<WorkoutSet>> getBySession(String sessionId);
  Future<void> save(WorkoutSet set);
  Future<void> delete(String id);
}
