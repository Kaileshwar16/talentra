-- =============================================================================
-- Migration: 007_licences_sourcing_and_notifications.sql
-- Modules 7, 8, 10, 11: Enterprise Licences, Sourcing, Notifications & Analytics
-- Source: Talentra_Modules_4_to_11_Complete_Database_Documentation.md
-- Description:
--   Implements:
--   Module 7: account_licence, licence_seat_assignment, device_session, user_credential
--   Module 8: sourcing_pool, sourcing_pool_candidate, consultant_request
--   Module 10: notification_delivery, notification_preference, support_ticket, support_ticket_message, faq_article
--   Module 11: analytics_application_funnel_daily
-- =============================================================================

BEGIN;

-- =============================================================================
-- MODULE 7: LICENCES, SEATS, DEVICES & SESSIONS
-- =============================================================================

-- 1. account_licence
CREATE TABLE IF NOT EXISTS public.account_licence (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    licence_key VARCHAR(100) NOT NULL UNIQUE,
    max_seats INTEGER NOT NULL DEFAULT 5 CHECK (max_seats > 0),
    max_devices_per_user INTEGER NOT NULL DEFAULT 3 CHECK (max_devices_per_user > 0),
    starts_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_licence_dates CHECK (expires_at IS NULL OR expires_at >= starts_at)
);

