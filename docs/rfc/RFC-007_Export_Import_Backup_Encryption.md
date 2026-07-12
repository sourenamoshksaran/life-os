# RFC-007

Module: Export, Import, Backup & Encryption

Document ID: RFC-DATA-001

Project: LifeOS

Version: 1.0

Status: Approved

Priority: Important

Owner: Core System

---

# 1. Purpose

Resolves Important Improvement 2.5: the prior spec mentioned "optional local encryption" (SRS) and "encrypted ZIP backup" (DB Schema) without clarifying whether these are the same mechanism, what algorithm is used, or where keys are stored.

---

# 2. Two Distinct, Related Mechanisms

1. **At-Rest Database Encryption (optional, Settings toggle, off by default in v1)**
   Uses Isar's native AES-256 encryption support. The encryption key is generated on first enable and stored in the platform secure enclave (iOS Keychain / Android Keystore) — never in the exported JSON, never in application code, never recoverable by Anthropic or any third party since nothing leaves the device.

2. **Backup Encryption (Export → ZIP, optional, prompted at export time)**
   The JSON export is always the standard, unencrypted interchange format described in `01_Project_Overview.md` ("Export Philosophy: JSON"). When the user chooses "Export as encrypted backup," LifeOS wraps that same JSON inside a **password-protected ZIP (AES-256, via a standard ZIP-crypto library)** using a password the user sets at export time — not the same key as #1. This backup password is never stored by the app; losing it means losing access to that specific backup file (the user is warned explicitly before export).

These two mechanisms are independent and both optional. Enabling one does not require the other.

---

# 3. Import Validation Pipeline

Import JSON → Version Check → Schema Check → Integrity Check → Reference Check → Preview → Confirm → Import → Refresh Database

- **Version Check**: compares the export's `schemaVersion` against the app's current version; if older, runs the same migration scripts used for in-place upgrades (see `04A_Data_Modeling_Strategy.md` Migration Rules) before import.
- **Reference Check**: any Task/Session/etc. referencing a `goalId`/`projectId`/etc. not present in the import file is imported with that reference set to `null` and flagged in the Preview screen, rather than silently dropped or failing the whole import.
- **Conflict Rule**: if an imported entity's `id` already exists locally, the import screen shows a per-conflict choice: **Keep Local / Replace with Imported / Keep Both** (duplicating the imported one with a new id). Default bulk action is "Keep Local" to avoid accidental overwrite.

---

# 4. Acceptance Criteria

✓ At-rest encryption and backup encryption are documented as two independent, clearly-named mechanisms.

✓ Key storage uses platform secure enclave; backup passwords are never stored by the app.

✓ Import conflict resolution is explicit, not silent.

---

End of Document
