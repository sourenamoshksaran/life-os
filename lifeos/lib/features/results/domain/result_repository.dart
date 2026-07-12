import 'result.dart';

abstract class ResultRepository {
  Future<Result?> getDailyResult(String localDate);
  Future<List<Result>> getRange(String startLocalDate, String endLocalDate,
      {ResultPeriod period = ResultPeriod.daily});
  Future<void> save(Result result);
}
