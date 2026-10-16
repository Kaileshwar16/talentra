# Talentra Phase 3: Commercial Access, Licences, Sourcing & Wallet (Modules 7–9)

This document provides the complete data dictionary, architectural design specifications, constraint rules, and financial ledger integrity model for Phase 3, implementing Milestones 11–13 of the Talentra Platform.

---

## 1. Module Overview & Schema Organization

Phase 3 introduces 12 production-grade enterprise entities deployed under the `public` schema:

| Module | Entities | Functional Scope |
| --- | --- | --- |
| **Module 7 — Licences, Seats, Devices and Sessions** | `subscription_plan`, `account_subscription`, `account_licence`, `licence_seat_assignment`, `device_session` | Commercial subscription tiers, quota definitions, enterprise licence keys, seat allocations, active user seats, and hardware device session tracking with concurrency limits. |
| **Module 8 — Sourcing and Consultant Requests** | `sourcing_pool`, `sourcing_pool_candidate`, `consultant_request` | Talent sourcing candidate pools, pipeline talent classification, sourcing workflows, and external expert consultant engagement lifecycle management. |
| **Module 9 — Subscriptions, Wallet, Payments and Download History** | `wallet_account`, `wallet_transaction_ledger`, `payment_transaction`, `profile_download_event` | Double-entry credit wallet accounts, immutable audit transaction ledgers, payment gateway transactions, balance invariant validation, and unforgeable candidate profile download auditing. |

---

## 2. Module 7: Licences, Seats, Devices & Sessions

### Entities & Data Dictionary

1. **`public.subscription_plan`**: Commercial tier definitions and entitlement quotas.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `code VARCHAR(50) NOT NULL UNIQUE`: Canonical tier identifier (`TIER_1_STARTER`, `TIER_2_GROWTH`, `TIER_3_ENTERPRISE`).
   - `name VARCHAR(100) NOT NULL`, `description TEXT`.
   - `tier_level INTEGER NOT NULL CHECK (tier_level >= 1)`: Hierarchical subscription tier index.
   - `billing_period VARCHAR(20) NOT NULL CHECK (billing_period IN ('MONTHLY', 'ANNUAL', 'QUARTERLY'))`.
   - `price_amount NUMERIC(12,2) NOT NULL CHECK (price_amount >= 0)`.
   - `currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON DELETE RESTRICT`.
   - `max_seats INTEGER NOT NULL CHECK (max_seats >= 1)`: Maximum licensed recruiter seats.
   - `candidate_download_credits INTEGER NOT NULL CHECK (candidate_download_credits >= 0)`: Monthly credit quota.
   - `is_active BOOLEAN NOT NULL DEFAULT true`.

2. **`public.account_subscription`**: Binding billing subscription agreement.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON DELETE RESTRICT`.
   - `subscription_plan_id BIGINT NOT NULL REFERENCES public.subscription_plan(id) ON DELETE RESTRICT`.
   - `subscription_status VARCHAR(50) NOT NULL CHECK (subscription_status IN ('ACTIVE', 'TRIAL', 'PAST_DUE', 'CANCELLED', 'EXPIRED'))`.
   - `current_period_starts_at TIMESTAMPTZ NOT NULL`.
   - `current_period_ends_at TIMESTAMPTZ NOT NULL CHECK (current_period_ends_at > current_period_starts_at)`.
   - `auto_renew BOOLEAN NOT NULL DEFAULT true`.

3. **`public.account_licence`**: Cryptographic license activation key.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON DELETE RESTRICT`.
   - `subscription_plan_id BIGINT NOT NULL REFERENCES public.subscription_plan(id) ON DELETE RESTRICT`.
   - `licence_key VARCHAR(100) NOT NULL UNIQUE`: High-entropy platform license token.
   - `allocated_seats INTEGER NOT NULL CHECK (allocated_seats >= 1)`.
   - `licence_status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (licence_status IN ('ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED'))`.
   - `issued_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `expires_at TIMESTAMPTZ CHECK (expires_at > issued_at)`.

4. **`public.licence_seat_assignment`**: Recruiter seat allocation.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `account_licence_id BIGINT NOT NULL REFERENCES public.account_licence(id) ON DELETE RESTRICT`.
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `seat_role VARCHAR(50) NOT NULL DEFAULT 'RECRUITER' CHECK (seat_role IN ('ADMIN', 'RECRUITER', 'SOURCER', 'READ_ONLY'))`.
   - `valid_from TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `valid_to TIMESTAMPTZ CHECK (valid_to > valid_from)`.
   - `is_active BOOLEAN NOT NULL DEFAULT true`.
   - `CONSTRAINT uq_active_licence_seat UNIQUE (account_licence_id, user_account_id)`: A user can hold at most one active seat under a licence.

