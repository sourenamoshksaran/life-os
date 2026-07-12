import 'learning_topic.dart';

abstract class LearningTopicRepository {
  Future<List<LearningTopic>> getAll();
  Future<List<LearningTopic>> getNeedingReview();
  Future<LearningTopic?> getById(String id);
  Future<void> save(LearningTopic topic);

  /// Deleting a topic with past Sessions unlinks rather than cascades
  /// (RFC-009 §7, matching RFC-004 §7's orphan-unlink rule) — enforced by
  /// the use case layer, this method only removes the topic record itself.
  Future<void> delete(String id);
}
