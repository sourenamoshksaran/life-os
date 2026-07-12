# RFC-006

Module: Notification & Reminder Architecture

Document ID: RFC-NOTIFICATION-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important

Owner: Core System

---

# 1. Purpose

Medicine, Supplement, Water, and Task-deadline reminders all depend on local notification scheduling, but no prior document specified the mechanism, permissions, or entity fields. Resolves Important Improvement 2.4 (missing Notification entity) from PROJECT_AUDIT.md.

---

# 2. Notification Entity (finalized fields)

id, title, body, scheduledTime, sourceType (`Medicine/Supplement/Water/TaskDeadline/Custom`), sourceId (nullable — the linked entity), repeatRule, delivered, dismissed, actionTaken, createdAt, updatedAt

---

# 3. Platform Mechanism

- **Local notifications only** — no push infrastructure, no server, consistent with the 100% offline / no-telemetry security rule in `02_Software_Requirements.md` §5.
- Android: uses exact-alarm scheduling where required (medicine reminders must fire at the scheduled minute); the app requests the `SCHEDULE_EXACT_ALARM` permission on Android 12+ with a clear in-app explanation before the OS prompt.
- iOS: uses `UNUserNotificationCenter` local notifications; because iOS limits background scheduling reliability, all recurring reminders (Medicine, Supplement, Water) are re-scheduled for the next 7 days every time the app is opened, not scheduled once far into the future.

---

# 4. Permission Flow

Notifications permission is requested **contextually**, not at first launch — the first time a user creates a Medicine, Supplement, or Task deadline that requires a reminder, not during onboarding. This matches the "no mandatory account, minimal upfront friction" philosophy already established.

---

# 5. Notification Style

Per `05_UI_UX_Specification.md` "Notification Style" section: minimal, silent by default (no sound unless user enables it in Settings), grouped by `sourceType`, with inline action buttons (`Taken`, `Skip`, `Snooze 10m`) that write directly to the relevant Log entity (`MedicineLog`, `SupplementLog`, `WaterLog`) without opening the app.

---

# 6. Acceptance Criteria

✓ Notification entity has full field definition.

✓ Android exact-alarm and iOS re-scheduling behavior explicitly specified.

✓ Permission requested contextually, not blocking onboarding.

---

End of Document
