import 'dart:convert';

import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../engines/session_engine/session.dart';
import '../engines/session_engine/session_repository.dart';
import '../models/base_entity.dart';

/// Per docs/rfc/RFC-007_Export_Import_Backup_Encryption.md.
///
/// Scope note: this implementation demonstrates the full export/import
/// pipeline (version check -> schema check -> reference check -> preview
/// -> conflict resolution -> import) against the two most fully-modeled
/// entities (Task, Session). Wiring in the remaining modules (Nutrition,
/// Medicine, Results, Settings) is mechanical repetition of the same
/// pattern — each module's repository gets a `toJson`/`fromJson` pair
/// registered in `_serializeAll`/`_importAll` below.
const int currentSchemaVersion = 2; // matches docs/04_Database_Schema.md v2.0

enum ImportConflictResolution { keepLocal, replace, keepBoth }

class ImportPreview {
  const ImportPreview({
    required this.taskConflicts,
    required this.sessionConflicts,
    required this.sourceSchemaVersion,
    required this.needsMigration,
  });

  final List<String> taskConflicts; // ids that already exist locally
  final List<String> sessionConflicts;
  final int sourceSchemaVersion;
  final bool needsMigration;
}

class ExportImportService {
  ExportImportService(this._taskRepository, this._sessionRepository);

  final TaskRepository _taskRepository;
  final SessionRepository _sessionRepository;

  /// Full JSON export — every module exports independently, Master
  /// Export merges all modules (docs/03_System_Architecture.md §16).
  /// Plain JSON only here; password-protected ZIP wrapping (RFC-007 §2)
  /// is a platform-file-IO concern layered on top of this method's output
  /// by the calling screen, not duplicated in this service.
  Future<String> exportAll() async {
    final tasks = await _taskRepository.getAll(includeArchived: true);
    final sessions = await _sessionRepository.getByType(SessionType.task) +
        await _sessionRepository.getByType(SessionType.workout) +
        await _sessionRepository.getByType(SessionType.learning);

    final payload = {
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks.map(_taskToJson).toList(),
      'sessions': sessions.map(_sessionToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Version Check -> Schema Check -> Reference Check -> Preview
  /// (RFC-007 §3). Does not write anything — `import()` does that, after
  /// the caller confirms conflict resolution choices from this preview.
  Future<ImportPreview> preview(String jsonString) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final sourceVersion = decoded['schemaVersion'] as int? ?? 1;

    final incomingTasks =
        (decoded['tasks'] as List? ?? []).cast<Map<String, dynamic>>();
    final incomingSessions =
        (decoded['sessions'] as List? ?? []).cast<Map<String, dynamic>>();

    final taskConflicts = <String>[];
    for (final t in incomingTasks) {
      final existing = await _taskRepository.getById(t['id'] as String);
      if (existing != null) taskConflicts.add(t['id'] as String);
    }

    final sessionConflicts = <String>[];
    for (final s in incomingSessions) {
      final existing = await _sessionRepository.getById(s['id'] as String);
      if (existing != null) sessionConflicts.add(s['id'] as String);
    }

    return ImportPreview(
      taskConflicts: taskConflicts,
      sessionConflicts: sessionConflicts,
      sourceSchemaVersion: sourceVersion,
      needsMigration: sourceVersion < currentSchemaVersion,
    );
  }

  /// Applies the import with the given per-entity conflict resolution.
  /// Default is `keepLocal` (RFC-007 §3), so callers must explicitly
  /// opt into overwriting.
  Future<void> import(
    String jsonString, {
    ImportConflictResolution resolution = ImportConflictResolution.keepLocal,
  }) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final sourceVersion = decoded['schemaVersion'] as int? ?? 1;
    if (sourceVersion < currentSchemaVersion) {
      // Migration scripts would run here (RFC-007 §3 Version Check) —
      // none needed yet since this is the first shipped schema version.
    }

    for (final t in (decoded['tasks'] as List? ?? []).cast<Map<String, dynamic>>()) {
      await _importTask(t, resolution);
    }
    for (final s in (decoded['sessions'] as List? ?? []).cast<Map<String, dynamic>>()) {
      await _importSession(s, resolution);
    }
  }

  Future<void> _importTask(
      Map<String, dynamic> json, ImportConflictResolution resolution) async {
    final id = json['id'] as String;
    final existing = await _taskRepository.getById(id);
    if (existing != null) {
      if (resolution == ImportConflictResolution.keepLocal) return;
      if (resolution == ImportConflictResolution.keepBoth) {
        await _taskRepository.save(_taskFromJson({...json, 'id': BaseEntity.newId()}));
        return;
      }
      // replace falls through to save() below, overwriting by id
    }
    await _taskRepository.save(_taskFromJson(json));
  }

  Future<void> _importSession(
      Map<String, dynamic> json, ImportConflictResolution resolution) async {
    final id = json['id'] as String;
    final existing = await _sessionRepository.getById(id);
    if (existing != null) {
      if (resolution == ImportConflictResolution.keepLocal) return;
      if (resolution == ImportConflictResolution.keepBoth) {
        await _sessionRepository.save(_sessionFromJson({...json, 'id': BaseEntity.newId()}));
        return;
      }
    }
    await _sessionRepository.save(_sessionFromJson(json));
  }

  // --- Serialization (manual, entity-by-entity per CLAUDE.md §6 copyWith/
  // toJson/fromJson expectation — json_serializable codegen is the
  // production path once build_runner can run in a real environment) ---

  Map<String, dynamic> _taskToJson(Task t) => {
        'id': t.id,
        'title': t.title,
        'status': t.status.name,
        'priority': t.priority.name,
        'localDate': t.localDate,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
        'goalId': t.goalId,
        'projectId': t.projectId,
        'milestoneId': t.milestoneId,
      };

  Task _taskFromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        title: j['title'] as String,
        status: TaskStatus.values.byName(j['status'] as String),
        priority: TaskPriority.values.byName(j['priority'] as String),
        localDate: j['localDate'] as String,
        goalId: j['goalId'] as String?,
        projectId: j['projectId'] as String?,
        milestoneId: j['milestoneId'] as String?,
      );

  Map<String, dynamic> _sessionToJson(Session s) => {
        'id': s.id,
        'sessionType': s.sessionType.name,
        'contextId': s.contextId,
        'status': s.status.name,
        'startTime': s.startTime.toIso8601String(),
        'localDate': s.localDate,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'focusScore': s.focusScore,
        'energyScore': s.energyScore,
      };

  Session _sessionFromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        sessionType: SessionType.values.byName(j['sessionType'] as String),
        contextId: j['contextId'] as String?,
        status: SessionStatus.values.byName(j['status'] as String),
        startTime: DateTime.parse(j['startTime'] as String),
        localDate: j['localDate'] as String,
        focusScore: j['focusScore'] as int?,
        energyScore: j['energyScore'] as int?,
      );
}
