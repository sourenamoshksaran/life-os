import 'package:hive/hive.dart';

import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

/// Hive-backed implementation — Settings/DailyGoals/User are lightweight
/// singleton records, the documented fit for Hive rather than Isar
/// (docs/02_Software_Requirements.md §6 Storage). Swaps in behind the
/// same `SettingsRepository` interface `InMemorySettingsRepository`
/// implements (CLAUDE.md §6) — no caller changes.
///
/// BUILD NOTE: requires `Hive.openBox('lifeos_settings')` to have been
/// called at app startup (after `Hive.initFlutter()` in main.dart) before
/// this repository is constructed. Uses plain `Map<String, dynamic>`
/// storage rather than Hive TypeAdapters to avoid a second codegen
/// dependency — acceptable for these three small, rarely-changing
/// singleton records.
class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._box);

  final Box _box;

  static const _settingsKey = 'settings';
  static const _dailyGoalsKey = 'dailyGoals';
  static const _userKey = 'user';

  @override
  Future<AppSettings> getSettings() async {
    final raw = _box.get(_settingsKey) as Map?;
    if (raw == null) return const AppSettings();
    return AppSettings(
      language: raw['language'] as String? ?? 'fa',
      theme: raw['theme'] as String? ?? 'dark',
      notificationSound: raw['notificationSound'] as bool? ?? false,
      gracePeriodMinutes: raw['gracePeriodMinutes'] as int? ?? 120,
      moduleToggles: (raw['moduleToggles'] as Map?)?.cast<String, bool>() ??
          const {
            'task': true,
            'sessionQuality': true,
            'workout': true,
            'learning': true,
            'sleep': true,
            'nutrition': true,
            'consistency': true,
          },
      encryptionEnabled: raw['encryptionEnabled'] as bool? ?? false,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, {
      'language': settings.language,
      'theme': settings.theme,
      'notificationSound': settings.notificationSound,
      'gracePeriodMinutes': settings.gracePeriodMinutes,
      'moduleToggles': settings.moduleToggles,
      'encryptionEnabled': settings.encryptionEnabled,
    });
  }

  @override
  Future<DailyGoals> getDailyGoals() async {
    final raw = _box.get(_dailyGoalsKey) as Map?;
    if (raw == null) return const DailyGoals();
    return DailyGoals(
      dailyWaterGoalMl: (raw['dailyWaterGoalMl'] as num?)?.toDouble() ?? 2000,
      dailyCalorieGoal: (raw['dailyCalorieGoal'] as num?)?.toDouble() ?? 2200,
      dailyProteinGoal: (raw['dailyProteinGoal'] as num?)?.toDouble() ?? 120,
      sleepGoalHours: (raw['sleepGoalHours'] as num?)?.toDouble() ?? 8,
      weeklyWorkoutSessionGoal: raw['weeklyWorkoutSessionGoal'] as int? ?? 4,
      dailyLearningMinutesGoal: raw['dailyLearningMinutesGoal'] as int? ?? 30,
      dailyDeepWorkMinutesGoal: raw['dailyDeepWorkMinutesGoal'] as int? ?? 90,
    );
  }

  @override
  Future<void> saveDailyGoals(DailyGoals goals) async {
    await _box.put(_dailyGoalsKey, {
      'dailyWaterGoalMl': goals.dailyWaterGoalMl,
      'dailyCalorieGoal': goals.dailyCalorieGoal,
      'dailyProteinGoal': goals.dailyProteinGoal,
      'sleepGoalHours': goals.sleepGoalHours,
      'weeklyWorkoutSessionGoal': goals.weeklyWorkoutSessionGoal,
      'dailyLearningMinutesGoal': goals.dailyLearningMinutesGoal,
      'dailyDeepWorkMinutesGoal': goals.dailyDeepWorkMinutesGoal,
    });
  }

  @override
  Future<AppUser?> getUser() async {
    final raw = _box.get(_userKey) as Map?;
    if (raw == null) return null;
    return AppUser(
      id: raw['id'] as String,
      createdAt: DateTime.parse(raw['createdAt'] as String),
      updatedAt: DateTime.parse(raw['updatedAt'] as String),
      displayName: raw['displayName'] as String,
      avatarIcon: raw['avatarIcon'] as String?,
      timezone: raw['timezone'] as String?,
      calendarPreference: raw['calendarPreference'] as String? ?? 'SolarHijri',
    );
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _box.put(_userKey, {
      'id': user.id,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'displayName': user.displayName,
      'avatarIcon': user.avatarIcon,
      'timezone': user.timezone,
      'calendarPreference': user.calendarPreference,
    });
  }
}
