import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/base_entity.dart';
import '../../../core/services/date_manager.dart';
import '../data/in_memory_sleep_repository.dart';
import '../domain/sleep_log.dart';
import '../domain/sleep_repository.dart';

const _dateManager = DateManager();

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return InMemorySleepRepository();
});

final todaySleepLogProvider =
    AsyncNotifierProvider<TodaySleepLogNotifier, SleepLog?>(TodaySleepLogNotifier.new);

class TodaySleepLogNotifier extends AsyncNotifier<SleepLog?> {
  @override
  Future<SleepLog?> build() => ref.watch(sleepRepositoryProvider).getByDate(_dateManager.today());

  Future<void> logSleep({
    required DateTime sleepTime,
    required DateTime wakeTime,
    required int quality,
    String? dreamNotes,
    int? energyAfterWake,
  }) async {
    final now = DateTime.now();
    await ref.read(sleepRepositoryProvider).save(SleepLog(
          id: BaseEntity.newId(),
          createdAt: now,
          updatedAt: now,
          sleepTime: sleepTime,
          wakeTime: wakeTime,
          quality: quality,
          dreamNotes: dreamNotes,
          energyAfterWake: energyAfterWake,
          // localDate = the wake-up day, per docs/04_Database_Schema.md
          // "Sleep Log" and RFC-005 §7's day-boundary rule.
          localDate: _dateManager.localDateFor(wakeTime),
        ));
    ref.invalidateSelf();
    await future;
  }
}
