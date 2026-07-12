import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/engines/session_engine/in_memory_session_repository.dart';
import 'package:lifeos/core/engines/session_engine/session.dart';
import 'package:lifeos/core/engines/session_engine/session_engine.dart';

/// Covers RFC-005_Core_Session_Engine.md §11 Acceptance Criteria:
/// "Exactly one active Session (Running/Paused) exists at any time,
/// enforced by the engine, not by UI convention."
void main() {
  late SessionEngine engine;

  setUp(() {
    engine = SessionEngine(InMemorySessionRepository());
  });

  group('SessionEngine concurrency rule', () {
    test('starting a session succeeds when none is active', () async {
      final session = await engine.start(sessionType: SessionType.task, contextId: 't1');
      expect(session.status, SessionStatus.running);
    });

    test('starting a second session while one is Running throws', () async {
      await engine.start(sessionType: SessionType.task, contextId: 't1');

      expect(
        () => engine.start(sessionType: SessionType.workout, contextId: 'w1'),
        throwsA(isA<SessionAlreadyActiveException>()),
      );
    });

    test('starting a second session while one is Paused throws', () async {
      final session =
          await engine.start(sessionType: SessionType.learning, contextId: 'l1');
      await engine.pause(session.id);

      expect(
        () => engine.start(sessionType: SessionType.task, contextId: 't2'),
        throwsA(isA<SessionAlreadyActiveException>()),
      );
    });

    test('a new session can start after the previous one finishes', () async {
      final first = await engine.start(sessionType: SessionType.task, contextId: 't1');
      await engine.finish(first.id);

      final second =
          await engine.start(sessionType: SessionType.workout, contextId: 'w1');
      expect(second.status, SessionStatus.running);
    });

    test('a new session can start after the previous one is cancelled', () async {
      final first = await engine.start(sessionType: SessionType.task, contextId: 't1');
      await engine.cancel(first.id);

      final second =
          await engine.start(sessionType: SessionType.learning, contextId: 'l1');
      expect(second.status, SessionStatus.running);
    });
  });

  group('SessionEngine lifecycle', () {
    test('finish computes effective duration excluding paused time', () async {
      final session = await engine.start(sessionType: SessionType.task, contextId: 't1');
      await engine.pause(session.id);
      await Future.delayed(const Duration(milliseconds: 20));
      await engine.resume(session.id);

      final finished = await engine.finish(session.id);
      expect(finished.status, SessionStatus.finished);
      expect(finished.effectiveDuration, isNotNull);
    });

    test('reflect requires session to be Finished first', () async {
      final session = await engine.start(sessionType: SessionType.task, contextId: 't1');

      expect(
        () => engine.reflect(session.id,
            focusScore: 5, energyScore: 5, difficultyScore: 5),
        throwsStateError,
      );
    });

    test('full lifecycle reaches Reflected', () async {
      final session = await engine.start(sessionType: SessionType.task, contextId: 't1');
      await engine.finish(session.id);
      final reflected = await engine.reflect(
        session.id,
        focusScore: 8,
        energyScore: 7,
        difficultyScore: 4,
        note: 'Good focus session',
      );
      expect(reflected.status, SessionStatus.reflected);
      expect(reflected.focusScore, 8);
    });
  });
}
