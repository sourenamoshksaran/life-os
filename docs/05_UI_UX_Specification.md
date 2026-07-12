# UI / UX Specification

Document ID: UI-001

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# Purpose

This document defines every UI and UX rule of LifeOS.

Developers must never make visual decisions independently.

All visual behaviors must comply with this specification.

---

# Design Philosophy

LifeOS is not a ToDo application.

LifeOS is a Personal Operating System.

Every screen must feel like a premium control center.

Users should experience:

• Calm

• Focus

• Clarity

• Precision

• Confidence

---

# Design Keywords

Minimal

Premium

Modern

Functional

Elegant

Technical

Editorial

Cyber

Gaming Inspired

Formula 1 Telemetry

Apple Level Polish

---

# Interface Rules

No visual clutter.

No unnecessary cards.

No decorative elements without purpose.

Every pixel must provide value.

---

# Layout System

Grid: 8pt

Spacing:

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

# Safe Area

Every screen must fully respect:

Status Bar

Navigation Bar

Dynamic Island

Camera Cutout

Gesture Area

---

# Screen Structure

Header

↓

Content

↓

Floating Actions (Optional)

↓

Bottom Navigation

---

# Navigation

Persistent Bottom Navigation

Five Tabs:

Dashboard

Tasks

Timeline

Results

Life Designer

---

# Header

Each screen contains:

Title

Optional Subtitle

Quick Search

More Menu

---

# Cards

Cards must have:

Rounded Corners

Soft Shadow

Subtle Border

Padding 16

No heavy elevation

---

# Buttons

Primary Button

Filled

Accent Color

Secondary Button

Outlined

Text Button

Ghost Button

Danger Button

Success Button

Disabled State

Loading State

---

# Input Fields

Rounded

Filled

Clear Label

Validation

Helper Text

Error State

Focus State

---

# Lists

Support:

Swipe

Drag

Reorder

Multi Select

Search

Grouping

Filtering

Sorting

---

# Empty States

Every module requires:

Illustration

Description

Action Button

---

# Loading States

Skeleton Loader

Never use spinning indicators for full pages.

---

# Error States

Friendly Message

Retry Button

Technical details hidden.

---

# Animations

Purposeful only.

Maximum Duration:

250 ms

Minimum:

120 ms

Use:

Fade

Scale

Slide

Shared Axis

Never overuse.

---

# Gestures

Tap

Double Tap

Long Press

Swipe

Drag

Pinch (Future)

---

# Typography Hierarchy

Display

Headline

Title

Body

Caption

Label

Button

---

# Color Usage

Primary

Burgundy

Secondary

Graphite

Background

Near Black

Surface

Dark Gray

Success

Green

Warning

Amber

Danger

Red

Information

Blue

---

# Icons

Outlined Style

Consistent Stroke Width

24dp Default

Never mix icon families.

---

# Dashboard Layout

Contains:

Greeting

Life Score

Today's Focus

Current Session

Progress Rings

Quick Actions

Today's Tasks

Workout

Learning

Nutrition

Water

Medicine

Supplement

Quote

---

# Tasks Screen

Contains:

Search

Filter

Sort

Task List

Quick Add

Categories

Today's Progress

---

# Timeline

Vertical Timeline

Grouped by Time

Supports:

Completed

Missed

Running

Upcoming

---

# Results Screen

Daily Summary

Weekly Summary

Monthly Summary

Charts

Statistics

Reflection

Life Score History

Achievements

---

# Life Designer

Contains:

Workout Builder

Routine Builder

Learning Builder

Task Templates

Theme Settings

Goals

Milestones

Amendment: The former "Plugins" entry is removed from v1 scope. It named-collided with the internal "Module Lifecycle Interface" pattern in `03_System_Architecture.md` §17 and implied a user-facing extension marketplace, which has no RFC and is in tension with the offline/no-network security posture. A user-facing extensibility feature may return in a future version once it has its own RFC with a name that doesn't collide (e.g. "Custom Modules").

---

# Search

Global Search

Instant Results

Highlight Matches

Recent Searches

---

# Command Center

Amendment: Command Center is **Section 03 of the Dashboard** (see `rfc/RFC-001_Dashboard.md` §5), not a separate screen, not a bottom-navigation tab, and not a distinct feature module. Any prior reference implying otherwise (e.g. in `06_User_Flows.md`'s old Main Navigation Flow) has been corrected.

Top priority widget within the Dashboard.

Shows:

Current Mission (from Core Session Engine's active Session, if any)

Focus Timer

Next Task

Remaining Time

Life Score (from today's Result, or live provisional preview)

Energy

---

# Mission Mode

Distraction Free.

Only displays:

Current Task

Timer

Checklist

Notes

Exit Button

Everything else hidden.

---

# Notification Style

Minimal

Silent by default.

Grouped.

Action buttons supported.

---

# Dialog Rules

Maximum two primary actions.

Clear title.

No unnecessary confirmation.

---

# Bottom Sheets

Preferred over dialogs.

Support drag.

Rounded top corners.

---

# Accessibility

Dynamic Text

RTL Support

High Contrast

Reduced Motion

Screen Reader Labels

---

# Responsive Design

Must support:

Small Phones

Large Phones

Foldables

Tablets

Desktop (Future)

---

# Microinteractions

Every important action provides feedback:

Haptic

Animation

Visual Confirmation

---

# UX Principles

Less thinking.

Less tapping.

Less waiting.

More clarity.

More confidence.

More focus.

---

# Golden Rule

Users should never wonder:

"What should I do next?"

The interface must always answer that question.

---

End of Document