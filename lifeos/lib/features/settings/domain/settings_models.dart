import '../../../core/models/base_entity.dart';

class AppUser extends BaseEntity {
  AppUser({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.displayName,
    this.avatarIcon,
    this.timezone,
    this.calendarPreference = 'SolarHijri',
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String displayName;
  final String? avatarIcon;
  final String? timezone;

  /// Display-only — see docs/04_Database_Schema.md Recurrence Calendar Rule.
  final String calendarPreference;
}

/// Backs every progress ring in the UI (Water, Nutrition, Sleep, Workout,
/// Learning). Singleton per device — see docs/rfc/RFC-014_Settings.md §3.
class DailyGoals {
  const DailyGoals({
    this.dailyWaterGoalMl = 2000,
    this.dailyCalorieGoal = 2200,
    this.dailyProteinGoal = 120,
    this.sleepGoalHours = 8,
    this.weeklyWorkoutSessionGoal = 4,
    this.dailyLearningMinutesGoal = 30,
    this.dailyDeepWorkMinutesGoal = 90,
  });

  final double dailyWaterGoalMl;
  final double dailyCalorieGoal;
  final double dailyProteinGoal;
  final double sleepGoalHours;
  final int weeklyWorkoutSessionGoal;
  final int dailyLearningMinutesGoal;
  final int dailyDeepWorkMinutesGoal;

  DailyGoals copyWith({
    double? dailyWaterGoalMl,
    double? dailyCalorieGoal,
    double? sleepGoalHours,
  }) {
    return DailyGoals(
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal,
      sleepGoalHours: sleepGoalHours ?? this.sleepGoalHours,
      weeklyWorkoutSessionGoal: weeklyWorkoutSessionGoal,
      dailyLearningMinutesGoal: dailyLearningMinutesGoal,
      dailyDeepWorkMinutesGoal: dailyDeepWorkMinutesGoal,
    );
  }
}

/// `moduleToggles` keys must match the component names used by
/// LifeScoreEngine's `disabledModules` set (core/engines/life_score_engine).
class AppSettings {
  const AppSettings({
    this.language = 'fa',
    this.theme = 'dark',
    this.notificationSound = false,
    this.gracePeriodMinutes = 120,
    this.moduleToggles = const {
      'task': true,
      'sessionQuality': true,
      'workout': true,
      'learning': true,
      'sleep': true,
      'nutrition': true,
      'consistency': true,
    },
    this.encryptionEnabled = false,
  });

  final String language;
  final String theme;
  final bool notificationSound;
  final int gracePeriodMinutes;
  final Map<String, bool> moduleToggles;
  final bool encryptionEnabled;

  Set<String> get disabledModules =>
      moduleToggles.entries.where((e) => !e.value).map((e) => e.key).toSet();
}
