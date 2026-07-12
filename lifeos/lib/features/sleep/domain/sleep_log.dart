import '../../../core/models/base_entity.dart';

/// See docs/04_Database_Schema.md "Sleep Log". Not covered by its own
/// RFC yet (deferred per FINAL_SPECIFICATION_REPORT.md §4), but the data
/// model already exists in the schema, so basic CRUD needs no bespoke
/// RFC — this closes the gap that left the Life Score Engine's sleep
/// component permanently at 0 (see IMPLEMENTATION_REPORT.md §4).
class SleepLog extends BaseEntity {
  SleepLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.sleepTime,
    required this.wakeTime,
    required this.quality,
    required this.localDate,
    this.dreamNotes,
    this.energyAfterWake,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final DateTime sleepTime;
  final DateTime wakeTime;

  /// 1-10 — see docs/04_Database_Schema.md.
  final int quality;

  final String? dreamNotes;
  final int? energyAfterWake;

  /// The day of the wake-up, per DateManager's day-boundary rule —
  /// correlation key (RFC-005 §7).
  final String localDate;

  Duration get duration => wakeTime.difference(sleepTime);
}
