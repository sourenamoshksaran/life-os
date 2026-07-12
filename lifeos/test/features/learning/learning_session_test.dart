import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/engines/session_engine/in_memory_session_repository.dart';
import 'package:lifeos/core/engines/session_engine/session.dart';
import 'package:lifeos/core/engines/session_engine/session_engine.dart';
import 'package:lifeos/core/models/base_entity.dart';
import 'package:lifeos/features/learning/data/in_memory_learning_repository.dart';
import 'package:lifeos/features/learning/domain/learning_session_use_cases.dart';
import 'package:lifeos/features/learning/domain/learning_topic.dart';

/// Covers RFC-009_Learning.md §5 Validation Rules and §10 Testing
/// Requirements: "Unit tests for review-needed auto-flagging logic."
void main() {
  late SessionEngine sessionEngine;
  late InMemoryLearningTopicRepository topicRepository;
  late StartLearningSessionUseCase startUseCase;
  late FinishLearningSessionUseCase finishUseCase;
  late LearningTopic topic;

  setUp(() async {
    sessionEngine = SessionEngine(InMemorySessionRepository());
    topicRepository = InMemoryLearningTopicRepository();
    startUseCase = StartLearningSessionUseCase(sessionEngine);
    finishUseCase = FinishLearningSessionUseCase(sessionEngine, topicRepository);

    final now = DateTime.now();
    topic = LearningTopic(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      subject: 'Flutter',
      course: 'Advanced Widgets',
    );
    await topicRepository.save(topic);
  });

  test('freeform learning session is allowed with contextId null', () async {
    final session = await startUseCase.call();
    expect(session.sessionType, SessionType.learning);
    expect(session.contextId, isNull);
  });

  test('understanding < 4 auto-flags reviewNeeded true', () async {
    final session = await startUseCase.call(topicId: topic.id);
    await finishUseCase.call(
      sessionId: session.id,
      topicId: topic.id,
      understanding: 2,
      focusScore: 6,
      energyScore: 6,
    );

    final updated = await topicRepository.getById(topic.id);
    expect(updated!.reviewNeeded, isTrue);
  });

  test('understanding >= 4 does not auto-flag reviewNeeded', () async {
    final session = await startUseCase.call(topicId: topic.id);
    await finishUseCase.call(
      sessionId: session.id,
      topicId: topic.id,
      understanding: 8,
      focusScore: 6,
      energyScore: 6,
    );

    final updated = await topicRepository.getById(topic.id);
    expect(updated!.reviewNeeded, isFalse);
  });

  test('explicit override wins over the auto-flag default', () async {
    final session = await startUseCase.call(topicId: topic.id);
    await finishUseCase.call(
      sessionId: session.id,
      topicId: topic.id,
      understanding: 2,
      reviewNeededOverride: false,
      focusScore: 6,
      energyScore: 6,
    );

    final updated = await topicRepository.getById(topic.id);
    expect(updated!.reviewNeeded, isFalse);
  });

  test('a low-understanding topic surfaces in getNeedingReview', () async {
    final session = await startUseCase.call(topicId: topic.id);
    await finishUseCase.call(
      sessionId: session.id,
      topicId: topic.id,
      understanding: 1,
      focusScore: 5,
      energyScore: 5,
    );

    final needsReview = await topicRepository.getNeedingReview();
    expect(needsReview.map((t) => t.id), contains(topic.id));
  });
}
