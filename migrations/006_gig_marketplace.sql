-- =============================================================================
-- Migration: 006_gig_marketplace.sql
-- Module 6: Gig Marketplace Architecture
-- Source: Talentra_Modules_4_to_11_Complete_Database_Documentation.md
-- Description:
--   Implements the normalized contractor / on-demand gig marketplace:
--   1. gig_worker_profile
--   2. gig_request
--   3. gig_request_skill
--   4. gig_service
--   5. gig_service_skill
--   6. gig_application
--   7. gig_assignment
--   8. gig_rating
--   9. gig_earnings_reconciliation
--   10. gig_worker_list
--   11. gig_worker_list_entry
-- =============================================================================

BEGIN;

-- 1. gig_worker_profile
CREATE TABLE IF NOT EXISTS public.gig_worker_profile (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL UNIQUE REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    headline VARCHAR(200) NOT NULL,
    bio TEXT NULL,
    hourly_rate NUMERIC(14,2) NULL CHECK (hourly_rate IS NULL OR hourly_rate >= 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    availability_status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gig_worker_user ON public.gig_worker_profile(user_account_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_worker_profile;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_worker_profile
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. gig_request
CREATE TABLE IF NOT EXISTS public.gig_request (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    created_by_user_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    budget_amount NUMERIC(14,2) NULL CHECK (budget_amount IS NULL OR budget_amount >= 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    pricing_model VARCHAR(30) NOT NULL DEFAULT 'FIXED' CHECK (pricing_model IN ('FIXED', 'HOURLY', 'MILESTONE')),
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('DRAFT', 'OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    starts_at TIMESTAMPTZ NULL,
    deadline TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_gig_request_timing CHECK (deadline IS NULL OR starts_at IS NULL OR deadline >= starts_at)
);

CREATE INDEX IF NOT EXISTS idx_gig_request_org ON public.gig_request(organisation_id);
CREATE INDEX IF NOT EXISTS idx_gig_request_status ON public.gig_request(status);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_request;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_request
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 3. gig_request_skill
CREATE TABLE IF NOT EXISTS public.gig_request_skill (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_request_id BIGINT NOT NULL REFERENCES public.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    skill_id BIGINT NOT NULL REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_gig_req_skill UNIQUE (gig_request_id, skill_id)
);

CREATE INDEX IF NOT EXISTS idx_gig_req_skill_req ON public.gig_request_skill(gig_request_id);


-- 4. gig_service
CREATE TABLE IF NOT EXISTS public.gig_service (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    fixed_price NUMERIC(14,2) NULL CHECK (fixed_price IS NULL OR fixed_price >= 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    delivery_days INTEGER NULL CHECK (delivery_days IS NULL OR delivery_days > 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gig_service_worker ON public.gig_service(gig_worker_profile_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_service;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_service
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 5. gig_service_skill
CREATE TABLE IF NOT EXISTS public.gig_service_skill (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_service_id BIGINT NOT NULL REFERENCES public.gig_service(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    skill_id BIGINT NOT NULL REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_gig_service_skill UNIQUE (gig_service_id, skill_id)
);


-- 6. gig_application
CREATE TABLE IF NOT EXISTS public.gig_application (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_request_id BIGINT NOT NULL REFERENCES public.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    application_status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED' CHECK (application_status IN ('SUBMITTED', 'UNDER_REVIEW', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    proposed_price NUMERIC(14,2) NULL CHECK (proposed_price IS NULL OR proposed_price >= 0),
    proposed_rate NUMERIC(14,2) NULL CHECK (proposed_rate IS NULL OR proposed_rate >= 0),
    proposed_hours NUMERIC(8,2) NULL CHECK (proposed_hours IS NULL OR proposed_hours > 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    cover_note TEXT NULL,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMPTZ NULL,
    decided_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_gig_application UNIQUE (gig_request_id, gig_worker_profile_id)
);

CREATE INDEX IF NOT EXISTS idx_gig_app_request ON public.gig_application(gig_request_id);
CREATE INDEX IF NOT EXISTS idx_gig_app_worker ON public.gig_application(gig_worker_profile_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_application;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_application
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 7. gig_assignment
CREATE TABLE IF NOT EXISTS public.gig_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_application_id BIGINT NOT NULL UNIQUE REFERENCES public.gig_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    gig_request_id BIGINT NOT NULL REFERENCES public.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    assignment_status VARCHAR(30) NOT NULL DEFAULT 'ACCEPTED' CHECK (assignment_status IN ('ACCEPTED', 'ACTIVE', 'COMPLETED', 'DISPUTED', 'CANCELLED')),
    scheduled_start_at TIMESTAMPTZ NOT NULL,
    scheduled_end_at TIMESTAMPTZ NOT NULL,
    agreed_amount NUMERIC(14,2) NOT NULL CHECK (agreed_amount >= 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    accepted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ NULL,
    cancelled_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_gig_assignment_dates CHECK (scheduled_end_at >= scheduled_start_at)
);

CREATE INDEX IF NOT EXISTS idx_gig_assign_worker ON public.gig_assignment(gig_worker_profile_id);
CREATE INDEX IF NOT EXISTS idx_gig_assign_request ON public.gig_assignment(gig_request_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_assignment;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_assignment
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 8. gig_rating
CREATE TABLE IF NOT EXISTS public.gig_rating (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_assignment_id BIGINT NOT NULL REFERENCES public.gig_assignment(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    rater_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    ratee_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    rating_score NUMERIC(3,2) NOT NULL CHECK (rating_score BETWEEN 1.0 AND 5.0),
    review_text TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gig_rating_assignment ON public.gig_rating(gig_assignment_id);
CREATE INDEX IF NOT EXISTS idx_gig_rating_ratee ON public.gig_rating(ratee_user_account_id);


-- 9. gig_earnings_reconciliation
CREATE TABLE IF NOT EXISTS public.gig_earnings_reconciliation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_assignment_id BIGINT NOT NULL REFERENCES public.gig_assignment(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    external_system_code VARCHAR(60) NOT NULL,
    external_earnings_reference VARCHAR(200) NOT NULL,
    actual_amount NUMERIC(14,2) NOT NULL CHECK (actual_amount >= 0),
    currency_id BIGINT NULL REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    reconciled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reconciliation_status VARCHAR(30) NOT NULL DEFAULT 'RECONCILED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_gig_earnings_ref UNIQUE (external_system_code, external_earnings_reference)
);

CREATE INDEX IF NOT EXISTS idx_gig_earnings_assignment ON public.gig_earnings_reconciliation(gig_assignment_id);


-- 10. gig_worker_list
CREATE TABLE IF NOT EXISTS public.gig_worker_list (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    list_name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gig_worker_list_org ON public.gig_worker_list(organisation_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.gig_worker_list;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.gig_worker_list
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 11. gig_worker_list_entry
CREATE TABLE IF NOT EXISTS public.gig_worker_list_entry (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gig_worker_list_id BIGINT NOT NULL REFERENCES public.gig_worker_list(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT NULL,
    CONSTRAINT uq_gig_worker_list_entry UNIQUE (gig_worker_list_id, gig_worker_profile_id)
);

CREATE INDEX IF NOT EXISTS idx_gig_worker_list_entry_worker ON public.gig_worker_list_entry(gig_worker_profile_id);

COMMIT;
