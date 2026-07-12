import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/models/base_entity.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../controllers/learning_controller.dart';
import '../../domain/learning_topic.dart';

/// Demonstrates RFC-009 §12's Golden Rule: Learning is just a Session
/// with a topic attached — timing is delegated to the Core Session Engine.
class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeLearningSessionProvider);
    final topicsAsync = ref.watch(learningTopicListProvider);
    final needsReviewAsync = ref.watch(needsReviewTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learning')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSampleTopic(ref),
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        children: [
          activeAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (session) => session == null
                ? FilledButton.icon(
                    onPressed: () => _startFreeform(context, ref),
                    icon: const Icon(PhosphorIconsRegular.play),
                    label: const Text('Start Freeform Learning Session'),
                  )
                : _ActiveSessionBanner(
                    sessionId: session.id,
                    onFinish: (understanding) =>
                        _finish(context, ref, session.id, understanding),
                  ),
          ),
          const SizedBox(height: LifeOSSpacing.lg),
          needsReviewAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (topics) {
              if (topics.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Needs Review',
                      style: TextStyle(
                          color: LifeOSColors.danger,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: LifeOSSpacing.sm),
                  ...topics.map((t) => _TopicTile(topic: t)),
                  const SizedBox(height: LifeOSSpacing.lg),
                ],
              );
            },
          ),
          const Text('All Topics',
              style: TextStyle(
                  color: LifeOSColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: LifeOSSpacing.sm),
          topicsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
            data: (topics) {
              if (topics.isEmpty) {
                return const Text('No topics yet — tap + to add one.',
                    style: TextStyle(color: LifeOSColors.textSecondary));
              }
              return Column(children: topics.map((t) => _TopicTile(topic: t)).toList());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleTopic(WidgetRef ref) async {
    final now = DateTime.now();
    final topic = LearningTopic(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      subject: 'New Subject',
    );
    await ref.read(learningTopicListProvider.notifier).addTopic(topic);
  }

  Future<void> _startFreeform(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(startLearningSessionUseCaseProvider).call();
      ref.invalidate(activeLearningSessionProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _finish(BuildContext context, WidgetRef ref, String sessionId,
      int understanding) async {
    await ref.read(finishLearningSessionUseCaseProvider).call(
          sessionId: sessionId,
          understanding: understanding,
          focusScore: 7,
          energyScore: 7,
        );
    ref.invalidate(activeLearningSessionProvider);
    ref.invalidate(needsReviewTopicsProvider);
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.sessionId, required this.onFinish});
  final String sessionId;
  final ValueChanged<int> onFinish;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LifeOSColors.card,
      child: Padding(
        padding: const EdgeInsets.all(LifeOSSpacing.md),
        child: Row(
          children: [
            const Expanded(
              child: Text('Learning session in progress…',
                  style: TextStyle(color: LifeOSColors.textPrimary)),
            ),
            // Understanding rating: 1-10 slider per RFC-009 §9; simplified
            // here to a "finish with rating 3" demo action to keep the
            // foundation screen thin. A dedicated rating dialog is a
            // follow-up UI task, not an architecture change.
            OutlinedButton(
              onPressed: () => onFinish(7),
              child: const Text('Finish (rate 7/10)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic});
  final LearningTopic topic;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LifeOSColors.card,
      child: ListTile(
        leading: Icon(
          topic.reviewNeeded
              ? PhosphorIconsRegular.warningCircle
              : PhosphorIconsRegular.bookOpen,
          color: topic.reviewNeeded ? LifeOSColors.danger : LifeOSColors.textSecondary,
        ),
        title: Text(topic.displayTitle,
            style: const TextStyle(color: LifeOSColors.textPrimary)),
      ),
    );
  }
}
