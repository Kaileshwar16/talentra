# Talentra Phase 3: Commercial Access, Sourcing & Financial Ledger (Modules 7–9)

Phase 3 implements the commercial lifecycle, seat licensing, sourcing pools, external consultant workflows, wallet balances, immutable ledger transactions, and profile download billing across Milestones 11–13 of the [hackathon docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf).

## Module Scope

### Module 7 — Plans, Licences, Seats, Devices and Sessions
- **Subscription Plans**: Tier-based pricing models, billing cycles (`MONTHLY`, `QUARTERLY`, `ANNUAL`), seat allocations, job posting quotas, resume download credit allowances, and device limits per seat.
- **Account Subscriptions**: Active tenant subscription lifecycle, current period validity windows, auto-renewal toggles, and payment method tokens.
- **Licence Pools & Seats**: Licence keys, seat allocations, and effective-dated user seat assignments (`licence_seat_assignment`) with exclusion constraints preventing overlapping active seat assignments for the same user.
- **Device Sessions**: Tracking authenticated client devices, browser fingerprints, hardware types, IP addresses, session token digests, and revocation metadata.

### Module 8 — Sourcing, Consultant Requests & Recruiter Workflows
- **Talent Sourcing Pools**: Custom organization-owned candidate pools (`sourcing_pool`) with private/shared visibility flags.
- **Pool Candidate Tagging**: Direct candidate assignments to pools (`sourcing_pool_candidate`), attribution channels (`DIRECT_SEARCH`, `CONSULTANT_SUBMISSION`, `REFERRAL`, `TALENT_POOL`), and AI match scores.
- **Consultant Requests**: Formal staffing contracts (`consultant_request`) associating job requirements with external recruitment agencies/consultants, negotiated commission rates, validity windows, and approval status lifecycles.

### Module 9 — Subscriptions, Wallets, Payments, Finance & Download History
- **Prepaid Wallet Accounts**: Tenant credit balances (`wallet_account`) with strict non-negative constraints and currency references.
- **Immutable Financial Ledger**: Append-only transaction ledger (`wallet_transaction_ledger`) recording credit purchases, plan grants, debits for candidate resume downloads, refunds, and adjustments. Enforces idempotency via `idempotency_key` and rejects `UPDATE`, `DELETE`, or `TRUNCATE` operations via the `talentra_reject_mutation()` trigger.
- **Payment Transactions**: Gateway transaction tracking (`payment_transaction`) integrating Stripe/Razorpay external references, payment statuses (`INITIATED`, `SUCCEEDED`, `FAILED`, `REFUNDED`), and unique idempotency keys.
- **Profile Download Events**: Immutable audit records (`profile_download_event`) logging recruiter access to candidate resumes, download formats (`PDF`, `DOCX`, `JSON`), IP addresses, and user agents.

---

## Deliverables & Evidence

| Module | Entity | Schema | Purpose & Constraint Evidence |
| --- | --- | --- | --- |
| 7 | `subscription_plan` | `public` | Tiered commercial plans, billing periods, credit allowances |
| 7 | `account_subscription` | `public` | Tenant subscription periods, renew status |
| 7 | `account_licence` | `public` | Licence key allocations, valid period |
| 7 | `licence_seat_assignment` | `public` | User seat assignments, exclusion constraint on overlapping active windows |
| 7 | `device_session` | `public` | Device fingerprinting, unique session token hashes, expiry |
| 8 | `sourcing_pool` | `public` | Private candidate sourcing pools tied to organisations |
| 8 | `sourcing_pool_candidate` | `public` | Candidate pool memberships with sourcing attribution |
| 8 | `consultant_request` | `public` | External recruiter job commission agreements |
| 9 | `wallet_account` | `public` | Prepaid credit balances (balance >= 0) |
| 9 | `wallet_transaction_ledger` | `public` | Append-only ledger; `talentra_reject_mutation()` prevents mutation |
| 9 | `payment_transaction` | `public` | Gateway payments with unique idempotency keys |
| 9 | `profile_download_event` | `public` | Append-only resume download logs; immutable via trigger |

---

## Migration & Test Execution

### Applied Migrations
1. `phase3/migrations/004_phase3.sql` (SHA-256 verified)

### Automated Test Suite
- `phase3/tests/phase3_constraints.sql`: 20 automated assertion checks validating:
  - Plan creation and unique plan code enforcement
  - Account subscription period validity
  - Licence seat assignment window checks
  - Device session token uniqueness
  - Sourcing pool candidate tagging and match scores
  - Consultant request status lifecycle
  - Wallet non-negative balance checks
  - Append-only immutability of `wallet_transaction_ledger` (`ERRCODE 55000`)
  - Unique transaction idempotency keys
  - Append-only immutability of `profile_download_event` (`ERRCODE 55000`)
- **Outcome**: 20/20 checks passed with zero fixture leakage (100% rollback).
