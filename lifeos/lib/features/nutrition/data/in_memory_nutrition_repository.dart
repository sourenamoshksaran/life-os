import '../domain/nutrition.dart';
import '../domain/nutrition_repository.dart';

/// TODO(implementation): replace with IsarNutritionRepository.
class InMemoryNutritionRepository implements NutritionRepository {
  final List<NutritionEntry> _entries = [];
  final List<WaterLog> _waterLogs = [];

  @override
  Future<List<NutritionEntry>> getByDate(String localDate) async =>
      _entries.where((e) => e.localDate == localDate && !e.isDeleted).toList();

  @override
  Future<void> saveEntry(NutritionEntry entry) async {
    _entries.removeWhere((e) => e.id == entry.id);
    _entries.add(entry);
  }

  @override
  Future<List<WaterLog>> getWaterByDate(String localDate) async =>
      _waterLogs.where((w) => w.localDate == localDate).toList();

  @override
  Future<void> saveWater(WaterLog log) async {
    _waterLogs.removeWhere((w) => w.id == log.id);
    _waterLogs.add(log);
  }
}
