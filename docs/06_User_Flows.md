# User Flows & UX Journey

Document ID: UX-002

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# Purpose

This document defines every user journey inside LifeOS.

Developers must implement these flows exactly.

No interaction may skip mandatory states.

---

# UX Philosophy

Every action follows the same pattern:

Intent

↓

Preparation

↓

Execution

↓

Confirmation

↓

Reflection

↓

Analytics Update

---

# Main Navigation Flow

Launch App

↓

Splash

↓

First Launch? → Yes → Onboarding Flow (see below) → Dashboard

↓ No

Dashboard (Command Center renders as its top section — not a separate screen; see `rfc/RFC-001_Dashboard.md` §5)

↓

User chooses destination

↓

Feature Module

↓

Back to Dashboard

---

# Onboarding Flow (new — resolves missing first-launch specification)

Splash

↓

Welcome (brand introduction, no account required)

↓

Create Local User Profile (displayName, avatarIcon — writes the single `User` record)

↓

Language & Calendar Preference (Persian/English, Solar Hijri/Gregorian display)

↓

Daily Goals Setup (optional — Water/Calorie/Sleep/Workout targets; skippable, defaults applied if skipped)

↓

Notification Permission (deferred — NOT requested here; see RFC-006 §4, requested contextually on first Medicine/Supplement/Deadline creation)

↓

Dashboard (empty states shown per `rfc/RFC-001_Dashboard.md` §9)

---

# Dashboard Flow

Open App

↓

Dashboard Loaded

↓

Life Score Loaded

↓

Today's Tasks Loaded

↓

Running Session Check

↓

Workout Summary

↓

Learning Summary

↓

Nutrition Summary

↓

Medicine Status

↓

Next Recommended Action

---

# Quick Capture Flow

Tap +

↓

Quick Capture Panel

↓

Select Type

Task

Idea

Journal

Goal

Workout

Learning

↓

Write

↓

Save

↓

Instant Dashboard Update

---

# Task Creation Flow

Dashboard

↓

Quick Add

↓

Task Editor

↓

Title

↓

Category

↓

Priority

↓

Goal

↓

Milestone

↓

Estimated Time

↓

Save

↓

Animation

↓

Dashboard Refresh

↓

Analytics Refresh

---

# Task Session Flow (an instance of the generic Core Session Engine flow — RFC-005)

Tap Task

↓

Start Session (sessionType=Task, contextId=taskId) — Core Session Engine confirms no other session is active (RFC-005 §6)

↓

Timer Starts

↓

Session Screen

↓

Pause

↓

Resume

↓

Finish

↓

Reflection (generic: Focus/Energy/Difficulty/Notes/Need Review)

↓

Session marked Reflected

↓

Life Score Engine recomputes provisional score (RFC-003)

↓

Dashboard Refresh

Note: Workout Flow and Learning Flow (below) follow this exact same underlying engine flow with `sessionType=Workout` / `sessionType=Learning` respectively, plus their own module-specific reflection questions appended (Pain Level for Workout, Understanding for Learning).

---

# Reflection Flow

After every finished session:

Focus

1~10

↓

Energy

1~10

↓

Difficulty

1~10

↓

Notes

↓

Need Review?

↓

Save

↓

Analytics

---

# Workout Flow

Workout

↓

Select Routine

↓

Exercise List

↓

Exercise

↓

Set

↓

Rest Timer

↓

Next Exercise

↓

Finish Workout

↓

Workout Reflection

↓

Dashboard Update

---

# Exercise Flow

Open Exercise

↓

Set Counter

↓

Weight

↓

Reps

↓

Finish Set

↓

Rest

↓

Next Set

↓

Complete Exercise

---

# Learning Flow

Learning

↓

Choose Subject

↓

Choose Course

↓

Choose Chapter

↓

Start Session

↓

Study

↓

Reflection

↓

Need Review

↓

Save

---

# Nutrition Flow

Dashboard

↓

Add Meal

↓

Meal Type

↓

Food

↓

Calories

↓

Macros

↓

Water

↓

Save

↓

Dashboard Refresh

---

# Medicine Flow

Reminder

↓

Take Medicine

↓

Taken?

↓

Yes

↓

Timestamp Saved

↓

Analytics Updated

---

# Supplement Flow

Reminder

↓

Take Supplement

↓

Taken

↓

Timestamp

↓

Result Updated

---

# Water Flow

Quick Add

↓

+250ml

↓

Animation

↓

Daily Goal Update

---

# Journal Flow

Journal

↓

Today's Entry

↓

Reflection

↓

Lessons Learned

↓

Gratitude

↓

Save

↓

Result Updated

---

# Goal Flow

Goals

↓

Goal

↓

Milestone

↓

Project

↓

Task

↓

Session

↓

Completion

↓

Progress Update

---

# Search Flow

Search

↓

Typing

↓

Instant Results

↓

Filter

↓

Open Item

---

# Settings Flow

Settings

↓

Theme

↓

Language

↓

Backup

↓

Notifications

↓

Save

↓

Restart UI

---

# Export Flow (see RFC-007 for full detail)

Settings

↓

Export

↓

Choose: Plain JSON / Password-Protected Encrypted ZIP

↓

Generate JSON

↓

(If encrypted) Set backup password — app warns password is not recoverable

↓

Validation

↓

Export Success

---

# Import Flow (see RFC-007 §3 for full detail)

Import File

↓

Version Check

↓

Schema Check

↓

Integrity Check

↓

Reference Check (unresolved references nulled + flagged, not dropped)

↓

Preview (shows per-record conflicts if IDs already exist locally)

↓

Choose conflict resolution: Keep Local / Replace / Keep Both (default: Keep Local)

↓

Import

↓

Refresh Database

↓

Dashboard Refresh

---

# Daily Closing Flow

End Day

↓

Pending Tasks Review

↓

Reflection

↓

Daily Result Generated

↓

Life Score Calculated

↓

Stored

---

# Weekly Review Flow

Open Results

↓

Weekly Summary

↓

Charts

↓

Insights

↓

Weak Areas

↓

Next Week Planning

---

# Monthly Review Flow

Month Summary

↓

Goals Progress

↓

Learning Hours

↓

Workout Progress

↓

Life Score Trend

↓

Achievements

↓

Planning

---

# Error Flow

Action

↓

Failure

↓

Friendly Message

↓

Retry

↓

Recovered

---

# Offline Flow

Open App

↓

No Internet

↓

Everything Works Normally

---

# Golden UX Rules

Maximum 2 taps to start a session.

Maximum 5 taps to create a task.

Never lose user data.

Never interrupt user focus.

Always provide visual feedback.

Every completed action updates Dashboard automatically.

---

End of Document