import '../../../core/models/base_entity.dart';

enum DoseStatus { scheduled, taken, skipped, missed }

class Medicine extends BaseEntity {
  Medicine({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.dosage,
    required this.scheduleTimes,
    this.notes,
    this.active = true,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String name;
  final String dosage;
  final List<String> scheduleTimes; // e.g. ["08:00", "20:00"]
  final String? notes;
  final bool active;
}

class MedicineLog extends BaseEntity {
  MedicineLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.medicineId,
    required this.scheduledTime,
    required this.status,
    required this.localDate,
    this.actualTime,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String medicineId;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final DoseStatus status;
  final String localDate;

  MedicineLog copyWith({DoseStatus? status, DateTime? actualTime}) {
    return MedicineLog(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      localDate: localDate,
      actualTime: actualTime ?? this.actualTime,
    );
  }
}

/// Supplement mirrors Medicine exactly — shared pattern, RFC-011 §1.
class Supplement extends BaseEntity {
  Supplement({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.dosage,
    required this.scheduleTimes,
    this.notes,
    this.active = true,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String name;
  final String dosage;
  final List<String> scheduleTimes;
  final String? notes;
  final bool active;
}

class SupplementLog extends BaseEntity {
  SupplementLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.supplementId,
    required this.scheduledTime,
    required this.status,
    required this.localDate,
    this.actualTime,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String supplementId;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final DoseStatus status;
  final String localDate;

  SupplementLog copyWith({DoseStatus? status, DateTime? actualTime}) {
    return SupplementLog(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      supplementId: supplementId,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      localDate: localDate,
      actualTime: actualTime ?? this.actualTime,
    );
  }
}
