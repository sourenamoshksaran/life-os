import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/engines/session_engine/in_memory_session_repository.dart';
import 'package:lifeos/core/services/export_import_service.dart';
import 'package:lifeos/features/tasks/data/in_memory_task_repository.dart';
import 'package:lifeos/features/tasks/domain/task.dart';

/// Covers docs/rfc/RFC-007_Export_Import_Backup_Encryption.md §3 —
/// version check, reference/conflict detection, and the default
/// "Keep Local" conflict resolution behavior.
void main() {
  late InMemoryTaskRepository taskRepo;
  late InMemorySessionRepository sessionRepo;
  late ExportImportService service;

  setUp(() {
    taskRepo = InMemoryTaskRepository();
    sessionRepo = InMemorySessionRepository();
    service = ExportImportService(taskRepo, sessionRepo);
  });

  Task sampleTask(String id, {String title = 'Sample'}) {
    final now = DateTime.now();
    return Task(
      id: id,
      createdAt: now,
      updatedAt: now,
      title: title,
      status: TaskStatus.planned,
      priority: TaskPriority.medium,
      localDate: '2026-07-11',
    );
  }

  test('export produces valid JSON with current schema version', () async {
    await taskRepo.save(sampleTask('t1'));
    final json = await service.exportAll();
    expect(json, contains('"schemaVersion": $currentSchemaVersion'));
    expect(json, contains('t1'));
  });

  test('preview detects no conflicts on an empty local repository', () async {
    await taskRepo.save(sampleTask('t1'));
    final exported = await service.exportAll();

    final freshTaskRepo = InMemoryTaskRepository();
    final freshService = ExportImportService(freshTaskRepo, sessionRepo);
    final preview = await freshService.preview(exported);

    expect(preview.taskConflicts, isEmpty);
    expect(preview.needsMigration, isFalse);
  });

  test('preview detects a conflict when the id already exists locally', () async {
    await taskRepo.save(sampleTask('t1'));
    final exported = await service.exportAll();
    final preview = await service.preview(exported);
    expect(preview.taskConflicts, contains('t1'));
  });

  test('import with keepLocal (default) does not overwrite existing task', () async {
    await taskRepo.save(sampleTask('t1', title: 'Original'));
    final exported = await service.exportAll();

    await taskRepo.save(sampleTask('t1', title: 'Modified Locally'));
    await service.import(exported); // default keepLocal

    final result = await taskRepo.getById('t1');
    expect(result!.title, 'Modified Locally');
  });

  test('import with replace overwrites the existing task', () async {
    await taskRepo.save(sampleTask('t1', title: 'Original'));
    final exported = await service.exportAll();

    await taskRepo.save(sampleTask('t1', title: 'Will Be Replaced'));
    await service.import(exported, resolution: ImportConflictResolution.replace);

    final result = await taskRepo.getById('t1');
    expect(result!.title, 'Original');
  });

  test('import with keepBoth creates a new id rather than overwriting', () async {
    await taskRepo.save(sampleTask('t1'));
    final exported = await service.exportAll();
    await service.import(exported, resolution: ImportConflictResolution.keepBoth);

    final all = await taskRepo.getAll(includeArchived: true);
    expect(all.length, 2);
  });
}
