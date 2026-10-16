# Talentra Phase 3: Commercial Access, Sourcing & Financial Ledger (Modules 7–9)

Phase 3 implements commercial licensing, seat allocations, hardware device registration, candidate sourcing pools, outreach campaigns, consultant agency mandates, customer invoicing, payment refunds, prepaid wallet ledgers, and profile download billing across Milestones 11–13 of the hackathon docket and backlog requirements **B36–B47**.

---

## 1. Module Scope & Entities (18 Tables)

### Module 7 — Plans, Licences, Seats, Devices and Sessions (6 Entities)
- **`subscription_plan`**: Tiered commercial offerings (`FREE`, `GROWTH`, `ENTERPRISE`), billing periods (`MONTHLY`, `QUARTERLY`, `ANNUAL`), seat quotas, job posting allowances, resume download credits, and max devices per seat.
- **`account_subscription`**: Tenant subscription lifecycles, active period temporal boundaries (`current_period_starts_at`, `current_period_ends_at`), auto-renewal toggles, and overlap prevention (`trg_check_sub_no_overlap`).
- **`account_licence`**: Commercial licence keys, allocated seat quotas, validity intervals, and per-user device caps (`max_devices_per_user`).
- **`licence_seat_assignment`**: User seat assignments with role delegations (`RECRUITER`, `HIRING_MANAGER`), seat capacity quota triggers (`check_licence_seat_limit`), and partial unique indexes (`uq_licence_seat_active`) supporting historical re-assignment after deactivation.
- **`user_device` (NEW — B36/B37)**: Registered client devices per user account with hardware fingerprints, device types, trusted flags, revocation timestamps, and per-licence device-cap enforcement triggers (`check_user_device_limit`).
- **`device_session`**: Active user login sessions with secure session token hashes, client device links (`user_device_id`), and expiry timestamps.

### Module 8 — Sourcing, Consultant Requests & Recruiter Workflows (6 Entities)
- **`sourcing_pool`**: Private organizational candidate sourcing pools with target role classifications and access permissions.
- **`sourcing_pool_candidate`**: Candidate memberships in sourcing pools with acquisition channels (`DIRECT_SEARCH`, `REFERRAL`, `CONSULTANT_SUBMISSION`) and match scores.
- **`sourcing_outreach_batch` (NEW — B38)**: Recruiter-initiated outreach campaigns directed at talent pool segments, recording communication channels (`EMAIL`, `SMS`, `IN_APP`, `LINKEDIN`, `WHATSAPP`), templates, scheduled times, and aggregate metrics.
- **`sourcing_outreach_recipient` (NEW — B39)**: Per-candidate delivery and engagement tracking records (`PENDING`, `SENT`, `DELIVERED`, `OPENED`, `CLICKED`, `REPLIED`, `OPT_OUT`, `FAILED`), candidate responses, and external gateway message IDs.
- **`consultant_request`**: Staffing mandates connecting job requirements to external recruitment agencies, with negotiated commission percentages (`chk_cr_commission_rate` [0, 100]) and eligibility verification (`trg_check_consultant_job_eligibility`).
- **`consultant_request_decision` (NEW — B40)**: Immutable decision history log (`ACCEPTED`, `DECLINED`, `REVOKED`, `REINSTATED`) capturing decision makers, rationales, and timestamps with trigger-enforced append-only protection.

### Module 9 — Subscriptions, Wallets, Payments, Finance & Download History (6 Entities)
- **`wallet_account`**: Prepaid tenant credit accounts with non-negative balance constraints (`balance_credits >= 0`) and currency references.
- **`wallet_transaction_ledger`**: Append-only transactional financial ledger recording credit grants, purchases, debits, adjustments, and refunds. Enforces idempotency via unique `idempotency_key` (B43) and immutability via `talentra_reject_mutation()` (B44).
- **`payment_transaction`**: Gateway monetary settlements (Stripe, Razorpay) with positive amount constraints (`amount > 0`), settlement statuses, and unique gateway transaction references.
- **`invoice` (NEW — B41)**: Customer-facing formal billing documents linked to subscriptions and payment transactions, enforcing arithmetic integrity (`total_amount = subtotal_amount + tax_amount`) and unique invoice numbers.
- **`payment_refund` (NEW — B42)**: Full or partial refund records against payment transactions (`refund_amount > 0`), gateway refund IDs, and dedicated idempotency guards.
- **`profile_download_event`**: Immutable audit logs capturing recruiter candidate resume downloads (`PDF`, `DOCX`, `JSON`), IP addresses, and user agents, protected from mutation by `talentra_reject_mutation()` (B45).

---

