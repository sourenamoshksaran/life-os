# CLAUDE.md — LifeOS Implementation Rules

Version 2.0 — Complete rewrite per PROJECT_AUDIT.md Critical Issue 1.1. This document is binding for any AI coding agent (or human developer) implementing LifeOS. It contains actual rules, not headings.

---

## 1. Project Identity

LifeOS (codename Project NOVA) is an offline-first personal life operating system built in Flutter. Full product context: `docs/01_Project_Overview.md`.

---

## 2. Mission

Build a fast, calm, luxury-grade, 100% offline personal command center. Every implementation decision is checked against `01_Project_Overview.md`'s Core Philosophy: *"Every piece of data must serve analysis, decision-making, or progress display — or it should not be recorded."*

---

## 3. Architecture Rules

- Follow Modular Clean Architecture exactly as defined in `docs/03_System_Architecture.md`.
- Layer dependency direction is one-way: Presentation → Application → Domain → Data. Domain never imports Flutter. Presentation never contains business logic.
- No feature module may import another feature module directly. Cross-module communication happens only through `core/` interfaces.
- All timing/pause/resume/reflection logic for ANY time-bound activity (Task, Learning, Workout, Reading, Writing, Business, or any future module) MUST use the **Core Session Engine** (`core/engines/session_engine`, spec: `docs/rfc/RFC-005_Core_Session_Engine.md`). Implementing a second, module-specific timer/session system is a Forbidden Pattern (see §16).
- Life Score is computed ONLY by the Life Score Engine (`docs/rfc/RFC-003_Life_Score_Engine.md`) and written ONLY to the `Result` entity. No other engine, repository, or widget may write a Life Score value.

---

## 4. Coding Rules

- Dart null-safety strict mode. No `dynamic` outside of JSON deserialization boundaries.
- Every public function has a doc comment (`///`) if it is part of an Engine's or Repository's public interface.
- No magic numbers. Spacing, radius, duration, and color values come from `theme/tokens/` (see `docs/07_Design_System.md`), never hardcoded inline.
- No hardcoded user-facing strings. All copy goes through ARB localization files (`docs/07_Design_System.md` "Localization Format").
- Prefer composition over inheritance except for the shared `BaseEntity` mixin (Global Fields, §7 below).
- Every function that can fail returns a typed `Result<T, Failure>` (or equivalent), not a thrown exception, at repository/use-case boundaries. Exceptions are only used at the lowest data-source layer and converted to `Failure` before crossing into Domain.

---

## 5. Flutter Rules

