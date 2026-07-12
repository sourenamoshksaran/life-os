import 'sleep_log.dart';

abstract class SleepRepository {
  Future<SleepLog?> getByDate(String localDate);
  Future<List<SleepLog>> getRange(String startLocalDate, String endLocalDate);
  Future<void> save(SleepLog log);
}
