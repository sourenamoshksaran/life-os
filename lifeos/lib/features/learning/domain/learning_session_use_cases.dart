import '../../../core/engines/session_engine/session.dart';
import '../../../core/engines/session_engine/session_engine.dart';
import 'learning_repository.dart';

class StartLearningSessionUseCase {
  StartLearningSessionUseCase(this._sessionEngine);
  final SessionEngine _sessionEngine;

  /// Freeform (no [topicId]) is explicitly allowed per RFC-009 §7 — it
  /// still contributes learning-minutes to Life Score with `contextId=null`.
  Future<Session> call({String? topicId}) {
    return _sessionEngine.start(
      sessionType: SessionType.learning,
      contextId: topicId,
    );
  }
}

/// Implements the review-needed auto-flagging rule (RFC-009 §5):
/// `understanding` is required at reflection; if < 4, `reviewNeeded`
/// auto-defaults to true, but the caller may explicitly override it.
class FinishLearningSessionUseCase {
  FinishLearningSessionUseCase(this._sessionEngine, this._topicRepository);
  final SessionEngine _sessionEngine;
  final LearningTopicRepository _topicRepository;

  Future<Session> call({
    required String sessionId,
    String? topicId,
    required int understanding,
    bool? reviewNeededOverride,
    required int focusScore,
    required int energyScore,
    String? note,
  }) async {
    assert(understanding >= 1 && understanding <= 10,
        'understanding must be 1-10');

    await _sessionEngine.finish(sessionId);
    final reflected = await _sessionEngine.reflect(
      sessionId,
      focusScore: focusScore,
      energyScore: energyScore,
      difficultyScore: understanding,
      note: note == null
          ? 'understanding:$understanding'
          : '$note|understanding:$understanding',
    );

    if (topicId != null) {
      final topic = await _topicRepository.getById(topicId);
      if (topic != null) {
        final reviewNeeded = reviewNeededOverride ?? understanding < 4;
        await _topicRepository.save(topic.copyWith(reviewNeeded: reviewNeeded));
      }
    }

    return reflected;
  }
}
