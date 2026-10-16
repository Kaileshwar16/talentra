-- =============================================================================
-- Migration: 004_phase3.sql
-- Module Coverage: Phase 3 / Milestones 11–13 (Modules 7, 8, 9)
--   - Module 7: Plans, Licences, Seats, Devices and Sessions
--   - Module 8: Sourcing, Consultant Requests and Recruiter Workflows
--   - Module 9: Subscriptions, Wallets, Payments, Finance and Download History
-- Dependencies: Phase 1 (001_connected_er.sql), Phase 2 (002_phase2.sql, 003_restrict_security_functions.sql)
-- Target Platform: PostgreSQL 18 on Neon
-- =============================================================================

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- =============================================================================
-- MODULE 7: PLANS, LICENCES, SEATS, DEVICES AND SESSIONS
-- =============================================================================

-- 1. subscription_plan
CREATE TABLE IF NOT EXISTS public.subscription_plan (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(60) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    tier_level INTEGER NOT NULL DEFAULT 1,
    billing_period VARCHAR(30) NOT NULL DEFAULT 'MONTHLY',
    price_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_download_credits INTEGER NOT NULL DEFAULT 50,
    job_posting_limit INTEGER NOT NULL DEFAULT 5,
    max_seats INTEGER NOT NULL DEFAULT 1,
    max_devices_per_seat INTEGER NOT NULL DEFAULT 3,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.subscription_plan 
    ADD COLUMN IF NOT EXISTS plan_code VARCHAR(60),
    ADD COLUMN IF NOT EXISTS plan_name VARCHAR(120),
    ADD COLUMN IF NOT EXISTS tier_level INTEGER DEFAULT 1,
    ADD COLUMN IF NOT EXISTS billing_period VARCHAR(30) DEFAULT 'MONTHLY',
    ADD COLUMN IF NOT EXISTS price_amount NUMERIC(12, 2) DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS max_devices_per_seat INTEGER DEFAULT 3,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_subscription_plan_tier ON public.subscription_plan(tier_level, is_active);

-- 2. account_subscription
CREATE TABLE IF NOT EXISTS public.account_subscription (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_plan_id BIGINT NOT NULL REFERENCES public.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    current_period_starts_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    current_period_ends_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    payment_method_token VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.account_subscription
    ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS current_period_starts_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS current_period_ends_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS auto_renew BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS payment_method_token VARCHAR(200),
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_account_sub_account ON public.account_subscription(account_profile_id, subscription_status);

-- 3. account_licence
CREATE TABLE IF NOT EXISTS public.account_licence (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_plan_id BIGINT REFERENCES public.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    licence_key VARCHAR(100) NOT NULL UNIQUE,
    allocated_seats INTEGER NOT NULL DEFAULT 1,
    licence_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.account_licence
    ADD COLUMN IF NOT EXISTS subscription_plan_id BIGINT REFERENCES public.subscription_plan(id),
    ADD COLUMN IF NOT EXISTS allocated_seats INTEGER DEFAULT 1,
    ADD COLUMN IF NOT EXISTS licence_status VARCHAR(30) DEFAULT 'ACTIVE',
    ADD COLUMN IF NOT EXISTS valid_from TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS valid_to TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_account_licence_account ON public.account_licence(account_profile_id, licence_status);

-- 4. licence_seat_assignment
CREATE TABLE IF NOT EXISTS public.licence_seat_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_licence_id BIGINT NOT NULL REFERENCES public.account_licence(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    seat_role VARCHAR(40) NOT NULL DEFAULT 'RECRUITER',
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.licence_seat_assignment
    ADD COLUMN IF NOT EXISTS seat_role VARCHAR(40) DEFAULT 'RECRUITER',
    ADD COLUMN IF NOT EXISTS valid_from TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS valid_to TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_seat_assign_user ON public.licence_seat_assignment(user_account_id);

-- 5. device_session
CREATE TABLE IF NOT EXISTS public.device_session (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    device_fingerprint VARCHAR(128) NOT NULL,
    device_name VARCHAR(150),
    device_type VARCHAR(40) NOT NULL DEFAULT 'BROWSER',
    client_ip INET,
    user_agent TEXT,
    session_token_hash VARCHAR(128) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    revocation_reason VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.device_session
    ADD COLUMN IF NOT EXISTS device_name VARCHAR(150),
    ADD COLUMN IF NOT EXISTS client_ip INET,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS revocation_reason VARCHAR(100),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_device_session_user ON public.device_session(user_account_id, is_active);

-- =============================================================================
-- MODULE 8: SOURCING, CONSULTANT REQUESTS AND RECRUITER WORKFLOWS
-- =============================================================================

-- 6. sourcing_pool
CREATE TABLE IF NOT EXISTS public.sourcing_pool (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    pool_name VARCHAR(150),
    pool_description TEXT,
    target_role VARCHAR(120),
    is_private BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.sourcing_pool
    ADD COLUMN IF NOT EXISTS pool_name VARCHAR(150),
    ADD COLUMN IF NOT EXISTS pool_description TEXT,
    ADD COLUMN IF NOT EXISTS target_role VARCHAR(120),
    ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_sourcing_pool_org ON public.sourcing_pool(organisation_id);

-- 7. sourcing_pool_candidate
CREATE TABLE IF NOT EXISTS public.sourcing_pool_candidate (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sourcing_pool_id BIGINT NOT NULL REFERENCES public.sourcing_pool(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    added_by_recruiter_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    sourcing_channel VARCHAR(60) NOT NULL DEFAULT 'TALENT_POOL',
    candidate_match_score NUMERIC(5, 2),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.sourcing_pool_candidate
    ADD COLUMN IF NOT EXISTS added_by_recruiter_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS sourcing_channel VARCHAR(60) DEFAULT 'TALENT_POOL',
    ADD COLUMN IF NOT EXISTS candidate_match_score NUMERIC(5, 2),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_pool_candidate_pool ON public.sourcing_pool_candidate(sourcing_pool_id);

-- 8. consultant_request
CREATE TABLE IF NOT EXISTS public.consultant_request (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    consultant_user_account_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    consultant_organisation_id BIGINT REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    commission_rate_percent NUMERIC(5, 2),
    request_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    approved_by_user_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    approved_at TIMESTAMPTZ,
    valid_until TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.consultant_request
    ADD COLUMN IF NOT EXISTS consultant_user_account_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS commission_rate_percent NUMERIC(5, 2),
    ADD COLUMN IF NOT EXISTS approved_by_user_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS valid_until TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_consultant_req_job ON public.consultant_request(job_requirement_id, request_status);

-- =============================================================================
-- MODULE 9: SUBSCRIPTIONS, WALLETS, PAYMENTS, FINANCE AND DOWNLOAD HISTORY
-- =============================================================================

-- 9. wallet_account
CREATE TABLE IF NOT EXISTS public.wallet_account (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL UNIQUE REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    balance_credits INTEGER NOT NULL DEFAULT 0,
    currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    wallet_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.wallet_account
    ADD COLUMN IF NOT EXISTS balance_credits INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS wallet_status VARCHAR(30) DEFAULT 'ACTIVE',
    ADD COLUMN IF NOT EXISTS created_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS updated_by BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- 10. wallet_transaction_ledger (Append-only ledger)
CREATE TABLE IF NOT EXISTS public.wallet_transaction_ledger (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wallet_account_id BIGINT NOT NULL REFERENCES public.wallet_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    transaction_type VARCHAR(40) NOT NULL,
    credit_amount INTEGER,
    balance_after INTEGER NOT NULL,
    description TEXT,
    idempotency_key VARCHAR(150),
    reference_order_id VARCHAR(100),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.wallet_transaction_ledger
    ADD COLUMN IF NOT EXISTS credit_amount INTEGER,
    ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(150),
    ADD COLUMN IF NOT EXISTS reference_order_id VARCHAR(100),
    ADD COLUMN IF NOT EXISTS occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_wallet_ledger_wallet ON public.wallet_transaction_ledger(wallet_account_id);

-- Attach reject mutation trigger to enforce append-only ledger immutability
DROP TRIGGER IF EXISTS reject_mutation ON public.wallet_transaction_ledger;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE OR TRUNCATE ON public.wallet_transaction_ledger
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

-- 11. payment_transaction
CREATE TABLE IF NOT EXISTS public.payment_transaction (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    wallet_account_id BIGINT REFERENCES public.wallet_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_plan_id BIGINT REFERENCES public.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'INITIATED',
    payment_gateway VARCHAR(40) NOT NULL DEFAULT 'STRIPE',
    gateway_transaction_id VARCHAR(150) NOT NULL UNIQUE,
    idempotency_key VARCHAR(150) NOT NULL UNIQUE,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payment_trans_account ON public.payment_transaction(account_profile_id, payment_status);

-- 12. profile_download_event (Append-only access log)
CREATE TABLE IF NOT EXISTS public.profile_download_event (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    recruiter_user_account_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    wallet_transaction_id BIGINT REFERENCES public.wallet_transaction_ledger(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    download_format VARCHAR(20) NOT NULL DEFAULT 'PDF',
    ip_address INET,
    user_agent TEXT,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.profile_download_event
    ADD COLUMN IF NOT EXISTS recruiter_user_account_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS download_format VARCHAR(20) DEFAULT 'PDF',
    ADD COLUMN IF NOT EXISTS user_agent TEXT,
    ADD COLUMN IF NOT EXISTS occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_profile_download_candidate ON public.profile_download_event(candidate_profile_id);

-- Attach reject mutation trigger to enforce append-only download event immutability
DROP TRIGGER IF EXISTS reject_mutation ON public.profile_download_event;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE OR TRUNCATE ON public.profile_download_event
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

COMMIT;
