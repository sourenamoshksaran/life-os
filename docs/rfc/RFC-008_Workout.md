# RFC-008

Module: Workout

Document ID: RFC-WORKOUT-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Health Modules

Depends on: RFC-005 (Core Session Engine)

---

# 1. Purpose

Defines the Workout module's data model, screen behavior, and its integration with the Core Session Engine as `sessionType=Workout`.

# 2. User Stories

- As a user, I plan a workout (exercises, target sets/reps) ahead of time or start a freeform one.
- As a user, I start a Workout Session and log sets as I go, with rest timers.
- As a user, I see my workout history and volume trends.
- As a user, I finish and reflect (pain level, energy before/after) so it feeds Life Score.

# 3. Data Model

`Workout` (plan/template): id, title, type (`Strength/Cardio/Mobility/Custom`), exerciseIds (ordered list), estimatedMinutes, notes + Global Fields.

`Exercise`: id, name, muscleGroup, equipment, defaultSets, defaultReps, icon + Global Fields.

`WorkoutSet` (embedded context on a `Session` where `sessionType=Workout`, per RFC-005 §3): sessionId, workoutId, exerciseId, setNumber, repetitions, weight, rest, RPE, painLevel, energyBefore, energyAfter, notes.

# 4. State Machine

Workout Session follows the generic Core Session Engine lifecycle exactly (RFC-005 §4): `Running → Paused → Running → ... → Finished → Reflected` or `→ Cancelled`. No separate Workout-specific state machine exists — set logging happens while the parent Session is `Running`.

# 5. Validation Rules

- A Workout Session requires at least one logged `WorkoutSet` before it can move to `Finished`; otherwise the user is prompted to Cancel instead.
- `weight` and `repetitions` must be ≥ 0. `RPE` and `painLevel` are 1–10.

# 6. Acceptance Criteria

✓ Starting a Workout enforces the single-active-session rule (RFC-005 §6).
✓ Reflection appends Workout-specific fields (Pain Level) to the generic reflection flow (RFC-005 §8).
✓ Workout history screen lists past Sessions filtered by `sessionType=Workout`, with volume/trend charts sourced from `WorkoutSet` data joined via `sessionId`.

# 7. Error Handling & Edge Cases

- App closed mid-set: in-progress `WorkoutSet` entries are saved on every field change (not only on "next"), so no data loss on crash.
- Editing a completed Session's sets after Reflection: allowed within 24h with an "edited" flag stored on the Session, to correct logging mistakes without falsifying history.
- Zero-exercise Workout plan: blocked at creation with inline validation.

# 8. Performance Requirements

Set logging writes must complete in < 100ms (matches DB Query target in `02_Software_Requirements.md` §9) so the rest timer UI never stutters.

# 9. Accessibility Requirements

Set/rep steppers support screen-reader increment/decrement announcements. Rest timer has both visual and haptic completion signal.

# 10. Testing Requirements

Unit tests for volume/1RM calculation helpers. Widget tests for the set-logging row. Integration test: full Workout Session start → log 3 sets → finish → reflect → verify `Result` recomputation.

# 11. Future Expansion

Superset/circuit grouping; workout plan sharing (deferred — no network in v1).

# 12. Golden Rule

Workout is just a Session with sets attached — it never reinvents timing.

---

End of Document
