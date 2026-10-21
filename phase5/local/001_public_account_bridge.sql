-- Phase 3 and the existing Phase 5 seed use the older public.account_profile,
-- while Phase 2 creates organisation.account_profile. This table is required
-- by those SQL files; it follows migrations/004_organisation_hierarchy_and_recruitment.sql.
-- The two account tables are separate and their IDs are not inherently linked.
CREATE TABLE public.account_profile (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_code VARCHAR(60) NOT NULL UNIQUE,
    account_name VARCHAR(200) NOT NULL,
    account_type VARCHAR(40) NOT NULL DEFAULT 'ENTERPRISE'
        CHECK (account_type IN ('ENTERPRISE', 'STANDARD', 'AGENCY', 'INSTITUTION')),
    account_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    primary_organisation_id BIGINT REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    billing_email VARCHAR(254),
    preferred_language_id BIGINT REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    timezone_name VARCHAR(60) DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_account_profile_status ON public.account_profile(account_status)
    WHERE deleted_at IS NULL;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.account_profile
    FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();
