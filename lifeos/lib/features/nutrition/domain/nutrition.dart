import '../../../core/models/base_entity.dart';

enum MealType { breakfast, lunch, dinner, snack }

class NutritionEntry extends BaseEntity {
  NutritionEntry({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.mealType,
    required this.localDate,
    this.calories = 0,
    this.protein = 0,
    this.carbohydrate = 0,
    this.fat = 0,
    this.fiber = 0,
    this.water = 0,
    this.notes,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final MealType mealType;
  final double calories;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double fiber;
  final double water;
  final String? notes;

  /// Correlation key — RFC-005 §7.
  final String localDate;
}

class WaterLog extends BaseEntity {
  WaterLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.amount,
    required this.time,
    required this.localDate,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final double amount; // ml
  final DateTime time;
  final String localDate;
}
