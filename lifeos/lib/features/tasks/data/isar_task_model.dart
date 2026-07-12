import 'package:isar/isar.dart';

import '../domain/task.dart';
import '../domain/task_repository.dart';

part 'isar_task_model.g.dart';

/// Isar collection model for [Task]. See the BUILD NOTE in
/// core/engines/session_engine/isar_session_model.dart — the same
/// build_runner-codegen dependency applies here.
@collection
class IsarTaskModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  String? description;
  String? categoryId;

  @enumerated
  late TaskPriority priority;

  @Index()
  @enumerated
  late TaskStatus status;

  int? estimatedMinutes;
  int? actualMinutes;
  DateTime? deadline;
  DateTime? reminder;
  String? repeatRule;
  int? difficulty;
  int? energyRequirement;
  String? context;

  String? goalId;
  String? projectId;
  String? milestoneId;

  List<String> tags = const [];
  List<String> attachments = const [];
  String? icon;
  String? color;
  String? notes;

  @Index()
  late String localDate;

  DateTime? completedAt;
  DateTime? archivedAt;

  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  bool isArchived = false;
  bool isDeleted = false;
  int version = 1;
  String? deviceId;
  String? syncState;

  static IsarTaskModel fromDomain(Task t) {
    return IsarTaskModel()
      ..uuid = t.id
      ..title = t.title
      ..description = t.description
      ..categoryId = t.categoryId
      ..priority = t.priority
      ..status = t.status
      ..estimatedMinutes = t.estimatedMinutes
      ..actualMinutes = t.actualMinutes
      ..deadline = t.deadline
      ..reminder = t.reminder
      ..repeatRule = t.repeatRule
      ..difficulty = t.difficulty
      ..energyRequirement = t.energyRequirement
      ..context = t.context
      ..goalId = t.goalId
      ..projectId = t.projectId
      ..milestoneId = t.milestoneId
      ..tags = t.tags
      ..attachments = t.attachments
      ..icon = t.icon
      ..color = t.color
      ..notes = t.notes
      ..localDate = t.localDate
      ..completedAt = t.completedAt
      ..archivedAt = t.archivedAt
      ..createdAt = t.createdAt
      ..updatedAt = t.updatedAt
      ..deletedAt = t.deletedAt
      ..isArchived = t.isArchived
      ..isDeleted = t.isDeleted
      ..version = t.version
      ..deviceId = t.deviceId
      ..syncState = t.syncState;
  }

  Task toDomain() {
    return Task(
      id: uuid,
      createdAt: createdAt,
      updatedAt: updatedAt,
      title: title,
      status: status,
      priority: priority,
      localDate: localDate,
      description: description,
      categoryId: categoryId,
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
      completedAt: completedAt,
      archivedAt: archivedAt,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}

/// Isar-backed implementation of [TaskRepository] — same swap-in
/// guarantee as [IsarSessionRepository] (CLAUDE.md §6).
class IsarTaskRepository implements TaskRepository {
  IsarTaskRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<Task>> getAll({bool includeArchived = false}) async {
    final query = includeArchived
        ? _isar.isarTaskModels.filter().isDeletedEqualTo(false)
        : _isar.isarTaskModels.filter().isDeletedEqualTo(false).isArchivedEqualTo(false);
    final models = await query.findAll();
    return models.map((m) => m.toDomain()).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Task?> getById(String id) async {
    final model = await _isar.isarTaskModels.filter().uuidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> save(Task task) async {
    await _isar.writeTxn(() async {
      await _isar.isarTaskModels.put(IsarTaskModel.fromDomain(task));
    });
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.isarTaskModels.filter().uuidEqualTo(id).findFirst();
      if (model != null) {
        // Soft delete by default (CLAUDE.md §14) — flip isDeleted rather
        // than physically removing the row.
        model.isDeleted = true;
        model.deletedAt = DateTime.now();
        await _isar.isarTaskModels.put(model);
      }
    });
  }
}
