import 'session.dart';
import 'session_repository.dart';

/// In-memory implementation used until Isar codegen (`build_runner`) is run
/// in a real Flutter environment. The interface is what the rest of the app
/// depends on, so swapping this for an Isar-backed `IsarSessionRepository`
/// later requires zero changes anywhere else (CLAUDE.md §6 repository rule).
///
/// TODO(implementation): replace with IsarSessionRepository once `isar`
/// collections are generated via `flutter pub run build_runner build`.
class InMemorySessionRepository implements SessionRepository {
  final Map<String, Session> _store = {};

  @override
  Future<Session?> getActiveSession() async {
    for (final session in _store.values) {
      if (session.isActive) return session;
    }
    return null;
  }

  @override
  Future<Session?> getById(String id) async => _store[id];

  @override
  Future<List<Session>> getByType(SessionType type, {String? localDate}) async {
    return _store.values
        .where((s) =>
            s.sessionType == type &&
            (localDate == null || s.localDate == localDate))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<void> save(Session session) async {
    _store[session.id] = session;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }
}
