import '../../../core/models/base_entity.dart';

enum WorkoutType { strength, cardio, mobility, custom }

/// Workout plan/template — see docs/rfc/RFC-008_Workout.md §3.
/// This is distinct from a `Session` (sessionType=workout): the plan is
/// what you intend to do, the Session is the timed act of doing it.
class Workout extends BaseEntity {
  Workout({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.type,
    this.exerciseIds = const [],
    this.estimatedMinutes,
    this.notes,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String title;
  final WorkoutType type;

  /// Ordered list per RFC-008 §3. Must be non-empty at creation
  /// (RFC-008 §7 "Zero-exercise Workout plan: blocked at creation").
  final List<String> exerciseIds;
  final int? estimatedMinutes;
  final String? notes;

  Workout copyWith({
    String? title,
    WorkoutType? type,
    List<String>? exerciseIds,
    int? estimatedMinutes,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      title: title ?? this.title,
      type: type ?? this.type,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      notes: notes ?? this.notes,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}
