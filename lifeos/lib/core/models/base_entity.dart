import 'package:uuid/uuid.dart';

/// Global Fields required on every LifeOS entity.
///
/// See docs/04_Database_Schema.md "Global Fields" and CLAUDE.md §7.
/// Every domain entity mixes this in instead of re-declaring these
/// fields individually.
abstract class BaseEntity {
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.version = 1,
    this.deviceId,
    this.syncState,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isArchived;
  final bool isDeleted;
  final int version;

  /// Reserved for future Cloud Sync (see CLAUDE.md §25 Future Expansion Rules).
  final String? deviceId;
  final String? syncState;

  static String newId() => const Uuid().v4();
}
