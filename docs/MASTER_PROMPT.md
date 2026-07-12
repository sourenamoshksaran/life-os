# MASTER_PROMPT.md — LifeOS AI Build Specification

Version 2.0 — Complete rewrite per PROJECT_AUDIT.md Critical Issue 1.1. This is the document handed to an AI coding agent ("Cloud Code") to build LifeOS. Read this document, then `CLAUDE.md`, then the documents it references, in order, before writing any code.

---

## 1. Project Overview

LifeOS (Project NOVA) is an offline-first, Persian/English bilingual, Flutter-based personal life operating system. It centralizes Tasks, Goals, Learning, Workout, Nutrition, Medicine, Journal, and Analytics into one calm, luxury-grade, 100% local application. Full vision: `docs/01_Project_Overview.md`.

---

## 2. Vision

*"Your Life. Engineered."* The product must feel like a personal command center — precise, calm, premium — never a to-do list or habit tracker. See `docs/01_Project_Overview.md` for full philosophy, design inspirations, and Non-Goals (never a social network, messenger, game, or Notion/Obsidian clone).

---

## 3. Product Philosophy

Every recorded piece of data must serve analysis, decision-making, or progress display. The system's flagship idea is **"Everything is Connected"** — daily data across modules is correlated via a shared `localDate` key so the app can surface insights like "sleep quality dropped, and so did focus" without any AI or network dependency. See `docs/01_Project_Overview.md` and `docs/04A_Data_Modeling_Strategy.md`.

---

## 4. Architecture Summary

Modular Clean Architecture, 4 layers (Presentation → Application → Domain → Data), Riverpod state management, GoRouter navigation, Isar as primary DB, Hive for Settings. No feature module depends on another directly — all cross-module communication goes through Core.

**The single most important architectural decision in this project:** all time-bound activity (Task execution, Learning, Workout, Reading, Writing, Business, and any future module) shares ONE **Core Session Engine** (`docs/rfc/RFC-005_Core_Session_Engine.md`). Do not build a second session/timer system for any module, ever. Full detail: `docs/03_System_Architecture.md`.

---

## 5. Folder Structure

See `CLAUDE.md` §9 for the exact, binding folder tree. Do not deviate.

---

## 6. Technology Stack (Locked — do not substitute)

- Flutter (latest stable, pinned) / Dart
- Isar (primary DB) — minimum versions per `docs/03_System_Architecture.md` §22A
- Hive (lightweight Settings/cache only — not primary storage)
- Riverpod (state management)
- GoRouter (navigation)
- json_serializable (entity serialization, paired with Isar/Hive models)
- flutter_local_notifications (Medicine/Supplement/Water/Task reminders — implements RFC-006)
- FL Chart (Results/Analytics charts)
- flutter_animate (motion/transitions per `07_Design_System.md` Motion section)
- Phosphor Icons (`phosphor_flutter`)
- ARB + `gen-l10n` (localization)
- Minimum Android API 26, minimum iOS 15

---

## 7. DDD

Domain layer contains entities, repository interfaces, business rules, and the Core Engines' domain contracts. No Flutter dependency in Domain. See `CLAUDE.md` §6.

---

## 8. Clean Architecture

Every entity uses the shared `BaseEntity` mixin (Global Fields). Use Cases are single-purpose. Repositories are interface-first. See `CLAUDE.md` §7.

---

## 9. Database Summary

Isar-based, entity-centric, UUID v4 IDs, Global Fields on every entity via `BaseEntity`, soft delete by default. Canonical schema: `docs/04_Database_Schema.md` v2.0. Key resolved decisions since v1.0:

- **Task Status** is the 8-state lifecycle (`Inbox, Planned, Ready, Running, Paused, Completed, Cancelled, Archived`) — the old 5-state version is deprecated.
- **Session** is one generic entity shared by all modules (not `TaskSession`/`WorkoutSession`/`LearningSession` separately).
- **`Result`** is the single source of truth for Life Score and all periodic summaries. `LifeScore` as a separate entity is removed; `AnalyticsSnapshot` is a non-authoritative, regenerable cache only.
- **`DailyGoals`** stores user target values (water, calories, sleep, workout, learning) that power every progress ring.
- **`localDate`** is the correlation key present on every daily-loggable entity.

---

## 10. Design System Summary

Dark-first, burgundy/near-black luxury palette, 8pt grid, Phosphor Icons, SF Pro / Vazirmatn typography, WCAG AA contrast (validated automatically in CI). Full spec: `docs/07_Design_System.md`.

---

## 11. UI/UX Summary

Calm, minimal, premium. 5-tab Bottom Navigation (Dashboard, Tasks, Timeline, Results, Life Designer). Command Center is Dashboard Section 03, not a separate screen. Full spec: `docs/05_UI_UX_Specification.md`.

---

## 12. Navigation Summary

GoRouter, 5 persistent bottom tabs, deep linking supported. Search and Command Center are accessed within Dashboard/header, not as separate tabs. Full spec: `docs/03_System_Architecture.md` §14.

---

## 13. Component Library Summary

Reusable, stateless-where-possible, Dark Mode + RTL support mandatory on every component. Session-related components (`SessionCard`, `MissionWidget`, `FocusTimer`) are generic and shared across Task/Workout/Learning/future modules. Full spec: `docs/08_Component_Library.md`.

