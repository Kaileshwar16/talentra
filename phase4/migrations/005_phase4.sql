-- =============================================================================
-- Migration: 005_phase4.sql
-- Module Coverage: Phase 4 / Milestones 14–16 (Modules 10, 11)
--   - Module 10: Notifications, Preferences and Community
--   - Module 11: Analytics, Reporting and Data Marts
-- Dependencies: Phases 1–3 (001_connected_er.sql, 002_phase2.sql, 003_restrict_security_functions.sql, 004_phase3.sql)
-- Target Platform: PostgreSQL 18 on Neon
-- =============================================================================

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

-- =============================================================================
-- MODULE 10: NOTIFICATIONS, PREFERENCES AND COMMUNITY
-- =============================================================================

-- 1. notification_template
CREATE TABLE IF NOT EXISTS public.notification_template (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    template_code VARCHAR(80) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
    subject_template VARCHAR(250) NOT NULL,
    body_template TEXT NOT NULL,
    supported_channels VARCHAR(100) NOT NULL DEFAULT 'IN_APP,EMAIL',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);

-- 2. notification_preference
CREATE TABLE IF NOT EXISTS public.notification_preference (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    category VARCHAR(50) NOT NULL DEFAULT 'ALL',
    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    digest_frequency VARCHAR(20) NOT NULL DEFAULT 'INSTANT',
    marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.notification_preference
    ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'ALL',
    ADD COLUMN IF NOT EXISTS in_app_enabled BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS email_enabled BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS sms_enabled BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS push_enabled BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS digest_frequency VARCHAR(20) DEFAULT 'INSTANT',
    ADD COLUMN IF NOT EXISTS marketing_opt_in BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_notif_pref_user ON public.notification_preference(user_account_id);

-- 3. notification_delivery
CREATE TABLE IF NOT EXISTS public.notification_delivery (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    template_id BIGINT REFERENCES public.notification_template(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    channel VARCHAR(30) NOT NULL DEFAULT 'IN_APP',
    title VARCHAR(250),
    body_content TEXT,
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'QUEUED',
    retry_count INTEGER NOT NULL DEFAULT 0,
    read_at TIMESTAMPTZ,
    last_error TEXT,
    idempotency_key VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.notification_delivery
    ADD COLUMN IF NOT EXISTS template_id BIGINT REFERENCES public.notification_template(id),
    ADD COLUMN IF NOT EXISTS channel VARCHAR(30) DEFAULT 'IN_APP',
    ADD COLUMN IF NOT EXISTS title VARCHAR(250),
    ADD COLUMN IF NOT EXISTS body_content TEXT,
    ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_error TEXT,
    ADD COLUMN IF NOT EXISTS idempotency_key VARCHAR(150),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_notif_delivery_user ON public.notification_delivery(user_account_id, delivery_status);

-- 4. support_ticket
CREATE TABLE IF NOT EXISTS public.support_ticket (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_reference VARCHAR(60),
    user_account_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    subject VARCHAR(200),
    category VARCHAR(50) NOT NULL DEFAULT 'GENERAL',
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    ticket_status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    assigned_admin_user_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    resolution_summary TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.support_ticket
    ADD COLUMN IF NOT EXISTS ticket_reference VARCHAR(60),
    ADD COLUMN IF NOT EXISTS user_account_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS ticket_status VARCHAR(30) DEFAULT 'OPEN',
    ADD COLUMN IF NOT EXISTS assigned_admin_user_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS resolution_summary TEXT,
    ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_support_ticket_user ON public.support_ticket(user_account_id);

-- 5. support_ticket_message
CREATE TABLE IF NOT EXISTS public.support_ticket_message (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    support_ticket_id BIGINT NOT NULL REFERENCES public.support_ticket(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    sender_user_account_id BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    is_staff_reply BOOLEAN NOT NULL DEFAULT FALSE,
    message_body TEXT,
    attachment_storage_reference VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.support_ticket_message
    ADD COLUMN IF NOT EXISTS sender_user_account_id BIGINT REFERENCES public.user_account(id),
    ADD COLUMN IF NOT EXISTS is_staff_reply BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS attachment_storage_reference VARCHAR(500);

CREATE INDEX IF NOT EXISTS idx_support_msg_ticket ON public.support_ticket_message(support_ticket_id);

-- 6. faq_article
CREATE TABLE IF NOT EXISTS public.faq_article (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category VARCHAR(60) NOT NULL DEFAULT 'GENERAL',
    question VARCHAR(300) NOT NULL,
    answer_markdown TEXT,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    view_count INTEGER NOT NULL DEFAULT 0,
    helpful_votes INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

ALTER TABLE public.faq_article
    ADD COLUMN IF NOT EXISTS answer_markdown TEXT,
    ADD COLUMN IF NOT EXISTS view_count INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS helpful_votes INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_faq_article_cat ON public.faq_article(category, is_published);

-- 7. community_discussion
CREATE TABLE IF NOT EXISTS public.community_discussion (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    title VARCHAR(250) NOT NULL,
    body TEXT NOT NULL,
    category VARCHAR(60) NOT NULL DEFAULT 'CAREER_ADVICE',
    view_count INTEGER NOT NULL DEFAULT 0 CHECK (view_count >= 0),
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    is_moderated BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_comm_disc_author ON public.community_discussion(author_user_account_id);

-- 8. community_comment
CREATE TABLE IF NOT EXISTS public.community_comment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    discussion_id BIGINT NOT NULL REFERENCES public.community_discussion(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    author_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    parent_comment_id BIGINT REFERENCES public.community_comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    body TEXT NOT NULL,
    upvotes INTEGER NOT NULL DEFAULT 0 CHECK (upvotes >= 0),
    is_moderated BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_comm_comment_disc ON public.community_comment(discussion_id);

-- =============================================================================
-- MODULE 11: ANALYTICS LAYER, REPORTING AND DATA MARTS
-- =============================================================================

-- 9. analytics_refresh_log
CREATE TABLE IF NOT EXISTS public.analytics_refresh_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mart_name VARCHAR(100) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    rows_processed INTEGER NOT NULL DEFAULT 0,
    refresh_status VARCHAR(30) NOT NULL DEFAULT 'SUCCESS',
    error_message TEXT,
    duration_ms INTEGER,
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_analytics_refresh_mart ON public.analytics_refresh_log(mart_name, refreshed_at);

-- 10. analytics_application_funnel_daily
CREATE TABLE IF NOT EXISTS public.analytics_application_funnel_daily (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_date DATE NOT NULL,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    job_requirement_id BIGINT REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    total_views INTEGER NOT NULL DEFAULT 0,
    total_applications INTEGER NOT NULL DEFAULT 0,
    total_shortlisted INTEGER NOT NULL DEFAULT 0,
    total_interviewed INTEGER NOT NULL DEFAULT 0,
    total_offered INTEGER NOT NULL DEFAULT 0,
    total_joined INTEGER NOT NULL DEFAULT 0,
    total_withdrawn INTEGER NOT NULL DEFAULT 0,
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.analytics_application_funnel_daily
    ADD COLUMN IF NOT EXISTS total_views INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_applications INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_shortlisted INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_interviewed INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_offered INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_joined INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_withdrawn INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS refreshed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_funnel_daily_org ON public.analytics_application_funnel_daily(organisation_id, report_date);

-- 11. analytics_recruiter_velocity
CREATE TABLE IF NOT EXISTS public.analytics_recruiter_velocity (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_month DATE NOT NULL,
    recruiter_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    total_jobs_managed INTEGER NOT NULL DEFAULT 0,
    total_applications_reviewed INTEGER NOT NULL DEFAULT 0,
    avg_hours_to_first_review NUMERIC(8, 2),
    avg_days_to_hire NUMERIC(8, 2),
    total_offers_extended INTEGER NOT NULL DEFAULT 0,
    total_offers_accepted INTEGER NOT NULL DEFAULT 0,
    offer_acceptance_rate_percent NUMERIC(5, 2),
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_recruiter_velocity_rec ON public.analytics_recruiter_velocity(recruiter_user_account_id, report_month);

-- 12. analytics_sourcing_efficiency
CREATE TABLE IF NOT EXISTS public.analytics_sourcing_efficiency (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_date DATE NOT NULL,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    sourcing_channel VARCHAR(60) NOT NULL,
    candidates_sourced INTEGER NOT NULL DEFAULT 0,
    candidates_applied INTEGER NOT NULL DEFAULT 0,
    candidates_hired INTEGER NOT NULL DEFAULT 0,
    channel_conversion_rate NUMERIC(5, 2),
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sourcing_eff_org ON public.analytics_sourcing_efficiency(organisation_id, report_date);

-- 13. analytics_wallet_reconciliation_summary
CREATE TABLE IF NOT EXISTS public.analytics_wallet_reconciliation_summary (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reconciliation_date DATE NOT NULL UNIQUE,
    total_credits_purchased INTEGER NOT NULL DEFAULT 0,
    total_credits_granted INTEGER NOT NULL DEFAULT 0,
    total_credits_consumed INTEGER NOT NULL DEFAULT 0,
    total_credits_refunded INTEGER NOT NULL DEFAULT 0,
    net_active_wallet_balance INTEGER NOT NULL DEFAULT 0,
    total_resumes_downloaded INTEGER NOT NULL DEFAULT 0,
    discrepancy_count INTEGER NOT NULL DEFAULT 0,
    reconciled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_recon_date ON public.analytics_wallet_reconciliation_summary(reconciliation_date);

COMMIT;
