# Component Library

Document ID: UI-DS-002

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# Purpose

This document defines every reusable UI component.

No screen shall create custom UI before checking this library.

Every component must be reusable.

Every component must be stateless whenever possible.

Every component must support Dark Mode.

Every component must support RTL.

---

# Component Categories

LifeOS components are divided into:

• Foundation

• Navigation

• Inputs

• Data Display

• Feedback

• Layout

• Dashboard

• Analytics

• Cards

• Dialogs

• Sheets

• Charts

• Timers

• Special Components

---

====================================================

FOUNDATION COMPONENTS

====================================================

## AppScaffold

Purpose

Root scaffold of every screen.

Contains

Safe Area

Background

Navigation

Floating Elements

Keyboard Handling

Loading Layer

Notification Layer

---

## GlassCard

Purpose

Premium card.

Properties

Title

Subtitle

Child

Padding

Border

Shadow

Radius

Clickable

Loading

Disabled

---

## SectionHeader

Contains

Title

Subtitle

Action Button

Optional Badge

---

## Divider

Types

Normal

Inset

Vertical

Dashed

---

## Spacer

Allowed values

4

8

12

16

20

24

32

40

48

64

---

====================================================

BUTTON COMPONENTS

====================================================

PrimaryButton

SecondaryButton

GhostButton

DangerButton

SuccessButton

IconButton

FAB

SegmentButton

ChipButton

FilterChip

ActionChip

Each button supports

Loading

Disabled

Pressed

Focused

Hovered

Selected

---

====================================================

INPUT COMPONENTS

====================================================

TextField

SearchField

PasswordField

NumberField

DatePicker

TimePicker

Slider

Stepper

Dropdown

Checkbox

Radio

Switch

Tag Selector

Color Picker

--- v1 scope ends here ---

Deferred to post-v1 (do not implement until a future RFC scopes them):

Emoji Picker

Voice Input

---

====================================================

TASK COMPONENTS

====================================================

TaskCard

Displays

Priority

Category

Duration

Deadline

Progress

Status

Tags

Quick Actions

Supports

Swipe

Long Press

Drag

Animation

---

TaskTile

Compact version

---

TaskGroup

Group by

Date

Priority

Category

Goal

Project

---

====================================================

SESSION COMPONENTS (Generic — powers Task, Workout, Learning, and every future module via Core Session Engine, RFC-005)

====================================================

SessionCard

Contains

Timer

Focus

Energy

Progress

Pause

Resume

Finish

Renders identically regardless of `sessionType`; only the header icon/label and any module-specific reflection extension differ.

---

MissionWidget

Displays

Current Mission (reads the single active Session from Core Session Engine, whatever its `sessionType`)

Remaining Time

Current Goal

Life Score (from Result, or live provisional preview — see RFC-003)

---

FocusTimer

Supports

Start

Pause

Resume

Finish

Lap

Reused by every module that starts a Session — never re-implemented per module.

---

====================================================

WORKOUT COMPONENTS

====================================================

WorkoutCard

ExerciseCard

SetCounter

WeightSelector

RepCounter

RestTimer

WorkoutProgress

MuscleGroupSelector

---

====================================================

LEARNING COMPONENTS

====================================================

CourseCard

LessonCard

StudyTimer

DifficultySelector

UnderstandingMeter

ReviewFlag

---

====================================================

NUTRITION COMPONENTS

====================================================

MealCard

MacroChart

WaterTracker

CalorieRing

NutritionSummary

---

====================================================

MEDICINE COMPONENTS

====================================================

MedicineCard

MedicineReminder

SupplementCard

DoseSelector

TakenButton

ScheduleWidget

---

====================================================

GOAL COMPONENTS

====================================================

GoalCard

MilestoneCard

ProjectCard

ProgressRing

CompletionBar

TimelineView

---

====================================================

RESULT COMPONENTS

====================================================

DailySummaryCard

WeeklySummaryCard

MonthlySummaryCard

AchievementCard

LifeScoreCard

ReflectionCard

InsightCard

RecommendationCard

---

====================================================

ANALYTICS COMPONENTS

====================================================

LineChart

BarChart

RadarChart

DonutChart

Heatmap

ConsistencyChart

FocusChart

WorkoutChart

LearningChart

SleepChart

NutritionChart

---

====================================================

COMMAND CENTER COMPONENTS (Dashboard Section 03 — not a separate screen; see rfc/RFC-001_Dashboard.md §5)

====================================================

MissionCard

QuickLaunch

PriorityWidget

Today's Focus

EnergyMeter

LifeScoreRing

Today's Progress

Upcoming Widget

Deep Work Widget

Quick Capture Button

---

====================================================

LAYOUT COMPONENTS

====================================================

AdaptiveGrid

AdaptiveList

AdaptiveColumn

AdaptiveRow

ResponsiveContainer

GlassContainer

AnimatedContainer

---

====================================================

FEEDBACK COMPONENTS

====================================================

SnackBar

Toast

Success Banner

Warning Banner

Error Banner

Loading Overlay

Progress Overlay

Empty State

Offline Banner

---

====================================================

DIALOG COMPONENTS

====================================================

Confirmation Dialog

Delete Dialog

Export Dialog

Import Dialog

Error Dialog

Success Dialog

Bottom Sheet

Action Sheet

Selection Sheet

---

====================================================

SPECIAL COMPONENTS

====================================================

LifeScoreRing

MissionMode

CommandCenter

QuickCapture

DailyReplay

WeeklyReview

MonthlyReview

StreakCounter

XPBar

AchievementPopup

---

====================================================

COMPONENT STATES

Every component supports

Idle

Loading

Disabled

Selected

Focused

Error

Success

Empty

Offline

---

====================================================

ACCESSIBILITY

Every component must support

RTL

Dynamic Fonts

Screen Readers

High Contrast

Reduced Motion

Keyboard Navigation (Future)

---

====================================================

PERFORMANCE

No unnecessary rebuilds

const widgets whenever possible

Lazy loading

Widget caching

Animation optimization

Image caching

---

====================================================

REUSABILITY RULES

No duplicated components.

No hardcoded colors.

No hardcoded text.

No hardcoded spacing.

No hardcoded radius.

Everything must use Design Tokens.

---

====================================================

GOLDEN RULE

If two screens use the same UI twice,

it becomes a reusable component.

Never duplicate UI.

Always extract.

---

End of Document