import 'task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll({bool includeArchived = false});
  Future<Task?> getById(String id);
  Future<void> save(Task task);
  Future<void> delete(String id);
}
