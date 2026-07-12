import '../../../core/models/base_entity.dart';

/// Reference entity — see docs/rfc/RFC-009_Learning.md §3.
/// `subject` is the only required nesting level; course/chapter/lesson
/// are optional (RFC-009 §5).
class LearningTopic extends BaseEntity {
  LearningTopic({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.subject,
    this.course,
    this.chapter,
    this.lesson,
    this.resource,
    this.order = 0,
    this.reviewNeeded = false,
    super.deletedAt,
    super.isArchived,
    super.isDeleted,
    super.version,
    super.deviceId,
    super.syncState,
  });

  final String subject;
  final String? course;
  final String? chapter;
  final String? lesson;
  final String? resource;
  final int order;

  /// Surfaces this topic in the "Needs Review" list (RFC-009 §6).
  /// Set by the reflection flow, not edited freely by the user in v1.
  final bool reviewNeeded;

  String get displayTitle =>
      [subject, course, chapter, lesson].whereType<String>().join(' › ');

  LearningTopic copyWith({
    String? subject,
    String? course,
    String? chapter,
    String? lesson,
    String? resource,
    int? order,
    bool? reviewNeeded,
    DateTime? updatedAt,
  }) {
    return LearningTopic(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      subject: subject ?? this.subject,
      course: course ?? this.course,
      chapter: chapter ?? this.chapter,
      lesson: lesson ?? this.lesson,
      resource: resource ?? this.resource,
      order: order ?? this.order,
      reviewNeeded: reviewNeeded ?? this.reviewNeeded,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}