- State management: Riverpod exclusively. One provider per responsibility (`docs/03_System_Architecture.md` §12).
- No `setState` for anything beyond purely local, ephemeral widget state (e.g., a text field's focus ring). Anything touching persisted or cross-widget state goes through a Riverpod provider.
- Widgets are `const` wherever possible.
- No business logic inside `build()` methods. `build()` reads provider state and renders; it does not compute.
- Heavy computation (Life Score calculation, Analytics aggregation, JSON export/import validation) runs in an isolate via `compute()`, never on the UI thread.
- Every screen is wrapped in `AppScaffold` (see `docs/08_Component_Library.md`); no screen builds its own raw `Scaffold`.

---

## 6. DDD Rules

- Domain entities are immutable. Every entity supports `copyWith()`, `toJson()`, `fromJson()`, structural equality, and `hashCode` (see `docs/04A_Data_Modeling_Strategy.md` Serialization).
- Repositories are interfaces in `domain/`, implementations in `data/`. Domain never depends on a concrete Isar/Hive type.
- Business rules (e.g., "a Task cannot be Running unless its linked Session is Running") live in Domain-layer use cases, not in the UI and not in the data layer.

---

## 7. Clean Architecture Rules

- Every entity implements the shared `BaseEntity` mixin providing the Global Fields: `id (UUID v4), createdAt, updatedAt, deletedAt, isArchived, isDeleted, version, deviceId, syncState`. No entity re-declares these individually (see `docs/04_Database_Schema.md` Global Fields rule).
- Use Cases are single-purpose classes (`StartSessionUseCase`, `ComputeLifeScoreUseCase`, etc.), not god-classes.
- Dependency Injection: every service/engine/repository is injectable (Riverpod providers act as the DI mechanism). Singletons only for genuinely stateless or app-lifetime-scoped services (Logger, DateManager, StorageManager).

---

## 8. Naming Convention

Follows `docs/04A_Data_Modeling_Strategy.md` exactly:

- Collections/Entities: singular PascalCase (`Task`, `Session`, `Goal` — never `TaskList`, `SessionsCollection`).
- Fields: camelCase (`createdAt`, `lifeScore`, `localDate`).
- Enums: PascalCase (`TaskStatus`, `SessionType`, `WorkoutType`).
- Files: snake_case (`task_repository.dart`, `session_engine.dart`).
- Riverpod providers: `camelCaseNameProvider` (e.g., `activeSessionProvider`).
- Widgets matching `docs/08_Component_Library.md` component names exactly (`TaskCard`, `GlassCard`, `LifeScoreRing`) — no renaming during implementation.

---

## 9. Folder Convention

Follows `docs/03_System_Architecture.md` §10–11 exactly:

```
lib/
  core/
    engines/        # session_engine, life_score_engine, analytics_engine, notification_engine, export_engine, search_engine, theme_engine
    services/        # storage_manager, permission_manager, date_manager, logger — device/platform-facing only
    config/
    localization/
    constants/
    extensions/
    models/          # cross-cutting models only
  features/
    <feature_name>/
      presentation/  # screens/, widgets/
      domain/        # entities, repository interfaces, feature-specific rules (NOT timing logic)
      data/           # repositories, models/, data sources
      controllers/    # Riverpod providers/notifiers
  shared/            # components used by 2+ features
  theme/
    tokens/
  generated/
  main.dart
```

Do not create a root-level `services/` folder separate from `core/services/`. Do not create a root-level `models/` folder for feature-specific models — those live inside each feature's own `data/models/`.

---

## 10. Design Rules

- Every visual decision traces to `docs/07_Design_System.md`. No developer invents a new color, spacing value, radius, or font size outside the documented token set.
- Icon package: Phosphor Icons only (`phosphor_flutter`), Outlined/Regular weight, 2px stroke. Never mix icon packages.
- Dark mode is the primary experience; light mode must maintain identical visual hierarchy.

---

## 11. UI Rules

- Every screen follows Header → Content → Floating Actions (optional) → Bottom Navigation structure (`docs/05_UI_UX_Specification.md`).
- Maximum 6 visible cards on Dashboard at once (`docs/rfc/RFC-001_Dashboard.md` §6).
- Bottom Navigation has exactly 5 tabs: Dashboard, Tasks, Timeline, Results, Life Designer. Command Center and Search are NOT tabs — Command Center is Dashboard Section 03; Search is accessed via header quick search.
- Every list supports the states defined in `docs/08_Component_Library.md` "Component States" (Idle, Loading, Disabled, Selected, Focused, Error, Success, Empty, Offline).
- Skeleton loaders only. Never a full-page spinner (`docs/05_UI_UX_Specification.md` Loading States).

---

## 12. Performance Rules

- No blocking UI thread — heavy calculations run in isolates (`compute()`).
- 60 FPS minimum scrolling target; Page Transition < 250ms; Search < 200ms; Database Query < 100ms (`docs/02_Software_Requirements.md` §9).
- Lazy-load Journal, Results, Analytics, and Attachments (`docs/04A_Data_Modeling_Strategy.md` Lazy Loading).
- Dispose inactive controllers and streams.

---

## 13. Offline First Rules

- Every feature must work with zero network access. No feature may gate its primary function on connectivity.
- No network calls exist anywhere in v1 except none — there are no network calls in v1. If a package pulled in transitively makes network calls (e.g., a crash-reporting SDK), it must be disabled/stripped, per Security Rules.

---

## 14. Database Rules

- Follow `docs/04_Database_Schema.md` v2.0 exactly, including the canonical 8-state Task Status enum (`Inbox, Planned, Ready, Running, Paused, Completed, Cancelled, Archived`) — the previous 5-state version is deprecated and must not be implemented.
- No duplicate IDs. No orphan records without an explicit unlink notice (`docs/rfc/RFC-004_Goals_Milestones_Projects.md` §7).
- Every entity includes `localDate` if it is daily-loggable (Session, NutritionEntry, SleepLog, WaterLog, MedicineLog, SupplementLog, JournalEntry, Task) — computed once via `core/services/date_manager.dart`, never ad hoc.
- Soft delete only by default (`isDeleted`, `deletedAt`); hard delete requires explicit secondary confirmation.
- Migrations never delete data and must be reversible whenever possible (`docs/04A_Data_Modeling_Strategy.md` Migration Rules).

---

## 15. Session Engine Rules

- There is exactly one Session entity type in the schema (`docs/rfc/RFC-005_Core_Session_Engine.md`). Do not create `TaskSession`, `WorkoutSession`, or `LearningSession` as separate top-level entities.
- Enforce the single-active-session rule (only one Session may be `Running` or `Paused` at a time, across ALL `sessionType` values) at the engine layer, not just in the UI.
- Every new module that involves doing something for a period of time (Reading, Writing, Business, or any future module) must integrate via a new `sessionType` enum value and a small context payload — never via a new bespoke timer implementation.

---

## 16. Analytics Rules

- Analytics Engine reads from `Result` + raw entities. It never independently computes or persists a competing Life Score.
- `AnalyticsSnapshot` (if implemented) is a non-authoritative cache only, must be fully regenerable from `Result`, and is excluded from Export.
- Insight generation (`docs/rfc/RFC-001_Dashboard.md` §5 Section 10) requires a minimum of 7 days of data before surfacing a correlation-based insight, to avoid misleading conclusions from small samples.

---

## 17. Life Score Rules

- Formula, weights, and missing-data handling follow `docs/rfc/RFC-003_Life_Score_Engine.md` exactly. Any future change to weights increments `formulaVersion` on new `Result` records; historical records keep their original `formulaVersion`.
- Weekly/Monthly/Yearly Life Score values are always an aggregate of Daily `Result` records — never independently recomputed from raw data.

---

## 18. Testing Rules

- Unit tests required for every Engine and Repository (target 80%+ coverage in `core/engines/`).
- Widget tests required for Foundation, Button, and Input component categories.
- Golden tests required for `GlassCard`, `LifeScoreRing`, `MissionWidget`.
- Integration tests required for: Task Session Flow, Daily Closing Flow, Export Flow, Import Flow.
- See `docs/03_System_Architecture.md` §22B.

---

## 19. Git Rules

- Trunk-based development. Feature branches named `feature/<module>-<short-description>`.
- No direct commits to `main`. Every change lands via PR referencing the relevant RFC or SRS section.
- A PR that changes an entity's schema must update `docs/04_Database_Schema.md` in the same PR.

---

## 20. Commit Rules

- Conventional Commits format: `feat(tasks): add task status transition guard`, `fix(session): prevent concurrent session start`, `docs(rfc): update RFC-003 weighting`.
- Commit body references the governing document (e.g., "Implements RFC-005 §6").

---

## 21. Documentation Rules

- Any deviation from an approved spec document requires updating that document in the same PR — the docs are never allowed to silently drift from the implementation.
- New feature modules require an RFC before implementation begins (see `MASTER_PROMPT.md` RFC Summary for the current backlog).

---

## 22. Definition of Done

A feature is Done only when:

1. It matches its governing RFC/SRS section exactly, or the document was updated to match an approved deviation.
2. It uses Core Session Engine for any time-bound behavior (no bespoke timers).
3. It uses only Design System tokens (no hardcoded colors/spacing/strings).
4. It has its required test tier (§18) passing.
5. It works fully offline.
6. It handles Loading, Empty, Error, and Offline states per `docs/08_Component_Library.md`.
7. It performs within the targets in `docs/02_Software_Requirements.md` §9.

---

## 23. Golden Rules

Everything is modular. Everything is replaceable. Everything is testable. Everything is documented. Everything is offline-first. Everything is local-first. Everything is extensible. Everything is beautiful by default. Everything is connected — through `localDate` correlation and the Core Session Engine, not by convention.

---

## 24. Forbidden Patterns

- ❌ A second timer/session implementation outside Core Session Engine.
- ❌ Writing Life Score anywhere other than the Life Score Engine → `Result`.
- ❌ A feature module importing another feature module's `data/` or `domain/` directly.
- ❌ Hardcoded colors, spacing, radii, durations, or user-facing strings.
- ❌ Network calls of any kind in v1.
- ❌ `setState` for persisted or cross-widget state.
- ❌ Business logic inside `build()`.
- ❌ Hard-deleting a record without explicit secondary confirmation.
- ❌ Implementing the deprecated 5-state Task Status enum.
- ❌ A "Plugins" marketplace or any network-facing extensibility feature (deferred, unscoped — see `docs/05_UI_UX_Specification.md` Life Designer amendment).
- ❌ Skipping a required test tier to ship faster.

---

## 25. Future Expansion Rules

- New modules (Finance, Business CRM, Knowledge Base, AI Coach, Wearables, Cloud Sync) must integrate through existing Core interfaces (Session Engine, Module Lifecycle Interface, Global Fields) without requiring a redesign of Core.
- Cloud Sync, if ever implemented, activates the currently-reserved `deviceId`/`syncState` fields already present in the schema — no new fields needed at that time, only new engine logic.

---

End of Document
