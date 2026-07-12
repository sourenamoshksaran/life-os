import '../../../core/engines/session_engine/session.dart';
import '../../../core/engines/session_engine/session_engine.dart';
import '../../../core/models/base_entity.dart';
import 'workout_repository.dart';
import 'workout_set.dart';

/// Thrown per RFC-008 §5: a Workout Session requires at least one logged
/// `WorkoutSet` before it can move to Finished.
class NoSetsLoggedException implements Exception {
  @override
  String toString() =>
      'This workout has no logged sets yet. Log at least one set, or cancel the session instead.';
}

class StartWorkoutSessionUseCase {
  StartWorkoutSessionUseCase(this._sessionEngine);
  final SessionEngine _sessionEngine;

  /// [workoutId] is optional — a freeform Workout Session (no plan
  /// selected) is allowed per the same pattern as Learning (RFC-009 §7).
  Future<Session> call({String? workoutId}) {
    return _sessionEngine.start(
      sessionType: SessionType.workout,
      contextId: workoutId,
    );
  }
}

/// Logs a single set against the active Workout Session. Writes are
/// expected to complete in <100ms per RFC-008 §8 — the in-memory/Isar
/// repository does a single keyed upsert, no scan.
class LogWorkoutSetUseCase {
  LogWorkoutSetUseCase(this._setRepository);
  final WorkoutSetRepository _setRepository;

  Future<WorkoutSet> call({
    required String sessionId,
    String? workoutId,
    required String exerciseId,
    required int setNumber,
    required int repetitions,
    required double weight,
    int? rest,
    int? rpe,
    String? notes,
  }) async {
    final now = DateTime.now();
    final set = WorkoutSet(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      sessionId: sessionId,
      workoutId: workoutId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      repetitions: repetitions,
      weight: weight,
      rest: rest,
      rpe: rpe,
      notes: notes,
    );
    await _setRepository.save(set);
    return set;
  }
}

class FinishWorkoutSessionUseCase {
  FinishWorkoutSessionUseCase(this._sessionEngine, this._setRepository);
  final SessionEngine _sessionEngine;
  final WorkoutSetRepository _setRepository;

  Future<Session> call({
    required String sessionId,
    required int focusScore,
    required int energyScore,
    required int difficultyScore,
    required int painLevel,
    String? note,
  }) async {
    final sets = await _setRepository.getBySession(sessionId);
    if (sets.isEmpty) {
      throw NoSetsLoggedException();
    }
    assert(painLevel >= 1 && painLevel <= 10, 'painLevel must be 1-10');

    await _sessionEngine.finish(sessionId);
    // Pain Level is appended to the generic reflection flow per RFC-008
    // §6 — stored in reflectionNote as a structured suffix rather than a
    // new Session field, matching RFC-005 §8's "typed extension" rule.
    return _sessionEngine.reflect(
      sessionId,
      focusScore: focusScore,
      energyScore: energyScore,
      difficultyScore: difficultyScore,
      note: note == null ? 'painLevel:$painLevel' : '$note|painLevel:$painLevel',
    );
  }
}
