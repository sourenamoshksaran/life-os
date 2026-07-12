import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/engines/session_engine/session.dart';
import '../../../../core/services/date_manager.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../tasks/controllers/task_controller.dart' show sessionRepositoryProvider;

const _dateManager = DateManager();

/// A real chronological Timeline of today's activity — merges every
/// `sessionType` (Task, Workout, Learning, ...) from the Core Session
/// Engine into one ordered list, demonstrating exactly the "one shared
/// session system, many modules" principle from RFC-005 §2: the Timeline
/// never has to know about each module individually, it just reads
/// Sessions.
final todayTimelineProvider = FutureProvider<List<Session>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final today = _dateManager.today();

  final all = <Session>[];
  for (final type in SessionType.values) {
    all.addAll(await repo.getByType(type, localDate: today));
  }
  all.sort((a, b) => a.startTime.compareTo(b.startTime));
  return all;
});

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(todayTimelineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('Nothing logged yet today.',
                  style: TextStyle(color: LifeOSColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(LifeOSSpacing.md),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: LifeOSSpacing.sm),
            itemBuilder: (context, i) {
              final s = sessions[i];
              return Container(
                padding: const EdgeInsets.all(LifeOSSpacing.md),
                decoration:
                    BoxDecoration(color: LifeOSColors.card, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(_formatTime(s.startTime),
                          style: const TextStyle(color: LifeOSColors.textSecondary, fontSize: 12)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.sessionType.name,
                              style: const TextStyle(
                                  color: LifeOSColors.textPrimary, fontWeight: FontWeight.w600)),
                          Text(
                            s.effectiveDuration == null
                                ? s.status.name
                                : '${s.effectiveDuration!.inMinutes} min · ${s.status.name}',
                            style: const TextStyle(color: LifeOSColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
