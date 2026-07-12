import '../domain/result.dart';
import '../domain/result_repository.dart';

/// TODO(implementation): replace with IsarResultRepository once Isar
/// collections are generated. `localDate` is unique per
/// `(localDate, period=Daily)` — enforced here at save() time per
/// docs/rfc/RFC-012_Results.md §5; the Isar impl should mirror via a
/// composite unique index.
class InMemoryResultRepository implements ResultRepository {
  final Map<String, Result> _dailyByDate = {};
  final List<Result> _periodResults = [];

  @override
  Future<Result?> getDailyResult(String localDate) async => _dailyByDate[localDate];

  @override
  Future<List<Result>> getRange(String startLocalDate, String endLocalDate,
      {ResultPeriod period = ResultPeriod.daily}) async {
    if (period == ResultPeriod.daily) {
      return _dailyByDate.values
          .where((r) =>
              r.localDate.compareTo(startLocalDate) >= 0 &&
              r.localDate.compareTo(endLocalDate) <= 0)
          .toList()
        ..sort((a, b) => a.localDate.compareTo(b.localDate));
    }
    return _periodResults
        .where((r) =>
            r.period == period &&
            r.localDate.compareTo(startLocalDate) >= 0 &&
            r.localDate.compareTo(endLocalDate) <= 0)
        .toList();
  }

  @override
  Future<void> save(Result result) async {
    if (result.period == ResultPeriod.daily) {
      _dailyByDate[result.localDate] = result;
    } else {
      _periodResults.removeWhere(
          (r) => r.period == result.period && r.localDate == result.localDate);
      _periodResults.add(result);
    }
  }
}
