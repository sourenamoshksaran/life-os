# System Architecture

Document ID: ARCH-001

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md — see FINAL_SPECIFICATION_REPORT.md for full changelog)

Status: Approved

---

# 1. Architecture Philosophy

LifeOS shall follow a Modular Clean Architecture.

The architecture must prioritize:

- Scalability
- Maintainability
- Testability
- Performance
- Offline-first design
- Feature isolation
- Code readability

No module may directly depend on another feature module.

Communication between modules must occur through Core interfaces.

---

# 2. High Level Architecture

Application

↓

Presentation Layer

↓

Application Layer

↓

Domain Layer

↓

Data Layer

↓

Local Database

↓

Device Storage

---

# 3. Layers

## Presentation Layer

Responsibilities:

• UI

• Screens

• Widgets

• Theme

• Animation

• Navigation

• State Rendering

No business logic allowed.

---

## Application Layer

Responsibilities:

Use Cases

Controllers

Session Management

Navigation Logic

Permission Handling

Validation

---

## Domain Layer

Contains:

Entities

Repositories (Interfaces)

Business Rules

Life Score Engine

Analytics Engine

Session Engine

Goal Engine

Decision Engine

No dependency on Flutter.

---

## Data Layer

Contains:

Repositories

Database Models

JSON Models

Local Storage

Caching

Serialization

---

# 4. Core Modules

Core/

Configuration

Theme Engine

Localization

Utilities

Logger

Storage Manager

Date Manager

Permission Manager

Export Manager

Notification Manager

Plugin Manager

Constants

Extensions

Shared Widgets

---

# 5. Feature Modules

Dashboard (includes Command Center as its top section — see RFC-001 §5 Section 03; Command Center is NOT a separate module or screen)

Tasks

Goals / Milestones / Projects (single combined module — see RFC-004)

Learning

Workout

Nutrition

Medicine

Supplements

Journal

Timeline

Results

Analytics

Life Score

Settings

Life Designer

Search

---

# 6. Engine Architecture

**Core Session Engine** (see `rfc/RFC-005_Core_Session_Engine.md`) is the single shared engine for all time-bound activity — Task, Learning, Workout, Reading, Writing, Business, and every future execution module. No module implements its own timer/pause/resume/reflection logic; all modules consume Core Session Engine and attach only module-specific context data.

Other engines, each owning only their module-specific business rules (not timing):

Task Engine (task hierarchy, status transitions, dependencies — delegates all timing to Core Session Engine)

Workout Engine (exercise/set/rep logic — delegates timing to Core Session Engine)

Learning Engine (subject/course/chapter structure — delegates timing to Core Session Engine)

Nutrition Engine

Medicine Engine

Life Score Engine (see `rfc/RFC-003_Life_Score_Engine.md` — the single authoritative score computation)

Analytics Engine (reads from Result + raw entities; never independently writes a competing score)

Notification Engine (see `rfc/RFC-006_Notification_Reminder_Architecture.md`)

Theme Engine

Export Engine (see `rfc/RFC-007_Export_Import_Backup_Encryption.md`)

Search Engine

Module Lifecycle Interface (formerly called "Plugin Engine" — renamed to avoid collision with the user-facing "Plugins" concept in Life Designer; see §17 below and `05_UI_UX_Specification.md`)

Each engine must expose public interfaces. Only Core Session Engine may own timing/pause/resume/reflection state.

---

# 7. Session Flow (Generic — applies to Task, Learning, Workout, and every future module)

User

↓

Start Session (sessionType = Task/Learning/Workout/...)

↓

Core Session Engine (RFC-005) — enforces single-active-session rule

↓

Timer Starts

↓

Database Update (Session entity)

↓

Dashboard Refresh (Mission Widget reads the one active Session)

↓

Finish Session

↓

Reflection (generic, with module-specific extensions)

↓

Session marked Reflected

↓

Analytics Engine reads updated Sessions

↓

Life Score Engine recomputes provisional score (RFC-003)

↓

Dashboard shows live/provisional Life Score until Daily Closing

---

# 8. Life Score Flow (see RFC-003_Life_Score_Engine.md for the full formula)

Task Sessions

Workout Sessions

Sleep Logs

Nutrition Entries

Medicine Logs

Learning Sessions

Consistency (7-day streak)

↓

Life Score Engine (computes 7 weighted components → single 0–100 score)

↓

Result entity (single authoritative record — Daily/Weekly/Monthly/Yearly)

↓

Dashboard (reads Result, or live provisional preview)

↓

Results screen (reads Result)

↓

Analytics screen (reads Result + raw entities for trend charts; never writes a competing score)

---

# 9. Database Flow

UI

↓

Repository

↓

Data Source

↓

Isar Database

↓

Entity Mapping

↓

UI Refresh

---

# 10. Folder Structure (Revised — resolves core/services ambiguity and missing engines folder)

lib/

core/

