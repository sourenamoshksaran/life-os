# RFC-002

Module: Task Management

Document ID: RFC-TASK-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Critical

Owner: Core Productivity

Amendment (v1.1): The Task Status enum below is now the single canonical version, matching `04_Database_Schema.md`. The previously conflicting 5-state enum (`Pending/In Progress/Completed/Cancelled/Archived`) that appeared in the Database Schema document has been removed there in favor of this 8-state lifecycle.

Amendment (v1.1): All Task session behavior (start/pause/resume/finish/reflect, "only one active session" rule) is now delegated entirely to the **Core Session Engine** (`RFC-005_Core_Session_Engine.md`). This document's §11 "Session Rules" is retained for historical context but the enforcement mechanism now lives in RFC-005 §6 and applies across all modules, not just Tasks.

Amendment (v1.1): The Task entity now includes the Global Fields and the previously-missing fields listed in §5 below, matching the updated `04_Database_Schema.md`.

---

# 1. Purpose

Task Management is the execution engine of LifeOS.

A Task is not merely a checklist item.

A Task represents a meaningful unit of work that contributes to a Goal, Milestone, or Project.

The module must optimize execution, focus, and consistency rather than only task completion.

---

# 2. Objectives

The module shall enable users to:

- Capture tasks quickly.
- Organize work hierarchically.
- Execute one task at a time.
- Track actual work time.
- Measure completion quality.
- Feed Analytics and Life Score.

---

# 3. User Stories

As a user, I want to:

- create a task in less than 10 seconds.
- organize tasks into Projects and Goals.
- prioritize today's work.
- start a focused work session.
- pause and resume work.
- review completed work.
- understand what remains.

---

# 4. Task Lifecycle

Inbox

↓

Planned

↓

Ready

↓

Running

↓

Paused

↓

Completed

↓

Archived

or

Cancelled

---

# 5. Task Properties

Every task contains:

UUID

Title

Description

Priority

Status

Category

Tags

Goal

Milestone

Project

Estimated Duration

Actual Duration

Deadline

Reminder

Repeat Rule

Difficulty

Energy Requirement

Context

Attachments

Notes

Created At

Updated At

Completed At

Archived At

---

# 6. Priority Levels

Critical

High

Medium

Low

Someday

Priority determines default ordering.

---

# 7. Task Status

Inbox

Planned

Ready

Running

Paused

Completed

Cancelled

Archived

No custom statuses allowed.

---

# 8. Categories

Learning

Workout

Business

Personal

Health

Finance

Family

University

Research

Custom

Categories are customizable.

---

# 9. Tags

Unlimited tags.

Color supported.

Emoji optional.

Searchable.

---

# 10. Time Estimation

Every task may contain:

Estimated Minutes

Actual Minutes

Difference

Efficiency %

---

# 11. Session Rules

Only one active task session is allowed.

Starting another session automatically requests confirmation.

---

# 12. Repeat Rules

None

Daily

Weekly

Monthly

Yearly

Custom

Skipped occurrences are logged.

---

# 13. Reminder Rules

Reminder can occur:

At Time

Before Deadline

After Inactivity

Custom Schedule

---

# 14. Sorting

Supported sorting:

Priority

Deadline

Category

Duration

Alphabetical

Recently Created

Recently Updated

Manual

---

# 15. Filtering

Status

Priority

Category

Goal

Project

Milestone

Tags

Deadline

Duration

---

# 16. Search

Global search.

Supports:

Title

Description

Category

Tags

Goal

Project

Notes

---

# 17. Quick Actions

Swipe Right

Complete

Swipe Left

Delete / Archive

Long Press

Selection Mode

Double Tap

Start Session

---

# 18. Bulk Operations

Delete

Archive

Move

Assign Category

Assign Goal

Assign Project

Duplicate

Export

---

# 19. Dependencies

Tasks may depend on other tasks.

Blocked tasks display lock indicator.

Completion order enforced when enabled.

---

# 20. Templates

Users may create reusable templates.

Examples:

Study Session

Workout

Reading

Meeting

Coding

Writing

---

# 21. Validation Rules

Title is mandatory.

Estimated duration > 0.

Deadline cannot precede creation date.

Duplicate IDs forbidden.

---

# 22. Empty State

Display:

Illustration

Create Task Button

Quick Capture Button

---

# 23. Loading State

Skeleton cards.

Independent loading.

No full-screen spinner.

---

# 24. Error Handling

Validation errors shown inline.

Database failures recover gracefully.

Unsaved changes prompt before exit.

---

# 25. Analytics Integration

Each completed task updates:

Task Statistics

Completion Rate

Deep Work Time

Consistency

Life Score

---

# 26. Accessibility

RTL

Dynamic Fonts

Voice Labels

Keyboard Navigation (Future)

High Contrast

Reduced Motion

---

# 27. Performance Targets

Create Task < 300ms

Open Task < 150ms

Search < 100ms

List Scroll 60 FPS

---

# 28. Security

All task data stored locally.

No cloud dependency.

JSON export supported.

---

# 29. Acceptance Criteria

✓ Task creation under 10 seconds.

✓ One active session only.

✓ Offline functionality.

✓ Automatic analytics updates.

✓ Search across all task fields.

✓ No duplicated records.

✓ Smooth interactions at 60 FPS.

---

# 30. Future Enhancements

AI-assisted prioritization.

Natural language task creation.

Voice input.

Task dependency visualization.

Calendar synchronization.

Shared projects.

---

# 31. Golden Rule

Tasks exist to drive meaningful execution.

The interface should always reduce friction and encourage action.

Every interaction should help the user start, continue, or complete valuable work with minimal effort.

---

End of Document