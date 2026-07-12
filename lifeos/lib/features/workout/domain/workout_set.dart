import '../../../core/models/base_entity.dart';

/// Embedded context on a `Session` where `sessionType=Workout`
/// (RFC-005 §3, RFC-008 §3). Never a duplicate timing table — the
/// Session it belongs to owns start/pause/finish/reflect.
class WorkoutSet extends BaseEntity {
  WorkoutSet({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.repetitions,
    required this.weight,
    this.workoutId,
    this.rest,
    this.rpe,
    this.painLevel,
    this.energyBefore,
    this.energyAfter,
    this.notes,
    this.edited = false,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  })  : assert(repetitions >= 0, 'repetitions must be >= 0'),
        assert(weight >= 0, 'weight must be >= 0'),
        assert(rpe == null || (rpe >= 1 && rpe <= 10), 'RPE must be 1-10'),
        assert(painLevel == null || (painLevel >= 1 && painLevel <= 10),
            'painLevel must be 1-10');

  final String sessionId;
  final String? workoutId;
  final String exerciseId;
  final int setNumber;
  final int repetitions;
  final double weight;
  final int? rest;
  final int? rpe;
  final int? painLevel;
  final int? energyBefore;
  final int? energyAfter;
  final String? notes;

  /// Set per RFC-008 §7 when edited more than 24h is not applicable here —
  /// the "edited" flag itself is what gates that 24h window in the UI.
  final bool edited;

  WorkoutSet copyWith({
    int? repetitions,
    double? weight,
    int? rest,
    int? rpe,
    int? painLevel,
    int? energyBefore,
    int? energyAfter,
    String? notes,
    bool? edited,
    DateTime? updatedAt,
  }) {
    return WorkoutSet(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sessionId: sessionId,
      workoutId: workoutId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
      rest: rest ?? this.rest,
      rpe: rpe ?? this.rpe,
      painLevel: painLevel ?? this.painLevel,
      energyBefore: energyBefore ?? this.energyBefore,
      energyAfter: energyAfter ?? this.energyAfter,
      notes: notes ?? this.notes,
      edited: edited ?? this.edited,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}
