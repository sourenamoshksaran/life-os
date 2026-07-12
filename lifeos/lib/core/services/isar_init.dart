import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../engines/session_engine/isar_session_model.dart';
import '../../features/tasks/data/isar_task_model.dart';

/// Opens the single app-wide Isar instance. NOT currently wired into
/// `main.dart`'s active provider graph — the app's default DI (see
/// `task_controller.dart`, `session_engine`'s providers) still points at
/// the in-memory repositories, because the schemas this file references
/// (`IsarSessionModelSchema`, `IsarTaskModelSchema`) only exist after
/// `flutter pub run build_runner build` generates the `.g.dart` part
/// files — which this sandbox cannot run (no pub.dev network access).
///
/// To switch the app over to real persistence in a real Flutter
/// environment:
///   1. Run build_runner (generates isar_session_model.g.dart,
///      isar_task_model.g.dart).
///   2. Call `openIsar()` once at app startup (in `main.dart`, after
///      `Hive.initFlutter()`) and store the returned `Isar` instance in a
///      Riverpod `Provider<Isar>`.
///   3. Change `sessionRepositoryProvider` and `taskRepositoryProvider`
///      (in `task_controller.dart`) to construct `IsarSessionRepository`/
///      `IsarTaskRepository` instead of the `InMemory*` classes — every
///      call site is unaffected, since both implement the same
///      repository interfaces (CLAUDE.md §6).
///
/// Note: `path_provider` (for `getApplicationDocumentsDirectory()`) is
/// not currently in pubspec.yaml — add it alongside this wiring, since
/// it's needed to resolve Isar's on-device storage directory.
Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [IsarSessionModelSchema, IsarTaskModelSchema],
    directory: dir.path,
    name: 'lifeos',
  );
}
