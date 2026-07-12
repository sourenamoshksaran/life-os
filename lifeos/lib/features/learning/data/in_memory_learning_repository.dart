import '../domain/learning_repository.dart';
import '../domain/learning_topic.dart';

/// TODO(implementation): replace with IsarLearningTopicRepository once
/// Isar collections are generated (see session_engine's TODO for the
/// pattern — the interface requires zero call-site changes when swapped).
class InMemoryLearningTopicRepository implements LearningTopicRepository {
  final Map<String, LearningTopic> _store = {};

  @override
  Future<List<LearningTopic>> getAll() async {
    return _store.values.where((t) => !t.isDeleted).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<List<LearningTopic>> getNeedingReview() async {
    return _store.values.where((t) => t.reviewNeeded && !t.isDeleted).toList();
  }

  @override
  Future<LearningTopic?> getById(String id) async => _store[id];

  @override
  Future<void> save(LearningTopic topic) async => _store[topic.id] = topic;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}
