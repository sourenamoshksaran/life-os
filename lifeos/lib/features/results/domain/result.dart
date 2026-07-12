import '../../../core/models/base_entity.dart';

enum ResultPeriod { daily, weekly, monthly, yearly }

/// The single authoritative entity for Life Score and all periodic
/// summaries. See docs/rfc/RFC-003_Life_Score_Engine.md §6 and
/// docs/rfc/RFC-012_Results.md. `LifeScore`/`AnalyticsSnapshot` as
/// independent write targets do not exist — this is the only one.
class Result extends BaseEntity {
  Result({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.localDate,
    required this.period,
    required this.rangeStart,
    required this.rangeEnd,
    required this.lifeScore,
    required this.taskScore,
    required this.sessionQualityScore,
    required this.workoutScore,
    required this.learningScore,
    required this.sleepScore,
    required this.nutritionScore,
    required this.consistencyScore,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.deepWorkMinutes = 0,
    this.journalCompleted = false,
    this.isProvisional = true,
    this.formulaVersion = 1,
    this.notes,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String localDate;
  final ResultPeriod period;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  final int lifeScore;
  final int taskScore;
  final int sessionQualityScore;
  final int workoutScore;
  final int learningScore;
  final int sleepScore;
  final int nutritionScore;
  final int consistencyScore;

  final int completedTasks;
  final int totalTasks;
  final int deepWorkMinutes;
  final bool journalCompleted;
  final bool isProvisional;
  final int formulaVersion;
  final String? notes;
}
