import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

/// TODO(implementation): replace with HiveSettingsRepository — Settings,
/// DailyGoals, and User are all lightweight singleton records, a natural
/// fit for Hive boxes rather than Isar collections (docs/02_Software_
/// Requirements.md §6).
class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();
  DailyGoals _dailyGoals = const DailyGoals();
  AppUser? _user;

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => _settings = settings;

  @override
  Future<DailyGoals> getDailyGoals() async => _dailyGoals;

  @override
  Future<void> saveDailyGoals(DailyGoals goals) async => _dailyGoals = goals;

  @override
  Future<AppUser?> getUser() async => _user;

  @override
  Future<void> saveUser(AppUser user) async => _user = user;
}
