# Database Schema

Document ID: DB-001

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md — see FINAL_SPECIFICATION_REPORT.md for full changelog)

Status: Approved

---

# Database Engine

Primary Database:
Isar Database

Secondary Storage:
Hive

Export Format:
JSON

Future Backup:
Encrypted ZIP

---

# Database Philosophy

LifeOS uses an Entity-Centric architecture.

Each entity must:

• Have its own unique ID

• Contain creation/update timestamps

• Support future migration

• Be exportable

• Be searchable

• Be recoverable

---

# Global Fields

Every Entity MUST contain:

id (UUID v4)

createdAt

updatedAt

deletedAt (nullable)

isArchived

isDeleted

version

deviceId

syncState (Reserved)

Rule: Every field list below is written as "Module Fields" and does **not** repeat the Global Fields inline for brevity — but every entity implements them via a shared `BaseEntity` mixin/base class at the code level. No entity may omit them. This replaces the prior ambiguity where individual entity field lists appeared to omit Global Fields.

---

# Entity List

The application consists of the following entities.

User

Task

Session (generic — replaces the former TaskSession / WorkoutSession / LearningSession; see RFC-005_Core_Session_Engine.md)

Goal

Milestone

Project

Workout

Exercise

WorkoutSet (embedded context data for a Session of sessionType=Workout)

LearningTopic

NutritionEntry

Meal

Medicine

MedicineLog

Supplement

SupplementLog

WaterLog

SleepLog

JournalEntry

DecisionLog

Result (canonical Daily/Weekly/Monthly/Yearly summary — now the single source of truth for Life Score; see RFC-003_Life_Score_Engine.md)

Notification

