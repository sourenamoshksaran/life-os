import 'session.dart';

/// Repository interface — implemented by the data layer (Isar-backed).
/// Domain/engine code never depends on a concrete Isar type (CLAUDE.md §6).
abstract class SessionRepository {
  Future<Session?> getActiveSession();
  Future<Session?> getById(String id);
  Future<List<Session>> getByType(SessionType type, {String? localDate});
  Future<void> save(Session session);
  Future<void> delete(String id);
}
