-- =============================================================================
-- Migration: 004_organisation_hierarchy_and_recruitment.sql
-- Module 5: Organisation & Account Architecture
-- Source: Talentra_Modules_4_to_11_Complete_Database_Documentation.md
-- Description:
--   Unifies enterprise account billing profiles, multi-organization hierarchy,
--   team memberships, recruiter assignments, verification, and privacy blocking:
--   1. account_profile
--   2. account_organisation
--   3. organisation_hierarchy
--   4. organisation_member
--   5. organisation_recruiter
--   6. job_recruiter_assignment
--   7. organisation_verification
--   8. user_block
-- =============================================================================

BEGIN;

-- 1. account_profile
CREATE TABLE IF NOT EXISTS public.account_profile (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_code VARCHAR(60) NOT NULL UNIQUE,
    account_name VARCHAR(200) NOT NULL,
    account_type VARCHAR(40) NOT NULL DEFAULT 'ENTERPRISE' CHECK (account_type IN ('ENTERPRISE', 'STANDARD', 'AGENCY', 'INSTITUTION')),
    account_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    primary_organisation_id BIGINT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    billing_email VARCHAR(254) NULL,
    preferred_language_id BIGINT NULL REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    timezone_name VARCHAR(60) NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS idx_account_profile_code ON public.account_profile(account_code);
CREATE INDEX IF NOT EXISTS idx_account_profile_status ON public.account_profile(account_status) WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS set_updated_at ON public.account_profile;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.account_profile
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. account_organisation
CREATE TABLE IF NOT EXISTS public.account_organisation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id BIGINT NOT NULL REFERENCES public.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_account_organisation UNIQUE (account_profile_id, organisation_id)
);

CREATE INDEX IF NOT EXISTS idx_account_org_account ON public.account_organisation(account_profile_id);
CREATE INDEX IF NOT EXISTS idx_account_org_org ON public.account_organisation(organisation_id);


-- 3. organisation_hierarchy
CREATE TABLE IF NOT EXISTS public.organisation_hierarchy (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    child_organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    relationship_type VARCHAR(40) NOT NULL DEFAULT 'SUBSIDIARY',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_org_hierarchy UNIQUE (parent_organisation_id, child_organisation_id),
    CONSTRAINT chk_no_self_parent CHECK (parent_organisation_id <> child_organisation_id)
);

CREATE INDEX IF NOT EXISTS idx_org_hierarchy_parent ON public.organisation_hierarchy(parent_organisation_id);
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_child ON public.organisation_hierarchy(child_organisation_id);


-- 4. organisation_member
CREATE TABLE IF NOT EXISTS public.organisation_member (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    member_role VARCHAR(40) NOT NULL DEFAULT 'MEMBER' CHECK (member_role IN ('OWNER', 'ADMIN', 'MEMBER', 'GUEST')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT uq_organisation_member UNIQUE (organisation_id, user_account_id)
);

CREATE INDEX IF NOT EXISTS idx_org_member_org ON public.organisation_member(organisation_id);
CREATE INDEX IF NOT EXISTS idx_org_member_user ON public.organisation_member(user_account_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.organisation_member;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.organisation_member
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 5. organisation_recruiter
CREATE TABLE IF NOT EXISTS public.organisation_recruiter (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    recruiter_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT chk_recruiter_validity CHECK (valid_to IS NULL OR valid_to > valid_from),
    CONSTRAINT uq_org_recruiter UNIQUE (organisation_id, recruiter_user_account_id)
);

CREATE INDEX IF NOT EXISTS idx_org_recruiter_org ON public.organisation_recruiter(organisation_id);
CREATE INDEX IF NOT EXISTS idx_org_recruiter_user ON public.organisation_recruiter(recruiter_user_account_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.organisation_recruiter;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.organisation_recruiter
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 6. job_recruiter_assignment
CREATE TABLE IF NOT EXISTS public.job_recruiter_assignment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    organisation_recruiter_id BIGINT NOT NULL REFERENCES public.organisation_recruiter(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT uq_job_recruiter_assign UNIQUE (job_requirement_id, organisation_recruiter_id)
);

CREATE INDEX IF NOT EXISTS idx_job_recruiter_assign_job ON public.job_recruiter_assignment(job_requirement_id);
CREATE INDEX IF NOT EXISTS idx_job_recruiter_assign_rec ON public.job_recruiter_assignment(organisation_recruiter_id);


-- 7. organisation_verification
CREATE TABLE IF NOT EXISTS public.organisation_verification (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    verification_status_id BIGINT NOT NULL REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    verified_at TIMESTAMPTZ NULL,
    verified_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    notes TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_org_verification_org ON public.organisation_verification(organisation_id);
CREATE INDEX IF NOT EXISTS idx_org_verification_status ON public.organisation_verification(verification_status_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.organisation_verification;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.organisation_verification
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 8. user_block
CREATE TABLE IF NOT EXISTS public.user_block (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    blocker_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    blocked_user_account_id BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    blocked_organisation_id BIGINT NULL REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_profile_id BIGINT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    reason VARCHAR(500) NULL,
    blocked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT chk_user_block_target CHECK (blocked_user_account_id IS NOT NULL OR blocked_organisation_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_user_block_blocker ON public.user_block(blocker_user_account_id);
CREATE INDEX IF NOT EXISTS idx_user_block_blocked_user ON public.user_block(blocked_user_account_id);
CREATE INDEX IF NOT EXISTS idx_user_block_blocked_org ON public.user_block(blocked_organisation_id);

DROP TRIGGER IF EXISTS set_updated_at ON public.user_block;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_block
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();

COMMIT;
