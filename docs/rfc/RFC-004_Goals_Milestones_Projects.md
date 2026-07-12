# RFC-004

Module: Goals, Milestones & Projects

Document ID: RFC-GOALS-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Critical (Task Management depends on this hierarchy)

Owner: Core Productivity

---

# 1. Purpose

`RFC-002_Task_Management.md` assumes a Goal → Milestone → Project → Task hierarchy already exists (Tasks reference `goalId`, `milestoneId`, `projectId`). This RFC formally specifies that hierarchy, which was previously only implied by `04_Database_Schema.md`'s Entity Relationships section.

---

# 2. Hierarchy Rule

User → Goal → Milestone → Project → Task → Session

- A **Goal** may contain multiple Milestones.
- A **Milestone** may contain multiple Projects.
- A **Project** may contain multiple Tasks.
- A **Task** may contain unlimited Sessions (via Core Session Engine, RFC-005).

**Flexibility rule:** intermediate levels are optional. A Task may link directly to a Goal with no Milestone/Project, or directly to a Project with no Milestone, etc. `goalId`, `milestoneId`, and `projectId` on Task are all independently nullable — the hierarchy is a convenience for organization, not a mandatory chain. This matches the product's "minimal friction" UX principle from `05_UI_UX_Specification.md`.

---

# 3. Progress Rollup Rule

- **Project.progress** = completed Task count ÷ total Task count within that Project (0–100%).
- **Milestone.progress** = average of its Projects' progress (weighted equally, unless a Milestone has directly-attached Tasks with no Project, which count as their own 100%/0% unit alongside Projects).
- **Goal.progress** = average of its Milestones' progress.

Progress is recomputed reactively whenever a Task's status changes to/from `Completed` (see updated Task Status enum in `04_Database_Schema.md`), not on a timer.

---

# 4. Goal Entity (finalized fields)

id, title, description, targetDate, progress, priority, icon, color, status (`Active/Completed/Abandoned`), completed, localDate (creation day, for correlation), + Global Fields

# 5. Milestone Entity (finalized fields)

id, goalId (nullable), title, progress, deadline, completed, order, + Global Fields

# 6. Project Entity (finalized fields)

id, milestoneId (nullable), goalId (nullable — for Projects attached directly to a Goal), title, description, progress, status (`Active/OnHold/Completed/Cancelled`), deadline, order, + Global Fields

---

# 7. Deletion Rule

Deleting a Goal/Milestone/Project does not cascade-delete its children by default. Children are **orphaned upward**: their parent-link field is set to `null` and the user is shown a non-blocking notice ("3 tasks were unlinked from the deleted goal"). This matches `04_Database_Schema.md`'s existing rule: *"Restrict deletion if linked records exist"* is reinterpreted here specifically as "warn and unlink," not "block deletion" — since blocking would conflict with the product's low-friction philosophy. Hard/cascading delete is available as an explicit secondary confirmation ("Delete this Goal and all its Milestones, Projects, and Tasks?").

---

# 8. Acceptance Criteria

✓ Task can attach to any subset of Goal/Milestone/Project, including none.

✓ Progress rolls up automatically and reactively at every level.

✓ Deleting a parent never silently deletes children; it unlinks with a visible notice, unless the user explicitly opts into cascading delete.

---

# 9. Golden Rule

The hierarchy exists to give Tasks meaning, not to force structure on the user. A Task with no Goal is always valid.

---

End of Document
