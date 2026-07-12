import 'nutrition.dart';

abstract class NutritionRepository {
  Future<List<NutritionEntry>> getByDate(String localDate);
  Future<void> saveEntry(NutritionEntry entry);
  Future<List<WaterLog>> getWaterByDate(String localDate);
  Future<void> saveWater(WaterLog log);
}
