# RFC-005

Module: Core Session Engine

Document ID: RFC-SESSION-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Critical (Foundational — all execution modules depend on this)

Owner: Core System

Supersedes: Ambiguous per-module session handling in RFC-002 §11 and 03_System_Architecture.md §6.

---

# 1. Purpose

LifeOS previously treated Task Session, Workout Session, and Learning Session as independent, per-module concepts, each with its own engine. This created an unresolved question: can a Task session and a Workout session run at the same time? The Dashboard's Mission Widget assumes exactly one "current" session exists — but nothing enforced that.

This RFC establishes the **Core Session Engine** as the single, shared execution primitive for all time-bound activity in LifeOS, resolving Critical Issue 1.4 from PROJECT_AUDIT.md.

---

# 2. Golden Rule

> **There is exactly one Session concept in LifeOS. Every module that involves "doing something for a period of time" uses it.**

This includes, today and in the future:

Task Execution

Learning

Workout

Reading

Writing

Business Work

Any future module (Finance work, CRM work, Meetings, etc.)

Modules do not implement their own session logic. They implement a **Session Context** — a small piece of module-specific data attached to a generic Session.

---

# 3. Core Concept

## Session Entity (Generic)

Fields:

id (UUID v4)

sessionType (enum — see §5)

contextId (ID of the module-specific object being worked on, e.g. taskId, courseId, workoutId — nullable for freeform sessions)

status (enum — see §4)

startTime

pauseIntervals (list of {pausedAt, resumedAt})

endTime

effectiveDuration (computed: total time minus paused time)

focusScore (1–10)

energyScore (1–10)

difficultyScore (1–10)

reflectionNote

localDate (see §7 — the correlation key)

createdAt / updatedAt / deletedAt / isDeleted / isArchived / version / deviceId / syncState

The generic Session entity owns **all timing, pause/resume, and reflection logic**, exactly once, in one place.

## Session Context (Module-Specific)

Each module attaches a small typed payload to a Session via `sessionType` + `contextId`:

- `Task` → contextId = Task.id
- `Learning` → contextId = LearningTopic.id (subject/course/chapter/lesson reference)
- `Workout` → contextId = Workout.id
- `Reading` → contextId = Book/Article reference (future module)
- `Writing` → contextId = Writing Project reference (future module)
- `Business` → contextId = Business Task reference (future module)
- `Freeform` → contextId = null (a session with no linked entity, e.g. ad-hoc deep work)

This means adding a new module (e.g. "Reading") never requires new session/timer/pause/reflection code — only a new `sessionType` value and a small context payload.

---

# 4. Session Status Lifecycle

Idle (no session) → Running → Paused → Running → ... → Finished → Reflected

or

Running → Cancelled

States: `Running, Paused, Finished, Cancelled, Reflected`

`Reflected` is the terminal success state — a session is not considered complete for Analytics/Life Score purposes until reflection is saved. A `Finished` session with no reflection yet is shown to the user as "needs reflection" and excluded from Life Score computation until it becomes `Reflected` (or the user explicitly skips reflection, which is logged as `reflectionSkipped: true`).

---

# 5. Session Types

`sessionType` enum: `Task, Learning, Workout, Reading, Writing, Business, Research, Journal, Meditation, Freeform`

New modules add new enum values here. This is the **only** place a new module needs to touch to participate in the Session system. (Locked list per FINAL_BUILD_AUTHORIZATION: Tasks, Workout, Learning, Reading, Writing, Business, Research, Journal, Meditation, and every future module all share this one engine.)

---

# 6. Concurrency Rule (Resolves Critical Issue 1.4)

> **Only one Session may be in `Running` or `Paused` state at any time, regardless of `sessionType`.**

Rules:

- Starting a new session while another is `Running` or `Paused` triggers a **confirmation dialog**: "Finish or pause [current session] to start a new one?" — matching the existing pattern already specified in RFC-002 §11, now generalized to all types.
- The Dashboard Mission Widget always reads **the single active Session record**, regardless of its `sessionType`. This removes the prior ambiguity entirely.
- A user may explicitly enable **"Parallel Mode"** in Settings (off by default) for advanced users who want to track a passive session (e.g., a long Reading session) alongside an active one (e.g., a Task). Parallel Mode is v1.1+ scope, not required for launch, and is called out explicitly so it is never silently assumed to exist.

---

# 7. Correlation Key — `localDate`

Every Session (and every other daily-loggable entity: `NutritionEntry`, `SleepLog`, `WaterLog`, `MedicineLog`, `SupplementLog`, `JournalEntry`) stores a computed **`localDate`** field: a `YYYY-MM-DD` string representing the day the activity belongs to, computed once, centrally, by `core/utils/DateManager`.

**Day boundary rule:** A new local day begins at **00:00 local device time** (not Solar Hijri midnight, not UTC midnight). `DateManager` is the single source of truth for this conversion; no feature module performs its own date-boundary math.

This `localDate` field is the join key the Analytics Engine uses to correlate cross-module data (e.g., "sleep quality on 2026-07-08" vs. "focus scores of Sessions with localDate = 2026-07-08"), resolving Critical Issue 1.7.

---

# 8. Reflection

After every session reaches `Finished`, the same generic Reflection flow is shown regardless of `sessionType`:

Focus (1–10) → Energy (1–10) → Difficulty (1–10) → Notes → Need Review? → Save

Module-specific reflection questions (if any) are appended, not substituted — e.g., Workout sessions additionally ask "Pain Level," Learning sessions additionally ask "Understanding." These are defined per-module in their own RFC, as extensions of this shared flow.

---

# 9. Analytics & Life Score Integration

The Analytics Engine and Life Score Engine (RFC-003) read from the single `Session` collection filtered by `sessionType`, rather than from separate Task/Workout/Learning session tables. This eliminates the need to write separate aggregation logic per module and guarantees consistent time-tracking math across the whole app.

---

# 10. Migration Note for Existing Documents

- `04_Database_Schema.md`'s prior `TaskSession`, `WorkoutSession`, and `LearningSession` entities are replaced by the generic `Session` entity plus lightweight per-module context objects. See updated `04_Database_Schema.md`.
- `03_System_Architecture.md` §6 "Engine Architecture" no longer lists `Task Engine / Workout Engine / Learning Engine` as independently owning session logic. They now depend on **Core Session Engine** for all timing/pause/reflection behavior and own only their module-specific business rules (e.g., Workout Engine still owns exercise/set/rep logic, but not timers).

---

# 11. Acceptance Criteria

✓ Exactly one active Session (Running/Paused) exists at any time, enforced by the engine, not by UI convention.

✓ Adding a new module (e.g., Reading) requires zero changes to timer, pause, resume, or reflection code — only a new `sessionType` and context mapping.

✓ Every Session has a computed `localDate` usable for cross-module correlation.

✓ Dashboard Mission Widget always resolves to a single, unambiguous "current session," regardless of its type.

---

# 12. Golden Rule

One Session system. Every module borrows it. No module reinvents it.

---

End of Document
