-- Migration 008: Complete Modules 4 to 11 Enterprise Entities & Cross-Schema Compatibility
-- Purpose: Create all remaining entities across Modules 4-11 (59, 29, 32, 24, 39, 14, 23, 22 entity references = 242 total)
-- Resolving 100% of the 142 unique documented entities in Neon PostgreSQL.

-- 1. Create Core Missing Tables in public

-- Module 4 & 7: account_role
CREATE TABLE IF NOT EXISTS public.account_role (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_code VARCHAR(60) NOT NULL UNIQUE,
    role_name VARCHAR(120) NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT false NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by BIGINT
);

INSERT INTO public.account_role (role_code, role_name, description, is_system_role, is_active, sort_order)
VALUES 
    ('super_admin', 'Super Administrator', 'Complete platform governance and system configuration', true, true, 1),
    ('org_admin', 'Organisation Administrator', 'Full tenant organization administration and billing oversight', true, true, 2),
    ('recruiter', 'Recruiter', 'Recruitment pipeline, job management, candidate evaluation and hiring', true, true, 3),
    ('candidate', 'Candidate', 'Job applicant, verified profile holder, and gig contractor', true, true, 4),
    ('consultant', 'Consultant', 'External specialist recruiter or staffing partner', false, true, 5)
ON CONFLICT (role_code) DO NOTHING;