DailyGoals (new — user's daily targets, see below)

Settings

Theme

QuickCapture

Attachment

Tag

Category

Template

Routine

Note: `LifeScore` and `AnalyticsSnapshot` as independently-written entities are **removed** (Critical Issue 1.5 resolution). `AnalyticsSnapshot` may still exist as a non-authoritative, fully regenerable cache table for chart performance, but it is never a data source of truth and is never included in Export.

---

# Entity Relationships

User

↓

Goals (optional)

↓

Milestones (optional)

↓

Projects (optional)

↓

Tasks

↓

Sessions (sessionType = Task)

Every Goal may contain multiple Milestones.

Every Milestone may contain multiple Projects.

Every Project may contain multiple Tasks.

Every Task may contain unlimited Sessions (sessionType=Task).

A Task may attach directly to a Goal, Milestone, or Project independently — the chain is not mandatory. See RFC-004_Goals_Milestones_Projects.md §2.

All other execution modules (Learning, Workout, Reading, Writing, Business) attach to the same generic Session entity via their own `sessionType`, not via separate session tables. See RFC-005_Core_Session_Engine.md.

---

# Task Entity

Fields (Global Fields implied — see rule above)

id

title

description

categoryId

priority

status

estimatedMinutes

actualMinutes

deadline

reminder

repeatRule

difficulty

energyRequirement

context

goalId (nullable)

projectId (nullable)

milestoneId (nullable)

tags

attachments

icon

color

notes

localDate (the day this task is scheduled/relevant for — correlation key, see RFC-005 §7)

completedAt (nullable)

archivedAt (nullable)

createdAt

updatedAt

---

# Task Status

Canonical 8-state lifecycle (matches RFC-002_Task_Management.md §7 — this replaces the previous 5-state list, which was a contradiction; see FINAL_SPECIFICATION_REPORT.md):

Inbox

Planned

Ready

Running

Paused

Completed

Cancelled

Archived

No custom statuses allowed.

Note: `Running` and `Paused` on the Task itself mirror the state of its currently-linked Session (Core Session Engine, RFC-005). A Task cannot be `Running` unless a Session with `sessionType=Task` and `contextId=this task` is currently `Running`.

---

# Session Entity (Generic — Core Session Engine, RFC-005)

Fields

id

sessionType (`Task/Learning/Workout/Reading/Writing/Business/Freeform`)

contextId (nullable — points to Task/LearningTopic/Workout/etc.)

status (`Running/Paused/Finished/Cancelled/Reflected`)

startTime

pauseIntervals (embedded list of {pausedAt, resumedAt})

endTime

effectiveDuration

focusScore

energyScore

difficultyScore

reflectionNote

reflectionSkipped

localDate (correlation key)

createdAt

This single entity replaces the former separate `TaskSession`, `WorkoutSession`, and `LearningSession` tables. Module-specific extra data (e.g., a Workout session's sets/reps, a Learning session's understanding rating) is stored as a small **embedded context payload** keyed by `sessionType`, not as a separate top-level entity. See `WorkoutSet` and `LearningTopic` below for the two context payloads needed at v1.

---

# Goal Entity

Fields

id

title

description

targetDate

progress

priority

icon

color

completed

---

# Milestone Entity

Fields

id

goalId

title

progress

deadline

completed

---

# Project Entity

Fields

id

milestoneId

title

description

progress

status

deadline

---

# Workout Entity

Fields

id

name

type

estimatedDuration

difficulty

notes

---

# Exercise Entity

Fields

id

workoutId

name

targetMuscle

equipment

order

---

# WorkoutSet (Embedded Context — attached to a Session where sessionType=Workout)

Fields

id

sessionId (the parent generic Session)

workoutId

exerciseId

setNumber

repetitions

weight

rest

RPE

painLevel

energyBefore

energyAfter

notes

Note: `duration`/`date`/`focus`-equivalent fields live on the parent Session (RFC-005), not duplicated here.

---

# LearningTopic (Reference Entity — what a Learning Session's contextId points to)

Fields

id

subject

course

chapter

lesson

resource

order

---

Learning-specific reflection data (`understanding`, `reviewNeeded`) is stored directly on the parent Session's reflection payload (Session.reflectionNote plus a small typed extension — see RFC-005 §8) rather than as a separate `LearningSession` table.

---

# Nutrition Entry

Fields

id

mealType

calories

protein

carbohydrate

fat

fiber

water

notes

localDate (correlation key, see RFC-005 §7)

---

# Medicine

Fields

id

name

dosage

beforeFood

afterFood

timesPerDay

instructions

---

# Medicine Log

Fields

id

medicineId

scheduledTime

takenTime

taken

notes

---

# Supplement

Fields

id

name

dosage

schedule

instructions

---

# Supplement Log

Fields

id

supplementId

scheduledTime

takenTime

taken

notes

---

# Water Log

Fields

id

amount

time (exact timestamp)

localDate (correlation key, derived from `time` via DateManager — see RFC-005 §7)

---

# Sleep Log

Fields

id

sleepTime

wakeTime

duration

quality

dreamNotes

energyAfterWake

localDate (the day of the wake-up, per DateManager rule — correlation key)

---

# Journal Entry

Fields

id

title

content

mood

gratitude

reflection

localDate (correlation key)

---

# Decision Log

Fields

id

decision

reason

alternatives

expectedOutcome

actualOutcome

reviewDate

---

# Result (Canonical Life Score & Summary Record — see RFC-003_Life_Score_Engine.md)

Fields

id

localDate (day this Result anchors to; for Weekly/Monthly/Yearly this is the period's start day)

period (`Daily/Weekly/Monthly/Yearly`)

rangeStart

rangeEnd

lifeScore

taskScore

sessionQualityScore

workoutScore

learningScore

sleepScore

nutritionScore

consistencyScore

completedTasks

totalTasks

deepWorkMinutes

journalCompleted

isProvisional (true if computed live before Daily Closing, not yet finalized)

formulaVersion (which Life Score formula version produced this record)

notes

`Result` is the single authoritative entity for Life Score and all periodic summaries. `LifeScore` as an independent entity is removed (Critical Issue 1.5).

---

# Analytics Snapshot (Non-authoritative cache — regenerable, not exported)

Fields

id

localDate

period (`week/month/year`)

averageFocus

averageEnergy

averageSleep

averageWorkout

averageLearning

completionRate

streak

deepWorkHours

Note: This table exists purely to speed up chart rendering. Every value here is derivable from `Result` + raw entities and may be dropped/rebuilt at any time without data loss. It is not part of Export/Backup (RFC-007).

---

# User

Fields

id

displayName

avatarIcon

timezone

calendarPreference (`SolarHijri/Gregorian` — display only, storage is always Gregorian ISO-8601 internally)

createdAt

Note: LifeOS has exactly one local User profile per device in v1 (no multi-profile, no account system — matches "No mandatory account" in `02_Software_Requirements.md` §5). This record is created during first-launch Onboarding (see `06_User_Flows.md` Onboarding Flow).

---

# Notification

Fields

id

title

body

scheduledTime

sourceType (`Medicine/Supplement/Water/TaskDeadline/Custom`)

sourceId (nullable)

repeatRule

delivered

dismissed

actionTaken

See RFC-006_Notification_Reminder_Architecture.md for scheduling behavior.

---

# DailyGoals

Fields

id (singleton per user — always one active record, versioned by updatedAt)

dailyWaterGoalMl

dailyCalorieGoal

dailyProteinGoal

sleepGoalHours

weeklyWorkoutSessionGoal

dailyLearningMinutesGoal

dailyDeepWorkMinutesGoal

updatedAt

This entity supplies the target values referenced by every progress ring in the UI (Water, Nutrition, Sleep, Workout, Learning) — previously undefined (Important Improvement 2.3). Editable from Settings → Daily Goals.

---

# Settings

Fields

language

theme

accentColor

fontScale

animationsEnabled

hapticsEnabled

backupEnabled

notificationsEnabled

calendarType

---

# Theme

Fields

primaryColor

secondaryColor

backgroundColor

surfaceColor

textColor

borderRadius

spacingScale

animationScale

---

# Category

Fields

id

name

icon

color

order

---

# Tag

Fields

id

name

color

---

# Routine

Fields

id

title

tasks

daysOfWeek

enabled

---

# Template

Fields

id

title

description

taskStructure

workoutStructure

learningStructure

---

# Quick Capture

Fields

id

content

type

processed

createdAt

---

# Attachment

Fields

id

entityId

entityType

fileName

mimeType

size

path

---

# Indexing Strategy (Per-Entity — resolves prior unscoped flat list)

Task: status, deadline, localDate, categoryId, goalId, projectId, milestoneId, normalizedText

Session: sessionType, status, localDate, contextId

Result: localDate, period

Goal / Milestone / Project: status, deadline

Tag / Category: name (normalized)

All searchable entities: normalizedText (see `04A_Data_Modeling_Strategy.md` Search Strategy)

---

# Search Engine

Global Search shall search:

Tasks

Goals

Projects

Workout

Learning

Nutrition

Journal

Results

Decision Logs

Quick Capture

---

# Soft Delete

Every entity supports:

deletedAt

isDeleted

No record is permanently removed unless user confirms permanent deletion.

---

# Migration Strategy

Each entity contains:

schemaVersion

Database versioning shall support automatic migration.

---

# Recurrence Calendar Rule (resolves Important Improvement 2.6)

`repeatRule` values (`Daily/Weekly/Monthly/Yearly/Custom`) are always computed against the **Gregorian calendar**, since internal storage is Gregorian ISO-8601. The Solar Hijri calendar is a **display-only transformation** applied by `core/DateManager` at render time and never governs recurrence math, migration, or storage. This avoids Hijri/Gregorian month-length mismatches producing incorrect recurrence dates.

---

# Encryption

See `rfc/RFC-007_Export_Import_Backup_Encryption.md` for the full specification of at-rest database encryption vs. backup-file encryption. These are two independent, optional mechanisms with separate key handling.

---

# Database Rules

No duplicate IDs.

No orphan records.

Cascade updates where necessary.

Restrict deletion if linked records exist.

Lazy load large collections.

---

# Future Ready

Database must support future entities without redesign.

Finance

CRM

Knowledge Base

AI Memory

Habits

Assets

Business

Investments

Health Devices

Wearables

---

End of Document