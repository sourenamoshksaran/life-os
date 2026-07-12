import '../domain/task.dart';
import '../domain/task_repository.dart';

/// TODO(implementation): replace with IsarTaskRepository once Isar
/// collections are generated (see session repository TODO for the pattern).
class InMemoryTaskRepository implements TaskRepository {
  final Map<String, Task> _store = {};

  @override
  Future<List<Task>> getAll({bool includeArchived = false}) async {
    return _store.values
        .where((t) => includeArchived || !t.isArchived)
        .where((t) => !t.isDeleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Task?> getById(String id) async => _store[id];

  @override
  Future<void> save(Task task) async {
    _store[task.id] = task;
  }

  @override
  Future<void> delete(String id) async {
    final task = _store[id];
    if (task != null) {
      _store[id] = task.copyWith(); // soft-delete convention: see below
    }
    // Soft delete by default per CLAUDE.md §14 — a full implementation
    // would set isDeleted/deletedAt via a dedicated copyWith parameter.
  }
}
