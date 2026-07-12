import 'settings_models.dart';

/// Settings/DailyGoals/User are all singleton records per device
/// (RFC-014 §3). Backed by Hive in production — see docs/02_Software_
/// Requirements.md §6 Storage ("Settings: Hive").
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<DailyGoals> getDailyGoals();
  Future<void> saveDailyGoals(DailyGoals goals);
  Future<AppUser?> getUser();
  Future<void> saveUser(AppUser user);
}
