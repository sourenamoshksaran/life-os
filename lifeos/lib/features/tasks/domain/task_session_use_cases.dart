import '../../../core/engines/session_engine/session.dart';
import '../../../core/engines/session_engine/session_engine.dart';
import 'task.dart';
import 'task_repository.dart';

/// Enforces the rule in docs/04_Database_Schema.md "Task Status":
/// a Task's Running/Paused status mirrors the state of its linked
/// Session — Tasks never manage their own timing state independently
/// of the Core Session Engine (CLAUDE.md §15).
class StartTaskSessionUseCase {
  StartTaskSessionUseCase(this._sessionEngine, this._taskRepository);

  final SessionEngine _sessionEngine;
  final TaskRepository _taskRepository;

  Future<Session> call(Task task) async {
    final session = await _sessionEngine.start(
      sessionType: SessionType.task,
      contextId: task.id,
    );
    await _taskRepository.save(task.copyWith(status: TaskStatus.running));
    return session;
  }
}

class FinishTaskSessionUseCase {
  FinishTaskSessionUseCase(this._sessionEngine, this._taskRepository);

  final SessionEngine _sessionEngine;
  final TaskRepository _taskRepository;

  Future<Session> call({
    required String sessionId,
    required Task task,
    required int focusScore,
    required int energyScore,
    required int difficultyScore,
    String? note,
  }) async {
    await _sessionEngine.finish(sessionId);
    final reflected = await _sessionEngine.reflect(
      sessionId,
      focusScore: focusScore,
      energyScore: energyScore,
      difficultyScore: difficultyScore,
      note: note,
    );
    await _taskRepository.save(
      task.copyWith(status: TaskStatus.completed, completedAt: DateTime.now()),
    );
    return reflected;
  }
}
