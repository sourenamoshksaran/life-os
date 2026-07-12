# Data Modeling Strategy

Document ID: DB-002

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# Purpose

This document defines how data should be modeled inside LifeOS.

The goal is to maximize:

- Performance
- Simplicity
- Maintainability
- Future scalability

while remaining fully Offline-First.

---

# Core Principles

Every model must satisfy:

✓ Single Responsibility

✓ Immutable Domain Models

✓ Serializable

✓ Searchable

✓ Exportable

✓ Versioned

---

# Entity Types

LifeOS contains four different model types.

## Root Entity

Large independent objects.

Examples:

Task

Goal

Project

Workout

Journal

Result

Settings

Analytics

---

## Embedded Entity

Objects that never exist independently.

Examples:

Exercise

Workout Set

Nutrition Macro

Reflection

Attachment Metadata

Medicine Schedule

Supplement Schedule

Tag Reference

---

## Reference Entity

Objects linked through IDs.

Examples:

Goal → Project

Project → Task

Task → Session (sessionType=Task)

Workout → Session (sessionType=Workout) → WorkoutSet (embedded context)

Journal → Attachment

Note: As of v2.0, there is one generic `Session` entity shared by all execution modules (Task, Learning, Workout, Reading, Writing, Business) rather than a separate session table per module. See `rfc/RFC-005_Core_Session_Engine.md`. Module-specific extra data attaches as a small embedded context object (e.g. `WorkoutSet`), not as a full duplicate session table.

---

## Cache Entity

Temporary models.

Never exported.

Never backed up.

Examples:

Search Cache

Dashboard Cache

Recent Items

Current Session

Notification Queue

---

# ID Strategy

Every Root Entity shall use:

UUID v4

Example:

550e8400-e29b-41d4-a716-446655440000

IDs never change.

---

# Date Strategy

All timestamps stored internally:

UTC ISO-8601

Example:

2026-07-19T14:22:51Z

Displayed to user:

Solar Hijri (display-only transformation; recurrence and migration math always use Gregorian — see `04_Database_Schema.md` "Recurrence Calendar Rule")

# Correlation Key: localDate

Every daily-loggable entity (Session, NutritionEntry, SleepLog, WaterLog, MedicineLog, SupplementLog, JournalEntry, Task) additionally stores a computed `localDate` (`YYYY-MM-DD`, local device time, day boundary = 00:00 local time). This is the join key the Analytics Engine uses to correlate cross-module data — e.g. sleep quality vs. same-day focus scores — fulfilling the "Everything is Connected" principle locked in `01_Project_Overview.md`. Computed once, centrally, by `core/services/DateManager` — never computed ad hoc per module.

---

# Entity Ownership

Each Root Entity owns:

Created Time

Updated Time

Version

Deleted Flag

Archive Flag

---

# Embedded vs Reference

Use Embedded when:

Data never exists alone.

Small object.

Always loaded together.

Rarely queried separately.

Example:

Workout

↓

Exercise

↓

Sets

---

Use Reference when:

Large object.

Shared object.

Frequently queried.

Frequently modified.

Example:

Goal

↓

Project

↓

Task

↓

Task Session

---

# Naming Rules

Collections

Singular

Task

Goal

Workout

Never:

TasksCollection

WorkoutItems

---

Fields

camelCase

Examples:

createdAt

updatedAt

lifeScore

sleepDuration

energyScore

---

Enums

PascalCase

Examples:

TaskPriority

WorkoutType

MealType

LifeScoreLevel

---

Files

snake_case

Examples:

task_repository.dart

goal_entity.dart

analytics_engine.dart

---

# Null Strategy

Nullable only when required.

Avoid nullable collections.

Prefer empty list over null.

---

# Soft Delete

Entities are never immediately deleted.

Fields:

isDeleted

deletedAt

User may restore deleted items.

Permanent deletion requires confirmation.

---

# Archive Strategy

Archive != Delete

Archived objects:

Hidden from default UI

Still searchable

Still exportable

Still recoverable

---

# Versioning

Every Entity:

schemaVersion

Current:

1

Future migrations must increase version.

---

# Migration Rules

Migration must never delete data.

Migration must be reversible whenever possible.

Migration scripts required.

---

# Search Strategy

Every searchable entity stores:

normalizedText

Example:

"Python"

↓

"python"

↓

"PYTHON"

All normalized for fast search.

---

# Index Strategy

Primary indexes:

id

createdAt

updatedAt

status

deadline

goalId

projectId

categoryId

lifeScore

date

---

# Lazy Loading

Large objects loaded only when needed.

Examples:

Journal

Results

Analytics

Attachments

---

# Memory Rules

Do not keep unnecessary objects in RAM.

Dispose inactive controllers.

Dispose inactive streams.

---

# Serialization

Every entity supports:

toJson()

fromJson()

copyWith()

equality()

hashCode()

---

# Validation Rules

No empty IDs.

No invalid dates.

No orphan references.

No duplicated UUIDs.

---

# Backup Strategy

Export:

Single JSON

Import:

Version Validation

Schema Validation

Integrity Validation

Reference Validation

---

# Future Ready

Data model must support:

AI Memory

Cloud Sync

Finance

Business CRM

Wearables

Knowledge Graph

without redesign.

---

# Golden Rules

Every model must be:

Small.

Fast.

Predictable.

Documented.

Replaceable.

Testable.

Offline-first.

---

End of Document