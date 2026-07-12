# Design System

Document ID: DS-001

Project: LifeOS

Version: 2.0 (Revised per PROJECT_AUDIT.md)

Status: Approved

---

# Purpose

This document defines the complete visual language of LifeOS.

No developer may invent new visual styles.

Every component must follow this Design System.

---

# Design Philosophy

LifeOS must feel like:

A premium operating system.

Not a productivity app.

Not a habit tracker.

Not a task manager.

The interface must communicate:

Calm

Precision

Authority

Clarity

Focus

Luxury

Technology

---

# Visual Identity

Keywords

Minimal

Premium

Elegant

Tactical

Editorial

Technical

Gaming Inspired

Apple Quality

Formula 1 Telemetry

Cyber Minimalism

---

# Color Palette

Primary

Burgundy

#6E2233

Primary Hover

#7F2A3C

Primary Active

#5A1A28

---

Background

#0E0E11

---

Surface

#17181C

---

Surface Variant

#202228

---

Card

#23252C

---

Border

#2D3038

---

Divider

#353840

---

Text Primary

#FFFFFF

---

Text Secondary

#B8BCC6

---

Text Disabled

#7D818A

---

Success

#22C55E

---

Warning

#F59E0B

---

Danger

#EF4444

---

Information

#3B82F6

---

Typography

Primary Font

SF Pro

Fallback

Inter

Persian

Vazirmatn

Fallback

IRANYekanX

---

Type Scale

Display

48

Headline

36

Title

28

Subtitle

22

Body Large

18

Body

16

Caption

14

Small

12

---

Grid System

Base Unit

8dp

Allowed spacing

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

80

96

---

Border Radius

Small

12

Medium

20

Large

28

Floating

32

---

Elevation

Level 0

Flat

Level 1

Very Soft Shadow

Level 2

Soft Shadow

Level 3

Floating

No heavy shadows.

---

Iconography

Package: Phosphor Icons (Outlined/Regular weight) — chosen for consistent 2px stroke width, broad coverage, and Flutter-native package support (`phosphor_flutter`). This is the single icon source; no other icon package or font may be mixed in.

Style

Outlined

Stroke Width

2

Default Size

24dp

Allowed Sizes

20

24

28

32

40

48

Never mix icon styles or icon packages.

---

Buttons

Primary

Filled

Accent Color

Rounded

Medium Height

---

Secondary

Outlined

---

Ghost

Transparent

---

Danger

Red Filled

---

Success

Green Filled

---

Loading

Spinner inside button

---

Disabled

Reduced opacity

---

Input Fields

Filled Style

Rounded

Label Always Visible

Support:

Prefix

Suffix

Helper

Validation

Error

Disabled

Loading

---

Cards

Padding

16

Radius

20

Border

1px

Background

Surface

Optional Glass Effect

---

Lists

Support

Swipe

Reorder

Selection

Search

Grouping

Sorting

Filtering

---

Progress

Linear

Circular

Ring

Segmented

Animated

---

Charts

Line

Bar

Radar

Heatmap

Circular

Donut

---

Animation

General Duration

180ms

Fast

120ms

Slow

250ms

Curve

Ease Out

---

Motion Principles

Movement must explain change.

Never decorate.

Never distract.

---

Glass Effect

Opacity

8%

Blur

18

Border

1px White 6%

Shadow

Soft

---

Haptic

Light

Selection

Medium

Complete

Heavy

Danger

---

Illustration Style

Flat

Minimal

Monochrome

Accent Burgundy

---

Photography

Avoid stock photos.

Prefer illustration.

---

Spacing Rules

Content Padding

24

Card Gap

16

Section Gap

32

Screen Margin

20

---

Dark Mode

Primary Experience

---

Light Mode

Optional

Identical hierarchy

---

Accessibility

WCAG AA

Minimum Contrast

4.5

Every color pair in this document's palette (Primary on Background, Text Secondary on Card, Danger on Background, etc.) must be run through an automated contrast checker as part of CI before release; any pair failing 4.5 is adjusted before merge, not assumed compliant.

Dynamic Font

Supported

Reduced Motion

Supported

RTL

Fully Supported

---

# Localization Format

Translation strings stored as ARB files (`app_fa.arb`, `app_en.arb`), consumed via Flutter's built-in `gen-l10n` tooling. Persian (`fa`) is the primary/default locale; English (`en`) is secondary. No hardcoded strings permitted in any widget (see `CLAUDE.md` Forbidden Patterns).

---

Responsive Breakpoints

Phone

Tablet

Desktop

Future Foldables

---

Component Naming

ButtonPrimary

ButtonSecondary

TaskCard

WorkoutCard

GoalCard

LifeScoreRing

ProgressRing

GlassCard

CommandTile

MissionCard

ResultCard

InsightCard

AnalyticsChart

---

Design Principles

Consistency

Predictability

Hierarchy

Feedback

Minimalism

Focus

Purpose

Performance

Accessibility

---

Golden Rule

If a component does not improve clarity,

it should not exist.

---

End of Document