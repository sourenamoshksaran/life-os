# LifeOS — MVP Foundation

This is the architectural foundation for LifeOS, built exactly to the rules in
`docs/CLAUDE.md` and `docs/MASTER_PROMPT.md`. It is **not** the full MVP —
see `IMPLEMENTATION_REPORT.md` at the repository root for exactly what's
built, what's stubbed, and what remains.

## What's implemented here

- **Core Session Engine** (`lib/core/engines/session_engine/`) — the single
  shared session system for every time-bound module, per
  `docs/rfc/RFC-005_Core_Session_Engine.md`. Fully implemented with the
  single-active-session concurrency rule enforced at the engine layer,
  pause/resume duration accounting, and the generic reflection flow.
- **Task module** (`lib/features/tasks/`) — domain entity with the canonical
  8-state status enum, repository interface + in-memory implementation,
  Riverpod controllers, and a working screen that starts/finishes a Task's
  Session exclusively through the Core Session Engine.
- **`BaseEntity`** (`lib/core/models/base_entity.dart`) — the Global Fields
  mixin every entity uses.
- **`DateManager`** (`lib/core/services/date_manager.dart`) — the single
  source of truth for the `localDate` correlation key.
- **Design tokens + theme** (`lib/theme/`) — dark-first palette, 8pt spacing.
- **Unit tests** for the Session Engine's concurrency rule and lifecycle
  (`test/core/engines/session_engine/session_engine_test.dart`).

## What's stubbed, on purpose

Repositories are **in-memory**, not Isar-backed. Every repository is written
against an interface (`SessionRepository`, `TaskRepository`), so swapping in
a real `IsarSessionRepository`/`IsarTaskRepository` requires zero changes
anywhere else in the app — that's the point of the repository pattern
mandated in `CLAUDE.md` §6. Generating the actual Isar collections requires
running `flutter pub get` and `flutter pub run build_runner build` in a real
Flutter environment with network access to pub.dev, which this sandbox does
not have.

## Running this project

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

This has not been run or compiled in the sandbox that generated it — see
`IMPLEMENTATION_REPORT.md` for why, and what verification steps to run
first in a real environment.
