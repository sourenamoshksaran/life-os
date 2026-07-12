import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engines/life_score_engine/life_score_engine.dart';
import '../../../core/engines/session_engine/session.dart';
import '../../../core/services/date_manager.dart';
import '../../nutrition/controllers/nutrition_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../sleep/controllers/sleep_controller.dart';
import '../../tasks/controllers/task_controller.dart'
    show sessionRepositoryProvider, taskListProvider;
import '../../tasks/domain/task.dart' show TaskStatus;
import '../data/in_memory_result_repository.dart';
import '../domain/result.dart';
import '../domain/result_repository.dart';

const _dateManager = DateManager();

final lifeScoreEngineProvider = Provider<LifeScoreEngine>((ref) => LifeScoreEngine());

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return InMemoryResultRepository();
});

/// Computes (or reads, if already finalized) today's Result — the
/// Dashboard/Results "live provisional preview" described in RFC-003 §5
/// and RFC-012 §4. This is the single call site that gathers inputs from
/// every module and hands them to the Life Score Engine; no other code
/// path computes Life Score.
final todayResultProvider = FutureProvider<Result>((ref) async {
  final localDate = _dateManager.today();
  final resultRepo = ref.watch(resultRepositoryProvider);

  final existing = await resultRepo.getDailyResult(localDate);
  if (existing != null && !existing.isProvisional) {
    return existing; // Finalized days are never silently recomputed (RFC-012 §4)
  }

  final tasks = await ref.watch(taskListProvider.future);
  final todaysTasks = tasks.where((t) => t.localDate == localDate).toList();
  final completedTasks = todaysTasks.where((t) => t.status == TaskStatus.completed).length;

  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final allTaskSessions = await sessionRepo.getByType(SessionType.task, localDate: localDate);
  final allWorkoutSessions =
      await sessionRepo.getByType(SessionType.workout, localDate: localDate);
  final allLearningSessions =
      await sessionRepo.getByType(SessionType.learning, localDate: localDate);
  final allSessions = [...allTaskSessions, ...allWorkoutSessions, ...allLearningSessions];

  final sleepLog = await ref.watch(todaySleepLogProvider.future);
  final waterLogs = await ref.watch(todayWaterLogProvider.future);
  final meals = await ref.watch(todayNutritionProvider.future);
  final goals = await ref.watch(dailyGoalsProvider.future);
  final settings = await ref.watch(settingsProvider.future);

  final totalWater = waterLogs.fold<double>(0, (s, w) => s + w.amount);
  final learningMinutes = allLearningSessions
      .where((s) => s.effectiveDuration != null)
      .fold<int>(0, (s, sess) => s + sess.effectiveDuration!.inMinutes);

  final inputs = DailyScoreInputs(
    localDate: localDate,
    completedTasks: completedTasks,
    totalTasks: todaysTasks.length,
    sessions: allSessions,
    workoutPlanned: false,
    workoutCompleted: allWorkoutSessions.any((s) => s.status == SessionStatus.reflected),
    learningMinutes: learningMinutes,
    learningTargetMinutes: goals.dailyLearningMinutesGoal,
    sleepHours: sleepLog == null ? null : sleepLog.duration.inMinutes / 60,
    sleepTargetHours: goals.sleepGoalHours,
    sleepQuality: sleepLog?.quality,
    mealsLogged: meals.length,
    nutritionTargetsMet: goals.dailyCalorieGoal == 0
        ? 0
        : (meals.fold<double>(0, (s, m) => s + m.calories) / goals.dailyCalorieGoal)
            .clamp(0, 1),
    waterGoalPercent:
        goals.dailyWaterGoalMl == 0 ? 0 : (totalWater / goals.dailyWaterGoalMl).clamp(0, 2),
    sevenDayStreak: 0, // requires historical Result range; computed in Daily Closing use case
    disabledModules: settings.disabledModules,
  );

  final computed = ref.read(lifeScoreEngineProvider).computeDaily(inputs, isProvisional: true);
  await resultRepo.save(computed);
  return computed;
});

/// Finalizes today's Result — see docs/rfc/RFC-012_Results.md §4 Daily
/// Closing Flow. Locks the record (`isProvisional=false`); correcting a
/// finalized day requires the explicit "Reopen Day" action, not a silent
/// recompute.
class FinalizeDailyResultUseCase {
  FinalizeDailyResultUseCase(this._repository);
  final ResultRepository _repository;

  Future<Result> call(Result provisional, {String? note}) async {
    final finalized = Result(
      id: provisional.id,
      createdAt: provisional.createdAt,
      updatedAt: DateTime.now(),
      localDate: provisional.localDate,
      period: provisional.period,
      rangeStart: provisional.rangeStart,
      rangeEnd: provisional.rangeEnd,
      lifeScore: provisional.lifeScore,
      taskScore: provisional.taskScore,
      sessionQualityScore: provisional.sessionQualityScore,
      workoutScore: provisional.workoutScore,
      learningScore: provisional.learningScore,
      sleepScore: provisional.sleepScore,
      nutritionScore: provisional.nutritionScore,
      consistencyScore: provisional.consistencyScore,
      completedTasks: provisional.completedTasks,
      totalTasks: provisional.totalTasks,
      deepWorkMinutes: provisional.deepWorkMinutes,
      journalCompleted: provisional.journalCompleted,
      isProvisional: false,
      formulaVersion: provisional.formulaVersion,
      notes: note ?? provisional.notes,
    );
    await _repository.save(finalized);
    return finalized;
  }
}

final finalizeDailyResultUseCaseProvider = Provider((ref) {
  return FinalizeDailyResultUseCase(ref.watch(resultRepositoryProvider));
});
