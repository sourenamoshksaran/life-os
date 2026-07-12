import '../../models/base_entity.dart';

/// The single, shared session type used by every time-bound module.
///
/// See docs/rfc/RFC-005_Core_Session_Engine.md §5. New modules add a new
/// value here and nothing else — no new timer/pause/resume/reflection
/// code is ever written for a new module.
enum SessionType {
  task,
  learning,
  workout,
  reading,
  writing,
  business,
  research,
  journal,
  meditation,
  freeform,
}

/// See docs/rfc/RFC-005_Core_Session_Engine.md §4.
enum SessionStatus {
  running,
  paused,
  finished,
  cancelled,
  reflected,
}

class PauseInterval {
  const PauseInterval({required this.pausedAt, this.resumedAt});

  final DateTime pausedAt;
  final DateTime? resumedAt;

  Duration get elapsed =>
      (resumedAt ?? DateTime.now()).difference(pausedAt);
}

/// The generic Session entity — replaces the former separate
/// TaskSession / WorkoutSession / LearningSession tables.
///
/// Module-specific data (e.g. a Workout's sets/reps) attaches as a small
/// typed context payload keyed by [contextId], not as a duplicate table.
/// See docs/rfc/RFC-005_Core_Session_Engine.md §3.
class Session extends BaseEntity {
  Session({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.sessionType,
    required this.status,
    required this.startTime,
    required this.localDate,
    this.contextId,
    this.pauseIntervals = const [],
    this.endTime,
    this.effectiveDuration,
    this.focusScore,
    this.energyScore,
    this.difficultyScore,
    this.reflectionNote,
    this.reflectionSkipped = false,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final SessionType sessionType;
  final String? contextId;
  final SessionStatus status;
  final DateTime startTime;
  final List<PauseInterval> pauseIntervals;
  final DateTime? endTime;
  final Duration? effectiveDuration;
  final int? focusScore; // 1-10
  final int? energyScore; // 1-10
  final int? difficultyScore; // 1-10
  final String? reflectionNote;
  final bool reflectionSkipped;

  /// Correlation key — see docs/rfc/RFC-005_Core_Session_Engine.md §7.
  final String localDate;

  bool get isActive =>
      status == SessionStatus.running || status == SessionStatus.paused;

  Session copyWith({
    SessionStatus? status,
    List<PauseInterval>? pauseIntervals,
    DateTime? endTime,
    Duration? effectiveDuration,
    int? focusScore,
    int? energyScore,
    int? difficultyScore,
    String? reflectionNote,
    bool? reflectionSkipped,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sessionType: sessionType,
      contextId: contextId,
      status: status ?? this.status,
      startTime: startTime,
      localDate: localDate,
      pauseIntervals: pauseIntervals ?? this.pauseIntervals,
      endTime: endTime ?? this.endTime,
      effectiveDuration: effectiveDuration ?? this.effectiveDuration,
      focusScore: focusScore ?? this.focusScore,
      energyScore: energyScore ?? this.energyScore,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      reflectionNote: reflectionNote ?? this.reflectionNote,
      reflectionSkipped: reflectionSkipped ?? this.reflectionSkipped,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}
