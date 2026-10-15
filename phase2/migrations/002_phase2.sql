-- Talentra Phase 2 / docket B24-B35. Run once after Phase 1.
-- Includes Administration, Organisation/account, and Gig marketplace.
-- The app principal is a dedicated database login role mapped to user_account;
-- shared runtime roles never trust client-writable custom GUCs for identity.

BEGIN;

SET LOCAL lock_timeout = '5s';

SET LOCAL statement_timeout = '120s';

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE SCHEMA identity;

CREATE SCHEMA organisation;

CREATE SCHEMA gig;

CREATE ROLE talentra_runtime NOLOGIN;

CREATE TABLE identity.account_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.credential_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.hash_algorithm (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.consent_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.session_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.app_role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(60) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.permission (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.role_permission (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.user_role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  user_account_id BIGINT NOT NULL,
  app_role_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.db_principal (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  db_role_name NAME NOT NULL UNIQUE,
  user_account_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.credential (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  secret_hash VARCHAR(500),
  external_reference VARCHAR(500),
  issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  user_account_id BIGINT NOT NULL,
  credential_type_id BIGINT NOT NULL,
  hash_algorithm_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.session_record (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  neon_auth_session_id UUID UNIQUE,
  session_digest CHAR(64) NOT NULL UNIQUE CHECK (session_digest ~ '^[a-f0-9]{64}$'),
  started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ,
  last_activity_at TIMESTAMPTZ,
  user_account_id BIGINT NOT NULL,
  session_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.user_consent (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  consent_version VARCHAR(40) NOT NULL,
  granted BOOLEAN NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  withdrawn_at TIMESTAMPTZ,
  user_account_id BIGINT NOT NULL,
  consent_type_id BIGINT NOT NULL,
  language_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.user_block (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reason VARCHAR(500),
  candidate_profile_id BIGINT NOT NULL,
  blocked_user_account_id BIGINT,
  blocked_organisation_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.audit_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action_code VARCHAR(100) NOT NULL,
  entity_schema VARCHAR(80) NOT NULL,
  entity_table VARCHAR(100) NOT NULL,
  entity_id BIGINT,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  request_id UUID,
  source_ip INET,
  details JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(details) = 'object'),
  actor_user_account_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE identity.system_error_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  error_code VARCHAR(100) NOT NULL,
  severity VARCHAR(40) NOT NULL,
  component_name VARCHAR(100) NOT NULL,
  safe_message VARCHAR(2000) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  correlation_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.account_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.organisation_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.identifier_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.verification_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.account_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_name VARCHAR(150) NOT NULL,
  account_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.organisation_location (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  location_name VARCHAR(150),
  address_line_1 VARCHAR(250) NOT NULL,
  address_line_2 VARCHAR(250),
  postal_code VARCHAR(30),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  organisation_id BIGINT NOT NULL,
  city_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.organisation_identifier (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  identifier_ciphertext BYTEA NOT NULL,
  identifier_fingerprint CHAR(64) NOT NULL CHECK (identifier_fingerprint ~ '^[a-f0-9]{64}$'),
  verified_at TIMESTAMPTZ,
  organisation_id BIGINT NOT NULL,
  country_id BIGINT NOT NULL,
  identifier_type_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.verification_record (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  provider_code VARCHAR(80) NOT NULL,
  provider_reference VARCHAR(200),
  checked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  verified_at TIMESTAMPTZ,
  failure_code VARCHAR(80),
  organisation_id BIGINT NOT NULL,
  verification_type_id BIGINT NOT NULL,
  verification_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.organisation_recruiter (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  organisation_id BIGINT NOT NULL,
  recruiter_user_account_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.account_administrator (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  account_profile_id BIGINT NOT NULL,
  user_account_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.organisation_member (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  organisation_id BIGINT NOT NULL,
  user_account_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE organisation.job_recruiter_assignment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  job_requirement_id BIGINT NOT NULL,
  organisation_id BIGINT NOT NULL,
  recruiter_user_account_id BIGINT NOT NULL,
  organisation_recruiter_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.availability_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.request_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.pricing_model (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.application_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.assignment_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.rate_unit (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.worker_list_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_worker_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  public_name VARCHAR(150) NOT NULL,
  bio VARCHAR(4000),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  user_account_id BIGINT NOT NULL,
  home_city_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_service (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  service_name VARCHAR(150) NOT NULL,
  description VARCHAR(2000),
  rate_amount NUMERIC(18,2) NOT NULL CHECK (rate_amount >= 0),
  gig_worker_profile_id BIGINT NOT NULL,
  currency_id BIGINT NOT NULL,
  rate_unit_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_availability (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  available_from TIMESTAMPTZ NOT NULL,
  available_to TIMESTAMPTZ NOT NULL,
  gig_worker_profile_id BIGINT NOT NULL,
  availability_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_request (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  price_amount NUMERIC(18,2) NOT NULL CHECK (price_amount >= 0),
  source_timezone VARCHAR(100) NOT NULL DEFAULT 'UTC',
  requester_organisation_id BIGINT NOT NULL,
  requester_user_account_id BIGINT NOT NULL,
  pricing_model_id BIGINT NOT NULL,
  currency_id BIGINT NOT NULL,
  request_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_application (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  proposed_amount NUMERIC(18,2) CHECK (proposed_amount >= 0),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  decided_at TIMESTAMPTZ,
  gig_request_id BIGINT NOT NULL,
  gig_worker_profile_id BIGINT NOT NULL,
  application_status_id BIGINT NOT NULL,
  proposed_currency_id BIGINT,
  decision_by_user_account_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_assignment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_system_code VARCHAR(80) NOT NULL,
  handoff_reference VARCHAR(200) NOT NULL,
  assignment_start_at TIMESTAMPTZ NOT NULL,
  assignment_end_at TIMESTAMPTZ NOT NULL,
  handed_off_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reconciled_at TIMESTAMPTZ,
  estimated_earnings NUMERIC(18,2) CHECK (estimated_earnings >= 0),
  total_earnings NUMERIC(18,2) CHECK (total_earnings >= 0),
  projected_earnings NUMERIC(18,2) CHECK (projected_earnings >= 0),
  gig_application_id BIGINT NOT NULL,
  gig_request_id BIGINT NOT NULL,
  gig_worker_profile_id BIGINT NOT NULL,
  assignment_status_id BIGINT NOT NULL,
  estimated_currency_id BIGINT,
  total_currency_id BIGINT,
  projected_currency_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_worker_list_entry (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  requester_organisation_id BIGINT NOT NULL,
  gig_worker_profile_id BIGINT NOT NULL,
  worker_list_type_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.gig_rating (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  rating_value SMALLINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
  review_text VARCHAR(2000),
  gig_assignment_id BIGINT NOT NULL,
  requester_user_account_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.fulfilment_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_system_code VARCHAR(80) NOT NULL,
  external_event_id VARCHAR(200) NOT NULL,
  event_kind VARCHAR(80) NOT NULL,
  observed_at TIMESTAMPTZ NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  payload_digest CHAR(64) CHECK (payload_digest ~ '^[a-f0-9]{64}$'),
  gig_assignment_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE gig.worker_project (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  project_role VARCHAR(150) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  outcome VARCHAR(4000),
  gig_worker_profile_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

ALTER TABLE identity.account_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_reference_code_id ON identity.account_status (reference_code_id);

ALTER TABLE identity.credential_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_type_reference_code_id ON identity.credential_type (reference_code_id);

ALTER TABLE identity.hash_algorithm ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hash_algorithm_reference_code_id ON identity.hash_algorithm (reference_code_id);

ALTER TABLE identity.consent_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_consent_type_reference_code_id ON identity.consent_type (reference_code_id);

ALTER TABLE identity.session_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_status_reference_code_id ON identity.session_status (reference_code_id);

ALTER TABLE identity.role_permission ADD FOREIGN KEY (app_role_id) REFERENCES identity.app_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_role_permission_app_role_id ON identity.role_permission (app_role_id);

ALTER TABLE identity.role_permission ADD FOREIGN KEY (permission_id) REFERENCES identity.permission(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_role_permission_permission_id ON identity.role_permission (permission_id);

ALTER TABLE identity.user_role ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_role_user_account_id ON identity.user_role (user_account_id);

ALTER TABLE identity.user_role ADD FOREIGN KEY (app_role_id) REFERENCES identity.app_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_role_app_role_id ON identity.user_role (app_role_id);

ALTER TABLE identity.db_principal ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_db_principal_user_account_id ON identity.db_principal (user_account_id);

ALTER TABLE identity.credential ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_user_account_id ON identity.credential (user_account_id);

ALTER TABLE identity.credential ADD FOREIGN KEY (credential_type_id) REFERENCES identity.credential_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_credential_type_id ON identity.credential (credential_type_id);

ALTER TABLE identity.credential ADD FOREIGN KEY (hash_algorithm_id) REFERENCES identity.hash_algorithm(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_hash_algorithm_id ON identity.credential (hash_algorithm_id);

ALTER TABLE identity.session_record ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_record_user_account_id ON identity.session_record (user_account_id);

ALTER TABLE identity.session_record ADD FOREIGN KEY (session_status_id) REFERENCES identity.session_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_record_session_status_id ON identity.session_record (session_status_id);

ALTER TABLE identity.user_consent ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_consent_user_account_id ON identity.user_consent (user_account_id);

ALTER TABLE identity.user_consent ADD FOREIGN KEY (consent_type_id) REFERENCES identity.consent_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_consent_consent_type_id ON identity.user_consent (consent_type_id);

ALTER TABLE identity.user_consent ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_consent_language_id ON identity.user_consent (language_id);

ALTER TABLE identity.user_block ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_block_candidate_profile_id ON identity.user_block (candidate_profile_id);

ALTER TABLE identity.user_block ADD FOREIGN KEY (blocked_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_block_blocked_user_account_id ON identity.user_block (blocked_user_account_id);

ALTER TABLE identity.user_block ADD FOREIGN KEY (blocked_organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_block_blocked_organisation_id ON identity.user_block (blocked_organisation_id);

ALTER TABLE identity.audit_event ADD FOREIGN KEY (actor_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_audit_event_actor_user_account_id ON identity.audit_event (actor_user_account_id);

ALTER TABLE organisation.account_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_reference_code_id ON organisation.account_status (reference_code_id);

ALTER TABLE organisation.organisation_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_type_reference_code_id ON organisation.organisation_type (reference_code_id);

ALTER TABLE organisation.identifier_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_identifier_type_reference_code_id ON organisation.identifier_type (reference_code_id);

ALTER TABLE organisation.verification_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_type_reference_code_id ON organisation.verification_type (reference_code_id);

ALTER TABLE organisation.account_profile ADD FOREIGN KEY (account_status_id) REFERENCES organisation.account_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_profile_account_status_id ON organisation.account_profile (account_status_id);

ALTER TABLE organisation.organisation_location ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_location_organisation_id ON organisation.organisation_location (organisation_id);

ALTER TABLE organisation.organisation_location ADD FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_location_city_id ON organisation.organisation_location (city_id);

ALTER TABLE organisation.organisation_identifier ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_identifier_organisation_id ON organisation.organisation_identifier (organisation_id);

ALTER TABLE organisation.organisation_identifier ADD FOREIGN KEY (country_id) REFERENCES public.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_identifier_country_id ON organisation.organisation_identifier (country_id);

ALTER TABLE organisation.organisation_identifier ADD FOREIGN KEY (identifier_type_id) REFERENCES organisation.identifier_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_identifier_identifier_type_id ON organisation.organisation_identifier (identifier_type_id);

ALTER TABLE organisation.verification_record ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_record_organisation_id ON organisation.verification_record (organisation_id);

ALTER TABLE organisation.verification_record ADD FOREIGN KEY (verification_type_id) REFERENCES organisation.verification_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_record_verification_type_id ON organisation.verification_record (verification_type_id);

ALTER TABLE organisation.verification_record ADD FOREIGN KEY (verification_status_id) REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_record_verification_status_id ON organisation.verification_record (verification_status_id);

ALTER TABLE organisation.organisation_recruiter ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_recruiter_organisation_id ON organisation.organisation_recruiter (organisation_id);

ALTER TABLE organisation.organisation_recruiter ADD FOREIGN KEY (recruiter_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_recruiter_recruiter_user_account_id ON organisation.organisation_recruiter (recruiter_user_account_id);

ALTER TABLE organisation.account_administrator ADD FOREIGN KEY (account_profile_id) REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_administrator_account_profile_id ON organisation.account_administrator (account_profile_id);

ALTER TABLE organisation.account_administrator ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_administrator_user_account_id ON organisation.account_administrator (user_account_id);

ALTER TABLE organisation.organisation_member ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_member_organisation_id ON organisation.organisation_member (organisation_id);

ALTER TABLE organisation.organisation_member ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_member_user_account_id ON organisation.organisation_member (user_account_id);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_job_requirement_id ON organisation.job_recruiter_assignment (job_requirement_id);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_organisation_id ON organisation.job_recruiter_assignment (organisation_id);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (recruiter_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_recruiter_user_account_id ON organisation.job_recruiter_assignment (recruiter_user_account_id);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (organisation_recruiter_id) REFERENCES organisation.organisation_recruiter(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_organisation_recruiter_id ON organisation.job_recruiter_assignment (organisation_recruiter_id);

ALTER TABLE gig.availability_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_availability_status_reference_code_id ON gig.availability_status (reference_code_id);

ALTER TABLE gig.request_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_request_status_reference_code_id ON gig.request_status (reference_code_id);

ALTER TABLE gig.pricing_model ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_pricing_model_reference_code_id ON gig.pricing_model (reference_code_id);

ALTER TABLE gig.application_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_reference_code_id ON gig.application_status (reference_code_id);

ALTER TABLE gig.assignment_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assignment_status_reference_code_id ON gig.assignment_status (reference_code_id);

ALTER TABLE gig.rate_unit ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_rate_unit_reference_code_id ON gig.rate_unit (reference_code_id);

ALTER TABLE gig.worker_list_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_list_type_reference_code_id ON gig.worker_list_type (reference_code_id);

ALTER TABLE gig.gig_worker_profile ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_profile_user_account_id ON gig.gig_worker_profile (user_account_id);

ALTER TABLE gig.gig_worker_profile ADD FOREIGN KEY (home_city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_profile_home_city_id ON gig.gig_worker_profile (home_city_id);

ALTER TABLE gig.gig_service ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_service_gig_worker_profile_id ON gig.gig_service (gig_worker_profile_id);

ALTER TABLE gig.gig_service ADD FOREIGN KEY (currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_service_currency_id ON gig.gig_service (currency_id);

ALTER TABLE gig.gig_service ADD FOREIGN KEY (rate_unit_id) REFERENCES gig.rate_unit(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_service_rate_unit_id ON gig.gig_service (rate_unit_id);

ALTER TABLE gig.gig_availability ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_availability_gig_worker_profile_id ON gig.gig_availability (gig_worker_profile_id);

ALTER TABLE gig.gig_availability ADD FOREIGN KEY (availability_status_id) REFERENCES gig.availability_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_availability_availability_status_id ON gig.gig_availability (availability_status_id);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (requester_organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_requester_organisation_id ON gig.gig_request (requester_organisation_id);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (requester_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_requester_user_account_id ON gig.gig_request (requester_user_account_id);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (pricing_model_id) REFERENCES gig.pricing_model(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_pricing_model_id ON gig.gig_request (pricing_model_id);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_currency_id ON gig.gig_request (currency_id);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (request_status_id) REFERENCES gig.request_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_request_status_id ON gig.gig_request (request_status_id);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (gig_request_id) REFERENCES gig.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_gig_request_id ON gig.gig_application (gig_request_id);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_gig_worker_profile_id ON gig.gig_application (gig_worker_profile_id);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (application_status_id) REFERENCES gig.application_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_application_status_id ON gig.gig_application (application_status_id);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (proposed_currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_proposed_currency_id ON gig.gig_application (proposed_currency_id);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (decision_by_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_decision_by_user_account_id ON gig.gig_application (decision_by_user_account_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_application_id) REFERENCES gig.gig_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_gig_application_id ON gig.gig_assignment (gig_application_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_request_id) REFERENCES gig.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_gig_request_id ON gig.gig_assignment (gig_request_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_gig_worker_profile_id ON gig.gig_assignment (gig_worker_profile_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (assignment_status_id) REFERENCES gig.assignment_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_assignment_status_id ON gig.gig_assignment (assignment_status_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (estimated_currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_estimated_currency_id ON gig.gig_assignment (estimated_currency_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (total_currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_total_currency_id ON gig.gig_assignment (total_currency_id);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (projected_currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_projected_currency_id ON gig.gig_assignment (projected_currency_id);

ALTER TABLE gig.gig_worker_list_entry ADD FOREIGN KEY (requester_organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_list_entry_requester_organisation_id ON gig.gig_worker_list_entry (requester_organisation_id);

ALTER TABLE gig.gig_worker_list_entry ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_list_entry_gig_worker_profile_id ON gig.gig_worker_list_entry (gig_worker_profile_id);

ALTER TABLE gig.gig_worker_list_entry ADD FOREIGN KEY (worker_list_type_id) REFERENCES gig.worker_list_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_list_entry_worker_list_type_id ON gig.gig_worker_list_entry (worker_list_type_id);

ALTER TABLE gig.gig_rating ADD FOREIGN KEY (gig_assignment_id) REFERENCES gig.gig_assignment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_rating_gig_assignment_id ON gig.gig_rating (gig_assignment_id);

ALTER TABLE gig.gig_rating ADD FOREIGN KEY (requester_user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_rating_requester_user_account_id ON gig.gig_rating (requester_user_account_id);

ALTER TABLE gig.fulfilment_event ADD FOREIGN KEY (gig_assignment_id) REFERENCES gig.gig_assignment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_fulfilment_event_gig_assignment_id ON gig.fulfilment_event (gig_assignment_id);

ALTER TABLE gig.worker_project ADD FOREIGN KEY (gig_worker_profile_id) REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_project_gig_worker_profile_id ON gig.worker_project (gig_worker_profile_id);

ALTER TABLE identity.account_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_created_by ON identity.account_status (created_by);

ALTER TABLE identity.account_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_updated_by ON identity.account_status (updated_by);

ALTER TABLE identity.credential_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_type_created_by ON identity.credential_type (created_by);

ALTER TABLE identity.credential_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_type_updated_by ON identity.credential_type (updated_by);

ALTER TABLE identity.hash_algorithm ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hash_algorithm_created_by ON identity.hash_algorithm (created_by);

ALTER TABLE identity.hash_algorithm ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hash_algorithm_updated_by ON identity.hash_algorithm (updated_by);

ALTER TABLE identity.consent_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_consent_type_created_by ON identity.consent_type (created_by);

ALTER TABLE identity.consent_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_consent_type_updated_by ON identity.consent_type (updated_by);

ALTER TABLE identity.session_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_status_created_by ON identity.session_status (created_by);

ALTER TABLE identity.session_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_status_updated_by ON identity.session_status (updated_by);

ALTER TABLE identity.app_role ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_app_role_created_by ON identity.app_role (created_by);

ALTER TABLE identity.app_role ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_app_role_updated_by ON identity.app_role (updated_by);

ALTER TABLE identity.permission ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_permission_created_by ON identity.permission (created_by);

ALTER TABLE identity.permission ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_permission_updated_by ON identity.permission (updated_by);

ALTER TABLE identity.role_permission ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_role_permission_created_by ON identity.role_permission (created_by);

ALTER TABLE identity.role_permission ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_role_permission_updated_by ON identity.role_permission (updated_by);

ALTER TABLE identity.user_role ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_role_created_by ON identity.user_role (created_by);

ALTER TABLE identity.user_role ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_role_updated_by ON identity.user_role (updated_by);

ALTER TABLE identity.db_principal ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_db_principal_created_by ON identity.db_principal (created_by);

ALTER TABLE identity.db_principal ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_db_principal_updated_by ON identity.db_principal (updated_by);

ALTER TABLE identity.credential ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_created_by ON identity.credential (created_by);

ALTER TABLE identity.credential ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_credential_updated_by ON identity.credential (updated_by);

ALTER TABLE identity.session_record ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_record_created_by ON identity.session_record (created_by);

ALTER TABLE identity.session_record ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_session_record_updated_by ON identity.session_record (updated_by);

ALTER TABLE identity.user_consent ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_consent_created_by ON identity.user_consent (created_by);

ALTER TABLE identity.user_consent ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_consent_updated_by ON identity.user_consent (updated_by);

ALTER TABLE identity.user_block ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_block_created_by ON identity.user_block (created_by);

ALTER TABLE identity.user_block ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_block_updated_by ON identity.user_block (updated_by);

ALTER TABLE identity.audit_event ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_audit_event_created_by ON identity.audit_event (created_by);

ALTER TABLE identity.audit_event ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_audit_event_updated_by ON identity.audit_event (updated_by);

ALTER TABLE identity.system_error_log ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_system_error_log_created_by ON identity.system_error_log (created_by);

ALTER TABLE identity.system_error_log ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_system_error_log_updated_by ON identity.system_error_log (updated_by);

ALTER TABLE organisation.account_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_created_by ON organisation.account_status (created_by);

ALTER TABLE organisation.account_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_status_updated_by ON organisation.account_status (updated_by);

ALTER TABLE organisation.organisation_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_type_created_by ON organisation.organisation_type (created_by);

ALTER TABLE organisation.organisation_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_type_updated_by ON organisation.organisation_type (updated_by);

ALTER TABLE organisation.identifier_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_identifier_type_created_by ON organisation.identifier_type (created_by);

ALTER TABLE organisation.identifier_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_identifier_type_updated_by ON organisation.identifier_type (updated_by);

ALTER TABLE organisation.verification_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_type_created_by ON organisation.verification_type (created_by);

ALTER TABLE organisation.verification_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_type_updated_by ON organisation.verification_type (updated_by);

ALTER TABLE organisation.account_profile ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_profile_created_by ON organisation.account_profile (created_by);

ALTER TABLE organisation.account_profile ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_profile_updated_by ON organisation.account_profile (updated_by);

ALTER TABLE organisation.organisation_location ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_location_created_by ON organisation.organisation_location (created_by);

ALTER TABLE organisation.organisation_location ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_location_updated_by ON organisation.organisation_location (updated_by);

ALTER TABLE organisation.organisation_identifier ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_identifier_created_by ON organisation.organisation_identifier (created_by);

ALTER TABLE organisation.organisation_identifier ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_identifier_updated_by ON organisation.organisation_identifier (updated_by);

ALTER TABLE organisation.verification_record ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_record_created_by ON organisation.verification_record (created_by);

ALTER TABLE organisation.verification_record ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_record_updated_by ON organisation.verification_record (updated_by);

ALTER TABLE organisation.organisation_recruiter ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_recruiter_created_by ON organisation.organisation_recruiter (created_by);

ALTER TABLE organisation.organisation_recruiter ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_recruiter_updated_by ON organisation.organisation_recruiter (updated_by);

ALTER TABLE organisation.account_administrator ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_administrator_created_by ON organisation.account_administrator (created_by);

ALTER TABLE organisation.account_administrator ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_account_administrator_updated_by ON organisation.account_administrator (updated_by);

ALTER TABLE organisation.organisation_member ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_member_created_by ON organisation.organisation_member (created_by);

ALTER TABLE organisation.organisation_member ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_member_updated_by ON organisation.organisation_member (updated_by);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_created_by ON organisation.job_recruiter_assignment (created_by);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_recruiter_assignment_updated_by ON organisation.job_recruiter_assignment (updated_by);

ALTER TABLE gig.availability_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_availability_status_created_by ON gig.availability_status (created_by);

ALTER TABLE gig.availability_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_availability_status_updated_by ON gig.availability_status (updated_by);

ALTER TABLE gig.request_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_request_status_created_by ON gig.request_status (created_by);

ALTER TABLE gig.request_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_request_status_updated_by ON gig.request_status (updated_by);

ALTER TABLE gig.pricing_model ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_pricing_model_created_by ON gig.pricing_model (created_by);

ALTER TABLE gig.pricing_model ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_pricing_model_updated_by ON gig.pricing_model (updated_by);

ALTER TABLE gig.application_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_created_by ON gig.application_status (created_by);

ALTER TABLE gig.application_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_updated_by ON gig.application_status (updated_by);

ALTER TABLE gig.assignment_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assignment_status_created_by ON gig.assignment_status (created_by);

ALTER TABLE gig.assignment_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assignment_status_updated_by ON gig.assignment_status (updated_by);

ALTER TABLE gig.rate_unit ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_rate_unit_created_by ON gig.rate_unit (created_by);

ALTER TABLE gig.rate_unit ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_rate_unit_updated_by ON gig.rate_unit (updated_by);

ALTER TABLE gig.worker_list_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_list_type_created_by ON gig.worker_list_type (created_by);

ALTER TABLE gig.worker_list_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_list_type_updated_by ON gig.worker_list_type (updated_by);

ALTER TABLE gig.gig_worker_profile ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_profile_created_by ON gig.gig_worker_profile (created_by);

ALTER TABLE gig.gig_worker_profile ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_profile_updated_by ON gig.gig_worker_profile (updated_by);

ALTER TABLE gig.gig_service ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_service_created_by ON gig.gig_service (created_by);

ALTER TABLE gig.gig_service ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_service_updated_by ON gig.gig_service (updated_by);

ALTER TABLE gig.gig_availability ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_availability_created_by ON gig.gig_availability (created_by);

ALTER TABLE gig.gig_availability ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_availability_updated_by ON gig.gig_availability (updated_by);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_created_by ON gig.gig_request (created_by);

ALTER TABLE gig.gig_request ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_request_updated_by ON gig.gig_request (updated_by);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_created_by ON gig.gig_application (created_by);

ALTER TABLE gig.gig_application ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_application_updated_by ON gig.gig_application (updated_by);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_created_by ON gig.gig_assignment (created_by);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_assignment_updated_by ON gig.gig_assignment (updated_by);

ALTER TABLE gig.gig_worker_list_entry ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_list_entry_created_by ON gig.gig_worker_list_entry (created_by);

ALTER TABLE gig.gig_worker_list_entry ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_worker_list_entry_updated_by ON gig.gig_worker_list_entry (updated_by);

ALTER TABLE gig.gig_rating ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_rating_created_by ON gig.gig_rating (created_by);

ALTER TABLE gig.gig_rating ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_gig_rating_updated_by ON gig.gig_rating (updated_by);

ALTER TABLE gig.fulfilment_event ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_fulfilment_event_created_by ON gig.fulfilment_event (created_by);

ALTER TABLE gig.fulfilment_event ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_fulfilment_event_updated_by ON gig.fulfilment_event (updated_by);

ALTER TABLE gig.worker_project ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_project_created_by ON gig.worker_project (created_by);

ALTER TABLE gig.worker_project ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_worker_project_updated_by ON gig.worker_project (updated_by);

ALTER TABLE identity.account_status ADD UNIQUE (reference_code_id);

ALTER TABLE identity.credential_type ADD UNIQUE (reference_code_id);

ALTER TABLE identity.hash_algorithm ADD UNIQUE (reference_code_id);

ALTER TABLE identity.consent_type ADD UNIQUE (reference_code_id);

ALTER TABLE identity.session_status ADD UNIQUE (reference_code_id);

ALTER TABLE identity.role_permission ADD UNIQUE (app_role_id, permission_id);

ALTER TABLE identity.user_role ADD UNIQUE (id, user_account_id);

ALTER TABLE identity.db_principal ADD UNIQUE (user_account_id);

ALTER TABLE identity.user_consent ADD UNIQUE (user_account_id, consent_type_id, consent_version, recorded_at);

ALTER TABLE organisation.account_status ADD UNIQUE (reference_code_id);

ALTER TABLE organisation.organisation_type ADD UNIQUE (reference_code_id);

ALTER TABLE organisation.identifier_type ADD UNIQUE (reference_code_id);

ALTER TABLE organisation.verification_type ADD UNIQUE (reference_code_id);

ALTER TABLE organisation.organisation_identifier ADD UNIQUE (country_id, identifier_type_id, identifier_fingerprint);

ALTER TABLE organisation.verification_record ADD UNIQUE (provider_code, provider_reference);

ALTER TABLE organisation.organisation_recruiter ADD UNIQUE (id, organisation_id, recruiter_user_account_id);

ALTER TABLE gig.availability_status ADD UNIQUE (reference_code_id);

ALTER TABLE gig.request_status ADD UNIQUE (reference_code_id);

ALTER TABLE gig.pricing_model ADD UNIQUE (reference_code_id);

ALTER TABLE gig.application_status ADD UNIQUE (reference_code_id);

ALTER TABLE gig.assignment_status ADD UNIQUE (reference_code_id);

ALTER TABLE gig.rate_unit ADD UNIQUE (reference_code_id);

ALTER TABLE gig.worker_list_type ADD UNIQUE (reference_code_id);

ALTER TABLE gig.gig_worker_profile ADD UNIQUE (user_account_id);

ALTER TABLE gig.gig_service ADD UNIQUE (gig_worker_profile_id, service_name);

ALTER TABLE gig.gig_request ADD UNIQUE (id, requester_organisation_id);

ALTER TABLE gig.gig_application ADD UNIQUE (gig_request_id, gig_worker_profile_id);

ALTER TABLE gig.gig_application ADD UNIQUE (id, gig_request_id, gig_worker_profile_id);

ALTER TABLE gig.gig_assignment ADD UNIQUE (gig_application_id);

ALTER TABLE gig.gig_assignment ADD UNIQUE (external_system_code, handoff_reference);

ALTER TABLE gig.gig_worker_list_entry ADD UNIQUE (requester_organisation_id, gig_worker_profile_id);

ALTER TABLE gig.gig_rating ADD UNIQUE (gig_assignment_id);

ALTER TABLE gig.fulfilment_event ADD UNIQUE (external_system_code, external_event_id);

ALTER TABLE identity.user_role ADD CHECK (valid_to IS NULL OR valid_to > valid_from);

ALTER TABLE identity.credential ADD CHECK ((secret_hash IS NULL) <> (external_reference IS NULL));

ALTER TABLE identity.credential ADD CHECK (expires_at IS NULL OR expires_at > issued_at);

ALTER TABLE identity.credential ADD CHECK (revoked_at IS NULL OR revoked_at >= issued_at);

ALTER TABLE identity.session_record ADD CHECK (expires_at > started_at);

ALTER TABLE identity.session_record ADD CHECK (ended_at IS NULL OR ended_at >= started_at);

ALTER TABLE identity.user_consent ADD CHECK (withdrawn_at IS NULL OR (granted AND withdrawn_at >= recorded_at));

ALTER TABLE identity.user_block ADD CHECK (num_nonnulls(blocked_user_account_id, blocked_organisation_id) = 1);

ALTER TABLE organisation.organisation_recruiter ADD CHECK (valid_to IS NULL OR valid_to > valid_from);

ALTER TABLE organisation.account_administrator ADD CHECK (valid_to IS NULL OR valid_to > valid_from);

ALTER TABLE organisation.organisation_member ADD CHECK (valid_to IS NULL OR valid_to > valid_from);

ALTER TABLE organisation.job_recruiter_assignment ADD CHECK (valid_to IS NULL OR valid_to > valid_from);

ALTER TABLE gig.gig_availability ADD CHECK (available_to > available_from);

ALTER TABLE gig.gig_request ADD CHECK (end_at > start_at);

ALTER TABLE gig.gig_application ADD CHECK ((proposed_amount IS NULL) = (proposed_currency_id IS NULL));

ALTER TABLE gig.gig_application ADD CHECK ((decided_at IS NULL) = (decision_by_user_account_id IS NULL));

ALTER TABLE gig.gig_assignment ADD CHECK ((estimated_earnings IS NULL) = (estimated_currency_id IS NULL));

ALTER TABLE gig.gig_assignment ADD CHECK ((total_earnings IS NULL) = (total_currency_id IS NULL));

ALTER TABLE gig.gig_assignment ADD CHECK ((projected_earnings IS NULL) = (projected_currency_id IS NULL));

ALTER TABLE gig.gig_assignment ADD CHECK (assignment_end_at > assignment_start_at);

ALTER TABLE gig.worker_project ADD CHECK (end_date IS NULL OR end_date >= start_date);

ALTER TABLE public.user_account ADD COLUMN account_status_id BIGINT;

ALTER TABLE public.user_account ADD COLUMN email_verified_at TIMESTAMPTZ;

ALTER TABLE public.user_account ADD COLUMN last_login_at TIMESTAMPTZ;

ALTER TABLE public.user_account ADD FOREIGN KEY (account_status_id) REFERENCES identity.account_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_account_account_status_id ON public.user_account(account_status_id);

ALTER TABLE public.organisation ADD COLUMN account_profile_id BIGINT;

ALTER TABLE public.organisation ADD COLUMN parent_organisation_id BIGINT;

ALTER TABLE public.organisation ADD COLUMN organisation_type_id BIGINT;

ALTER TABLE public.organisation ADD COLUMN verification_status_id BIGINT;

ALTER TABLE public.organisation ADD COLUMN verified_at TIMESTAMPTZ;

ALTER TABLE public.organisation ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE public.organisation ADD COLUMN description TEXT;

ALTER TABLE public.organisation ADD FOREIGN KEY (account_profile_id) REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.organisation ADD FOREIGN KEY (parent_organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.organisation ADD FOREIGN KEY (organisation_type_id) REFERENCES organisation.organisation_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.organisation ADD FOREIGN KEY (verification_status_id) REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.organisation ADD CHECK (parent_organisation_id IS NULL OR parent_organisation_id <> id);

ALTER TABLE public.organisation ADD UNIQUE (id, account_profile_id);

ALTER TABLE public.organisation ADD FOREIGN KEY (parent_organisation_id, account_profile_id) REFERENCES public.organisation(id, account_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_account_profile_id ON public.organisation(account_profile_id);

CREATE INDEX idx_organisation_parent_organisation_id ON public.organisation(parent_organisation_id);

ALTER TABLE public.job_requirement ADD UNIQUE (id, organisation_id);

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (job_requirement_id, organisation_id) REFERENCES public.job_requirement(id, organisation_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (organisation_recruiter_id, organisation_id, recruiter_user_account_id) REFERENCES organisation.organisation_recruiter(id, organisation_id, recruiter_user_account_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_application_id, gig_request_id, gig_worker_profile_id) REFERENCES gig.gig_application(id, gig_request_id, gig_worker_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE gig.gig_request ADD UNIQUE (id, start_at, end_at);

ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_request_id, assignment_start_at, assignment_end_at) REFERENCES gig.gig_request(id, start_at, end_at) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE identity.session_record ADD FOREIGN KEY (neon_auth_session_id) REFERENCES neon_auth.session(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE identity.user_role ADD CONSTRAINT ex_user_role_no_overlap EXCLUDE USING gist (user_account_id WITH =, app_role_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE organisation.organisation_recruiter ADD CONSTRAINT ex_recruiter_company_no_overlap EXCLUDE USING gist (recruiter_user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE organisation.account_administrator ADD CONSTRAINT ex_account_admin_no_overlap EXCLUDE USING gist (account_profile_id WITH =, user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE organisation.organisation_member ADD CONSTRAINT ex_organisation_member_no_overlap EXCLUDE USING gist (organisation_id WITH =, user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE organisation.job_recruiter_assignment ADD CONSTRAINT ex_job_recruiter_assignment_no_overlap EXCLUDE USING gist (job_requirement_id WITH =, recruiter_user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE gig.gig_assignment ADD CONSTRAINT ex_gig_assignment_worker_no_overlap EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(assignment_start_at, assignment_end_at, '[)') WITH &&) WHERE (deleted_at IS NULL);

ALTER TABLE gig.gig_availability ADD CONSTRAINT ex_gig_availability_worker_no_overlap EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(available_from, available_to, '[)') WITH &&) WHERE (deleted_at IS NULL);

CREATE UNIQUE INDEX uq_organisation_primary_location ON organisation.organisation_location(organisation_id) WHERE is_primary AND deleted_at IS NULL;

CREATE UNIQUE INDEX uq_identity_block_user ON identity.user_block(candidate_profile_id, blocked_user_account_id) WHERE blocked_user_account_id IS NOT NULL AND deleted_at IS NULL;

CREATE UNIQUE INDEX uq_identity_block_org ON identity.user_block(candidate_profile_id, blocked_organisation_id) WHERE blocked_organisation_id IS NOT NULL AND deleted_at IS NULL;

CREATE UNIQUE INDEX uq_gig_available_window ON gig.gig_availability(gig_worker_profile_id, available_from, available_to) WHERE deleted_at IS NULL;

CREATE INDEX idx_identity_audit_time ON identity.audit_event(occurred_at, entity_table);

CREATE INDEX idx_gig_request_org_window ON gig.gig_request(requester_organisation_id, start_at, end_at) WHERE deleted_at IS NULL;

INSERT INTO identity.account_status (code, display_name, sort_order) VALUES ('pending', 'Pending', 0), ('active', 'Active', 1), ('suspended', 'Suspended', 2), ('closed', 'Closed', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'identity.account_status', code, display_name, active, sort_order FROM identity.account_status;

UPDATE identity.account_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'identity.account_status' AND r.code = l.code;

ALTER TABLE identity.account_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO identity.credential_type (code, display_name, sort_order) VALUES ('neon_auth', 'Neon Auth', 0), ('api_key', 'Api Key', 1), ('recovery', 'Recovery', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'identity.credential_type', code, display_name, active, sort_order FROM identity.credential_type;

UPDATE identity.credential_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'identity.credential_type' AND r.code = l.code;

ALTER TABLE identity.credential_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO identity.hash_algorithm (code, display_name, sort_order) VALUES ('argon2id', 'Argon2Id', 0), ('bcrypt', 'Bcrypt', 1), ('external', 'External', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'identity.hash_algorithm', code, display_name, active, sort_order FROM identity.hash_algorithm;

UPDATE identity.hash_algorithm l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'identity.hash_algorithm' AND r.code = l.code;

ALTER TABLE identity.hash_algorithm ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO identity.consent_type (code, display_name, sort_order) VALUES ('terms', 'Terms', 0), ('privacy', 'Privacy', 1), ('marketing', 'Marketing', 2), ('profile_visibility', 'Profile Visibility', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'identity.consent_type', code, display_name, active, sort_order FROM identity.consent_type;

UPDATE identity.consent_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'identity.consent_type' AND r.code = l.code;

ALTER TABLE identity.consent_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO identity.session_status (code, display_name, sort_order) VALUES ('active', 'Active', 0), ('expired', 'Expired', 1), ('revoked', 'Revoked', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'identity.session_status', code, display_name, active, sort_order FROM identity.session_status;

UPDATE identity.session_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'identity.session_status' AND r.code = l.code;

ALTER TABLE identity.session_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO organisation.account_status (code, display_name, sort_order) VALUES ('pending', 'Pending', 0), ('active', 'Active', 1), ('suspended', 'Suspended', 2), ('closed', 'Closed', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'organisation.account_status', code, display_name, active, sort_order FROM organisation.account_status;

UPDATE organisation.account_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'organisation.account_status' AND r.code = l.code;

ALTER TABLE organisation.account_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO organisation.organisation_type (code, display_name, sort_order) VALUES ('employer', 'Employer', 0), ('client', 'Client', 1), ('institution', 'Institution', 2), ('agency', 'Agency', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'organisation.organisation_type', code, display_name, active, sort_order FROM organisation.organisation_type;

UPDATE organisation.organisation_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'organisation.organisation_type' AND r.code = l.code;

ALTER TABLE organisation.organisation_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO organisation.identifier_type (code, display_name, sort_order) VALUES ('tax', 'Tax', 0), ('registration', 'Registration', 1), ('vat', 'Vat', 2), ('gst', 'Gst', 3), ('other', 'Other', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'organisation.identifier_type', code, display_name, active, sort_order FROM organisation.identifier_type;

UPDATE organisation.identifier_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'organisation.identifier_type' AND r.code = l.code;

ALTER TABLE organisation.identifier_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO organisation.verification_type (code, display_name, sort_order) VALUES ('company_registration', 'Company Registration', 0), ('tax_identifier', 'Tax Identifier', 1), ('address', 'Address', 2), ('other', 'Other', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'organisation.verification_type', code, display_name, active, sort_order FROM organisation.verification_type;

UPDATE organisation.verification_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'organisation.verification_type' AND r.code = l.code;

ALTER TABLE organisation.verification_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.availability_status (code, display_name, sort_order) VALUES ('available', 'Available', 0), ('unavailable', 'Unavailable', 1);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.availability_status', code, display_name, active, sort_order FROM gig.availability_status;

UPDATE gig.availability_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.availability_status' AND r.code = l.code;

ALTER TABLE gig.availability_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.request_status (code, display_name, sort_order) VALUES ('draft', 'Draft', 0), ('open', 'Open', 1), ('paused', 'Paused', 2), ('filled', 'Filled', 3), ('cancelled', 'Cancelled', 4), ('completed', 'Completed', 5);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.request_status', code, display_name, active, sort_order FROM gig.request_status;

UPDATE gig.request_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.request_status' AND r.code = l.code;

ALTER TABLE gig.request_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.pricing_model (code, display_name, sort_order) VALUES ('fixed', 'Fixed', 0), ('hourly', 'Hourly', 1), ('daily', 'Daily', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.pricing_model', code, display_name, active, sort_order FROM gig.pricing_model;

UPDATE gig.pricing_model l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.pricing_model' AND r.code = l.code;

ALTER TABLE gig.pricing_model ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.application_status (code, display_name, sort_order) VALUES ('submitted', 'Submitted', 0), ('accepted', 'Accepted', 1), ('rejected', 'Rejected', 2), ('withdrawn', 'Withdrawn', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.application_status', code, display_name, active, sort_order FROM gig.application_status;

UPDATE gig.application_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.application_status' AND r.code = l.code;

ALTER TABLE gig.application_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.assignment_status (code, display_name, sort_order) VALUES ('pending_handoff', 'Pending Handoff', 0), ('handed_off', 'Handed Off', 1), ('in_progress', 'In Progress', 2), ('completed', 'Completed', 3), ('failed', 'Failed', 4), ('cancelled', 'Cancelled', 5);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.assignment_status', code, display_name, active, sort_order FROM gig.assignment_status;

UPDATE gig.assignment_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.assignment_status' AND r.code = l.code;

ALTER TABLE gig.assignment_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.rate_unit (code, display_name, sort_order) VALUES ('hour', 'Hour', 0), ('day', 'Day', 1), ('project', 'Project', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.rate_unit', code, display_name, active, sort_order FROM gig.rate_unit;

UPDATE gig.rate_unit l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.rate_unit' AND r.code = l.code;

ALTER TABLE gig.rate_unit ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO gig.worker_list_type (code, display_name, sort_order) VALUES ('favourite', 'Favourite', 0), ('blacklisted', 'Blacklisted', 1);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'gig.worker_list_type', code, display_name, active, sort_order FROM gig.worker_list_type;

UPDATE gig.worker_list_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'gig.worker_list_type' AND r.code = l.code;

ALTER TABLE gig.worker_list_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.reference_translation (reference_code_id, language_id, display_name) SELECT r.id, l.id, r.display_name FROM public.reference_code r CROSS JOIN public.language l WHERE r.domain_code IN ('identity.account_status', 'identity.credential_type', 'identity.hash_algorithm', 'identity.consent_type', 'identity.session_status', 'organisation.account_status', 'organisation.organisation_type', 'organisation.identifier_type', 'organisation.verification_type', 'gig.availability_status', 'gig.request_status', 'gig.pricing_model', 'gig.application_status', 'gig.assignment_status', 'gig.rate_unit', 'gig.worker_list_type') AND l.code = 'en';

UPDATE public.user_account SET account_status_id = (SELECT id FROM identity.account_status WHERE code = 'active') WHERE account_status_id IS NULL;

ALTER TABLE public.user_account ALTER COLUMN account_status_id SET NOT NULL;

CREATE FUNCTION identity.default_active_account_status_id() RETURNS BIGINT LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = pg_catalog, identity AS $$ SELECT id FROM identity.account_status WHERE code = 'active' $$;

ALTER TABLE public.user_account ALTER COLUMN account_status_id SET DEFAULT identity.default_active_account_status_id();

INSERT INTO organisation.account_profile(account_name, account_status_id) SELECT 'Legacy organisation ' || o.id, s.id FROM public.organisation o CROSS JOIN organisation.account_status s WHERE s.code = 'active' AND o.account_profile_id IS NULL;

UPDATE public.organisation o SET account_profile_id = a.id FROM organisation.account_profile a WHERE a.account_name = 'Legacy organisation ' || o.id AND o.account_profile_id IS NULL;

UPDATE public.organisation SET organisation_type_id = (SELECT id FROM organisation.organisation_type WHERE code = 'employer') WHERE organisation_type_id IS NULL;

UPDATE public.organisation SET verification_status_id = (SELECT id FROM public.verification_status WHERE code = 'pending') WHERE verification_status_id IS NULL;

ALTER TABLE public.organisation ALTER COLUMN account_profile_id SET NOT NULL;

ALTER TABLE public.organisation ALTER COLUMN organisation_type_id SET NOT NULL;

ALTER TABLE public.organisation ALTER COLUMN verification_status_id SET NOT NULL;

INSERT INTO identity.app_role(code, display_name) VALUES ('super_admin','Super Admin'), ('admin','Admin'), ('account_admin','Account Admin'), ('guest','Guest'), ('candidate','Candidate'), ('employer','Employer'), ('recruiter','Recruiter'), ('consultant','Consultant'), ('placement_officer','Placement Officer');

INSERT INTO identity.permission(code, description) VALUES ('profile.read_own','Profile: Read Own'), ('profile.write_own','Profile: Write Own'), ('profile.read_applicant','Profile: Read Applicant'), ('job.read_published','Job: Read Published'), ('job.read_org','Job: Read Org'), ('job.write_org','Job: Write Org'), ('job.read_assigned','Job: Read Assigned'), ('job.write_assigned','Job: Write Assigned'), ('job.read_consultant_open','Job: Read Consultant Open'), ('organisation.read_own','Organisation: Read Own'), ('organisation.manage_own','Organisation: Manage Own'), ('gig.worker.manage','Gig: Worker: Manage'), ('gig.request.manage','Gig: Request: Manage'), ('gig.assignment.review','Gig: Assignment: Review'), ('admin.manage_roles','Admin: Manage Roles'), ('admin.read_audit','Admin: Read Audit');

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('job.read_published') WHERE r.code = 'guest';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_own', 'profile.write_own', 'job.read_published', 'gig.worker.manage') WHERE r.code = 'candidate';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_applicant', 'job.read_org', 'job.write_org', 'organisation.read_own', 'gig.request.manage', 'gig.assignment.review') WHERE r.code = 'employer';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_applicant', 'job.read_assigned', 'job.write_assigned', 'organisation.read_own') WHERE r.code = 'recruiter';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_applicant', 'job.read_consultant_open') WHERE r.code = 'consultant';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('job.read_published') WHERE r.code = 'placement_officer';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_applicant', 'job.read_org', 'job.write_org', 'organisation.read_own', 'organisation.manage_own', 'gig.request.manage', 'gig.assignment.review') WHERE r.code = 'account_admin';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_own', 'profile.write_own', 'profile.read_applicant', 'job.read_published', 'job.read_org', 'job.write_org', 'job.read_assigned', 'job.write_assigned', 'job.read_consultant_open', 'organisation.read_own', 'organisation.manage_own', 'gig.worker.manage', 'gig.request.manage', 'gig.assignment.review', 'admin.manage_roles', 'admin.read_audit') WHERE r.code = 'admin';

INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN ('profile.read_own', 'profile.write_own', 'profile.read_applicant', 'job.read_published', 'job.read_org', 'job.write_org', 'job.read_assigned', 'job.write_assigned', 'job.read_consultant_open', 'organisation.read_own', 'organisation.manage_own', 'gig.worker.manage', 'gig.request.manage', 'gig.assignment.review', 'admin.manage_roles', 'admin.read_audit') WHERE r.code = 'super_admin';

GRANT USAGE ON SCHEMA public, identity, organisation, gig TO talentra_runtime;

GRANT SELECT, INSERT, UPDATE ON public.candidate_profile, public.job_requirement TO talentra_runtime;

GRANT SELECT ON public.organisation TO talentra_runtime;

GRANT SELECT ON gig.gig_worker_profile, gig.gig_request, gig.gig_application, gig.gig_assignment TO talentra_runtime;

GRANT USAGE ON SEQUENCE public.candidate_profile_id_seq, public.job_requirement_id_seq TO talentra_runtime;

CREATE FUNCTION identity.actor_user_id() RETURNS BIGINT
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT p.user_account_id
  FROM identity.db_principal p
  JOIN public.user_account u ON u.id = p.user_account_id
  WHERE p.db_role_name = COALESCE(NULLIF(current_setting('role', true), 'none'), session_user)::name
    AND p.deleted_at IS NULL AND u.deleted_at IS NULL
  LIMIT 1
$$;

CREATE FUNCTION identity.role_has_permission(p_user_id BIGINT, p_code TEXT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_account u
    JOIN identity.account_status s ON s.id = u.account_status_id AND s.code = 'active'
    JOIN identity.user_role ur ON ur.user_account_id = u.id
    JOIN identity.app_role r ON r.id = ur.app_role_id
    JOIN identity.role_permission rp ON rp.app_role_id = r.id
    JOIN identity.permission p ON p.id = rp.permission_id
    WHERE u.id = p_user_id AND u.deleted_at IS NULL AND r.active
      AND ur.deleted_at IS NULL AND ur.valid_from <= CURRENT_TIMESTAMP
      AND (ur.valid_to IS NULL OR ur.valid_to > CURRENT_TIMESTAMP)
      AND p.code = p_code
  )
$$;

CREATE FUNCTION identity.has_permission(p_code TEXT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT COALESCE(identity.role_has_permission(identity.actor_user_id(), p_code), FALSE)
$$;

CREATE FUNCTION identity.is_organisation_member(p_user_id BIGINT, p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM organisation.organisation_member m
    WHERE m.user_account_id = p_user_id AND m.organisation_id = p_organisation_id
      AND m.deleted_at IS NULL AND m.valid_from <= CURRENT_TIMESTAMP
      AND (m.valid_to IS NULL OR m.valid_to > CURRENT_TIMESTAMP)
  ) OR EXISTS (
    SELECT 1 FROM organisation.account_administrator a
    JOIN public.organisation o ON o.account_profile_id = a.account_profile_id
    WHERE a.user_account_id = p_user_id AND o.id = p_organisation_id
      AND a.deleted_at IS NULL AND a.valid_from <= CURRENT_TIMESTAMP
      AND (a.valid_to IS NULL OR a.valid_to > CURRENT_TIMESTAMP)
  )
$$;

CREATE FUNCTION identity.is_assigned_recruiter(p_user_id BIGINT, p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM organisation.job_recruiter_assignment a
    JOIN organisation.organisation_recruiter m ON m.id = a.organisation_recruiter_id
    JOIN public.job_requirement j ON j.id = a.job_requirement_id AND j.organisation_id = a.organisation_id
    WHERE a.job_requirement_id = p_job_id AND a.recruiter_user_account_id = p_user_id
      AND m.recruiter_user_account_id = p_user_id AND m.organisation_id = j.organisation_id
      AND a.deleted_at IS NULL AND m.deleted_at IS NULL
      AND a.valid_from <= CURRENT_TIMESTAMP AND (a.valid_to IS NULL OR a.valid_to > CURRENT_TIMESTAMP)
      AND m.valid_from <= CURRENT_TIMESTAMP AND (m.valid_to IS NULL OR m.valid_to > CURRENT_TIMESTAMP)
  )
$$;

CREATE FUNCTION identity.can_manage_organisation(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN identity.role_has_permission(actor, 'organisation.manage_own')
    AND identity.is_organisation_member(actor, p_organisation_id);
END $$;

CREATE FUNCTION identity.can_read_organisation(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN (identity.role_has_permission(actor, 'organisation.read_own')
      AND (identity.is_organisation_member(actor, p_organisation_id)
        OR EXISTS (SELECT 1 FROM organisation.organisation_recruiter r
          WHERE r.organisation_id = p_organisation_id AND r.recruiter_user_account_id = actor
            AND r.deleted_at IS NULL AND r.valid_from <= CURRENT_TIMESTAMP
            AND (r.valid_to IS NULL OR r.valid_to > CURRENT_TIMESTAMP))));
END $$;

CREATE FUNCTION identity.can_read_job_as_staff(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); org_id BIGINT; is_open BOOLEAN;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT organisation_id, open_to_consultants INTO org_id, is_open
    FROM public.job_requirement WHERE id = p_job_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'job.read_org')
    AND identity.is_organisation_member(actor, org_id) THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'job.read_assigned')
    AND identity.is_assigned_recruiter(actor, p_job_id) THEN RETURN TRUE; END IF;
  RETURN is_open AND identity.role_has_permission(actor, 'job.read_consultant_open');
END $$;

CREATE FUNCTION identity.can_read_job(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.can_read_job_as_staff(p_job_id) THEN RETURN TRUE; END IF;
  RETURN identity.role_has_permission(actor, 'job.read_published') AND EXISTS (
    SELECT 1 FROM public.job_requirement j JOIN public.job_status s ON s.id = j.job_status_id
    WHERE j.id = p_job_id AND j.deleted_at IS NULL AND s.code = 'published'
      AND (j.deadline IS NULL OR j.deadline > CURRENT_TIMESTAMP));
END $$;

CREATE FUNCTION identity.can_manage_job(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); org_id BIGINT;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT organisation_id INTO org_id FROM public.job_requirement WHERE id = p_job_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN (identity.role_has_permission(actor, 'job.write_org') AND identity.is_organisation_member(actor, org_id))
    OR (identity.role_has_permission(actor, 'job.write_assigned') AND identity.is_assigned_recruiter(actor, p_job_id));
END $$;

CREATE FUNCTION identity.can_create_job(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT identity.has_permission('admin.manage_roles') OR
    (identity.has_permission('job.write_org') AND identity.is_organisation_member(identity.actor_user_id(), p_organisation_id))
$$;

CREATE FUNCTION identity.can_view_candidate(p_candidate_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); owner_id BIGINT;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT user_account_id INTO owner_id FROM public.candidate_profile
    WHERE id = p_candidate_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF actor = owner_id AND identity.role_has_permission(actor, 'profile.read_own') THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  IF NOT identity.role_has_permission(actor, 'profile.read_applicant') THEN RETURN FALSE; END IF;
  IF EXISTS (SELECT 1 FROM identity.user_block b WHERE b.candidate_profile_id = p_candidate_id
    AND b.deleted_at IS NULL AND (b.blocked_user_account_id = actor OR
       EXISTS (SELECT 1 FROM public.organisation o WHERE o.id = b.blocked_organisation_id
         AND (identity.is_organisation_member(actor, o.id) OR
              EXISTS (SELECT 1 FROM organisation.organisation_recruiter r
                WHERE r.organisation_id = o.id AND r.recruiter_user_account_id = actor
                  AND r.deleted_at IS NULL AND r.valid_from <= CURRENT_TIMESTAMP
                  AND (r.valid_to IS NULL OR r.valid_to > CURRENT_TIMESTAMP))))))
  THEN RETURN FALSE; END IF;
  RETURN EXISTS (SELECT 1 FROM public.application a
    WHERE a.candidate_profile_id = p_candidate_id AND a.deleted_at IS NULL
      AND identity.can_read_job_as_staff(a.job_requirement_id))
    OR EXISTS (SELECT 1 FROM public.job_shortlist s
      WHERE s.candidate_profile_id = p_candidate_id AND s.deleted_at IS NULL
        AND identity.can_read_job_as_staff(s.job_requirement_id));
END $$;

CREATE FUNCTION identity.audit_sensitive_change() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE row_id BIGINT;
BEGIN
  row_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END;
  INSERT INTO identity.audit_event(actor_user_account_id, action_code, entity_schema, entity_table,
      entity_id, request_id, details)
  VALUES (identity.actor_user_id(), TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME, row_id,
      NULLIF(current_setting('talentra.request_id', true), '')::UUID,
      jsonb_build_object('transaction_id', txid_current()));
  RETURN COALESCE(NEW, OLD);
END $$;

CREATE FUNCTION identity.validate_db_principal() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = NEW.db_role_name AND rolcanlogin) THEN
    RAISE EXCEPTION 'Principal must name an existing login role' USING ERRCODE = '23514';
  END IF;
  IF NOT pg_has_role(NEW.db_role_name, 'talentra_runtime', 'member') THEN
    RAISE EXCEPTION 'Principal role must inherit talentra_runtime' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_db_principal BEFORE INSERT OR UPDATE ON identity.db_principal FOR EACH ROW EXECUTE FUNCTION identity.validate_db_principal();

CREATE FUNCTION identity.validate_credential() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
DECLARE algorithm TEXT;
BEGIN
  SELECT code INTO algorithm FROM identity.hash_algorithm WHERE id = NEW.hash_algorithm_id;
  IF (algorithm = 'external') <> (NEW.external_reference IS NOT NULL) THEN
    RAISE EXCEPTION 'External credentials require an external reference; local credentials require a hash' USING ERRCODE = '23514';
  END IF;
  IF algorithm = 'argon2id' AND NEW.secret_hash NOT LIKE '$argon2id$%' THEN
    RAISE EXCEPTION 'Expected an Argon2id hash' USING ERRCODE = '23514';
  END IF;
  IF algorithm = 'bcrypt' AND NEW.secret_hash !~ '^[$]2[aby][$]' THEN
    RAISE EXCEPTION 'Expected a bcrypt hash' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_credential BEFORE INSERT OR UPDATE ON identity.credential FOR EACH ROW EXECUTE FUNCTION identity.validate_credential();

CREATE FUNCTION organisation.initialise_anchor() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, public AS $$
BEGIN
  IF NEW.account_profile_id IS NULL THEN
    INSERT INTO organisation.account_profile(account_name, account_status_id, created_by, updated_by)
    SELECT NEW.name, s.id, NEW.created_by, NEW.updated_by
      FROM organisation.account_status s WHERE s.code = 'active'
      RETURNING id INTO NEW.account_profile_id;
  END IF;
  IF NEW.organisation_type_id IS NULL THEN
    SELECT id INTO NEW.organisation_type_id FROM organisation.organisation_type WHERE code = 'employer';
  END IF;
  IF NEW.verification_status_id IS NULL THEN
    SELECT id INTO NEW.verification_status_id FROM public.verification_status WHERE code = 'pending';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER initialise_anchor BEFORE INSERT ON public.organisation FOR EACH ROW EXECUTE FUNCTION organisation.initialise_anchor();

CREATE FUNCTION identity.validate_block() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE owner_id BIGINT;
BEGIN
  SELECT user_account_id INTO owner_id FROM public.candidate_profile WHERE id = NEW.candidate_profile_id;
  IF NEW.blocked_user_account_id = owner_id THEN
    RAISE EXCEPTION 'A candidate cannot block their own account' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_block BEFORE INSERT OR UPDATE ON identity.user_block FOR EACH ROW EXECUTE FUNCTION identity.validate_block();

CREATE FUNCTION organisation.prevent_hierarchy_cycle() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, public AS $$
BEGIN
  PERFORM 1 FROM organisation.account_profile WHERE id = NEW.account_profile_id FOR UPDATE;
  IF NEW.parent_organisation_id IS NOT NULL THEN
    IF EXISTS (WITH RECURSIVE ancestors(id) AS (
      SELECT NEW.parent_organisation_id
      UNION
      SELECT o.parent_organisation_id FROM public.organisation o
        JOIN ancestors a ON o.id = a.id WHERE o.parent_organisation_id IS NOT NULL
    ) SELECT 1 FROM ancestors WHERE id = NEW.id) THEN
      RAISE EXCEPTION 'Organisation hierarchy cycle' USING ERRCODE = '23514';
    END IF;
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER prevent_hierarchy_cycle BEFORE INSERT OR UPDATE OF parent_organisation_id, account_profile_id ON public.organisation FOR EACH ROW EXECUTE FUNCTION organisation.prevent_hierarchy_cycle();

CREATE FUNCTION organisation.validate_recruiter_assignment() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, identity, public AS $$
DECLARE mapping organisation.organisation_recruiter%ROWTYPE;
BEGIN
  SELECT * INTO mapping FROM organisation.organisation_recruiter WHERE id = NEW.organisation_recruiter_id FOR UPDATE;
  IF mapping.deleted_at IS NOT NULL OR mapping.organisation_id <> NEW.organisation_id
     OR mapping.recruiter_user_account_id <> NEW.recruiter_user_account_id
     OR NOT (tstzrange(mapping.valid_from, mapping.valid_to, '[)') @>
             tstzrange(NEW.valid_from, NEW.valid_to, '[)')) THEN
    RAISE EXCEPTION 'Assignment must be within a valid recruiter-company mapping' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM identity.user_role ur JOIN identity.app_role r ON r.id = ur.app_role_id
    WHERE ur.user_account_id = NEW.recruiter_user_account_id AND r.code = 'recruiter'
      AND ur.deleted_at IS NULL AND ur.valid_from <= NEW.valid_from
      AND (ur.valid_to IS NULL OR (NEW.valid_to IS NOT NULL AND ur.valid_to >= NEW.valid_to))) THEN
    RAISE EXCEPTION 'Recruiter role must cover assignment' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_recruiter_assignment BEFORE INSERT OR UPDATE ON organisation.job_recruiter_assignment FOR EACH ROW EXECUTE FUNCTION organisation.validate_recruiter_assignment();

CREATE FUNCTION organisation.validate_mapping_change() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM organisation.job_recruiter_assignment a
    WHERE a.organisation_recruiter_id = NEW.id AND a.deleted_at IS NULL
      AND NOT (tstzrange(NEW.valid_from, NEW.valid_to, '[)') @>
               tstzrange(a.valid_from, a.valid_to, '[)'))) THEN
    RAISE EXCEPTION 'Recruiter mapping must cover its job assignments' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_mapping_change BEFORE UPDATE OF valid_from, valid_to ON organisation.organisation_recruiter FOR EACH ROW EXECUTE FUNCTION organisation.validate_mapping_change();

CREATE FUNCTION gig.validate_request_window() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig AS $$
BEGIN
  IF (NEW.start_at, NEW.end_at) IS DISTINCT FROM (OLD.start_at, OLD.end_at)
    AND EXISTS (SELECT 1 FROM gig.gig_application WHERE gig_request_id = OLD.id) THEN
      RAISE EXCEPTION 'Cannot change a gig window after applications exist' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_request_window BEFORE UPDATE OF start_at, end_at ON gig.gig_request FOR EACH ROW EXECUTE FUNCTION gig.validate_request_window();

CREATE FUNCTION gig.validate_application() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig, identity, public AS $$
DECLARE status_code TEXT; org_id BIGINT; request_status TEXT;
BEGIN
  SELECT code INTO status_code FROM gig.application_status WHERE id = NEW.application_status_id;
  SELECT r.requester_organisation_id, s.code INTO org_id, request_status
    FROM gig.gig_request r JOIN gig.request_status s ON s.id = r.request_status_id
    WHERE r.id = NEW.gig_request_id FOR UPDATE OF r;
  IF TG_OP = 'UPDATE' AND (NEW.gig_request_id <> OLD.gig_request_id OR NEW.gig_worker_profile_id <> OLD.gig_worker_profile_id) THEN
    RAISE EXCEPTION 'Gig application worker and request are immutable' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' AND status_code <> 'accepted'
    AND EXISTS (SELECT 1 FROM gig.gig_assignment WHERE gig_application_id = OLD.id) THEN
    RAISE EXCEPTION 'An assigned application must remain accepted' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'INSERT' AND request_status <> 'open' THEN
    RAISE EXCEPTION 'Gig request is not open' USING ERRCODE = '23514';
  END IF;
  IF EXISTS (SELECT 1 FROM gig.gig_worker_list_entry e JOIN gig.worker_list_type t ON t.id = e.worker_list_type_id
    WHERE e.requester_organisation_id = org_id AND e.gig_worker_profile_id = NEW.gig_worker_profile_id
      AND t.code = 'blacklisted' AND e.deleted_at IS NULL) THEN
    RAISE EXCEPTION 'Worker is blacklisted by requester' USING ERRCODE = '23514';
  END IF;
  IF status_code IN ('accepted', 'rejected') THEN
    IF NEW.decided_at IS NULL OR NEW.decision_by_user_account_id IS NULL
      OR NOT identity.is_organisation_member(NEW.decision_by_user_account_id, org_id) THEN
      RAISE EXCEPTION 'Requester decision requires an authorised organisation member' USING ERRCODE = '23514';
    END IF;
  ELSIF NEW.decided_at IS NOT NULL OR NEW.decision_by_user_account_id IS NOT NULL THEN
    RAISE EXCEPTION 'Undecided application cannot carry a requester decision' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_application BEFORE INSERT OR UPDATE ON gig.gig_application FOR EACH ROW EXECUTE FUNCTION gig.validate_application();

CREATE FUNCTION gig.validate_assignment() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig AS $$
DECLARE app_status TEXT; app_worker BIGINT; app_request BIGINT;
BEGIN
  SELECT s.code, a.gig_worker_profile_id, a.gig_request_id
    INTO app_status, app_worker, app_request
    FROM gig.gig_application a JOIN gig.application_status s ON s.id = a.application_status_id
    WHERE a.id = NEW.gig_application_id FOR UPDATE OF a;
  IF app_status <> 'accepted' OR app_worker <> NEW.gig_worker_profile_id OR app_request <> NEW.gig_request_id THEN
    RAISE EXCEPTION 'Assignment requires an accepted application for the same worker and request' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM gig.gig_availability v JOIN gig.availability_status s ON s.id = v.availability_status_id
    WHERE v.gig_worker_profile_id = NEW.gig_worker_profile_id AND v.deleted_at IS NULL
      AND s.code = 'available' AND v.available_from <= NEW.assignment_start_at
      AND v.available_to >= NEW.assignment_end_at) THEN
    RAISE EXCEPTION 'Worker availability must cover the full gig window' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' AND EXISTS (SELECT 1 FROM gig.gig_rating WHERE gig_assignment_id = OLD.id)
    AND (SELECT code FROM gig.assignment_status WHERE id = NEW.assignment_status_id) <> 'completed' THEN
    RAISE EXCEPTION 'A rated assignment must remain completed' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_assignment BEFORE INSERT OR UPDATE ON gig.gig_assignment FOR EACH ROW EXECUTE FUNCTION gig.validate_assignment();

CREATE FUNCTION gig.validate_rating() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig, identity AS $$
DECLARE org_id BIGINT; status_code TEXT;
BEGIN
  SELECT r.requester_organisation_id, s.code INTO org_id, status_code
    FROM gig.gig_assignment a JOIN gig.assignment_status s ON s.id = a.assignment_status_id
    JOIN gig.gig_request r ON r.id = a.gig_request_id
    WHERE a.id = NEW.gig_assignment_id;
  IF status_code <> 'completed' OR NOT identity.is_organisation_member(NEW.requester_user_account_id, org_id) THEN
    RAISE EXCEPTION 'Only the requester can rate a completed gig' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER validate_rating BEFORE INSERT OR UPDATE ON gig.gig_rating FOR EACH ROW EXECUTE FUNCTION gig.validate_rating();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.fulfilment_event FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_application FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_assignment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_rating FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_request FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_worker_list_entry FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON gig.gig_worker_profile FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.credential FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.db_principal FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.session_record FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.user_block FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.user_consent FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON identity.user_role FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.account_administrator FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.account_profile FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.job_recruiter_assignment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.organisation_identifier FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.organisation_member FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.organisation_recruiter FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON organisation.verification_record FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.academic_program FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.accomplishment_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.activity_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_answer FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_document FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_profile_snapshot FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_stage_result FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_status_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.application_withdrawal FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.assessment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.assessment_result FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_academic_result FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_accomplishment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_activity_log FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_activity_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_backlog FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_bookmark FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_bookmark_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_contact FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_document FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_education FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_experience FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_extracurricular_activity FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_job_eligibility_check FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_job_search_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_language FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_profile FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_project FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_skill FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_social_link FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_subject FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.candidate_volunteer_experience FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.city FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.country FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.course FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.course_enrolment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.course_enrolment_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.currency FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.document_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.education_level FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.education_verification FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.eligibility_check_result FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.eligibility_decision FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.employment_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.experience_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.hiring_stage_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.industry FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.institution FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.interview FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.interview_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_academic_criterion FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_application_policy FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_attachment FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_eligibility_policy FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_eligible_program FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_event FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_event_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_external_ats FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_hiring_stage FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_location FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_position FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_position_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_qualification_requirement FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_requirement FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_role FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_shortlist FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_skill_requirement FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.job_status_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.joining_record FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.language FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.offer FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.offer_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.organisation FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.proficiency_level FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.profile_completion_score FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.profile_view_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.qualification FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.question FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.question_option FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.question_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.questionnaire FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.reference_code FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.reference_translation FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.referral_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.referral_tracking FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.resume_template FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.resume_version FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.salary_period FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.score_scale FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.shortlist_history FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.skill FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.social_platform FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.stage_decision FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.state FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.subject FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.ui_translation FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.user_account FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.verification_status FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.withdrawal_outcome FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON public.work_type FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change();

CREATE FUNCTION identity.can_manage_gig_request(p_request_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig, public AS $$
  SELECT identity.has_permission('admin.manage_roles') OR
    (identity.has_permission('gig.request.manage') AND EXISTS (
      SELECT 1 FROM gig.gig_request r WHERE r.id = p_request_id AND r.deleted_at IS NULL
      AND identity.is_organisation_member(identity.actor_user_id(), r.requester_organisation_id)))
$$;

CREATE FUNCTION identity.can_read_gig_request(p_request_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig, public AS $$
  SELECT identity.can_manage_gig_request(p_request_id) OR EXISTS (
    SELECT 1 FROM gig.gig_request r JOIN gig.request_status s ON s.id = r.request_status_id
    WHERE r.id = p_request_id AND r.deleted_at IS NULL AND s.code = 'open'
      AND identity.has_permission('gig.worker.manage')) OR EXISTS (
    SELECT 1 FROM gig.gig_application a JOIN gig.gig_worker_profile w ON w.id = a.gig_worker_profile_id
    WHERE a.gig_request_id = p_request_id AND a.deleted_at IS NULL
      AND w.user_account_id = identity.actor_user_id())
$$;

CREATE FUNCTION identity.can_read_gig_application(p_application_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig AS $$
  SELECT EXISTS (SELECT 1 FROM gig.gig_application a JOIN gig.gig_worker_profile w ON w.id = a.gig_worker_profile_id
    WHERE a.id = p_application_id AND a.deleted_at IS NULL
      AND (w.user_account_id = identity.actor_user_id() OR identity.can_manage_gig_request(a.gig_request_id)))
$$;

ALTER TABLE public.candidate_profile ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.job_requirement ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.organisation ENABLE ROW LEVEL SECURITY;

ALTER TABLE gig.gig_worker_profile ENABLE ROW LEVEL SECURITY;

ALTER TABLE gig.gig_request ENABLE ROW LEVEL SECURITY;

ALTER TABLE gig.gig_application ENABLE ROW LEVEL SECURITY;

ALTER TABLE gig.gig_assignment ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_candidate ON public.candidate_profile FOR SELECT TO talentra_runtime USING (identity.can_view_candidate(id));

CREATE POLICY insert_candidate ON public.candidate_profile FOR INSERT TO talentra_runtime WITH CHECK (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own'));

CREATE POLICY update_candidate ON public.candidate_profile FOR UPDATE TO talentra_runtime USING (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own')) WITH CHECK (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own'));

CREATE POLICY read_job ON public.job_requirement FOR SELECT TO talentra_runtime USING (identity.can_read_job(id));

CREATE POLICY insert_job ON public.job_requirement FOR INSERT TO talentra_runtime WITH CHECK (identity.can_create_job(organisation_id));

CREATE POLICY update_job ON public.job_requirement FOR UPDATE TO talentra_runtime USING (identity.can_manage_job(id)) WITH CHECK (identity.can_manage_job(id));

CREATE POLICY read_organisation ON public.organisation FOR SELECT TO talentra_runtime USING (identity.can_read_organisation(id));

CREATE POLICY read_worker ON gig.gig_worker_profile FOR SELECT TO talentra_runtime USING (user_account_id = identity.actor_user_id() OR identity.has_permission('admin.manage_roles') OR EXISTS (SELECT 1 FROM gig.gig_application a WHERE a.gig_worker_profile_id = id AND identity.can_manage_gig_request(a.gig_request_id)));

CREATE POLICY read_gig_request ON gig.gig_request FOR SELECT TO talentra_runtime USING (identity.can_read_gig_request(id));

CREATE POLICY read_gig_application ON gig.gig_application FOR SELECT TO talentra_runtime USING (identity.can_read_gig_application(id));

CREATE POLICY read_gig_assignment ON gig.gig_assignment FOR SELECT TO talentra_runtime USING (identity.can_read_gig_application(gig_application_id));

GRANT SELECT ON gig.gig_service, gig.gig_availability TO talentra_runtime;

ALTER TABLE gig.gig_service ENABLE ROW LEVEL SECURITY;

ALTER TABLE gig.gig_availability ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_gig_service ON gig.gig_service FOR SELECT TO talentra_runtime USING (EXISTS (SELECT 1 FROM gig.gig_worker_profile w WHERE w.id = gig_worker_profile_id AND w.user_account_id = identity.actor_user_id()));

CREATE POLICY read_gig_availability ON gig.gig_availability FOR SELECT TO talentra_runtime USING (EXISTS (SELECT 1 FROM gig.gig_worker_profile w WHERE w.id = gig_worker_profile_id AND w.user_account_id = identity.actor_user_id()));

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.account_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.credential_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.hash_algorithm FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.consent_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.session_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.app_role FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.permission FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.role_permission FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.user_role FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.db_principal FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.credential FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.session_record FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON identity.user_consent FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON identity.user_consent FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON identity.user_block FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON identity.audit_event FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON identity.audit_event FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON identity.system_error_log FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON identity.system_error_log FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.account_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.organisation_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.identifier_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.verification_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.account_profile FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.organisation_location FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.organisation_identifier FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.verification_record FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.organisation_recruiter FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.account_administrator FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.organisation_member FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organisation.job_recruiter_assignment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.availability_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.request_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.pricing_model FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.application_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.assignment_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.rate_unit FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.worker_list_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_worker_profile FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_service FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_availability FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_request FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_application FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_assignment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_worker_list_entry FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.gig_rating FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON gig.fulfilment_event FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON gig.fulfilment_event FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON gig.worker_project FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

COMMIT;
