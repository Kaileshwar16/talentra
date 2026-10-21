-- The full legacy 007 migration conflicts with Phase 4's notification table.
-- This is its user_credential definition, required by the shared seed.
CREATE TABLE public.user_credential (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id BIGINT NOT NULL REFERENCES public.user_account(id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    credential_type VARCHAR(30) NOT NULL
        CHECK (credential_type IN ('PASSWORD_HASH', 'API_KEY', 'OAUTH_TOKEN')),
    credential_identifier VARCHAR(254) NOT NULL,
    secret_hash VARCHAR(500),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    failed_attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (failed_attempt_count >= 0),
    locked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_credential UNIQUE (credential_type, credential_identifier)
);
CREATE INDEX idx_user_cred_user ON public.user_credential(user_account_id);
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_credential
    FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();