-- Module 4: account_status_history
CREATE TABLE IF NOT EXISTS public.account_status_history (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    change_reason TEXT,
    changed_by BIGINT,
    changed_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_account_status_history_user ON public.account_status_history(user_account_id, changed_at);

-- Module 4, 7, 11: login_attempt
CREATE TABLE IF NOT EXISTS public.login_attempt (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_account_id BIGINT REFERENCES public.user_account(id) ON DELETE SET NULL,
    login_identifier VARCHAR(254) NOT NULL,
    attempted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    ip_address INET,
    user_agent TEXT,
    attempt_result VARCHAR(30) NOT NULL,
    failure_reason_code VARCHAR(50),
    correlation_id UUID,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_login_attempt_user ON public.login_attempt(user_account_id, attempted_at);
CREATE INDEX IF NOT EXISTS idx_login_attempt_time ON public.login_attempt(attempted_at);

-- Module 5 & 7: user_role
CREATE TABLE IF NOT EXISTS public.user_role (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE CASCADE,
    account_role_id BIGINT NOT NULL REFERENCES public.account_role(id) ON DELETE RESTRICT,
    scope_type VARCHAR(30) DEFAULT 'GLOBAL' NOT NULL,
    scope_organisation_id BIGINT REFERENCES public.organisation(id) ON DELETE SET NULL,
    valid_from TIMESTAMPTZ DEFAULT now() NOT NULL,
    valid_until TIMESTAMPTZ,
    assigned_by BIGINT,
    assignment_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT user_role_check CHECK (valid_until IS NULL OR valid_until > valid_from)
);
CREATE INDEX IF NOT EXISTS idx_user_role_user ON public.user_role(user_account_id);

-- Module 7, 9, 10: user_preference
CREATE TABLE IF NOT EXISTS public.user_preference (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE CASCADE,
    preference_key VARCHAR(100) NOT NULL,
    preference_value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT uq_user_preference_key UNIQUE(user_account_id, preference_key)
);

-- Module 7: identity_session
CREATE TABLE IF NOT EXISTS public.identity_session (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE CASCADE,
    session_token_hash TEXT NOT NULL UNIQUE,
    device_id BIGINT,
    ip_address INET,
    user_agent TEXT,
    source_timezone VARCHAR(60),
    started_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    last_activity_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    end_reason VARCHAR(40),
    session_status VARCHAR(30) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT identity_session_expiry_check CHECK (expires_at > started_at),
    CONSTRAINT identity_session_ended_check CHECK (ended_at IS NULL OR ended_at >= started_at)
);
CREATE INDEX IF NOT EXISTS idx_identity_session_user_status ON public.identity_session(user_account_id, session_status, expires_at);

-- Module 4 & 7: identity_db_principal
CREATE TABLE IF NOT EXISTS public.identity_db_principal (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    db_role_name NAME NOT NULL UNIQUE,
    user_account_id BIGINT NOT NULL UNIQUE REFERENCES public.user_account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

-- Module 5 & 8: organisation_account_admin
CREATE TABLE IF NOT EXISTS public.organisation_account_admin (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE CASCADE,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE CASCADE,
    admin_type VARCHAR(40) DEFAULT 'ACCOUNT_ADMIN' NOT NULL,
    is_primary BOOLEAN DEFAULT false NOT NULL,
    valid_from TIMESTAMPTZ DEFAULT now() NOT NULL,
    valid_until TIMESTAMPTZ,
    appointed_by BIGINT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT uq_organisation_account_admin UNIQUE(organisation_id, user_account_id, admin_type),
    CONSTRAINT organisation_account_admin_validity_check CHECK (valid_until IS NULL OR valid_until > valid_from)
);
CREATE INDEX IF NOT EXISTS idx_org_account_admin_org ON public.organisation_account_admin(organisation_id);

-- Module 5: organisation_external_system
CREATE TABLE IF NOT EXISTS public.organisation_external_system (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE CASCADE,
    system_code VARCHAR(60) NOT NULL,
    external_organisation_reference VARCHAR(200) NOT NULL,
    sync_direction VARCHAR(20) DEFAULT 'INBOUND' NOT NULL,
    last_synced_at TIMESTAMPTZ,
    sync_status VARCHAR(30) DEFAULT 'PENDING' NOT NULL,
    last_error TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT uq_org_ext_system_ref UNIQUE(system_code, external_organisation_reference)
);

-- Module 5: organisation_identifier
CREATE TABLE IF NOT EXISTS public.organisation_identifier (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    identifier_ciphertext BYTEA NOT NULL,
    identifier_fingerprint CHAR(64) NOT NULL,
    verified_at TIMESTAMPTZ,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE CASCADE,
    country_id BIGINT NOT NULL REFERENCES public.country(id),
    identifier_type_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_org_identifier_fingerprint UNIQUE(country_id, identifier_type_id, identifier_fingerprint),
    CONSTRAINT chk_org_identifier_fingerprint CHECK (identifier_fingerprint ~ '^[a-f0-9]{64}$')
);
CREATE INDEX IF NOT EXISTS idx_org_identifier_org ON public.organisation_identifier(organisation_id);

-- Module 5: organisation_location
CREATE TABLE IF NOT EXISTS public.organisation_location (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    location_name VARCHAR(150),
    address_line_1 VARCHAR(250) NOT NULL,
    address_line_2 VARCHAR(250),
    postal_code VARCHAR(30),
    is_primary BOOLEAN DEFAULT false NOT NULL,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE CASCADE,
    city_id BIGINT REFERENCES public.city(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_org_location_org ON public.organisation_location(organisation_id);

-- Module 5 & 11: organisation_status_history
CREATE TABLE IF NOT EXISTS public.organisation_status_history (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by BIGINT,
    reason TEXT,
    changed_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_org_status_history_org ON public.organisation_status_history(organisation_id, changed_at);

-- Module 5 & 11: organisation_verification_history
CREATE TABLE IF NOT EXISTS public.organisation_verification_history (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organisation_verification_id BIGINT NOT NULL REFERENCES public.organisation_verification(id) ON DELETE CASCADE,
    previous_outcome VARCHAR(30),
    new_outcome VARCHAR(30) NOT NULL,
    changed_by BIGINT,
    change_reason TEXT,
    changed_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_org_verif_hist_id ON public.organisation_verification_history(organisation_verification_id, changed_at);

-- Module 6 & 8: gig_worker_availability
CREATE TABLE IF NOT EXISTS public.gig_worker_availability (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON DELETE CASCADE,
    available_from TIMESTAMPTZ NOT NULL,
    available_until TIMESTAMPTZ NOT NULL,
    availability_status VARCHAR(30) DEFAULT 'AVAILABLE' NOT NULL,
    recurrence_rule TEXT,
    timezone_name VARCHAR(60) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT gig_worker_availability_check CHECK (available_until > available_from)
);
CREATE INDEX IF NOT EXISTS idx_gig_availability_worker_window ON public.gig_worker_availability(gig_worker_profile_id, available_from, available_until);

-- Module 6 & 8: gig_application_status_history
CREATE TABLE IF NOT EXISTS public.gig_application_status_history (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    gig_application_id BIGINT NOT NULL REFERENCES public.gig_application(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by BIGINT,
    reason TEXT,
    changed_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_gig_app_status_hist ON public.gig_application_status_history(gig_application_id, changed_at);

-- Module 6, 8, 10, 11: gig_event
CREATE TABLE IF NOT EXISTS public.gig_event (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    gig_request_id BIGINT REFERENCES public.gig_request(id) ON DELETE CASCADE,
    gig_application_id BIGINT REFERENCES public.gig_application(id) ON DELETE CASCADE,
    gig_assignment_id BIGINT REFERENCES public.gig_assignment(id) ON DELETE CASCADE,
    actor_user_account_id BIGINT REFERENCES public.user_account(id) ON DELETE SET NULL,
    event_type VARCHAR(60) NOT NULL,
    event_payload JSONB DEFAULT '{}' NOT NULL,
    occurred_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    correlation_id UUID,
    CONSTRAINT gig_event_check CHECK (num_nonnulls(gig_request_id, gig_application_id, gig_assignment_id) >= 1)
);
CREATE INDEX IF NOT EXISTS idx_gig_event_time ON public.gig_event(occurred_at);

-- Module 6 & 8: gig_fulfilment_handoff
CREATE TABLE IF NOT EXISTS public.gig_fulfilment_handoff (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    gig_assignment_id BIGINT NOT NULL REFERENCES public.gig_assignment(id) ON DELETE CASCADE,
    external_system_code VARCHAR(60) NOT NULL,
    external_handoff_reference VARCHAR(200) NOT NULL,
    handoff_status VARCHAR(30) DEFAULT 'PENDING' NOT NULL,
    sent_at TIMESTAMPTZ,
    acknowledged_at TIMESTAMPTZ,
    last_reconciled_at TIMESTAMPTZ,
    external_status VARCHAR(60),
    last_error TEXT,
    idempotency_key VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT uq_gig_fulfilment_handoff_ref UNIQUE(external_system_code, external_handoff_reference)
);

-- Module 6 & 8: gig_worker_project
CREATE TABLE IF NOT EXISTS public.gig_worker_project (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(150) NOT NULL,
    project_role VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    outcome VARCHAR(4000),
    gig_worker_profile_id BIGINT NOT NULL REFERENCES public.gig_worker_profile(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT gig_worker_project_dates_check CHECK (end_date IS NULL OR end_date >= start_date)
);
CREATE INDEX IF NOT EXISTS idx_gig_worker_project_worker ON public.gig_worker_project(gig_worker_profile_id);

-- Module 6 & 8: gig_fulfilment_event
CREATE TABLE IF NOT EXISTS public.gig_fulfilment_event (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    external_system_code VARCHAR(80) NOT NULL,
    external_event_id VARCHAR(200) NOT NULL,
    event_kind VARCHAR(80) NOT NULL,
    observed_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payload_digest CHAR(64),
    gig_assignment_id BIGINT NOT NULL REFERENCES public.gig_assignment(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_gig_fulfilment_event_ext UNIQUE(external_system_code, external_event_id),
    CONSTRAINT chk_gig_fulfilment_payload_digest CHECK (payload_digest IS NULL OR payload_digest ~ '^[a-f0-9]{64}$')
);
CREATE INDEX IF NOT EXISTS idx_gig_fulfilment_event_assign ON public.gig_fulfilment_event(gig_assignment_id);

-- 2. Domain Lookup & Status Tables

-- Helper tables with reference_code_id linkage
CREATE TABLE IF NOT EXISTS public.gig_pricing_model (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.gig_rate_unit (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.gig_request_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.gig_assignment_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.gig_availability_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.gig_worker_list_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.identity_credential_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.identity_hash_algorithm (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.identity_session_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.identity_consent_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.identity_account_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.organisation_identifier_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.organisation_verification_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.organisation_account_status (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.organisation_type (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code VARCHAR(80) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    reference_code_id BIGINT NOT NULL UNIQUE REFERENCES public.reference_code(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by BIGINT,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    deleted_at TIMESTAMPTZ
);

-- Seed lookup values with valid reference_code records
DO $$
DECLARE
    ref_id BIGINT;
    rec RECORD;
BEGIN
    FOR rec IN SELECT * FROM (VALUES
        ('GIG_PRICING_FIXED', 'Fixed Price', 'pricing_model', 'gig_pricing_model'),
        ('GIG_PRICING_HOURLY', 'Hourly Rate', 'pricing_model', 'gig_pricing_model'),
        ('GIG_RATE_HOUR', 'Per Hour', 'rate_unit', 'gig_rate_unit'),
        ('GIG_RATE_DAY', 'Per Day', 'rate_unit', 'gig_rate_unit'),
        ('GIG_RATE_PROJECT', 'Per Project', 'rate_unit', 'gig_rate_unit'),
        ('GIG_REQ_DRAFT', 'Draft', 'request_status', 'gig_request_status'),
        ('GIG_REQ_OPEN', 'Open for Bids', 'request_status', 'gig_request_status'),
        ('GIG_REQ_FILLED', 'Filled', 'request_status', 'gig_request_status'),
        ('GIG_REQ_CANCELLED', 'Cancelled', 'request_status', 'gig_request_status'),
        ('GIG_ASG_PENDING', 'Pending Start', 'assignment_status', 'gig_assignment_status'),
        ('GIG_ASG_ACTIVE', 'In Progress', 'assignment_status', 'gig_assignment_status'),
        ('GIG_ASG_COMPLETED', 'Completed', 'assignment_status', 'gig_assignment_status'),
        ('GIG_AVAIL_AVAILABLE', 'Available', 'availability_status', 'gig_availability_status'),
        ('GIG_AVAIL_BUSY', 'Busy', 'availability_status', 'gig_availability_status'),
        ('GIG_LIST_FAVOURITES', 'Favourite Contractors', 'worker_list_type', 'gig_worker_list_type'),
        ('ID_CRED_PASSWORD', 'Password Hash', 'credential_type', 'identity_credential_type'),
        ('ID_CRED_API_KEY', 'API Key Token', 'credential_type', 'identity_credential_type'),
        ('ID_HASH_ARGON2ID', 'Argon2id', 'hash_algorithm', 'identity_hash_algorithm'),
        ('ID_HASH_BCRYPT', 'Bcrypt', 'hash_algorithm', 'identity_hash_algorithm'),
        ('ID_SESS_ACTIVE', 'Active Session', 'session_status', 'identity_session_status'),
        ('ID_SESS_REVOKED', 'Revoked Session', 'session_status', 'identity_session_status'),
        ('ID_CONS_TOS', 'Terms of Service', 'consent_type', 'identity_consent_type'),
        ('ID_CONS_PRIVACY', 'Privacy Policy', 'consent_type', 'identity_consent_type'),
        ('ID_ACCT_ACTIVE', 'Active Account', 'account_status', 'identity_account_status'),
        ('ID_ACCT_SUSPENDED', 'Suspended Account', 'account_status', 'identity_account_status'),
        ('ORG_ID_CIN', 'Corporate Identification Number (CIN)', 'identifier_type', 'organisation_identifier_type'),
        ('ORG_ID_GSTIN', 'GST Identification Number', 'identifier_type', 'organisation_identifier_type'),
        ('ORG_VERIF_KYB', 'Know Your Business (KYB)', 'verification_type', 'organisation_verification_type'),
        ('ORG_ACCT_ACTIVE', 'Active Organisation Account', 'account_status', 'organisation_account_status'),
        ('ORG_TYPE_CORP', 'Corporate / Enterprise', 'organisation_type', 'organisation_type'),
        ('ORG_TYPE_STARTUP', 'Startup', 'organisation_type', 'organisation_type'),
        ('ORG_TYPE_AGENCY', 'Staffing / Recruitment Agency', 'organisation_type', 'organisation_type')
    ) AS t(code, display_name, domain_code, target_table)
    LOOP
        INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order)
        VALUES (rec.domain_code, rec.code, rec.display_name, true, 10)
        ON CONFLICT (domain_code, code) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id INTO ref_id;

        IF rec.target_table = 'gig_pricing_model' THEN
            INSERT INTO public.gig_pricing_model (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'gig_rate_unit' THEN
            INSERT INTO public.gig_rate_unit (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'gig_request_status' THEN
            INSERT INTO public.gig_request_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'gig_assignment_status' THEN
            INSERT INTO public.gig_assignment_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'gig_availability_status' THEN
            INSERT INTO public.gig_availability_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'gig_worker_list_type' THEN
            INSERT INTO public.gig_worker_list_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'identity_credential_type' THEN
            INSERT INTO public.identity_credential_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'identity_hash_algorithm' THEN
            INSERT INTO public.identity_hash_algorithm (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'identity_session_status' THEN
            INSERT INTO public.identity_session_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'identity_consent_type' THEN
            INSERT INTO public.identity_consent_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'identity_account_status' THEN
            INSERT INTO public.identity_account_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'organisation_identifier_type' THEN
            INSERT INTO public.organisation_identifier_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'organisation_verification_type' THEN
            INSERT INTO public.organisation_verification_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'organisation_account_status' THEN
            INSERT INTO public.organisation_account_status (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        ELSIF rec.target_table = 'organisation_type' THEN
            INSERT INTO public.organisation_type (code, display_name, reference_code_id)
            VALUES (rec.code, rec.display_name, ref_id) ON CONFLICT (code) DO NOTHING;
        END IF;
    END LOOP;
END $$;

-- 3. Create Compatibility Schemas and Views for all 45 Legacy Schema-Qualified References

CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS organisation;
CREATE SCHEMA IF NOT EXISTS gig;

-- identity views
CREATE OR REPLACE VIEW identity.audit_event AS SELECT * FROM public.audit_event;
CREATE OR REPLACE VIEW identity.system_error_log AS SELECT * FROM public.system_error_log;
CREATE OR REPLACE VIEW identity.permission AS SELECT * FROM public.permission;
CREATE OR REPLACE VIEW identity.role_permission AS SELECT * FROM public.role_permission;
CREATE OR REPLACE VIEW identity.app_role AS SELECT * FROM public.app_role;
CREATE OR REPLACE VIEW identity.user_role AS SELECT * FROM public.user_role;
CREATE OR REPLACE VIEW identity.user_block AS SELECT * FROM public.user_block;
CREATE OR REPLACE VIEW identity.user_consent AS SELECT * FROM public.consent_record;
CREATE OR REPLACE VIEW identity.credential AS SELECT * FROM public.user_credential;
CREATE OR REPLACE VIEW identity.session_record AS SELECT * FROM public.identity_session;
CREATE OR REPLACE VIEW identity.db_principal AS SELECT * FROM public.identity_db_principal;
CREATE OR REPLACE VIEW identity.account_status AS SELECT * FROM public.identity_account_status;
CREATE OR REPLACE VIEW identity.consent_type AS SELECT * FROM public.identity_consent_type;
CREATE OR REPLACE VIEW identity.credential_type AS SELECT * FROM public.identity_credential_type;
CREATE OR REPLACE VIEW identity.hash_algorithm AS SELECT * FROM public.identity_hash_algorithm;
CREATE OR REPLACE VIEW identity.session_status AS SELECT * FROM public.identity_session_status;

-- organisation views
CREATE OR REPLACE VIEW organisation.account_profile AS SELECT * FROM public.account_profile;
CREATE OR REPLACE VIEW organisation.account_administrator AS SELECT * FROM public.organisation_account_admin;
CREATE OR REPLACE VIEW organisation.organisation_member AS SELECT * FROM public.organisation_member;
CREATE OR REPLACE VIEW organisation.organisation_recruiter AS SELECT * FROM public.organisation_recruiter;
CREATE OR REPLACE VIEW organisation.job_recruiter_assignment AS SELECT * FROM public.job_recruiter_assignment;
CREATE OR REPLACE VIEW organisation.organisation_identifier AS SELECT * FROM public.organisation_identifier;
CREATE OR REPLACE VIEW organisation.organisation_location AS SELECT * FROM public.organisation_location;
CREATE OR REPLACE VIEW organisation.verification_record AS SELECT * FROM public.organisation_verification;
CREATE OR REPLACE VIEW organisation.organisation_type AS SELECT * FROM public.organisation_type;
CREATE OR REPLACE VIEW organisation.account_status AS SELECT * FROM public.organisation_account_status;
CREATE OR REPLACE VIEW organisation.identifier_type AS SELECT * FROM public.organisation_identifier_type;
CREATE OR REPLACE VIEW organisation.verification_type AS SELECT * FROM public.organisation_verification_type;

-- gig views
CREATE OR REPLACE VIEW gig.gig_request AS SELECT * FROM public.gig_request;
CREATE OR REPLACE VIEW gig.gig_service AS SELECT * FROM public.gig_service;
CREATE OR REPLACE VIEW gig.gig_worker_profile AS SELECT * FROM public.gig_worker_profile;
CREATE OR REPLACE VIEW gig.gig_worker_list_entry AS SELECT * FROM public.gig_worker_list_entry;
CREATE OR REPLACE VIEW gig.gig_application AS SELECT * FROM public.gig_application;
CREATE OR REPLACE VIEW gig.gig_assignment AS SELECT * FROM public.gig_assignment;
CREATE OR REPLACE VIEW gig.gig_rating AS SELECT * FROM public.gig_rating;
CREATE OR REPLACE VIEW gig.gig_availability AS SELECT * FROM public.gig_worker_availability;
CREATE OR REPLACE VIEW gig.worker_project AS SELECT * FROM public.gig_worker_project;
CREATE OR REPLACE VIEW gig.application_status AS SELECT * FROM public.application_status;
CREATE OR REPLACE VIEW gig.fulfilment_event AS SELECT * FROM public.gig_fulfilment_event;
CREATE OR REPLACE VIEW gig.pricing_model AS SELECT * FROM public.gig_pricing_model;
CREATE OR REPLACE VIEW gig.rate_unit AS SELECT * FROM public.gig_rate_unit;
CREATE OR REPLACE VIEW gig.request_status AS SELECT * FROM public.gig_request_status;
CREATE OR REPLACE VIEW gig.assignment_status AS SELECT * FROM public.gig_assignment_status;
CREATE OR REPLACE VIEW gig.availability_status AS SELECT * FROM public.gig_availability_status;
CREATE OR REPLACE VIEW gig.worker_list_type AS SELECT * FROM public.gig_worker_list_type;

