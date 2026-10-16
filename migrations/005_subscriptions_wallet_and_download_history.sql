-- =============================================================================
-- Migration: 005_subscriptions_wallet_and_download_history.sql
-- Module 9: Subscriptions, Wallet Ledger & Profile Download History
-- Source: Talentra_Modules_4_to_11_Complete_Database_Documentation.md
-- Description:
--   Resolves identified enterprise gaps in Module 9:
--   1. subscription_plan (Multi-tier enterprise subscription definitions)
--   2. account_subscription (Active subscription bindings & lifecycle)
--   3. wallet_account (Account credit balances)
--   4. wallet_transaction_ledger (Append-Only credit accounting ledger)
--   5. profile_download_event (Append-Only resume/profile download history)
-- =============================================================================

BEGIN;

-- 1. subscription_plan
CREATE TABLE IF NOT EXISTS public.subscription_plan (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(60) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    price NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    billing_interval VARCHAR(20) NOT NULL CHECK (billing_interval IN ('MONTHLY', 'QUARTERLY', 'ANNUAL')),
    candidate_download_credits INTEGER NOT NULL DEFAULT 0 CHECK (candidate_download_credits >= 0),
    job_posting_limit INTEGER NOT NULL DEFAULT 5 CHECK (job_posting_limit > 0),
    max_seats INTEGER NOT NULL DEFAULT 1 CHECK (max_seats > 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sub_plan_code ON public.subscription_plan(code);

DROP TRIGGER IF EXISTS set_updated_at ON public.subscription_plan;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.subscription_plan
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. account_subscription
CREATE TABLE IF NOT EXISTS public.account_subscription (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_plan_id BIGINT NOT NULL REFERENCES public.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subscription_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (subscription_status IN ('TRIAL', 'ACTIVE', 'PAST_DUE', 'CANCELLED', 'EXPIRED')),
    starts_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    renews_at TIMESTAMPTZ NULL,
    ends_at TIMESTAMPTZ NULL,
    cancelled_at TIMESTAMPTZ NULL,
    external_provider_subscription_id VARCHAR(255) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_sub_timing CHECK (ends_at IS NULL OR ends_at >= starts_at)
);

CREATE INDEX IF NOT EXISTS idx_acc_sub_account ON public.account_subscription(account_profile_id);
CREATE INDEX IF NOT EXISTS idx_acc_sub_status ON public.account_subscription(subscription_status);

DROP TRIGGER IF EXISTS set_updated_at ON public.account_subscription;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.account_subscription
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 3. wallet_account
CREATE TABLE IF NOT EXISTS public.wallet_account (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL UNIQUE REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    credit_balance INTEGER NOT NULL DEFAULT 0 CHECK (credit_balance >= 0),
    currency_id BIGINT NOT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_acc_account ON public.wallet_account(account_profile_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.wallet_account;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.wallet_account
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 4. wallet_transaction_ledger (Append-Only)
CREATE TABLE IF NOT EXISTS public.wallet_transaction_ledger (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    wallet_account_id BIGINT NOT NULL REFERENCES public.wallet_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    transaction_type VARCHAR(30) NOT NULL CHECK (transaction_type IN ('PURCHASE', 'PLAN_GRANT', 'PROFILE_DOWNLOAD', 'REFUND', 'CORRECTION', 'EXPIRY')),
    credits_delta INTEGER NOT NULL,
    balance_after INTEGER NOT NULL CHECK (balance_after >= 0),
    reference_id VARCHAR(100) NULL,
    description VARCHAR(500) NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_ledger_wallet ON public.wallet_transaction_ledger(wallet_account_id);
CREATE INDEX IF NOT EXISTS idx_wallet_ledger_time ON public.wallet_transaction_ledger(recorded_at);

DROP TRIGGER IF EXISTS reject_mutation ON public.wallet_transaction_ledger;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.wallet_transaction_ledger
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.wallet_transaction_ledger;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.wallet_transaction_ledger
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();


-- 5. profile_download_event (Append-Only)
CREATE TABLE IF NOT EXISTS public.profile_download_event (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    downloader_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    credits_deducted INTEGER NOT NULL DEFAULT 1 CHECK (credits_deducted >= 0),
    wallet_transaction_id BIGINT NULL REFERENCES public.wallet_transaction_ledger(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    resume_version_id BIGINT NULL REFERENCES public.resume_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    downloaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET NULL
);

CREATE INDEX IF NOT EXISTS idx_download_event_candidate ON public.profile_download_event(candidate_profile_id);
CREATE INDEX IF NOT EXISTS idx_download_event_downloader ON public.profile_download_event(downloader_user_account_id);
CREATE INDEX IF NOT EXISTS idx_download_event_org ON public.profile_download_event(organisation_id);
CREATE INDEX IF NOT EXISTS idx_download_event_time ON public.profile_download_event(downloaded_at);

DROP TRIGGER IF EXISTS reject_mutation ON public.profile_download_event;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.profile_download_event
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.profile_download_event;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.profile_download_event
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

COMMIT;
