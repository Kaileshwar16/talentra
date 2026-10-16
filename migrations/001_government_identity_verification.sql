-- =============================================================================
-- Migration: 001_government_identity_verification.sql
-- Module: Talentra Government Identity Verification Extension
-- Description:
--   Implements the normalized, high-security extension specified in
--   Talentra_Profile_Jobs_Applications_Module.md (lines 3151-3246).
--   Replaces unstructured identity storage with dedicated entities for
--   document storage (with client-side KMS/envelope encryption), verification
--   lifecycle, provider attempts, user consent, and immutable audit logs.
-- =============================================================================

BEGIN;

-- 1. candidate_identity_document
CREATE TABLE IF NOT EXISTS public.candidate_identity_document (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    document_type_id BIGINT NOT NULL REFERENCES public.document_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_document_id BIGINT NULL REFERENCES public.candidate_document(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    issuing_country_id BIGINT NOT NULL REFERENCES public.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    document_number_ciphertext BYTEA NULL,
    document_number_fingerprint BYTEA NULL,
    masked_document_number VARCHAR(40) NULL,
    name_on_document VARCHAR(150) NULL,
    issued_on DATE NULL,
    expires_on DATE NULL,
    document_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (document_status IN ('ACTIVE', 'REPLACED', 'REVOKED', 'EXPIRED', 'WITHDRAWN')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT chk_candidate_id_doc_dates CHECK (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on)
);

-- Indexes for candidate_identity_document
CREATE INDEX IF NOT EXISTS idx_cand_id_doc_candidate_profile_id ON public.candidate_identity_document(candidate_profile_id);
CREATE INDEX IF NOT EXISTS idx_cand_id_doc_document_type_id ON public.candidate_identity_document(document_type_id);
CREATE INDEX IF NOT EXISTS idx_cand_id_doc_issuing_country_id ON public.candidate_identity_document(issuing_country_id);
CREATE INDEX IF NOT EXISTS idx_cand_id_doc_status ON public.candidate_identity_document(document_status) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_cand_id_doc_fingerprint 
    ON public.candidate_identity_document(issuing_country_id, document_type_id, document_number_fingerprint) 
    WHERE document_number_fingerprint IS NOT NULL AND deleted_at IS NULL;

-- Trigger: set_updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.candidate_identity_document;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.candidate_identity_document
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 2. identity_verification
CREATE TABLE IF NOT EXISTS public.identity_verification (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_identity_document_id BIGINT NOT NULL REFERENCES public.candidate_identity_document(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    verification_status_id BIGINT NOT NULL REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    verification_reference UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    verification_method VARCHAR(30) NOT NULL CHECK (verification_method IN ('PROVIDER_API', 'MANUAL', 'DIGITAL_CREDENTIAL')),
    provider_code VARCHAR(80) NULL,
    provider_reference VARCHAR(255) NULL,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMPTZ NULL,
    completed_at TIMESTAMPTZ NULL,
    verified_at TIMESTAMPTZ NULL,
    reviewed_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    rejection_code VARCHAR(80) NULL,
    rejection_reason VARCHAR(1000) NULL,
    last_checked_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_identity_verification_timing CHECK (completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at)
);

-- Indexes for identity_verification
CREATE INDEX IF NOT EXISTS idx_identity_verification_doc_id ON public.identity_verification(candidate_identity_document_id);
CREATE INDEX IF NOT EXISTS idx_identity_verification_status_id ON public.identity_verification(verification_status_id);
CREATE INDEX IF NOT EXISTS idx_identity_verification_reviewed_by ON public.identity_verification(reviewed_by);

-- Trigger: set_updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.identity_verification;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.identity_verification
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 3. identity_verification_attempt (Append-Only)
CREATE TABLE IF NOT EXISTS public.identity_verification_attempt (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    identity_verification_id BIGINT NOT NULL REFERENCES public.identity_verification(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    attempt_number INTEGER NOT NULL CHECK (attempt_number > 0),
    attempt_status VARCHAR(20) NOT NULL CHECK (attempt_status IN ('STARTED', 'PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    provider_code VARCHAR(80) NULL,
    provider_reference VARCHAR(255) NULL,
    failure_code VARCHAR(80) NULL,
    failure_reason VARCHAR(1000) NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_identity_verification_attempt UNIQUE (identity_verification_id, attempt_number),
    CONSTRAINT chk_identity_attempt_timing CHECK (completed_at IS NULL OR completed_at >= started_at)
);

-- Indexes for identity_verification_attempt
CREATE INDEX IF NOT EXISTS idx_id_verif_attempt_parent ON public.identity_verification_attempt(identity_verification_id);

-- Append-Only Triggers for identity_verification_attempt
DROP TRIGGER IF EXISTS reject_mutation ON public.identity_verification_attempt;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.identity_verification_attempt
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.identity_verification_attempt;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.identity_verification_attempt
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();


-- 4. identity_verification_consent
CREATE TABLE IF NOT EXISTS public.identity_verification_consent (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_identity_document_id BIGINT NOT NULL REFERENCES public.candidate_identity_document(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    identity_verification_id BIGINT NULL REFERENCES public.identity_verification(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    purpose_code VARCHAR(80) NOT NULL,
    consent_text_version VARCHAR(50) NOT NULL,
    consent_status VARCHAR(20) NOT NULL CHECK (consent_status IN ('GRANTED', 'DECLINED', 'WITHDRAWN')),
    consented_at TIMESTAMPTZ NULL,
    withdrawn_at TIMESTAMPTZ NULL,
    capture_method VARCHAR(30) NOT NULL CHECK (capture_method IN ('WEB', 'MOBILE', 'ADMIN_ASSISTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- Indexes for identity_verification_consent
CREATE INDEX IF NOT EXISTS idx_id_verif_consent_candidate ON public.identity_verification_consent(candidate_profile_id);
CREATE INDEX IF NOT EXISTS idx_id_verif_consent_doc ON public.identity_verification_consent(candidate_identity_document_id);
CREATE INDEX IF NOT EXISTS idx_id_verif_consent_req ON public.identity_verification_consent(identity_verification_id);

-- Trigger: set_updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.identity_verification_consent;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.identity_verification_consent
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_set_updated_at();


-- 5. identity_verification_audit_log (Append-Only)
CREATE TABLE IF NOT EXISTS public.identity_verification_audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    identity_verification_id BIGINT NULL REFERENCES public.identity_verification(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_identity_document_id BIGINT NULL REFERENCES public.candidate_identity_document(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    actor_user_id BIGINT NULL REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    actor_type VARCHAR(30) NOT NULL CHECK (actor_type IN ('CANDIDATE', 'RECRUITER', 'ADMIN', 'SYSTEM', 'PROVIDER')),
    action_code VARCHAR(80) NOT NULL,
    old_status_id BIGINT NULL REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    new_status_id BIGINT NULL REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    reason_code VARCHAR(80) NULL,
    correlation_id UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for identity_verification_audit_log
CREATE INDEX IF NOT EXISTS idx_id_audit_verification_id ON public.identity_verification_audit_log(identity_verification_id);
CREATE INDEX IF NOT EXISTS idx_id_audit_doc_id ON public.identity_verification_audit_log(candidate_identity_document_id);
CREATE INDEX IF NOT EXISTS idx_id_audit_actor ON public.identity_verification_audit_log(actor_user_id);
CREATE INDEX IF NOT EXISTS idx_id_audit_created_at ON public.identity_verification_audit_log(created_at);

-- Append-Only Triggers for identity_verification_audit_log
DROP TRIGGER IF EXISTS reject_mutation ON public.identity_verification_audit_log;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.identity_verification_audit_log
    FOR EACH ROW
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.identity_verification_audit_log;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.identity_verification_audit_log
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

COMMIT;
