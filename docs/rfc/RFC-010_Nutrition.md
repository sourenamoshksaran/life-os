# RFC-010

Module: Nutrition

Document ID: RFC-NUTRITION-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Health Modules

---

# 1. Purpose

Defines meal/nutrition logging and its relationship to `DailyGoals` targets and the Life Score Nutrition component. Nutrition is a logging module, not a Session-based module — it does not use the Core Session Engine.

# 2. User Stories

- As a user, I log a meal with calories/macros in a few taps.
- As a user, I see daily progress against my calorie/protein/water targets.
- As a user, I log water intake quickly from the Dashboard.

# 3. Data Model

`NutritionEntry`: id, mealType (`Breakfast/Lunch/Dinner/Snack`), calories, protein, carbohydrate, fat, fiber, water, notes, localDate + Global Fields.

`Meal` (reusable template): id, name, defaultCalories, defaultMacros, icon + Global Fields.

`WaterLog`: id, amount, time, localDate + Global Fields.

Targets come from `DailyGoals` (RFC-003-adjacent, see `04_Database_Schema.md`), not stored per-entry.

# 4. State Machine

N/A — Nutrition entries are simple CRUD logs, not stateful sessions.

# 5. Validation Rules

- `calories` ≥ 0. Macro fields ≥ 0.
- `water` amount in `WaterLog` must be > 0.
- At least `mealType` and one nutrition value required to save an entry (empty entries blocked).

# 6. Acceptance Criteria

✓ Dashboard Nutrition Summary reads today's `NutritionEntry` records + `DailyGoals` to render progress rings.
✓ Water quick-add buttons (+250ml etc., per `06_User_Flows.md`) write directly to `WaterLog` without opening a full form.
✓ Nutrition Score component in Life Score reflects meals logged + macro/water target attainment (RFC-003 §3).

# 7. Error Handling & Edge Cases

- No `DailyGoals` configured (user skipped during Onboarding): progress rings show absolute values only, no percentage, with a prompt to set goals.
- Duplicate meal logging (double-tap): debounced at the UI layer; not a data-model concern.

# 8. Performance Requirements

Quick water-add completes and reflects on Dashboard in < 150ms.

# 9. Accessibility Requirements

Macro progress rings have text-equivalent values available to screen readers (not conveyed by color/shape alone).

# 10. Testing Requirements

Unit tests for progress-ring percentage calculation against `DailyGoals`. Widget test for quick water-add control.

# 11. Future Expansion

Barcode/food-database lookup (would require a bundled offline database, no network — deferred, separate RFC).

# 12. Golden Rule

Logging must never take more than 3 taps for a common action (matches Task Creation friction bar in RFC-002).

---

End of Document