&nbsp;&nbsp;engines/ — all shared engines live here: session_engine, life_score_engine, analytics_engine, notification_engine, export_engine, search_engine, theme_engine. This is the ONLY location for cross-cutting engine logic; feature `domain/` layers must not reimplement engine behavior.

&nbsp;&nbsp;services/ — device/platform-facing services only (storage manager, permission manager, date manager, logger). If a responsibility involves business logic or cross-module computation, it belongs in `core/engines/`, not `core/services/`.

&nbsp;&nbsp;config/, localization/, constants/, extensions/

features/ — one folder per feature module (§11)

shared/ — shared widgets/components used by 2+ features (Design System components live here, see `08_Component_Library.md` Golden Rule)

theme/ — theme definitions + `tokens/` (design tokens as code: colors, spacing, typography, radii — matches `07_Design_System.md`)

generated/

main.dart

Note: The former root-level `models/` and top-level `services/` (peer to `core/`) are removed as ambiguous. Cross-cutting models live in `core/models/`; feature-specific models live inside each feature's own `data/models/` (see §11).

---

# 11. Feature Structure

feature/

presentation/ (screens/, widgets/)

domain/ (entities, repository interfaces, feature-specific business rules — NOT engine logic, NOT timing/session logic)

data/ (repositories, models/, data sources)

controllers/ (Riverpod providers/notifiers)

Feature modules that involve time-bound activity (Tasks, Learning, Workout, etc.) do not implement their own session/timer code in `domain/` — they consume `core/engines/session_engine` and define only their `sessionType` context payload.

---

# 12. State Management

Riverpod

Rules:

One Provider per responsibility.

No business logic inside Widgets.

No global mutable state.

---

# 13. Dependency Injection

Every service must be injectable.

Singleton only when necessary.

Repositories accessed through interfaces.

---

# 14. Navigation

GoRouter

Bottom Navigation:

Dashboard

Tasks

Timeline

Results

Life Designer

Deep Linking supported.

---

# 15. Local Database

Primary:

Isar

Settings:

Hive

Temporary:

Memory Cache

---

# 16. JSON Export

Every module exports independently.

Master Export merges all modules.

Import validates schema version. See `rfc/RFC-007_Export_Import_Backup_Encryption.md` for the full pipeline (version/schema/integrity/reference checks, conflict resolution).

---

# 17. Module Lifecycle Interface (renamed from "Plugin System" — resolves Important Improvement 2.2)

This is an **internal architecture pattern**, not a user-facing feature. It has no relation to the "Plugins" section referenced in `05_UI_UX_Specification.md`'s Life Designer screen, which is deferred/unscoped (see that document's amendment note).

Every feature module implements:

Initialize()

Load()

Save()

Export()

Import()

Dispose()

Modules must never directly communicate with each other. Core handles communication via defined interfaces (§1 rule: "No module may directly depend on another feature module").

---

# 18. Error Handling

Every exception shall be:

Logged

Displayed gracefully

Recoverable when possible

Never crash the application.

---

# 19. Performance Rules

No blocking UI thread.

Heavy calculations run in isolates.

Lazy loading where possible.

Image caching.

Widget reuse.

Minimal rebuilds.

---

# 20. Security Rules

No internet required.

No analytics SDK.

No tracking.

No ads.

Local encryption optional.

Database access restricted through repositories.

---

# 21. Offline Rules

Every feature must work offline.

Synchronization layer is optional and disabled in v1.

---

# 22. Future Expansion

Architecture must support:

Desktop

Tablet

Web Dashboard

AI Coach

Cloud Sync

Wearables

Finance

Business CRM

Knowledge Base

without architectural redesign.

---

# 22A. Platform Baseline (new — resolves missing spec from PROJECT_AUDIT.md)

Flutter: latest stable channel at project start, pinned in `pubspec.yaml`.

Dart: SDK version matching the pinned Flutter release.

Minimum Android: API 26 (Android 8.0) — required for reliable notification channels.

Minimum iOS: iOS 15.

Isar: latest stable release compatible with the pinned Flutter/Dart version; version pinned explicitly, never left to "latest" in CI to avoid silent schema-compat breaks.

---

# 22B. Testing Strategy (new — resolves missing spec from PROJECT_AUDIT.md)

Unit tests: required for every Engine (Core Session Engine, Life Score Engine, Analytics Engine) and every Repository. Target 80%+ coverage on `core/engines/`.

Widget tests: required for every component in `08_Component_Library.md` Foundation, Button, and Input categories.

Golden tests: required for GlassCard, LifeScoreRing, and MissionWidget (visual-critical, luxury-brand components where regressions are easy to miss).

Integration tests: required for the four Golden Flows in `06_User_Flows.md` (Task Session Flow, Daily Closing Flow, Export Flow, Import Flow).

No feature is "Done" (see `CLAUDE.md` Definition of Done) without its corresponding test tier.

---

# 23. Golden Rules

Everything is modular.

Everything is replaceable.

Everything is testable.

Everything is documented.

Everything is offline-first.

Everything is local-first.

Everything is extensible.

Everything is beautiful by default.

---

End of Document