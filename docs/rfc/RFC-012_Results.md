# RFC-012

Module: Results

Document ID: RFC-RESULTS-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Core System

Depends on: RFC-003 (Life Score Engine)

---

# 1. Purpose

Defines the Results screen — the user-facing view of the canonical `Result` entity — and the Daily Closing Flow that finalizes each day's record.

# 2. User Stories

- As a user, I see my Daily/Weekly/Monthly/Yearly summary with Life Score and its components.
- As a user, I go through a short Daily Closing ritual at day's end that finalizes today's Result.
- As a user, I compare periods (this week vs. last week).

# 3. Data Model

Reads exclusively from `Result` (RFC-003 §6). No independent Results-owned entity — this is a read + finalize screen over the canonical record.

# 4. State Machine (Daily Closing Flow)

`Provisional` (auto-computed live all day) → user opens Daily Closing → reviews components → adds optional daily note → `Finalized` (`isProvisional=false`, `Result` record locked for that `localDate`).

A Finalized Result may still be viewed but is not recomputed automatically; correcting a Finalized day requires an explicit "Reopen Day" action (logged, not silent).

# 5. Validation Rules

- Only one `Result` per `(localDate, period=Daily)` pair — enforced at the repository layer.
- Weekly/Monthly/Yearly `Result` records are generated only from `Finalized` Daily records within their range; a period containing any still-Provisional day shows as "Partial" until all its days are finalized.

# 6. Acceptance Criteria

✓ Results screen never computes its own score — always reads `Result`.
✓ Daily Closing Flow is skippable (a day with no explicit closing auto-finalizes at local midnight using its last live-provisional value).
✓ Period comparison (week-over-week etc.) is a simple diff of two `Result` records, not a recomputation.

# 7. Error Handling & Edge Cases

- App not opened for several days: on next open, all skipped days auto-finalize using end-of-day provisional snapshots taken by a background-safe recompute at app-open time (no true background execution assumed, per iOS limitations noted in RFC-006 §3).
- Reopening a Finalized day and changing underlying data (e.g., editing a Task's completion after the fact): triggers recompute and re-finalization, with a visible "edited" badge.

# 8. Performance Requirements

Results screen with 365 days of history loads and scrolls at 60fps using lazy pagination (matches `04A_Data_Modeling_Strategy.md` Lazy Loading).

# 9. Accessibility Requirements

Life Score component breakdown is available as a table/list view, not only as a chart, for screen-reader users.

# 10. Testing Requirements

Integration test: full Daily Closing Flow → verify Result finalized → verify Weekly aggregate updates once all 7 days finalized.

# 11. Future Expansion

Custom date-range comparison (deferred to Analytics detail RFC).

# 12. Golden Rule

Results never lies about being final — Provisional vs. Finalized is always visibly distinguished.

---

End of Document
