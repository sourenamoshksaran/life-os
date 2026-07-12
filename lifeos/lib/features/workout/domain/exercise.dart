import '../../../core/models/base_entity.dart';

/// Reference entity — see docs/rfc/RFC-008_Workout.md §3.
class Exercise extends BaseEntity {
  Exercise({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.muscleGroup,
    this.equipment,
    this.defaultSets,
    this.defaultReps,
    this.icon,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String name;
  final String? muscleGroup;
  final String? equipment;
  final int? defaultSets;
  final int? defaultReps;
  final String? icon;
}
