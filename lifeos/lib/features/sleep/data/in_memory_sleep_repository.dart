import '../domain/sleep_log.dart';
import '../domain/sleep_repository.dart';

/// TODO(implementation): replace with IsarSleepRepository — same pattern
/// as IsarTaskRepository/IsarSessionRepository.
class InMemorySleepRepository implements SleepRepository {
  final Map<String, SleepLog> _byDate = {};

  @override
  Future<SleepLog?> getByDate(String localDate) async => _byDate[localDate];

  @override
  Future<List<SleepLog>> getRange(String startLocalDate, String endLocalDate) async {
    return _byDate.values
        .where((l) =>
            l.localDate.compareTo(startLocalDate) >= 0 && l.localDate.compareTo(endLocalDate) <= 0)
        .toList()
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
  }

  @override
  Future<void> save(SleepLog log) async {
    _byDate[log.localDate] = log;
  }
}