---

## 14. Session Engine Summary

One Core Session Engine for the entire app. Single-active-session rule enforced at the engine layer. New modules add a `sessionType` value and context payload — never a new timer. Full spec: `docs/rfc/RFC-005_Core_Session_Engine.md`.

---

## 15. Analytics Summary

Analytics Engine reads `Result` + raw entities for trend charts; never writes a competing score. Insights require ≥7 days of data before surfacing correlation claims. Full spec: `docs/rfc/RFC-001_Dashboard.md` §5 Section 10 and `CLAUDE.md` §16.

---

## 16. Life Score Summary

0–100 score, 7 weighted components (Task 25%, Session Quality 15%, Workout 15%, Learning 15%, Sleep 10%, Nutrition 10%, Consistency 10%). Missing data scores 0 for that component unless the module is disabled in Settings. Always explainable — tapping the score shows its 7 components. Full spec: `docs/rfc/RFC-003_Life_Score_Engine.md`.

---

## 17. RFC Summary

**All RFCs required for MVP are now approved and build-ready:**

- RFC-001 Dashboard (v1.1)
- RFC-002 Task Management (v1.1)
- RFC-003 Life Score Engine
- RFC-004 Goals, Milestones & Projects
- RFC-005 Core Session Engine (shared by Task, Workout, Learning, Reading, Writing, Business, Research, Journal, Meditation, and future modules)
- RFC-006 Notification & Reminder Architecture
- RFC-007 Export, Import, Backup & Encryption
- RFC-008 Workout
- RFC-009 Learning
- RFC-010 Nutrition
- RFC-011 Medicine & Supplements
- RFC-012 Results
- RFC-013 Analytics
- RFC-014 Settings

**Still pending (post-MVP, not required to ship v1):** Journal & Decision Log detail, Search implementation detail, Life Designer/Custom Modules extensibility.

---

## 18. Coding Standards

See `CLAUDE.md` §4–8 in full. Highlights: strict null-safety, no hardcoded values, Riverpod-only state, `Result<T, Failure>` error handling at boundaries, isolate-based heavy computation.

---

## 19. Performance Targets

Startup < 1s, Page Transition < 250ms, Search < 200ms, DB Query < 100ms, 60 FPS scrolling. Full targets: `docs/02_Software_Requirements.md` §9.

---

## 20. Security

No data leaves the device. No telemetry, no analytics SDK, no ads, no mandatory account, no network calls anywhere in v1. Optional at-rest DB encryption and optional encrypted backup export are two independent mechanisms — see `docs/rfc/RFC-007_Export_Import_Backup_Encryption.md`.

---

## 21. Offline First

100% offline functionality is a hard requirement, not a mode. See `CLAUDE.md` §13.

---

## 22. Testing

Unit tests on every Engine/Repository, widget tests on core components, golden tests on `GlassCard`/`LifeScoreRing`/`MissionWidget`, integration tests on the four Golden Flows (Task Session, Daily Closing, Export, Import). No feature ships without its test tier. Full spec: `docs/03_System_Architecture.md` §22B.

---

## 23. Roadmap

**Phase 1 (this build):** Core Session Engine, Task Management + Goals/Milestones/Projects, Dashboard, Life Score Engine, Notification Architecture, Export/Import/Backup, Onboarding.

**Phase 2:** Workout, Learning, Nutrition, Medicine/Supplement detail RFCs and full UX.

**Phase 3:** Journal, Settings/Life Designer detail, Search implementation detail.

**Future (explicitly out of scope for v1):** Desktop, Web, AI Coach, Wearables, Cloud Sync, Finance, Business CRM, Knowledge Base, user-facing Plugins/Custom Modules.

---

## 24. MVP Scope

**In scope for v1:** Dashboard (incl. Command Center), Tasks, Goals/Milestones/Projects, Core Session Engine (with Task/Workout/Learning integration), Life Score Engine, Results (Daily/Weekly/Monthly/Yearly), basic Analytics, Notifications for Medicine/Supplement/Water/Task deadlines, JSON Export/Import with optional encryption, Settings incl. Daily Goals, Onboarding.

**Explicitly out of scope for v1:** Voice Input, Emoji Picker, Parallel Session Mode, user-facing Plugins/extensibility, Cloud Sync, any network-dependent feature.

---

## 25. Golden Rules

See `CLAUDE.md` §23. Summarized: modular, replaceable, testable, documented, offline-first, local-first, extensible, beautiful by default, and connected through `localDate` + Core Session Engine rather than by convention.

---

## 26. Final Instructions

1. Read `CLAUDE.md` in full before writing any code.
2. Read the RFC for any module before implementing it. If no RFC exists yet for a module beyond what's listed as build-ready in §17, implement only its data model + Session integration and flag the UX gap rather than inventing behavior.
3. Never implement a second session/timer system, a second Life Score writer, or the deprecated 5-state Task Status enum.
4. Any spec ambiguity discovered during implementation must be resolved by updating the relevant document in the same PR — not by silent developer judgment call.
5. This document and `CLAUDE.md` are the contract. When any other document appears to conflict with them, `CLAUDE.md` and this `MASTER_PROMPT.md` win, and the conflicting document must be corrected.

---

End of Document