5. **`public.device_session`**: Authenticated hardware device session.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `device_fingerprint VARCHAR(128) NOT NULL`: Hardware/browser signature.
   - `device_name VARCHAR(100)`, `device_type VARCHAR(50)` (`DESKTOP`, `MOBILE`, `TABLET`).
   - `ip_address INET`, `user_agent TEXT`.
   - `last_seen_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `is_revoked BOOLEAN NOT NULL DEFAULT false`.

---

## 3. Module 8: Sourcing & Consultant Requests

### Entities & Data Dictionary

1. **`public.sourcing_pool`**: Named candidate pipeline folder.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`.
   - `created_by_user_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `name VARCHAR(150) NOT NULL`, `description TEXT`.
   - `pool_status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (pool_status IN ('ACTIVE', 'ARCHIVED', 'LOCKED'))`.

2. **`public.sourcing_pool_candidate`**: Candidate membership within a pool.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `sourcing_pool_id BIGINT NOT NULL REFERENCES public.sourcing_pool(id) ON DELETE RESTRICT`.
   - `candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON DELETE RESTRICT`.
   - `added_by_user_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `stage_status VARCHAR(50) NOT NULL DEFAULT 'IDENTIFIED' CHECK (stage_status IN ('IDENTIFIED', 'CONTACTED', 'SCREENED', 'ENGAGED', 'REJECTED'))`.
   - `added_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `CONSTRAINT uq_pool_candidate UNIQUE (sourcing_pool_id, candidate_profile_id)`: Prevents duplicate membership.

3. **`public.consultant_request`**: Professional recruitment consultant engagement request.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`.
   - `job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON DELETE RESTRICT`.
   - `consultant_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `request_status VARCHAR(50) NOT NULL DEFAULT 'REQUESTED' CHECK (request_status IN ('REQUESTED', 'ACCEPTED', 'DECLINED', 'TERMINATED'))`.
   - `fee_model VARCHAR(50) NOT NULL CHECK (fee_model IN ('PERCENTAGE_OF_SALARY', 'FIXED_RETAINER', 'HOURLY'))`.
   - `fee_amount NUMERIC(12,2) NOT NULL CHECK (fee_amount >= 0)`.
   - `requested_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `resolved_at TIMESTAMPTZ`.

---

## 4. Module 9: Subscriptions, Wallet, Payments & Download History

### Entities & Data Dictionary

1. **`public.wallet_account`**: Pre-funded credit and currency account.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON DELETE RESTRICT`.
   - `currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON DELETE RESTRICT`.
   - `balance NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0)`: Strict non-negative balance invariant.
   - `credit_points INTEGER NOT NULL DEFAULT 0 CHECK (credit_points >= 0)`: Download credit balance.
   - `is_frozen BOOLEAN NOT NULL DEFAULT false`: Fraud/risk freeze switch.
   - `CONSTRAINT uq_account_currency_wallet UNIQUE (account_profile_id, currency_id)`.

2. **`public.wallet_transaction_ledger`**: Append-only double-entry financial ledger.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `wallet_account_id BIGINT NOT NULL REFERENCES public.wallet_account(id) ON DELETE RESTRICT`.
   - `transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('PURCHASE', 'PLAN_GRANT', 'PROFILE_DOWNLOAD', 'REFUND', 'CORRECTION', 'EXPIRY'))`.
   - `amount NUMERIC(14,2) NOT NULL`: Financial delta (+ for deposits/refunds, - for charges).
   - `credits_delta INTEGER NOT NULL DEFAULT 0`: Credit delta.
   - `balance_after NUMERIC(14,2) NOT NULL CHECK (balance_after >= 0)`.
   - `credit_points_after INTEGER NOT NULL CHECK (credit_points_after >= 0)`.
   - `reference_id VARCHAR(100) NOT NULL UNIQUE`: Idempotency tracking key.
   - `created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `talentra_reject_mutation()`: Rejects UPDATE, DELETE, and TRUNCATE via SQLSTATE 55000.

3. **`public.payment_transaction`**: External payment processor settlement records.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON DELETE RESTRICT`.
   - `wallet_account_id BIGINT REFERENCES public.wallet_account(id) ON DELETE RESTRICT`.
   - `payment_gateway VARCHAR(50) NOT NULL` (`STRIPE`, `RAZORPAY`, `PAYPAL`, `WIRE_TRANSFER`).
   - `gateway_transaction_id VARCHAR(100) NOT NULL UNIQUE`: Gateway idempotency token.
   - `amount NUMERIC(14,2) NOT NULL CHECK (amount > 0)`.
   - `currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON DELETE RESTRICT`.
   - `payment_status VARCHAR(50) NOT NULL CHECK (payment_status IN ('INITIATED', 'SUCCEEDED', 'FAILED', 'REFUNDED'))`.
   - `payment_method VARCHAR(50)`, `raw_gateway_response JSONB`.

4. **`public.profile_download_event`**: Unforgeable audit record of candidate PII downloads.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `wallet_account_id BIGINT NOT NULL REFERENCES public.wallet_account(id) ON DELETE RESTRICT`.
   - `downloaded_by_user_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON DELETE RESTRICT`.
   - `resume_version_id BIGINT REFERENCES public.resume_version(id) ON DELETE RESTRICT`.
   - `credits_deducted INTEGER NOT NULL CHECK (credits_deducted >= 0)`.
   - `downloaded_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `ip_address INET`.
   - Immutable: Rejects UPDATE and DELETE.

---

## 5. Architectural & Financial Guarantees

1. **Non-Negative Balance Invariants**: The database enforces `CHECK (balance >= 0)` and `CHECK (credit_points >= 0)` at both table constraints and trigger validation level.
2. **Double-Entry Ledger Integrity**: Every balance modification on `wallet_account` requires a corresponding row in `wallet_transaction_ledger` with computed `balance_after`.
3. **Download Traceability**: Direct recruiter downloads of candidate resumes deduct credits and log an unforgeable compliance record with IP and user attribution.
