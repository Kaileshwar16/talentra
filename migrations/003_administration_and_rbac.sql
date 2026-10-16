-- =============================================================================
-- Migration: 003_administration_and_rbac.sql
-- Module 4: Administration & Unified RBAC Architecture
-- Source: Talentra_Modules_4_to_11_Complete_Database_Documentation.md
-- Description:
--   Implements a clean, unified administration schema directly in public:
--   1. app_role (Standard System & Enterprise Roles)
--   2. permission (Granular Module-scoped permissions)
--   3. role_permission (M:N role-permission bindings)
--   4. user_role_assignment (User to Role mapping)
--   5. audit_event (Append-Only enterprise compliance log with triggers)
--   6. system_error_log (Operational error logging & resolution)
--   7. consent_record (User compliance, terms, privacy consent history)
-- =============================================================================

BEGIN;

-- 1. app_role
CREATE TABLE IF NOT EXISTS public.app_role (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(60) NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_app_role_code ON public.app_role(code);

DROP TRIGGER IF EXISTS set_updated_at ON public.app_role;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.app_role
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. permission
CREATE TABLE IF NOT EXISTS public.permission (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    permission_code VARCHAR(120) NOT NULL UNIQUE,
    permission_name VARCHAR(150) NOT NULL,
    module_code VARCHAR(60) NOT NULL,
    description TEXT NULL,
    is_sensitive BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_permission_module ON public.permission(module_code);
CREATE INDEX IF NOT EXISTS idx_permission_code ON public.permission(permission_code);

DROP TRIGGER IF EXISTS set_updated_at ON public.permission;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.permission
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 3. role_permission
CREATE TABLE IF NOT EXISTS public.role_permission (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    app_role_id BIGINT NOT NULL REFERENCES public.app_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    permission_id BIGINT NOT NULL REFERENCES public.permission(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    granted_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_role_permission UNIQUE (app_role_id, permission_id)
);

CREATE INDEX IF NOT EXISTS idx_role_perm_role ON public.role_permission(app_role_id);
CREATE INDEX IF NOT EXISTS idx_role_perm_perm ON public.role_permission(permission_id);


-- 4. user_role_assignment
CREATE TABLE IF NOT EXISTS public.user_role_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    app_role_id BIGINT NOT NULL REFERENCES public.app_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_user_role_assignment UNIQUE (user_account_id, app_role_id)
);

CREATE INDEX IF NOT EXISTS idx_user_role_user ON public.user_role_assignment(user_account_id);
CREATE INDEX IF NOT EXISTS idx_user_role_role ON public.user_role_assignment(app_role_id);


-- 5. audit_event (Append-Only)
CREATE TABLE IF NOT EXISTS public.audit_event (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_user_account_id BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    action_code VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT NULL,
    outcome VARCHAR(30) NOT NULL CHECK (outcome IN ('SUCCESS', 'FAILURE', 'DENIED', 'ERROR')),
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET NULL,
    user_agent TEXT NULL,
    correlation_id UUID NULL,
    request_id VARCHAR(100) NULL,
    reason TEXT NULL,
    before_data JSONB NULL,
    after_data JSONB NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(metadata) = 'object')
);

CREATE INDEX IF NOT EXISTS idx_audit_event_actor_time ON public.audit_event(actor_user_account_id, occurred_at);
CREATE INDEX IF NOT EXISTS idx_audit_event_entity_time ON public.audit_event(entity_type, entity_id, occurred_at);
CREATE INDEX IF NOT EXISTS idx_audit_event_action ON public.audit_event(action_code);

DROP TRIGGER IF EXISTS reject_mutation ON public.audit_event;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.audit_event
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.audit_event;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.audit_event
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();


-- 6. system_error_log (Operational Error Log)
CREATE TABLE IF NOT EXISTS public.system_error_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    error_code VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    service_name VARCHAR(100) NOT NULL,
    operation_name VARCHAR(150) NULL,
    safe_message VARCHAR(2000) NOT NULL,
    stack_reference TEXT NULL,
    correlation_id UUID NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ NULL,
    resolved_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    resolution_note TEXT NULL,
    CONSTRAINT chk_error_resolution CHECK (resolved_at IS NULL OR resolved_at >= occurred_at)
);

CREATE INDEX IF NOT EXISTS idx_system_error_code ON public.system_error_log(error_code);
CREATE INDEX IF NOT EXISTS idx_system_error_service ON public.system_error_log(service_name);
CREATE INDEX IF NOT EXISTS idx_system_error_time ON public.system_error_log(occurred_at);


-- 7. consent_record
CREATE TABLE IF NOT EXISTS public.consent_record (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    consent_type VARCHAR(60) NOT NULL,
    consent_version VARCHAR(30) NOT NULL,
    is_granted BOOLEAN NOT NULL DEFAULT TRUE,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    withdrawn_at TIMESTAMPTZ NULL,
    ip_address INET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(metadata) = 'object'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_consent_withdrawal CHECK (withdrawn_at IS NULL OR withdrawn_at >= recorded_at)
);

CREATE INDEX IF NOT EXISTS idx_consent_user_type ON public.consent_record(user_account_id, consent_type);

DROP TRIGGER IF EXISTS set_updated_at ON public.consent_record;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.consent_record
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();

-- 8. Seed Core Administrative Roles & Essential Permissions
INSERT INTO public.app_role (code, display_name, description)
VALUES
    ('super_admin', 'Super Administrator', 'Full platform administrative access'),
    ('org_admin', 'Organization Administrator', 'Full access within assigned organization'),
    ('recruiter', 'Recruiter', 'Manages jobs, candidates, and hiring pipelines'),
    ('candidate', 'Candidate', 'Manages own profile, applications, and documents'),
    ('consultant', 'Consultant', 'External sourcing partner on authorized jobs')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    description = EXCLUDED.description;

INSERT INTO public.permission (permission_code, permission_name, module_code, is_sensitive)
VALUES
    ('admin.system.manage', 'Manage System Configuration', 'admin', TRUE),
    ('admin.audit.read', 'Read Audit Logs', 'admin', TRUE),
    ('org.profile.manage', 'Manage Organization Profile', 'organisation', FALSE),
    ('org.recruiter.manage', 'Manage Organization Recruiters', 'organisation', FALSE),
    ('job.create', 'Create Job Requirement', 'jobs', FALSE),
    ('job.publish', 'Publish Job Requirement', 'jobs', FALSE),
    ('job.close', 'Close Job Requirement', 'jobs', FALSE),
    ('application.read', 'View Applications', 'applications', FALSE),
    ('application.decision', 'Make Application Decision', 'applications', FALSE),
    ('candidate.profile.read', 'View Candidate Profile', 'candidate', FALSE),
    ('candidate.verify.identity', 'Verify Candidate Identity', 'identity', TRUE)
ON CONFLICT (permission_code) DO UPDATE
SET permission_name = EXCLUDED.permission_name,
    module_code = EXCLUDED.module_code,
    is_sensitive = EXCLUDED.is_sensitive;

COMMIT;
