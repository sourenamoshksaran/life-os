# RFC-001

Module: Dashboard

Document ID: RFC-DASHBOARD-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Critical

Owner: Core System

Amendment (v1.1): Command Center is confirmed as **Section 03 of the Dashboard**, not a separate screen or separate feature module. See §5 Section 03 below and `03_System_Architecture.md` §5/§14. This resolves the prior inconsistency between this RFC, `06_User_Flows.md`, and `08_Component_Library.md`.

Amendment (v1.1): "Mission Widget" / "Running Session" always reads the single active record from the **Core Session Engine** (`RFC-005_Core_Session_Engine.md`), regardless of whether it is a Task, Learning, Workout, or other session type. There is never more than one running session to disambiguate.

Amendment (v1.1): "Life Score" throughout this document refers to the canonical value stored on today's `Result` record (or a live provisional preview before Daily Closing), per `RFC-003_Life_Score_Engine.md`. Dashboard never reads a separately-maintained `LifeScore` entity.

---

# 1. Purpose

Dashboard is the heart of LifeOS.

It is not a Home Screen.

It is the user's Command Center.

Every important information should be visible without overwhelming the user.

Dashboard should answer these questions instantly:

• What should I do now?

• How am I performing today?

• What is my next priority?

• What needs attention?

---

# 2. Success Criteria

User understands today's situation within 3 seconds.

No scrolling required to view critical information.

Maximum two taps to start any important activity.

Dashboard loads under one second.

---

# 3. Primary User Story

As a user,

I want to open LifeOS

and immediately understand my entire day

without opening other pages.

---

# 4. Secondary User Stories

I want to

start a task

continue a session

check progress

see today's score

see today's workout

see learning progress

check medicine

track water

see today's schedule

all from one place.

---

# 5. Dashboard Sections

Sections are ordered by importance.

----------------------------------------------------

Section 01

Greeting

----------------------------------------------------

Displays

User Name

Current Time

Today's Date

Weather (Future)

Motivational Quote (Optional)

Adaptive Greeting

Examples

Good Morning

Good Afternoon

Good Evening

----------------------------------------------------

Section 02

Life Score

----------------------------------------------------

Circular Premium Widget

Displays

Current Score

Yesterday

Weekly Trend

Monthly Trend

Score Color

Tap

↓

Open Analytics

----------------------------------------------------

Section 03

Command Center (Mission Widget)

----------------------------------------------------

This section IS the "Command Center" referenced elsewhere in the spec. It is not a separate screen and does not appear in Bottom Navigation. It always renders as the top-priority section of the Dashboard, directly below Life Score.

Displays

Current Mission

Running Session

Remaining Time

Current Goal

Current Milestone

Current Project

Current Task

Tap

↓

Mission Mode

----------------------------------------------------

Section 04

Today's Focus

----------------------------------------------------

Top Three Priorities

Order

1

2

3

Swipe

Complete

Delay

Open

----------------------------------------------------

Section 05

Quick Actions

----------------------------------------------------

Buttons

Quick Task

Quick Workout

Quick Journal

Quick Learning

Quick Water

Quick Medicine

Quick Capture

Long Press

↓

Customization

----------------------------------------------------

Section 06

Progress Overview

----------------------------------------------------

Displays

Task Progress

Workout

Learning

Nutrition

Water

Medicine

Supplements

Sleep

----------------------------------------------------

Section 07

Timeline Preview

----------------------------------------------------

Shows

Completed

Running

Upcoming

Delayed

Maximum

5 items

Tap

↓

Timeline Page

----------------------------------------------------

Section 08

Health Summary

----------------------------------------------------

Calories

Water

Sleep

Workout

Medicine

Supplements

----------------------------------------------------

Section 09

Deep Work

----------------------------------------------------

Today's Deep Work

Best Session

Longest Session

Average Focus

----------------------------------------------------

Section 10

Insights

----------------------------------------------------

Generated from Analytics

Examples

You are more focused after workouts.

Sleep quality decreased.

Python sessions are improving.

Missed medicine yesterday.

----------------------------------------------------

Section 11

Daily Replay

----------------------------------------------------

Available after 18:00

Shows

Today's Summary

Life Score

Completed

Missed

Deep Work

Workout

Tomorrow Suggestion

----------------------------------------------------

# 6. Layout Rules

Dashboard is vertically scrollable.

Important widgets remain above the fold.

Maximum visible cards:

6

Never overload.

---

# 7. Responsive Rules

Phone

One Column

Tablet

Two Columns

Desktop

Adaptive Grid

---

# 8. Widget Priority

Priority Level

Critical

Mission

Life Score

Today's Focus

Running Session

Priority

High

Quick Actions

Timeline

Workout

Priority

Medium

Nutrition

Water

Medicine

Priority

Low

Quote

Achievements

Statistics

---

# 9. Empty States

No Tasks

↓

Suggest creating one.

No Workout

↓

Suggest today's workout.

No Learning

↓

Suggest learning session.

No Journal

↓

Suggest reflection.

---

# 10. Loading States

Skeleton UI

No spinner.

Widgets load independently.

---

# 11. Error States

Widget Failure

↓

Show only widget error.

Never fail entire Dashboard.

Retry available.

---

# 12. Interaction Rules

Tap

Open

Long Press

Quick Menu

Swipe

Dismiss

Pull

Refresh

---

# 13. Animation Rules

Dashboard Entry

Fade + Slide

Widgets

Fade

Progress

Animated

Mission

Pulse (Subtle)

Life Score

Smooth Ring Animation

Duration

180ms

---

# 14. Data Dependencies

Dashboard reads

Task Engine

Session Engine

Workout Engine

Learning Engine

Nutrition Engine

Medicine Engine

Analytics Engine

Life Score Engine

Result Engine

Never writes data directly.

---

# 15. Refresh Rules

Automatic refresh

Task Finished

Workout Finished

Medicine Taken

Learning Session End

Journal Saved

Water Added

Sleep Recorded

Manual Refresh also available.

---

# 16. Accessibility

Voice Labels

Large Text

RTL

Reduced Motion

Color Blind Safe

---

# 17. Performance

Initial Load

<1 second

Widget Refresh

<150ms

Scrolling

60 FPS

---

# 18. Acceptance Criteria

Dashboard loads correctly.

Mission widget always visible.

Life Score always accurate.

Quick Actions functional.

No visual overflow.

No duplicated widgets.

No frame drops.

---

# 19. Future Expansion

Weather

Calendar Sync

AI Suggestions

Apple Health

Google Fit

Wearables

Business Dashboard

Finance Dashboard

---

# 20. Golden Rule

Dashboard never tries to show everything.

Dashboard shows

only

what matters

right now.

---

End of Document