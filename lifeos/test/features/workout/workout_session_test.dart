import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/engines/session_engine/in_memory_session_repository.dart';
import 'package:lifeos/core/engines/session_engine/session.dart';
import 'package:lifeos/core/engines/session_engine/session_engine.dart';
import 'package:lifeos/features/workout/data/in_memory_workout_repository.dart';
import 'package:lifeos/features/workout/domain/workout_session_use_cases.dart';

/// Covers RFC-008_Workout.md §5 Validation Rules and §6 Acceptance Criteria.
void main() {
  late SessionEngine sessionEngine;
  late InMemoryWorkoutSetRepository setRepository;
  late StartWorkoutSessionUseCase startUseCase;
  late LogWorkoutSetUseCase logSetUseCase;
  late FinishWorkoutSessionUseCase finishUseCase;

  setUp(() {
    sessionEngine = SessionEngine(InMemorySessionRepository());
    setRepository = InMemoryWorkoutSetRepository();
    startUseCase = StartWorkoutSessionUseCase(sessionEngine);
    logSetUseCase = LogWorkoutSetUseCase(setRepository);
    finishUseCase = FinishWorkoutSessionUseCase(sessionEngine, setRepository);
  });

  test('starting a workout session uses sessionType.workout', () async {
    final session = await startUseCase.call();
    expect(session.sessionType, SessionType.workout);
    expect(session.status, SessionStatus.running);
  });

  test('finishing with zero logged sets throws NoSetsLoggedException', () async {
    final session = await startUseCase.call();

    await expectLater(
      finishUseCase.call(
        sessionId: session.id,
        focusScore: 7,
        energyScore: 7,
        difficultyScore: 5,
        painLevel: 2,
      ),
      throwsA(isA<NoSetsLoggedException>()),
    );
  });

  test('finishing after logging at least one set succeeds and reflects', () async {
    final session = await startUseCase.call();
    await logSetUseCase.call(
      sessionId: session.id,
      exerciseId: 'squat',
      setNumber: 1,
      repetitions: 8,
      weight: 60,
    );

    final reflected = await finishUseCase.call(
      sessionId: session.id,
      focusScore: 8,
      energyScore: 7,
      difficultyScore: 6,
      painLevel: 3,
    );

    expect(reflected.status, SessionStatus.reflected);
    expect(reflected.reflectionNote, contains('painLevel:3'));
  });

  test('logged set enforces non-negative repetitions and weight', () async {
    await expectLater(
      logSetUseCase.call(
        sessionId: 's1',
        exerciseId: 'squat',
        setNumber: 1,
        repetitions: -1,
        weight: 10,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
