# RFC-014

Module: Settings

Document ID: RFC-SETTINGS-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Core System

---

# 1. Purpose

Defines the Settings module: profile, Daily Goals, appearance, notifications, module toggles, data management, and where the (deferred) Life Designer customization surface lives.

# 2. User Stories

- As a user, I edit my display name, language, and calendar preference.
- As a user, I set my Daily Goals (water/calorie/sleep/workout/learning targets).
- As a user, I disable modules I don't use, so they don't count against my Life Score.
- As a user, I export/import my data and manage encryption from one place.

# 3. Data Model

`Settings`: language, theme, notificationSound (bool), gracePeriodMinutes (Medicine/Supplement, default 120), moduleToggles (map of module name → enabled bool, drives RFC-003 §4 weight redistribution), encryptionEnabled (bool) + Global Fields.

`DailyGoals`: see `04_Database_Schema.md` (dailyWaterGoalMl, dailyCalorieGoal, dailyProteinGoal, sleepGoalHours, weeklyWorkoutSessionGoal, dailyLearningMinutesGoal, dailyDeepWorkMinutesGoal).

`User`: see `04_Database_Schema.md` (displayName, avatarIcon, timezone, calendarPreference).

# 4. State Machine

N/A — Settings is direct-write CRUD on singleton records (`User`, `Settings`, `DailyGoals` each have exactly one active record per device).

# 5. Validation Rules

- Disabling a module in `moduleToggles` that has a Life Score component weight triggers redistribution per RFC-003 §4 — validated so weights always sum to 100%.
- `gracePeriodMinutes` must be between 15 and 1440 (1 day).
- Changing `calendarPreference` is display-only and never triggers a data migration (per `04_Database_Schema.md` Recurrence Calendar Rule).

# 6. Acceptance Criteria

✓ Settings is the single place Daily Goals, module toggles, and encryption are configured.
✓ Export/Import entry points (RFC-007) live under Settings → Data Management.
✓ Life Designer (workout/routine/learning builders, theme customization — `05_UI_UX_Specification.md`) is reachable from Settings but remains its own screen; "Plugins" stays out of scope per the naming-collision resolution in that document.

# 7. Error Handling & Edge Cases

- Disabling the last remaining active module: blocked with a warning ("At least one module must remain active for Life Score to be meaningful").
- Changing language mid-session: applies immediately via `gen-l10n` locale switch, no restart required.

# 8. Performance Requirements

Settings changes persist and reflect app-wide in < 100ms (Hive-backed, per `02_Software_Requirements.md` §6).

# 9. Accessibility Requirements

All toggles and sliders in Settings are fully operable via screen reader and external keyboard (matches `07_Design_System.md` Accessibility section).

# 10. Testing Requirements

Unit tests for weight-redistribution math on module toggle. Widget tests for Daily Goals form validation.

# 11. Future Expansion

Per-module notification sound customization; multiple Daily Goals profiles (e.g., "weekday" vs. "weekend" targets) — deferred, separate RFC.

# 12. Golden Rule

Nothing in Settings should require leaving Settings to complete — no dead-end links to unbuilt features.

---

End of Document