CREATE INDEX IF NOT EXISTS idx_licence_account ON public.account_licence(account_profile_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.account_licence;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.account_licence
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. licence_seat_assignment
CREATE TABLE IF NOT EXISTS public.licence_seat_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_licence_id BIGINT NOT NULL REFERENCES public.account_licence(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_licence_seat UNIQUE (account_licence_id, user_account_id)
);

CREATE INDEX IF NOT EXISTS idx_licence_seat_user ON public.licence_seat_assignment(user_account_id);


-- 3. device_session
CREATE TABLE IF NOT EXISTS public.device_session (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    session_token_hash VARCHAR(128) NOT NULL UNIQUE,
    device_fingerprint VARCHAR(255) NULL,
    device_type VARCHAR(40) NULL,
    ip_address INET NULL,
    user_agent TEXT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_session_user ON public.device_session(user_account_id);
CREATE INDEX IF NOT EXISTS idx_session_token ON public.device_session(session_token_hash);


-- 4. user_credential
CREATE TABLE IF NOT EXISTS public.user_credential (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    credential_type VARCHAR(30) NOT NULL CHECK (credential_type IN ('PASSWORD_HASH', 'API_KEY', 'OAUTH_TOKEN')),
    credential_identifier VARCHAR(254) NOT NULL,
    secret_hash VARCHAR(500) NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ NULL,
    expires_at TIMESTAMPTZ NULL,
    last_used_at TIMESTAMPTZ NULL,
    failed_attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (failed_attempt_count >= 0),
    locked_until TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_credential UNIQUE (credential_type, credential_identifier)
);

CREATE INDEX IF NOT EXISTS idx_user_cred_user ON public.user_credential(user_account_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.user_credential;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_credential
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- =============================================================================
-- MODULE 8: SOURCING & CONSULTANT REQUESTS
-- =============================================================================

-- 5. sourcing_pool
CREATE TABLE IF NOT EXISTS public.sourcing_pool (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sourcing_pool_org ON public.sourcing_pool(organisation_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.sourcing_pool;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.sourcing_pool
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 6. sourcing_pool_candidate
CREATE TABLE IF NOT EXISTS public.sourcing_pool_candidate (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sourcing_pool_id BIGINT NOT NULL REFERENCES public.sourcing_pool(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    added_by_user_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    notes TEXT NULL,
    added_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_sourcing_pool_cand UNIQUE (sourcing_pool_id, candidate_profile_id)
);

CREATE INDEX IF NOT EXISTS idx_pool_cand_cand ON public.sourcing_pool_candidate(candidate_profile_id);


-- 7. consultant_request
CREATE TABLE IF NOT EXISTS public.consultant_request (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    consultant_organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    request_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED' CHECK (request_status IN ('REQUESTED', 'ACCEPTED', 'DECLINED', 'TERMINATED')),
    commission_terms TEXT NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_consultant_req_job ON public.consultant_request(job_requirement_id);
CREATE INDEX IF NOT EXISTS idx_consultant_req_org ON public.consultant_request(consultant_organisation_id);


-- =============================================================================
-- MODULE 10: NOTIFICATIONS, PREFERENCES & COMMUNITY
-- =============================================================================

-- 8. notification_delivery
CREATE TABLE IF NOT EXISTS public.notification_delivery (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    notification_type VARCHAR(60) NOT NULL,
    channel_code VARCHAR(30) NOT NULL CHECK (channel_code IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    provider_name VARCHAR(80) NULL,
    provider_message_reference VARCHAR(200) NULL,
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'QUEUED' CHECK (delivery_status IN ('QUEUED', 'SENT', 'DELIVERED', 'FAILED')),
    subject VARCHAR(255) NULL,
    queued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMPTZ NULL,
    delivered_at TIMESTAMPTZ NULL,
    failed_at TIMESTAMPTZ NULL,
    failure_code VARCHAR(80) NULL,
    retry_count INTEGER NOT NULL DEFAULT 0 CHECK (retry_count >= 0),
    correlation_id UUID NULL
);

CREATE INDEX IF NOT EXISTS idx_notif_delivery_user ON public.notification_delivery(user_account_id, queued_at);
CREATE INDEX IF NOT EXISTS idx_notif_delivery_status ON public.notification_delivery(delivery_status);


-- 9. notification_preference
CREATE TABLE IF NOT EXISTS public.notification_preference (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    notification_category VARCHAR(60) NOT NULL,
    channel_code VARCHAR(30) NOT NULL CHECK (channel_code IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_notif_pref UNIQUE (user_account_id, notification_category, channel_code)
);

CREATE INDEX IF NOT EXISTS idx_notif_pref_user ON public.notification_preference(user_account_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.notification_preference;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.notification_preference
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 10. support_ticket
CREATE TABLE IF NOT EXISTS public.support_ticket (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    requester_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    assigned_to_user_account_id BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    category VARCHAR(60) NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    subject VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_support_ticket_user ON public.support_ticket(requester_user_account_id);
CREATE INDEX IF NOT EXISTS idx_support_ticket_status ON public.support_ticket(status);

DROP TRIGGER IF EXISTS set_updated_at ON public.support_ticket;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.support_ticket
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 11. support_ticket_message
CREATE TABLE IF NOT EXISTS public.support_ticket_message (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    support_ticket_id BIGINT NOT NULL REFERENCES public.support_ticket(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    author_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    message_body TEXT NOT NULL,
    is_internal_note BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ticket_msg_ticket ON public.support_ticket_message(support_ticket_id);


-- 12. faq_article
CREATE TABLE IF NOT EXISTS public.faq_article (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category VARCHAR(60) NOT NULL,
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_faq_cat ON public.faq_article(category);

DROP TRIGGER IF EXISTS set_updated_at ON public.faq_article;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.faq_article
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- =============================================================================
-- MODULE 11: ANALYTICS LAYER & REPORTING MARTS
-- =============================================================================

-- 13. analytics_application_funnel_daily
CREATE TABLE IF NOT EXISTS public.analytics_application_funnel_daily (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_date DATE NOT NULL,
    job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    applied_count INTEGER NOT NULL DEFAULT 0,
    shortlisted_count INTEGER NOT NULL DEFAULT 0,
    interviewing_count INTEGER NOT NULL DEFAULT 0,
    offered_count INTEGER NOT NULL DEFAULT 0,
    joined_count INTEGER NOT NULL DEFAULT 0,
    rejected_count INTEGER NOT NULL DEFAULT 0,
    withdrawn_count INTEGER NOT NULL DEFAULT 0,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_funnel_daily UNIQUE (report_date, job_requirement_id)
);

CREATE INDEX IF NOT EXISTS idx_funnel_daily_org ON public.analytics_application_funnel_daily(organisation_id, report_date);

COMMIT;
