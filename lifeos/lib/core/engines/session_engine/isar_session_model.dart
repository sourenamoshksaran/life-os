import 'package:isar/isar.dart';

import 'session.dart';
import 'session_repository.dart';

part 'isar_session_model.g.dart';

/// Isar collection model for [Session]. Mirrors the domain entity's
/// fields exactly (docs/04_Database_Schema.md "Session Entity (Generic)").
///
/// BUILD NOTE: this file requires `flutter pub run build_runner build` to
/// generate `isar_session_model.g.dart` before it will compile — Isar's
/// codegen produces the `IsarSessionModelSchema` and adapter code. This
/// sandbox has no network access to pub.dev, so that generation step has
/// NOT been run here (see IMPLEMENTATION_REPORT.md §1). The domain layer
/// (`Session`, `SessionRepository`) has zero dependency on this file or
/// on Isar — only `IsarSessionRepository` below does, per the repository
/// pattern in CLAUDE.md §6.
@collection
class IsarSessionModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @enumerated
  late SessionType sessionType;

  String? contextId;

  @enumerated
  late SessionStatus status;

  late DateTime startTime;

  @Index()
  late String localDate;

  DateTime? endTime;
  int? effectiveDurationSeconds;
  int? focusScore;
  int? energyScore;
  int? difficultyScore;
  String? reflectionNote;
  bool reflectionSkipped = false;

  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? deletedAt;
  bool isArchived = false;
  bool isDeleted = false;
  int version = 1;
  String? deviceId;
  String? syncState;

  // Pause intervals stored as flattened parallel lists — Isar embedded
  // objects require their own @embedded class; kept simple here since
  // pause/resume timestamps are always paired.
  List<DateTime> pausedAtTimes = const [];
  List<DateTime?> resumedAtTimes = const [];

  static IsarSessionModel fromDomain(Session s) {
    return IsarSessionModel()
      ..uuid = s.id
      ..sessionType = s.sessionType
      ..contextId = s.contextId
      ..status = s.status
      ..startTime = s.startTime
      ..localDate = s.localDate
      ..endTime = s.endTime
      ..effectiveDurationSeconds = s.effectiveDuration?.inSeconds
      ..focusScore = s.focusScore
      ..energyScore = s.energyScore
      ..difficultyScore = s.difficultyScore
      ..reflectionNote = s.reflectionNote
      ..reflectionSkipped = s.reflectionSkipped
      ..createdAt = s.createdAt
      ..updatedAt = s.updatedAt
      ..deletedAt = s.deletedAt
      ..isArchived = s.isArchived
      ..isDeleted = s.isDeleted
      ..version = s.version
      ..deviceId = s.deviceId
      ..syncState = s.syncState
      ..pausedAtTimes = s.pauseIntervals.map((p) => p.pausedAt).toList()
      ..resumedAtTimes = s.pauseIntervals.map((p) => p.resumedAt).toList();
  }

  Session toDomain() {
    final intervals = <PauseInterval>[
      for (var i = 0; i < pausedAtTimes.length; i++)
        PauseInterval(
          pausedAt: pausedAtTimes[i],
          resumedAt: i < resumedAtTimes.length ? resumedAtTimes[i] : null,
        ),
    ];
    return Session(
      id: uuid,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sessionType: sessionType,
      contextId: contextId,
      status: status,
      startTime: startTime,
      localDate: localDate,
      pauseIntervals: intervals,
      endTime: endTime,
      effectiveDuration:
          effectiveDurationSeconds == null ? null : Duration(seconds: effectiveDurationSeconds!),
      focusScore: focusScore,
      energyScore: energyScore,
      difficultyScore: difficultyScore,
      reflectionNote: reflectionNote,
      reflectionSkipped: reflectionSkipped,
      deletedAt: deletedAt,
      isArchived: isArchived,
      isDeleted: isDeleted,
      version: version,
      deviceId: deviceId,
      syncState: syncState,
    );
  }
}

/// Isar-backed implementation of [SessionRepository]. Swaps in behind the
/// exact same interface `InMemorySessionRepository` implements — no
/// caller anywhere in the app needs to change (CLAUDE.md §6).
class IsarSessionRepository implements SessionRepository {
  IsarSessionRepository(this._isar);

  final Isar _isar;

  @override
  Future<Session?> getActiveSession() async {
    final model = await _isar.isarSessionModels
        .filter()
        .statusEqualTo(SessionStatus.running)
        .or()
        .statusEqualTo(SessionStatus.paused)
        .findFirst();
    return model?.toDomain();
  }

  @override
  Future<Session?> getById(String id) async {
    final model = await _isar.isarSessionModels.filter().uuidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<List<Session>> getByType(SessionType type, {String? localDate}) async {
    var query = _isar.isarSessionModels.filter().sessionTypeEqualTo(type);
    final models = localDate == null
        ? await query.findAll()
        : await query.localDateEqualTo(localDate).findAll();
    return models.map((m) => m.toDomain()).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<void> save(Session session) async {
    await _isar.writeTxn(() async {
      await _isar.isarSessionModels.put(IsarSessionModel.fromDomain(session));
    });
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.isarSessionModels.filter().uuidEqualTo(id).findFirst();
      if (model != null) {
        await _isar.isarSessionModels.delete(model.isarId);
      }
    });
  }
}
