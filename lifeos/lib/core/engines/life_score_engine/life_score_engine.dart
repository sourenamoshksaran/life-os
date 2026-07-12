import '../../../features/results/domain/result.dart';
import '../../models/base_entity.dart';
import '../session_engine/session.dart';

/// Inputs the Life Score Engine needs for a single day, gathered by the
/// caller (Results/Dashboard controllers) from each module's repository.
/// The engine itself has no repository dependencies — it is a pure
/// calculator, per docs/rfc/RFC-003_Life_Score_Engine.md.
class DailyScoreInputs {
  const DailyScoreInputs({
    required this.localDate,
    required this.completedTasks,
    required this.totalTasks,
    required this.sessions,
    required this.workoutPlanned,
    required this.workoutCompleted,
    required this.learningMinutes,
    required this.learningTargetMinutes,
    required this.sleepHours,
    required this.sleepTargetHours,
    required this.sleepQuality,
    required this.mealsLogged,
    required this.nutritionTargetsMet,
    required this.waterGoalPercent,
    required this.sevenDayStreak,
    required this.disabledModules,
  });

  final String localDate;
  final int completedTasks;
  final int totalTasks;
  final List<Session> sessions; // all Sessions (any type) for this localDate
  final bool workoutPlanned;
  final bool workoutCompleted;
  final int learningMinutes;
  final int learningTargetMinutes;
  final double? sleepHours;
  final double sleepTargetHours;
  final int? sleepQuality;
  final int mealsLogged;
  final double nutritionTargetsMet; // 0.0-1.0
  final double waterGoalPercent; // 0.0-1.0+
  final int sevenDayStreak; // consecutive days with >=1 completed session, capped at 7
  final Set<String> disabledModules; // matches Settings.moduleToggles keys
}

class _Component {
  const _Component(this.name, this.weight, this.score);
  final String name;
  final double weight;
  final int score;
}

/// Computes the single 0-100 Life Score from raw daily inputs. This is
/// the ONLY place Life Score is computed — see CLAUDE.md §17. Weights
/// and missing-data handling follow RFC-003 §3-4 exactly.
class LifeScoreEngine {
  static const int currentFormulaVersion = 1;

  Result computeDaily(DailyScoreInputs input, {bool isProvisional = true}) {
    final taskScore = input.totalTasks == 0
        ? 0
        : ((input.completedTasks / input.totalTasks) * 100).round();

    final sessionQualityScore = _sessionQualityScore(input.sessions);

    final workoutScore = !input.workoutPlanned
        ? (input.sessions.any((s) => s.sessionType == SessionType.workout) ? 100 : 0)
        : (input.workoutCompleted ? 100 : 0);

    final learningScore = input.learningTargetMinutes == 0
        ? (input.learningMinutes > 0 ? 100 : 0)
        : ((input.learningMinutes / input.learningTargetMinutes) * 100)
            .clamp(0, 100)
            .round();

    final sleepDurationScore = input.sleepHours == null
        ? 0
        : ((input.sleepHours! / input.sleepTargetHours) * 100).clamp(0, 100).round();
    final sleepQualityScore = (input.sleepQuality ?? 0) * 10;
    final sleepScore =
        input.sleepHours == null ? 0 : ((sleepDurationScore + sleepQualityScore) / 2).round();

    final nutritionScore = ((input.mealsLogged > 0 ? 40 : 0) +
            (input.nutritionTargetsMet * 40) +
            (input.waterGoalPercent.clamp(0, 1) * 20))
        .round();

    final consistencyScore = ((input.sevenDayStreak.clamp(0, 7) / 7) * 100).round();

    final components = <_Component>[
      _Component('task', 0.25, taskScore),
      _Component('sessionQuality', 0.15, sessionQualityScore),
      _Component('workout', 0.15, workoutScore),
      _Component('learning', 0.15, learningScore),
      _Component('sleep', 0.10, sleepScore),
      _Component('nutrition', 0.10, nutritionScore),
      _Component('consistency', 0.10, consistencyScore),
    ];

    final active =
        components.where((c) => !input.disabledModules.contains(c.name)).toList();
    final totalActiveWeight = active.fold<double>(0, (sum, c) => sum + c.weight);

    final lifeScore = totalActiveWeight == 0
        ? 0
        : active
            .fold<double>(0, (sum, c) => sum + (c.score * (c.weight / totalActiveWeight)))
            .round();

    final now = DateTime.now();
    return Result(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      localDate: input.localDate,
      period: ResultPeriod.daily,
      rangeStart: now,
      rangeEnd: now,
      lifeScore: lifeScore,
      taskScore: taskScore,
      sessionQualityScore: sessionQualityScore,
      workoutScore: workoutScore,
      learningScore: learningScore,
      sleepScore: sleepScore,
      nutritionScore: nutritionScore,
      consistencyScore: consistencyScore,
      completedTasks: input.completedTasks,
      totalTasks: input.totalTasks,
      deepWorkMinutes: _deepWorkMinutes(input.sessions),
      isProvisional: isProvisional,
      formulaVersion: currentFormulaVersion,
    );
  }

  /// Weekly/Monthly/Yearly are always an aggregate of Daily records —
  /// never independently recomputed from raw data (RFC-003 §5).
  Result aggregate(List<Result> dailyResults, ResultPeriod period) {
    if (dailyResults.isEmpty) {
      throw ArgumentError('Cannot aggregate an empty list of Results.');
    }
    int avg(int Function(Result) selector) =>
        (dailyResults.map(selector).reduce((a, b) => a + b) / dailyResults.length).round();

    final sorted = [...dailyResults]..sort((a, b) => a.localDate.compareTo(b.localDate));
    final now = DateTime.now();

    return Result(
      id: BaseEntity.newId(),
      createdAt: now,
      updatedAt: now,
      localDate: sorted.first.localDate,
      period: period,
      rangeStart: sorted.first.rangeStart,
      rangeEnd: sorted.last.rangeEnd,
      lifeScore: avg((r) => r.lifeScore),
      taskScore: avg((r) => r.taskScore),
      sessionQualityScore: avg((r) => r.sessionQualityScore),
      workoutScore: avg((r) => r.workoutScore),
      learningScore: avg((r) => r.learningScore),
      sleepScore: avg((r) => r.sleepScore),
      nutritionScore: avg((r) => r.nutritionScore),
      consistencyScore: avg((r) => r.consistencyScore),
      completedTasks: dailyResults.fold(0, (s, r) => s + r.completedTasks),
      totalTasks: dailyResults.fold(0, (s, r) => s + r.totalTasks),
      deepWorkMinutes: dailyResults.fold(0, (s, r) => s + r.deepWorkMinutes),
      isProvisional: dailyResults.any((r) => r.isProvisional),
      formulaVersion: currentFormulaVersion,
    );
  }

  int _sessionQualityScore(List<Session> sessions) {
    final reflected = sessions.where((s) =>
        s.status == SessionStatus.reflected && s.focusScore != null && s.energyScore != null);
    if (reflected.isEmpty) return 0;
    final avg = reflected.fold<double>(0, (sum, s) => sum + ((s.focusScore! + s.energyScore!) / 2)) /
        reflected.length;
    return (avg * 10).round();
  }

  int _deepWorkMinutes(List<Session> sessions) {
    return sessions
        .where((s) => s.effectiveDuration != null)
        .fold<int>(0, (sum, s) => sum + s.effectiveDuration!.inMinutes);
  }
}
