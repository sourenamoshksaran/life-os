# RFC-013

Module: Analytics

Document ID: RFC-ANALYTICS-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important (MVP)

Owner: Core System

Depends on: RFC-003 (Life Score Engine), RFC-005 (Core Session Engine, `localDate` correlation key)

---

# 1. Purpose

Defines the Analytics Engine's read/correlation behavior and the Analytics screen — the surface for cross-module insight described in `01_Project_Overview.md`'s "Everything is Connected" principle.

# 2. User Stories

- As a user, I see trend charts (Life Score, sleep, focus) over selectable ranges.
- As a user, I see plain-language insights (e.g., "Low sleep days correlate with lower focus scores") based on my own data.
- As a user, I trust that insights are never shown from too little data.

# 3. Data Model

Reads from `Result` (for score trends) and raw entities joined by `localDate` (for correlation insights): `Session` (focus/energy), `SleepLog`, `NutritionEntry`, `MedicineLog`. May materialize `AnalyticsSnapshot` as a non-authoritative cache (RFC-003 §6) for chart performance — always regenerable, never exported.

# 4. State Machine

N/A — Analytics is a read/compute-only module with no user-editable state.

# 5. Validation Rules / Insight Thresholds

- A correlation insight requires **minimum 7 days** of paired data points (matches `CLAUDE.md` §16) before it is surfaced.
- Correlation strength is computed via simple Pearson correlation on the two `localDate`-joined series; insights are only shown when |r| ≥ 0.4, to avoid overstating weak relationships.
- Insight copy is templated ("Your [X] tends to be lower on days with less [Y]") and always includes the sample size shown to the user, never a bare unqualified claim.

# 6. Acceptance Criteria

✓ No insight ever appears with fewer than 7 paired data points.
✓ Every insight is traceable — tapping it shows the underlying data points, not just the conclusion.
✓ Charts render from cached `AnalyticsSnapshot` when available, falling back to live computation with a loading skeleton when not.

# 7. Error Handling & Edge Cases

- Sparse data (e.g., only 3 days of Sleep logged in a 30-day range): chart renders with visible gaps, not interpolated/fabricated values.
- Conflicting correlations across overlapping ranges: each range computes independently; no smoothing across range boundaries.

# 8. Performance Requirements

Correlation computation for a 90-day range completes in < 500ms, run via `compute()` isolate (never blocks UI thread, per `CLAUDE.md` §5).

# 9. Accessibility Requirements

All charts (FL Chart-based) provide an accessible data-table fallback view.

# 10. Testing Requirements

Unit tests for the correlation threshold logic (7-day minimum, |r|≥0.4 gate). Unit tests for insight-copy templating with edge-case sample sizes (exactly 7, 6, 0).

# 11. Future Expansion

Multi-variable correlation (3+ factors), user-defined custom insight queries — deferred, needs its own RFC given local-only compute constraints.

# 12. Golden Rule

An insight the user can't verify against their own data is not an insight — it's a claim. Analytics always shows its work.

---

End of Document
