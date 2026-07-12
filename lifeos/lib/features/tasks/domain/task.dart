import '../../../core/models/base_entity.dart';

/// Canonical Task Status — see docs/04_Database_Schema.md and
/// docs/rfc/RFC-002_Task_Management.md §7. This is the ONLY valid enum;
/// the previously-conflicting 5-state version is deprecated and must not
/// be reintroduced (CLAUDE.md §24 Forbidden Patterns).
enum TaskStatus {
  inbox,
  planned,
  ready,
  running,
  paused,
  completed,
  cancelled,
  archived,
}

enum TaskPriority { high, medium, low, someday }

class Task extends BaseEntity {
  Task({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.title,
    required this.status,
    required this.priority,
    required this.localDate,
    this.description,
    this.categoryId,
    this.estimatedMinutes,
    this.actualMinutes,
    this.deadline,
    this.reminder,
    this.repeatRule,
    this.difficulty,
    this.energyRequirement,
    this.context,
    this.goalId,
    this.projectId,
    this.milestoneId,
    this.tags = const [],
    this.attachments = const [],
    this.icon,
    this.color,
    this.notes,
    this.completedAt,
    this.archivedAt,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String title;
  final String? description;
  final String? categoryId;
  final TaskPriority priority;
  final TaskStatus status;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final DateTime? deadline;
  final DateTime? reminder;
  final String? repeatRule;
  final int? difficulty;
  final int? energyRequirement;
  final String? context;

  /// Goal/Milestone/Project links are all independently nullable — the
  /// hierarchy is optional convenience, never mandatory.
  /// See docs/rfc/RFC-004_Goals_Milestones_Projects.md §2.
  final String? goalId;
  final String? projectId;
  final String? milestoneId;

  final List<String> tags;
  final List<String> attachments;
  final String? icon;
  final String? color;
  final String? notes;

  /// Correlation key — see docs/rfc/RFC-005_Core_Session_Engine.md §7.
  final String localDate;

  final DateTime? completedAt;
  final DateTime? archivedAt;

  bool get isRunning => status == TaskStatus.running;

  Task copyWith({
    String? title,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? completedAt,
    DateTime? archivedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      title: title ?? this.title,
      description: description,
      categoryId: categoryId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes,
      actualMinutes: actualMinutes,
      deadline: deadline,
      reminder: reminder,
      repeatRule: repeatRule,
      difficulty: difficulty,
      energyRequirement: energyRequirement,
      context: context,
      goalId: goalId,
      projectId: projectId,
      milestoneId: milestoneId,
      tags: tags,
      attachments: attachments,
      icon: icon,
      color: color,
      notes: notes,
      localDate: localDate,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}
