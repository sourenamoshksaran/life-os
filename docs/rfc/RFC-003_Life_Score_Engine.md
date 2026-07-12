# RFC-003

Module: Life Score Engine

Document ID: RFC-LIFESCORE-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Critical

Owner: Core System

---

# 1. Purpose

Life Score is LifeOS's headline metric — the single number that answers "how am I doing today?" It appears on the Dashboard, in Results, and in Analytics. This RFC defines the formula, resolving Critical Issue 1.8 (missing calculation) and Critical Issue 1.5 (triplicated aggregate entities) from PROJECT_AUDIT.md.

---

# 2. Single Source of Truth Rule (Resolves Critical Issue 1.5)

> **`Result` is the only entity that stores a computed Life Score for a given day/period. `LifeScore` and `AnalyticsSnapshot` are removed as independent write targets.**

- The **Life Score Engine** computes the score in memory from raw entities (Sessions, SleepLog, NutritionEntry, MedicineLog, WaterLog) and writes the outcome into `Result.lifeScore` and its component sub-scores.
- The **Analytics Engine** reads from `Result` (and raw entities for trend charts) — it does not maintain its own duplicate `lifeScore` field.
- Any screen needing "today's Life Score" reads `Result` for `localDate = today`. If no `Result` exists yet for today (not yet closed), the Dashboard requests a **live preview** computation from the Life Score Engine without persisting it, clearly labeled "Live / Provisional" in the UI.

See §6 for the resulting schema change.

---

# 3. Score Range & Components

Life Score is a value from **0 to 100**, composed of seven weighted sub-scores, each also 0–100:

| Component | Weight | Source |
|---|---|---|
| Task Score | 25% | Completion rate + effective focus time of `Session[sessionType=Task]` for the day |
| Session Quality Score | 15% | Average `focusScore` + `energyScore` across all Sessions (any type) for the day, normalized to 0–100 |
| Workout Score | 15% | Completion of planned workout + average RPE consistency |
| Learning Score | 15% | Learning session time vs. daily target + average `understanding` rating |
| Sleep Score | 10% | Sleep duration vs. target + sleep quality rating |
| Nutrition Score | 10% | Meals logged + macro targets met (if targets configured) + water goal % |
| Consistency Score | 10% | Rolling 7-day streak of days with at least one completed Session |

`lifeScore = round( Σ (component_score × weight) )`

---

# 4. Missing-Data Handling (Resolves the open question in PROJECT_AUDIT.md 2.8)

> **A component with no data for the day scores as 0 for that component, not as excluded.**

Rationale: This matches the product philosophy in `01_Project_Overview.md` ("if it has no use, don't record it" / consistency-driven design) — a day with no workout logged should visibly lower the Workout Score, not be silently ignored, since the whole point of Life Score is honest self-measurement.

**Exception:** if the user has explicitly marked a module as "not tracked" in Settings (e.g., a user who doesn't use the Medicine module at all), that component's weight is redistributed proportionally across the remaining active components rather than counted as 0. This is configured once in Settings → Life Score Components, not decided ad hoc per day.

---

# 5. Computation Timing

- **Daily**: Life Score Engine runs at the **Daily Closing Flow** (`06_User_Flows.md`), producing the canonical `Result` for that `localDate`. It may also run on-demand (live preview) any time the Dashboard is opened, without persisting.
- **Weekly / Monthly / Yearly**: computed as an aggregate (average) of the underlying Daily `Result.lifeScore` values for the period — not recomputed from raw data. This guarantees weekly/monthly numbers are always traceable back to daily numbers.

---

# 6. Schema Change

`LifeScore` entity is **removed**. `AnalyticsSnapshot` is **removed** as an independently-written entity and becomes a **derived/cached read-model** the Analytics screen may materialize for chart performance, always regenerable from `Result` — it is explicitly non-authoritative and may be wiped and rebuilt at any time without data loss.

`Result` entity gains the sub-score fields formerly on `LifeScore`:

id, localDate, period (`Daily/Weekly/Monthly/Yearly`), rangeStart, rangeEnd, lifeScore, taskScore, sessionQualityScore, workoutScore, learningScore, sleepScore, nutritionScore, consistencyScore, completedTasks, totalTasks, deepWorkMinutes, journalCompleted, notes, isProvisional, createdAt, updatedAt

See updated `04_Database_Schema.md` §Result Entity.

---

# 7. Acceptance Criteria

✓ Exactly one entity (`Result`) stores computed Life Score values.

✓ Formula and weights are documented and version-controlled (a future change to weights bumps a `formulaVersion` field on `Result` so historical scores remain interpretable).

✓ Missing data lowers the relevant component score rather than being silently excluded, unless the module is explicitly disabled in Settings.

✓ Weekly/Monthly/Yearly scores are always an aggregate of Daily scores, never independently recomputed from raw data.

---

# 8. Golden Rule

Life Score must always be explainable: a user should be able to tap the score and see exactly which seven numbers produced it, and why each one is what it is.

---

End of Document
