# RFC-011

Module: Medicine & Supplements

Document ID: RFC-MEDSUPP-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Health Modules

Depends on: RFC-006 (Notification & Reminder Architecture)

---

# 1. Purpose

Defines Medicine and Supplement tracking, sharing one pattern (scheduled item → reminder → log confirmation) since both are logging + reminder modules.

# 2. User Stories

- As a user, I add a medicine/supplement with a dosage and schedule.
- As a user, I get a reminder notification and can mark it Taken/Skipped directly from the notification.
- As a user, I see adherence history (taken vs. missed) over time.

# 3. Data Model

`Medicine`: id, name, dosage, schedule (times/day, repeatRule), notes, active + Global Fields.

`MedicineLog`: id, medicineId, scheduledTime, actualTime (nullable), status (`Taken/Skipped/Missed`), localDate + Global Fields.

`Supplement`: id, name, dosage, schedule, notes, active + Global Fields.

`SupplementLog`: id, supplementId, scheduledTime, actualTime (nullable), status (`Taken/Skipped/Missed`), localDate + Global Fields.

Each scheduled dose generates a `Notification` (`sourceType=Medicine` or `Supplement`, `sourceId=medicineId/supplementId`), per RFC-006 §2.

# 4. State Machine

Per dose: `Scheduled → Taken` or `Scheduled → Skipped` or `Scheduled → Missed` (auto-transitioned if no action taken within a configurable grace window, default 2 hours, editable in Settings).

# 5. Validation Rules

- `dosage` required, free-text (unit not enforced — supports "1 tablet," "5ml," etc.).
- `schedule` must resolve to at least one time/day.
- Deactivating a Medicine/Supplement (`active=false`) cancels its future scheduled Notifications but preserves historical Logs.

# 6. Acceptance Criteria

✓ Notification action buttons (Taken/Skip/Snooze, per RFC-006 §5) write directly to `MedicineLog`/`SupplementLog` without opening the app.
✓ Missed doses (no action within grace window) auto-transition to `Missed` and are visible in adherence history.
✓ Medicine/Supplement Score component in Life Score reflects adherence rate for the day.

# 7. Error Handling & Edge Cases

- Device off during scheduled time: dose is marked `Missed` retroactively when the app is next opened, using `scheduledTime` vs. current time vs. grace window — never silently dropped.
- Overlapping schedules (two doses at the same time): both generate independent Notifications; no merging.

# 8. Performance Requirements

Notification action (Taken/Skip) writes and updates any open Dashboard view in < 150ms.

# 9. Accessibility Requirements

Notification action buttons meet minimum 44×44pt touch target even in the compact notification tray layout.

# 10. Testing Requirements

Unit tests for grace-window auto-Missed logic. Integration test: schedule dose → simulate notification action → verify Log write → verify Life Score component update.

# 11. Future Expansion

Refill tracking / low-stock alerts (deferred, separate RFC).

# 12. Golden Rule

A reminder must always be actionable without opening the app.

---

End of Document
