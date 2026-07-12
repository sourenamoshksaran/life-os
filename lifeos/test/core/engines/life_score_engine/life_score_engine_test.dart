import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/engines/life_score_engine/life_score_engine.dart';
import 'package:lifeos/features/results/domain/result.dart';

/// Covers RFC-003 §3 (weights), §4 (missing-data handling), §5
/// (aggregation is an average of daily records, never recomputed).
void main() {
  final engine = LifeScoreEngine();

  DailyScoreInputs baseInputs({Set<String> disabled = const {}}) {
    return DailyScoreInputs(
      localDate: '2026-07-11',
      completedTasks: 4,
      totalTasks: 5,
      sessions: const [],
      workoutPlanned: false,
      workoutCompleted: false,
      learningMinutes: 30,
      learningTargetMinutes: 30,
      sleepHours: 8,
      sleepTargetHours: 8,
      sleepQuality: 8,
      mealsLogged: 3,
      nutritionTargetsMet: 1.0,
      waterGoalPercent: 1.0,
      sevenDayStreak: 7,
      disabledModules: disabled,
    );
  }

  test('computeDaily produces a score between 0 and 100', () {
    final result = engine.computeDaily(baseInputs());
    expect(result.lifeScore, inInclusiveRange(0, 100));
    expect(result.period, ResultPeriod.daily);
  });

  test('missing data scores 0 for that component, not excluded (RFC-003 §4)', () {
    final inputs = DailyScoreInputs(
      localDate: '2026-07-11',
      completedTasks: 0,
      totalTasks: 0,
      sessions: const [],
      workoutPlanned: false,
      workoutCompleted: false,
      learningMinutes: 0,
      learningTargetMinutes: 30,
      sleepHours: null,
      sleepTargetHours: 8,
      sleepQuality: null,
      mealsLogged: 0,
      nutritionTargetsMet: 0,
      waterGoalPercent: 0,
      sevenDayStreak: 0,
      disabledModules: const {},
    );
    final result = engine.computeDaily(inputs);
    expect(result.taskScore, 0);
    expect(result.sleepScore, 0);
    expect(result.lifeScore, lessThan(20));
  });

  test('disabling a low-scoring module redistributes weight upward (RFC-003 §4 exception)', () {
    final withWorkout = engine.computeDaily(baseInputs());
    final withoutWorkoutModule = engine.computeDaily(baseInputs(disabled: {'workout'}));
    expect(withoutWorkoutModule.lifeScore, greaterThanOrEqualTo(withWorkout.lifeScore));
  });

  test('aggregate averages daily results, never recomputes from raw data', () {
    final day1 = engine.computeDaily(baseInputs());
    final day2 = engine.computeDaily(baseInputs());
    final weekly = engine.aggregate([day1, day2], ResultPeriod.weekly);
    expect(weekly.lifeScore, day1.lifeScore);
    expect(weekly.period, ResultPeriod.weekly);
  });

  test('aggregate throws on empty list', () {
    expect(() => engine.aggregate([], ResultPeriod.weekly), throwsArgumentError);
  });
}
