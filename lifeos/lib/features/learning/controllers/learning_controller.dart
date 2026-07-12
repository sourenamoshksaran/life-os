import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engines/session_engine/session.dart';
import '../../tasks/controllers/task_controller.dart' show sessionEngineProvider;
import '../data/in_memory_learning_repository.dart';
import '../domain/learning_repository.dart';
import '../domain/learning_session_use_cases.dart';
import '../domain/learning_topic.dart';

// --- Dependency Injection ---
// Reuses the single shared `sessionEngineProvider` — one Core Session
// Engine instance app-wide (RFC-005 §2).

final learningTopicRepositoryProvider = Provider<LearningTopicRepository>((ref) {
  return InMemoryLearningTopicRepository();
});

final startLearningSessionUseCaseProvider = Provider((ref) {
  return StartLearningSessionUseCase(ref.watch(sessionEngineProvider));
});

final finishLearningSessionUseCaseProvider = Provider((ref) {
  return FinishLearningSessionUseCase(
    ref.watch(sessionEngineProvider),
    ref.watch(learningTopicRepositoryProvider),
  );
});

// --- State ---

final learningTopicListProvider =
    AsyncNotifierProvider<LearningTopicListNotifier, List<LearningTopic>>(
        LearningTopicListNotifier.new);

class LearningTopicListNotifier extends AsyncNotifier<List<LearningTopic>> {
  @override
  Future<List<LearningTopic>> build() =>
      ref.watch(learningTopicRepositoryProvider).getAll();

  Future<void> addTopic(LearningTopic topic) async {
    await ref.read(learningTopicRepositoryProvider).save(topic);
    ref.invalidateSelf();
    await future;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Backs the "Needs Review" list required by RFC-009 §6.
final needsReviewTopicsProvider = FutureProvider<List<LearningTopic>>((ref) {
  ref.watch(learningTopicListProvider); // re-fetch when topics change
  return ref.watch(learningTopicRepositoryProvider).getNeedingReview();
});

final activeLearningSessionProvider = FutureProvider<Session?>((ref) async {
  final session = await ref.watch(sessionEngineProvider).getActiveSession();
  if (session == null || session.sessionType != SessionType.learning) {
    return null;
  }
  return session;
});
