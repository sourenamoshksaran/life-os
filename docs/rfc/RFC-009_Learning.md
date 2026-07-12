# RFC-009

Module: Learning

Document ID: RFC-LEARNING-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Growth Modules

Depends on: RFC-005 (Core Session Engine)

---

# 1. Purpose

Defines the Learning module — subjects/courses/chapters/lessons — and its integration with the Core Session Engine as `sessionType=Learning`.

# 2. User Stories

- As a user, I organize learning material into Subject → Course → Chapter → Lesson.
- As a user, I start a Learning Session against a specific Lesson (or freeform).
- As a user, I rate my understanding after a session so weak areas surface later.

# 3. Data Model

`LearningTopic` (reference entity, per RFC-005 §3): id, subject, course, chapter, lesson, resource, order + Global Fields.

Learning-specific reflection fields (`understanding` 1–10, `reviewNeeded` boolean) are stored as a typed extension of `Session.reflectionNote` (RFC-005 §8), not a separate table.

# 4. State Machine

Identical to the generic Core Session Engine lifecycle (RFC-005 §4). No module-specific states.

# 5. Validation Rules

- `understanding` required at Reflection; if < 4, `reviewNeeded` auto-defaults to true (user can override).
- A `LearningTopic` must have a `subject` at minimum; `course/chapter/lesson` are optional nesting.

# 6. Acceptance Criteria

✓ Starting a Learning session enforces single-active-session rule (RFC-005 §6).
✓ Topics with `reviewNeeded=true` surface in a "Needs Review" list on the Learning screen.
✓ Learning time aggregates correctly into the Life Score Learning component (RFC-003 §3).

# 7. Error Handling & Edge Cases

- Freeform Learning session (no `LearningTopic` selected): allowed, `contextId=null`, still contributes learning-minutes to Life Score.
- Deleting a `LearningTopic` that has past Sessions: Sessions are not deleted; `contextId` is nulled and the Session retains its historical minutes (matches the orphan-unlink rule in RFC-004 §7).

# 8. Performance Requirements

Topic tree (Subject→Course→Chapter→Lesson) renders in < 250ms for up to 500 lessons (lazy-loaded per level).

# 9. Accessibility Requirements

Understanding rating uses an accessible 1–10 slider with numeric announcement, not color-only feedback.

# 10. Testing Requirements

Unit tests for review-needed auto-flagging logic. Integration test: full Learning Session → low understanding rating → verify item appears in Needs Review list.

# 11. Future Expansion

Spaced-repetition scheduling based on `reviewNeeded` history (deferred, needs its own RFC).

# 12. Golden Rule

Learning is just a Session with a topic attached — timing is never reimplemented here.

---

End of Document
