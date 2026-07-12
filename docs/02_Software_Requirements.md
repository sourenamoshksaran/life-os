# Software Requirements Specification (SRS)

Document ID: SRS-001

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# 1. Purpose

This document defines all functional and non-functional requirements of LifeOS.

Every feature implemented by Cloud Code must comply with this specification.

No feature may be added without updating this document.

---

# 2. Product Scope

LifeOS is an Offline-First Personal Life Operating System.

Its objective is to centralize every important aspect of a user's life inside one unified application.

The application must remain completely functional without internet access.

---

# 3. Functional Requirements

## Dashboard

The dashboard shall display:

• Life Score (from `Result`, per RFC-003; live provisional preview before Daily Closing)

• Command Center / Mission Widget (Dashboard Section 03 — not a separate screen; see RFC-001 §5)

• Today's Tasks

• Active Session (single active Session from Core Session Engine, RFC-005, regardless of type)

• Workout Progress

• Nutrition Summary

• Water Intake

• Sleep Status

• Learning Progress

• Medicine Reminder

• Supplement Reminder

• Calendar Summary

• Daily Quote (Optional)

---

## Daily Goals (new)

The application shall allow users to configure personal daily/weekly targets (`DailyGoals` entity, see `04_Database_Schema.md`):

Daily Water Goal (ml)

Daily Calorie Goal

Daily Protein Goal

Sleep Goal (hours)

Weekly Workout Session Goal

Daily Learning Minutes Goal

Daily Deep Work Minutes Goal

These targets drive every progress-ring component in the UI. Defaults are applied if the user skips configuration during Onboarding.

---

## Tasks

The application shall allow users to:

Create Tasks

Edit Tasks

Delete Tasks

Archive Tasks

Duplicate Tasks

Schedule Tasks

Assign Priority

Assign Category

Assign Tags

Assign Estimated Duration

Assign Deadline

Assign Goal

Assign Milestone

Assign Project

Start Session

Pause Session

Resume Session

Finish Session

Cancel Session

Write Reflection

---

## Time Tracking

Each Task Session must contain:

Start Time

Pause Time(s)

Resume Time(s)

Finish Time

Total Time

Effective Time

Break Time

Focus Score

Energy Score

Difficulty Score

Notes

Completion Status

---

## Workout Module

Each workout shall contain:

Workout Name

Workout Type

Exercise List

Sets

Repetitions

Duration

Weight

Rest Time

Difficulty

RPE

Pain Level

Energy Before

Energy After

Notes

Completion Status

---

## Learning Module

Each Learning Session shall contain:

Subject

Course

Chapter

Lesson

Duration

Focus

Difficulty

Understanding

Need Review

Notes

Resources

---

## Nutrition Module

Each meal shall contain:

Meal Type

Calories

Protein

Carbohydrates

Fat

Fiber

Water

Notes

---

## Medicine Module

Each medicine entry shall contain:

Medicine Name

Dose

Time

Before Food

After Food

Taken

Skipped

Notes

---

## Supplement Module

Each supplement entry shall contain:

Supplement Name

Dose

Time

Taken

Skipped

Notes

---

## Journal Module

Journal supports:

Reflection

Daily Notes

Ideas

Decision Logs

Lessons Learned

---

## Results Module

Results shall automatically generate:

Daily Summary

Weekly Summary

Monthly Summary

Yearly Summary

Every Result shall remain editable.

---

## Analytics Module

Analytics shall calculate:

Life Score

Focus Trend

Workout Trend

Learning Trend

Nutrition Trend

Sleep Trend

Consistency

Completion Rate

Deep Work Time

Streak

Most Productive Day

Average Energy

Average Focus

Average Sleep

Average Workout Duration

---

# 4. Non Functional Requirements

Application Startup

< 1 second

Animation Duration

150–250 ms

Task Creation

< 5 seconds

Session Start

< 2 taps

Offline Availability

100%

Local Data Ownership

100%

Internet Requirement

None

---

# 5. Security

No user data shall leave the device.

No analytics service.

No advertisement.

No mandatory account.

No telemetry.

Optional local encryption (at-rest DB encryption) and optional encrypted backup export — two independent mechanisms, see `rfc/RFC-007_Export_Import_Backup_Encryption.md`.

---

# 6. Storage

Primary Storage

Isar Database

Settings

Hive

Export

JSON (plain, or password-protected encrypted ZIP — see RFC-007)

Backup

ZIP (Future) — Note: encrypted ZIP export is available at v1 via RFC-007; "Future" here refers only to automatic scheduled/rotating backups, not to encryption itself.

---

# 7. Localization

Primary Language

Persian (RTL)

Secondary Language

English

Calendar

Solar Hijri

Internal Storage

Gregorian ISO-8601

---

# 8. Accessibility

Dynamic Font Size

Color Blind Support

High Contrast

Reduced Motion

Screen Reader Support

---

# 9. Performance Targets

Scrolling

60 FPS minimum

Page Transition

< 250 ms

Search

< 200 ms

Database Query

< 100 ms

---

# 9A. Platform Baseline (new)

See `03_System_Architecture.md` §22A for pinned Flutter/Dart/Isar versions and minimum OS versions (Android 8.0 / iOS 15).

---

# 9B. Testing Requirements (new)

See `03_System_Architecture.md` §22B for unit/widget/golden/integration test tier requirements. No feature ships without its required test tier (see `CLAUDE.md` Definition of Done).

---

# 9C. Notification Requirements (new)

See `rfc/RFC-006_Notification_Reminder_Architecture.md` for local notification scheduling, Android exact-alarm permission handling, and iOS re-scheduling strategy for Medicine/Supplement/Water reminders.

---

# 10. Future Compatibility

Architecture shall support:

Desktop

Tablet

Wearables

AI Assistant

Cloud Sync (Optional)

Finance Module

Business Module

CRM Module

Knowledge Base Module

without major architectural changes.

---

End of Document