## 2. B36–B47 Requirements Coverage Matrix

| Req ID | Business Requirement | Implementation Entity / Constraint | Verification Status |
| :--- | :--- | :--- | :--- |
| **B36** | Named device registry per user | `public.user_device` table with fingerprinting and metadata | ✅ Deployed & Verified |
| **B37** | Active device cap per licence & revocation handling | `check_user_device_limit()` trigger + `revoked_at` filtering | ✅ Deployed & Verified |
| **B38** | Recruiter talent outreach batching & templates | `public.sourcing_outreach_batch` table with channel checks | ✅ Deployed & Verified |
| **B39** | Per-candidate delivery state & response tracking | `public.sourcing_outreach_recipient` with delivery status enum | ✅ Deployed & Verified |
| **B40** | Immutable audit log of consultant request decisions | `public.consultant_request_decision` + `talentra_reject_mutation()` | ✅ Deployed & Verified |
| **B41** | Customer-facing itemized invoice documents | `public.invoice` with `chk_inv_total_eq_sum` & unique invoice numbers | ✅ Deployed & Verified |
| **B42** | Full and partial payment refunds | `public.payment_refund` with positive amount & gateway checks | ✅ Deployed & Verified |
| **B43** | Wallet ledger unique idempotency keys | `uq_wallet_ledger_idempotency` unique index on `wallet_transaction_ledger` | ✅ Deployed & Verified |
| **B44** | Append-only immutability of financial ledger | `talentra_reject_mutation()` triggers rejecting UPDATE, DELETE, TRUNCATE | ✅ Deployed & Verified |
| **B45** | Append-only immutability of profile download logs | `talentra_reject_mutation()` triggers rejecting UPDATE, DELETE, TRUNCATE | ✅ Deployed & Verified |
| **B46** | Consultant job eligibility & commission rate rules | `trg_check_consultant_job_eligibility` trigger & `chk_cr_commission_rate` | ✅ Deployed & Verified |
| **B47** | Non-overlapping active subscriptions & balance safety | `trg_check_sub_no_overlap` trigger & `wallet_account` non-negative check | ✅ Deployed & Verified |

---

## 3. Migration Pipeline

Phase 3 is deployed through two forward-only migrations executed in strict dependency sequence:

1. **`phase3/migrations/004_phase3.sql`** (Initial Deployment):
   - Creates the 12 core tables: `subscription_plan`, `account_subscription`, `account_licence`, `licence_seat_assignment`, `device_session`, `sourcing_pool`, `sourcing_pool_candidate`, `consultant_request`, `wallet_account`, `wallet_transaction_ledger`, `payment_transaction`, `profile_download_event`.
   - Attaches `talentra_reject_mutation()` triggers to `wallet_transaction_ledger` and `profile_download_event`.

2. **`phase3/migrations/006_phase3_gap_closure.sql`** (Additive Gap Closure):
   - Created forward-only to preserve production history.
   - Deploys the 6 missing entities: `user_device`, `sourcing_outreach_batch`, `sourcing_outreach_recipient`, `consultant_request_decision`, `invoice`, `payment_refund`.
   - Upgrades `licence_seat_assignment` uniqueness to a partial active index (`uq_licence_seat_active`) and attaches `check_licence_seat_limit()`.
   - Enforces device quotas via `check_user_device_limit()` BEFORE INSERT trigger on `user_device`.
   - Enforces consultant job eligibility via `check_consultant_job_eligibility()` trigger and commission bounds via `chk_cr_commission_rate`.
   - Enforces non-overlapping active subscription periods via `check_subscription_no_overlap()` trigger on `account_subscription`.
   - Protects `consultant_request_decision` with `talentra_reject_mutation()` statement triggers.

---

## 4. Automated Verification & Test Results

The comprehensive test suite is located in `phase3/tests/phase3_constraints.sql` and was executed directly against the Neon development branch `test-phase3-phase4` (`br-broad-star-az461ef4`).

- **Total Assertions Executed**: **37**
- **Passed**: **37** (100%)
- **Failed**: **0**
- **Test Pollution**: **0 rows** remaining (clean transactional rollback confirmed).

```
NOTICE: SUCCESS: 37 of 37 Phase 3 constraint & integrity tests PASSED. All test fixtures rolled back cleanly.
```

---

## 5. Live Catalog Summary

| Metric | Live Database Count |
| :--- | :--- |
| **Entities (Tables)** | 18 |
| **Columns** | 261 |
| **Constraints** | 252 |
| **Foreign Key Relationships** | 62 |
| **Indexes** | 69 |
| **Triggers** | 18 |
| **Row Count** | 0 (all test data safely rolled back) |
