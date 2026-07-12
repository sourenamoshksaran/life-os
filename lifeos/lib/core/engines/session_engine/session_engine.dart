import '../../models/base_entity.dart';
import '../../services/date_manager.dart';
import 'session.dart';
import 'session_repository.dart';

/// Thrown when a caller tries to start a session while another is already
/// active. See docs/rfc/RFC-005_Core_Session_Engine.md §6.
class SessionAlreadyActiveException implements Exception {
  SessionAlreadyActiveException(this.activeSession);
  final Session activeSession;

  @override
  String toString() =>
      'A ${activeSession.sessionType.name} session is already ${activeSession.status.name}. '
      'Finish or pause it before starting a new one.';
}

/// The single shared engine for all time-bound activity in LifeOS.
///
/// Golden Rule (RFC-005 §2): there is exactly one Session concept in
/// LifeOS. Every module that involves "doing something for a period of
/// time" uses this engine — it is never reimplemented per module.
class SessionEngine {
  SessionEngine(this._repository, {DateManager dateManager = const DateManager()})
      : _dateManager = dateManager;

  final SessionRepository _repository;
  final DateManager _dateManager;

  /// Starts a new Session. Enforces the single-active-session rule:
  /// only one Session may be Running or Paused at any time, regardless
  /// of its [sessionType] (RFC-005 §6).
  Future<Session> start({
    required SessionType sessionType,
    String? contextId,
  }) async {
    final existingActive = await _repository.getActiveSession();
    if (existingActive != null) {
      throw SessionAlreadyActiveException(existingActive);
    }

    final now = DateTime.now();
    final session = Session(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      sessionType: sessionType,
      contextId: contextId,
      status: SessionStatus.running,
      startTime: now,
      localDate: _dateManager.localDateFor(now),
    );

    await _repository.save(session);
    return session;
  }

  Future<Session> pause(String sessionId) async {
    final session = await _requireSession(sessionId);
    _assertStatus(session, SessionStatus.running, 'pause');

    final updated = session.copyWith(
      status: SessionStatus.paused,
      pauseIntervals: [
        ...session.pauseIntervals,
        PauseInterval(pausedAt: DateTime.now()),
      ],
    );
    await _repository.save(updated);
    return updated;
  }

  Future<Session> resume(String sessionId) async {
    final session = await _requireSession(sessionId);
    _assertStatus(session, SessionStatus.paused, 'resume');

    final intervals = [...session.pauseIntervals];
    if (intervals.isNotEmpty && intervals.last.resumedAt == null) {
      intervals[intervals.length - 1] = PauseInterval(
        pausedAt: intervals.last.pausedAt,
        resumedAt: DateTime.now(),
      );
    }

    final updated = session.copyWith(
      status: SessionStatus.running,
      pauseIntervals: intervals,
    );
    await _repository.save(updated);
    return updated;
  }

  /// Ends a session and computes its effective duration (total time minus
  /// paused time). The session moves to `Finished`, not yet `Reflected`
  /// (RFC-005 §4) — call [reflect] to complete it.
  Future<Session> finish(String sessionId) async {
    final session = await _requireSession(sessionId);
    if (!session.isActive) {
      throw StateError(
          'Cannot finish a session that is not Running or Paused (was ${session.status.name}).');
    }

    final endTime = DateTime.now();
    final pausedDuration = session.pauseIntervals.fold<Duration>(
      Duration.zero,
      (total, interval) => total + interval.elapsed,
    );
    final effectiveDuration =
        endTime.difference(session.startTime) - pausedDuration;

    final updated = session.copyWith(
      status: SessionStatus.finished,
      endTime: endTime,
      effectiveDuration: effectiveDuration,
    );
    await _repository.save(updated);
    return updated;
  }

  Future<Session> cancel(String sessionId) async {
    final session = await _requireSession(sessionId);
    final updated = session.copyWith(status: SessionStatus.cancelled);
    await _repository.save(updated);
    return updated;
  }

  /// Completes the generic reflection flow (RFC-005 §8). Module-specific
  /// reflection extensions (e.g. Workout's painLevel) are stored by the
  /// calling feature module in its own context payload, appended to —
  /// never substituted for — this generic reflection.
  Future<Session> reflect(
    String sessionId, {
    required int focusScore,
    required int energyScore,
    required int difficultyScore,
    String? note,
    bool skipped = false,
  }) async {
    final session = await _requireSession(sessionId);
    if (session.status != SessionStatus.finished) {
      throw StateError(
          'Cannot reflect on a session that is not Finished (was ${session.status.name}).');
    }

    final updated = session.copyWith(
      status: SessionStatus.reflected,
      focusScore: focusScore,
      energyScore: energyScore,
      difficultyScore: difficultyScore,
      reflectionNote: note,
      reflectionSkipped: skipped,
    );
    await _repository.save(updated);
    return updated;
  }

  Future<Session?> getActiveSession() => _repository.getActiveSession();

  Future<Session> _requireSession(String id) async {
    final session = await _repository.getById(id);
    if (session == null) {
      throw StateError('Session $id not found.');
    }
    return session;
  }

  void _assertStatus(Session session, SessionStatus expected, String action) {
    if (session.status != expected) {
      throw StateError(
          'Cannot $action a session in status ${session.status.name} (expected ${expected.name}).');
    }
  }
}
