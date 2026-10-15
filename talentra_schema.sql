-- Talentra Database Design Hackathon
-- Engine: PostgreSQL 16+
-- Source basis: Talentra Database Design Hackathon Docket, Sections 2-12.
-- Status: proposed implementation baseline; run in a disposable database first.
--
-- Key decisions:
-- * BIGINT identity surrogate PKs; PK column is always `id`.
-- * snake_case, singular table names, idx_<table>_<column>, uq_<table>_<column>.
-- * TIMESTAMPTZ for instants (PostgreSQL stores instants internally in UTC).
-- * Money is NUMERIC plus currency_code; never floating point.
-- * Fixed enumerations are lookup rows, not free text or native ENUMs.
-- * created_by/updated_by are nullable for initial seed/system actions; when supplied,
--   they reference identity.app_user. This is the documented nullability exception.
-- * Business tables use created_at, created_by, updated_at, updated_by, deleted_at.
-- * Append-only ledgers/audit/history are protected by triggers below.
-- * Sensitive values (passwords, verification tokens, tax IDs) must be hashed,
--   tokenized or encrypted by the application/KMS; do not store raw credentials.
--
-- Apply with psql: psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f talentra_schema.sql

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE SCHEMA IF NOT EXISTS master_data;
CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS organisation;
CREATE SCHEMA IF NOT EXISTS profile;
CREATE SCHEMA IF NOT EXISTS hiring;
CREATE SCHEMA IF NOT EXISTS gig;
CREATE SCHEMA IF NOT EXISTS sourcing;
CREATE SCHEMA IF NOT EXISTS licensing;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS engagement;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Shared domains
CREATE DOMAIN master_data.currency_code AS CHAR(3)
  CHECK (VALUE ~ '^[A-Z]{3}$');
CREATE DOMAIN master_data.e164_phone AS VARCHAR(16)
  CHECK (VALUE ~ '^\+[1-9][0-9]{1,14}$');
CREATE DOMAIN master_data.email_address AS VARCHAR(254)
  CHECK (VALUE = lower(VALUE) AND VALUE ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$');

-- Shared metadata columns are repeated intentionally so each table is self-describing.
-- created_by/updated_by FK constraints are added after identity.app_user exists.

-- ---------------------------------------------------------------------------
-- MASTER DATA
-- ---------------------------------------------------------------------------
CREATE TABLE master_data.country (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  country_code CHAR(2) NOT NULL UNIQUE,
  country_name VARCHAR(150) NOT NULL,
  phone_calling_code VARCHAR(8),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_country_country_name UNIQUE (country_name)
);
CREATE TABLE master_data.state (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  country_id BIGINT NOT NULL REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  state_code VARCHAR(20),
  state_name VARCHAR(150) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_state_country_state_name UNIQUE(country_id, state_name)
);
CREATE TABLE master_data.city (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  state_id BIGINT REFERENCES master_data.state(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  country_id BIGINT NOT NULL REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  city_name VARCHAR(150) NOT NULL,
  latitude NUMERIC(9,6),
  longitude NUMERIC(9,6),
  coordinate_source VARCHAR(150),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL)),
  CHECK ((latitude IS NULL AND coordinate_source IS NULL) OR (latitude IS NOT NULL AND coordinate_source IS NOT NULL)),
  CONSTRAINT uq_city_country_state_name UNIQUE(country_id, state_id, city_name)
);
CREATE TABLE master_data.language (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  language_code VARCHAR(16) NOT NULL UNIQUE,
  language_name VARCHAR(150) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_language_name UNIQUE(language_name)
);
CREATE TABLE master_data.skill (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  skill_code VARCHAR(80) UNIQUE,
  skill_name VARCHAR(150) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE master_data.qualification (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  qualification_code VARCHAR(80) UNIQUE,
  qualification_name VARCHAR(150) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE master_data.industry (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  industry_code VARCHAR(80) UNIQUE,
  industry_name VARCHAR(150) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE master_data.job_role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role_code VARCHAR(80) UNIQUE,
  role_name VARCHAR(150) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE master_data.reference_code (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  domain_code VARCHAR(80) NOT NULL,
  code VARCHAR(80) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_reference_code_domain_code UNIQUE(domain_code, code)
);
CREATE TABLE master_data.reference_translation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reference_code_id BIGINT NOT NULL REFERENCES master_data.reference_code(id) ON UPDATE RESTRICT ON DELETE CASCADE,
  language_id BIGINT NOT NULL REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_reference_translation_code_language UNIQUE(reference_code_id, language_id)
);
CREATE TABLE master_data.ui_translation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  translation_key VARCHAR(160) NOT NULL,
  language_id BIGINT NOT NULL REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  translated_text VARCHAR(2000) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_ui_translation_key_language UNIQUE(translation_key, language_id)
);

-- ---------------------------------------------------------------------------
-- IDENTITY, AUTHORIZATION, AUDIT, CONSENT, BLOCKING
-- ---------------------------------------------------------------------------
CREATE TABLE identity.app_user (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email master_data.email_address NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  phone_number master_data.e164_phone,
  phone_country_id BIGINT REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  preferred_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  account_status_code VARCHAR(40) NOT NULL DEFAULT 'active',
  email_verified_at TIMESTAMPTZ,
  phone_verified_at TIMESTAMPTZ,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE identity.credential (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  credential_type_code VARCHAR(40) NOT NULL,
  credential_hash TEXT NOT NULL,
  hash_algorithm VARCHAR(80) NOT NULL,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_credential_user_type UNIQUE(app_user_id, credential_type_code)
);
CREATE TABLE identity.role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role_code VARCHAR(60) NOT NULL UNIQUE,
  role_name VARCHAR(150) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE identity.permission (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  permission_code VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE identity.role_permission (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role_id BIGINT NOT NULL REFERENCES identity.role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  permission_id BIGINT NOT NULL REFERENCES identity.permission(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_role_permission UNIQUE(role_id, permission_id)
);
CREATE TABLE identity.user_role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  role_id BIGINT NOT NULL REFERENCES identity.role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(valid_to IS NULL OR valid_to >= valid_from),
  CONSTRAINT uq_user_role_start UNIQUE(app_user_id, role_id, valid_from)
);
CREATE TABLE identity.user_consent (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  consent_type_code VARCHAR(80) NOT NULL,
  consent_version VARCHAR(40) NOT NULL,
  is_granted BOOLEAN NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  withdrawn_at TIMESTAMPTZ,
  source_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(withdrawn_at IS NULL OR withdrawn_at >= recorded_at)
);
CREATE TABLE identity.user_block (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  blocker_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  blocked_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  block_reason_code VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(blocker_user_id <> blocked_user_id),
  CONSTRAINT uq_user_block UNIQUE(blocker_user_id, blocked_user_id)
);
CREATE TABLE identity.audit_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  action_code VARCHAR(100) NOT NULL,
  entity_schema VARCHAR(80) NOT NULL,
  entity_table VARCHAR(100) NOT NULL,
  entity_id BIGINT,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  request_id UUID,
  source_ip INET,
  outcome_code VARCHAR(40) NOT NULL,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE identity.system_error_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  error_code VARCHAR(100) NOT NULL,
  severity_code VARCHAR(30) NOT NULL,
  component_name VARCHAR(100) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  correlation_id UUID,
  safe_error_message VARCHAR(2000) NOT NULL,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- ORGANISATION AND ACCOUNTS
-- ---------------------------------------------------------------------------
CREATE TABLE organisation.account_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_name VARCHAR(150) NOT NULL,
  account_status_code VARCHAR(40) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE organisation.organisation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_profile_id BIGINT REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  parent_organisation_id BIGINT REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  organisation_name VARCHAR(150) NOT NULL,
  organisation_type_code VARCHAR(60) NOT NULL,
  website_url VARCHAR(2048),
  description TEXT,
  verification_status_code VARCHAR(40) NOT NULL DEFAULT 'pending',
  verified_at TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE organisation.organisation_location (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  location_name VARCHAR(150),
  address_line_1 VARCHAR(250) NOT NULL,
  address_line_2 VARCHAR(250),
  city_id BIGINT REFERENCES master_data.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  postal_code VARCHAR(30),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE organisation.organisation_identifier (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  country_id BIGINT NOT NULL REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  identifier_type_code VARCHAR(80) NOT NULL,
  identifier_value_encrypted BYTEA NOT NULL,
  identifier_fingerprint VARCHAR(128) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_organisation_identifier UNIQUE(country_id, identifier_type_code, identifier_fingerprint)
);
CREATE TABLE organisation.verification_record (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  provider_code VARCHAR(80) NOT NULL,
  verification_type_code VARCHAR(80) NOT NULL,
  status_code VARCHAR(40) NOT NULL,
  provider_reference VARCHAR(200),
  verified_at TIMESTAMPTZ,
  failure_code VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE organisation.organisation_recruiter (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  recruiter_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(valid_to IS NULL OR valid_to >= valid_from),
  CONSTRAINT uq_organisation_recruiter_start UNIQUE(organisation_id, recruiter_user_id, valid_from)
);
CREATE TABLE organisation.account_administrator (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(valid_to IS NULL OR valid_to >= valid_from),
  CONSTRAINT uq_account_admin_start UNIQUE(account_profile_id, app_user_id, valid_from)
);

-- ---------------------------------------------------------------------------
-- PROFILE
-- ---------------------------------------------------------------------------
CREATE TABLE profile.candidate_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL UNIQUE REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  given_name VARCHAR(150),
  family_name VARCHAR(150),
  headline VARCHAR(250),
  summary TEXT,
  date_of_birth DATE,
  country_id BIGINT REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  city_id BIGINT REFERENCES master_data.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  profile_visibility_code VARCHAR(40) NOT NULL DEFAULT 'employers',
  profile_completion_score NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK(profile_completion_score BETWEEN 0 AND 100),
  preferred_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_activity_at TIMESTAMPTZ,
  retention_review_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.candidate_contact (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  contact_type_code VARCHAR(40) NOT NULL,
  contact_value_encrypted BYTEA NOT NULL,
  contact_fingerprint VARCHAR(128),
  country_id BIGINT REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.candidate_education (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  qualification_id BIGINT REFERENCES master_data.qualification(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  institution_name VARCHAR(150) NOT NULL,
  field_of_study VARCHAR(150),
  start_date DATE,
  end_date DATE,
  grade_text VARCHAR(80),
  country_id BIGINT REFERENCES master_data.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(start_date IS NULL OR end_date IS NULL OR end_date >= start_date)
);
CREATE TABLE profile.candidate_experience (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  employer_name VARCHAR(150) NOT NULL,
  job_role_id BIGINT REFERENCES master_data.job_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_title VARCHAR(150) NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE,
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(end_date IS NULL OR end_date >= start_date),
  CHECK(NOT is_current OR end_date IS NULL)
);
CREATE TABLE profile.candidate_skill (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  skill_id BIGINT NOT NULL REFERENCES master_data.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  proficiency_code VARCHAR(40),
  years_experience NUMERIC(4,1) CHECK(years_experience IS NULL OR years_experience BETWEEN 0 AND 80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_candidate_skill UNIQUE(candidate_profile_id, skill_id)
);
CREATE TABLE profile.candidate_language (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  language_id BIGINT NOT NULL REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  proficiency_code VARCHAR(40),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_candidate_language UNIQUE(candidate_profile_id, language_id)
);
CREATE TABLE profile.resume_template (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  template_name VARCHAR(150) NOT NULL,
  template_version VARCHAR(40) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_resume_template_version UNIQUE(template_name, template_version)
);
CREATE TABLE profile.resume (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  resume_template_id BIGINT REFERENCES profile.resume_template(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  resume_name VARCHAR(150) NOT NULL,
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.resume_version (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  resume_id BIGINT NOT NULL REFERENCES profile.resume(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  version_number INTEGER NOT NULL CHECK(version_number > 0),
  body TEXT NOT NULL,
  source_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  checksum_sha256 CHAR(64) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_resume_version UNIQUE(resume_id, version_number)
);
CREATE TABLE profile.candidate_project (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  project_name VARCHAR(150) NOT NULL,
  project_role VARCHAR(150),
  description TEXT,
  start_date DATE,
  end_date DATE,
  outcome VARCHAR(1000),
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(start_date IS NULL OR end_date IS NULL OR end_date >= start_date)
);
CREATE TABLE profile.assessment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  assessment_name VARCHAR(150) NOT NULL,
  provider_code VARCHAR(80),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.assessment_result (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  assessment_id BIGINT NOT NULL REFERENCES profile.assessment(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  score NUMERIC(8,3),
  maximum_score NUMERIC(8,3),
  completed_at TIMESTAMPTZ,
  external_result_reference VARCHAR(200),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(score IS NULL OR score >= 0),
  CHECK(maximum_score IS NULL OR maximum_score >= 0),
  CHECK(score IS NULL OR maximum_score IS NULL OR score <= maximum_score)
);
CREATE TABLE profile.course_enrolment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  course_name VARCHAR(150) NOT NULL,
  provider_name VARCHAR(150),
  enrolled_on DATE,
  completed_on DATE,
  status_code VARCHAR(40) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(enrolled_on IS NULL OR completed_on IS NULL OR completed_on >= enrolled_on)
);
CREATE TABLE profile.candidate_profile_view (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  viewer_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source_code VARCHAR(60),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.candidate_activity_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  actor_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  activity_code VARCHAR(80) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.candidate_job_search_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  search_query VARCHAR(500),
  filters JSONB NOT NULL DEFAULT '{}'::jsonb,
  searched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE profile.referral_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  referrer_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  referred_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  referral_code VARCHAR(100) NOT NULL,
  event_code VARCHAR(60) NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- JOBS AND APPLICATIONS
-- ---------------------------------------------------------------------------
CREATE TABLE hiring.job_requirement (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_title VARCHAR(150) NOT NULL,
  job_description TEXT NOT NULL,
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_role_id BIGINT REFERENCES master_data.job_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  industry_id BIGINT REFERENCES master_data.industry(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  employment_type_code VARCHAR(60) NOT NULL,
  work_type_code VARCHAR(60) NOT NULL,
  job_status_code VARCHAR(40) NOT NULL DEFAULT 'draft',
  publish_state_code VARCHAR(40) NOT NULL DEFAULT 'unpublished',
  is_open_to_consultants BOOLEAN NOT NULL DEFAULT FALSE,
  location_city_id BIGINT REFERENCES master_data.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  minimum_salary NUMERIC(14,2),
  minimum_salary_currency master_data.currency_code,
  maximum_salary NUMERIC(14,2),
  maximum_salary_currency master_data.currency_code,
  salary_disclosure_code VARCHAR(40) NOT NULL DEFAULT 'undisclosed',
  application_open_at TIMESTAMPTZ,
  application_close_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(minimum_salary IS NULL OR minimum_salary >= 0),
  CHECK(maximum_salary IS NULL OR maximum_salary >= 0),
  CHECK(minimum_salary IS NULL OR maximum_salary IS NULL OR minimum_salary <= maximum_salary),
  CHECK((minimum_salary IS NULL) = (minimum_salary_currency IS NULL)),
  CHECK((maximum_salary IS NULL) = (maximum_salary_currency IS NULL)),
  CHECK(application_open_at IS NULL OR application_close_at IS NULL OR application_close_at >= application_open_at)
);
CREATE TABLE hiring.job_position (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  position_title VARCHAR(150) NOT NULL,
  headcount INTEGER NOT NULL DEFAULT 1 CHECK(headcount > 0),
  minimum_experience_years NUMERIC(4,1),
  maximum_experience_years NUMERIC(4,1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(minimum_experience_years IS NULL OR minimum_experience_years >= 0),
  CHECK(maximum_experience_years IS NULL OR maximum_experience_years >= 0),
  CHECK(minimum_experience_years IS NULL OR maximum_experience_years IS NULL OR minimum_experience_years <= maximum_experience_years)
);
CREATE TABLE hiring.job_required_skill (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  skill_id BIGINT NOT NULL REFERENCES master_data.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_job_required_skill UNIQUE(job_requirement_id, skill_id)
);
CREATE TABLE hiring.questionnaire (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  questionnaire_name VARCHAR(150) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE hiring.questionnaire_question (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  questionnaire_id BIGINT NOT NULL REFERENCES hiring.questionnaire(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  question_text VARCHAR(2000) NOT NULL,
  question_type_code VARCHAR(40) NOT NULL,
  is_required BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE hiring.candidate_application (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  application_status_code VARCHAR(40) NOT NULL DEFAULT 'applied',
  applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  current_stage_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source_code VARCHAR(60) NOT NULL DEFAULT 'direct',
  withdrawn_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_candidate_job_application UNIQUE(candidate_profile_id, job_requirement_id)
);
CREATE TABLE hiring.application_status_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_application_id BIGINT NOT NULL REFERENCES hiring.candidate_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  old_status_code VARCHAR(40),
  new_status_code VARCHAR(40) NOT NULL,
  changed_by_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason_code VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE hiring.application_answer (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_application_id BIGINT NOT NULL REFERENCES hiring.candidate_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  questionnaire_question_id BIGINT NOT NULL REFERENCES hiring.questionnaire_question(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  answer_text VARCHAR(5000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_application_answer UNIQUE(candidate_application_id, questionnaire_question_id)
);
CREATE TABLE hiring.job_shortlist (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  shortlisted_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  shortlist_status_code VARCHAR(40) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_job_shortlist_candidate UNIQUE(job_requirement_id, candidate_profile_id)
);
CREATE TABLE hiring.candidate_bookmark (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  owner_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_candidate_bookmark UNIQUE(owner_user_id, candidate_profile_id)
);
CREATE TABLE hiring.interview (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_application_id BIGINT NOT NULL REFERENCES hiring.candidate_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  scheduled_start_at TIMESTAMPTZ NOT NULL,
  scheduled_end_at TIMESTAMPTZ NOT NULL,
  source_time_zone VARCHAR(80),
  interview_mode_code VARCHAR(40) NOT NULL,
  status_code VARCHAR(40) NOT NULL DEFAULT 'scheduled',
  meeting_reference VARCHAR(500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(scheduled_end_at > scheduled_start_at)
);
CREATE TABLE hiring.job_offer (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_application_id BIGINT NOT NULL REFERENCES hiring.candidate_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  offer_status_code VARCHAR(40) NOT NULL DEFAULT 'draft',
  offered_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  annual_salary NUMERIC(14,2),
  salary_currency master_data.currency_code,
  joined_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(annual_salary IS NULL OR annual_salary >= 0),
  CHECK((annual_salary IS NULL) = (salary_currency IS NULL)),
  CHECK(expires_at IS NULL OR offered_at IS NULL OR expires_at >= offered_at)
);

-- ---------------------------------------------------------------------------
-- GIG MARKETPLACE (separate subsystem; distinct worker profile and lifecycle)
-- ---------------------------------------------------------------------------
CREATE TABLE gig.gig_worker_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL UNIQUE REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  public_name VARCHAR(150) NOT NULL,
  bio TEXT,
  home_city_id BIGINT REFERENCES master_data.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE gig.gig_service (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  service_name VARCHAR(150) NOT NULL,
  description VARCHAR(2000),
  rate_amount NUMERIC(14,2) NOT NULL CHECK(rate_amount >= 0),
  currency_code master_data.currency_code NOT NULL,
  rate_unit_code VARCHAR(40) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE gig.gig_availability (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  available_from TIMESTAMPTZ NOT NULL,
  available_to TIMESTAMPTZ NOT NULL,
  availability_status_code VARCHAR(40) NOT NULL DEFAULT 'available',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(available_to > available_from)
);
ALTER TABLE gig.gig_availability
  ADD CONSTRAINT ex_gig_availability_no_overlap
  EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(available_from, available_to, '[)') WITH &&)
  WHERE (deleted_at IS NULL AND availability_status_code = 'available');
CREATE TABLE gig.gig_request (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  requester_organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  gig_title VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  pricing_model_code VARCHAR(40) NOT NULL,
  price_amount NUMERIC(14,2) NOT NULL CHECK(price_amount >= 0),
  currency_code master_data.currency_code NOT NULL,
  status_code VARCHAR(40) NOT NULL DEFAULT 'open',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(end_at > start_at)
);
CREATE TABLE gig.gig_application (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gig_request_id BIGINT NOT NULL REFERENCES gig.gig_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  application_status_code VARCHAR(40) NOT NULL DEFAULT 'submitted',
  proposed_amount NUMERIC(14,2),
  proposed_currency master_data.currency_code,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  decision_at TIMESTAMPTZ,
  decision_by_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(proposed_amount IS NULL OR proposed_amount >= 0),
  CHECK((proposed_amount IS NULL) = (proposed_currency IS NULL)),
  CONSTRAINT uq_gig_application_worker_request UNIQUE(gig_request_id, gig_worker_profile_id)
);
CREATE TABLE gig.gig_assignment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gig_application_id BIGINT NOT NULL UNIQUE REFERENCES gig.gig_application(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  external_system_code VARCHAR(80) NOT NULL,
  handoff_reference VARCHAR(200) NOT NULL,
  assignment_status_code VARCHAR(40) NOT NULL,
  handed_off_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reconciled_at TIMESTAMPTZ,
  estimated_earnings NUMERIC(14,2),
  estimated_currency master_data.currency_code,
  total_earnings NUMERIC(14,2),
  total_currency master_data.currency_code,
  projected_earnings NUMERIC(14,2),
  projected_currency master_data.currency_code,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_gig_assignment_external_reference UNIQUE(external_system_code, handoff_reference),
  CHECK(estimated_earnings IS NULL OR estimated_earnings >= 0),
  CHECK(total_earnings IS NULL OR total_earnings >= 0),
  CHECK(projected_earnings IS NULL OR projected_earnings >= 0),
  CHECK((estimated_earnings IS NULL) = (estimated_currency IS NULL)),
  CHECK((total_earnings IS NULL) = (total_currency IS NULL)),
  CHECK((projected_earnings IS NULL) = (projected_currency IS NULL))
);
-- Copy the accepted worker and gig window onto the assignment so PostgreSQL can
-- enforce non-overlap without relying on a cross-table trigger.
ALTER TABLE gig.gig_assignment
  ADD COLUMN gig_worker_profile_id BIGINT REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  ADD COLUMN assignment_start_at TIMESTAMPTZ,
  ADD COLUMN assignment_end_at TIMESTAMPTZ;
ALTER TABLE gig.gig_assignment
  ADD CONSTRAINT ck_gig_assignment_window
  CHECK (assignment_start_at IS NULL OR assignment_end_at IS NULL OR assignment_end_at > assignment_start_at);
ALTER TABLE gig.gig_assignment
  ADD CONSTRAINT ex_gig_assignment_worker_no_overlap
  EXCLUDE USING gist (
    gig_worker_profile_id WITH =,
    tstzrange(assignment_start_at, assignment_end_at, '[)') WITH &&
  )
  WHERE (deleted_at IS NULL AND gig_worker_profile_id IS NOT NULL
         AND assignment_start_at IS NOT NULL AND assignment_end_at IS NOT NULL);

CREATE TABLE gig.gig_worker_list_entry (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  requester_organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  list_type_code VARCHAR(40) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_gig_worker_list UNIQUE(requester_organisation_id, gig_worker_profile_id, list_type_code)
);
CREATE TABLE gig.gig_rating (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  gig_assignment_id BIGINT NOT NULL UNIQUE REFERENCES gig.gig_assignment(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  requester_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  rating_value SMALLINT NOT NULL CHECK(rating_value BETWEEN 1 AND 5),
  review_text VARCHAR(2000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- SOURCING AND CONSULTANT REQUESTS
-- ---------------------------------------------------------------------------
CREATE TABLE sourcing.sourcing_request (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  consultant_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  requested_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  request_status_code VARCHAR(40) NOT NULL DEFAULT 'pending',
  requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  decision_at TIMESTAMPTZ,
  decision_reason VARCHAR(1000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE sourcing.outreach_batch (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_id BIGINT NOT NULL REFERENCES organisation.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_requirement_id BIGINT REFERENCES hiring.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  batch_status_code VARCHAR(40) NOT NULL DEFAULT 'queued',
  scheduled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE sourcing.outreach_recipient (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  outreach_batch_id BIGINT NOT NULL REFERENCES sourcing.outreach_batch(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  delivery_status_code VARCHAR(40) NOT NULL DEFAULT 'queued',
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_outreach_recipient UNIQUE(outreach_batch_id, candidate_profile_id)
);
CREATE TABLE sourcing.candidate_sourcing_shortlist (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sourcing_request_id BIGINT NOT NULL REFERENCES sourcing.sourcing_request(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  job_shortlist_id BIGINT NOT NULL REFERENCES hiring.job_shortlist(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  submitted_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_sourcing_shortlist UNIQUE(sourcing_request_id, job_shortlist_id)
);

-- ---------------------------------------------------------------------------
-- LICENSING, SEATS, DEVICES AND SESSIONS
-- ---------------------------------------------------------------------------
CREATE TABLE licensing.subscription_licence (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  licence_code VARCHAR(100) NOT NULL UNIQUE,
  max_users INTEGER NOT NULL CHECK(max_users > 0),
  max_devices_per_user INTEGER NOT NULL CHECK(max_devices_per_user > 0),
  valid_from TIMESTAMPTZ NOT NULL,
  valid_to TIMESTAMPTZ,
  licence_status_code VARCHAR(40) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(valid_to IS NULL OR valid_to >= valid_from)
);
CREATE TABLE licensing.licence_seat (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subscription_licence_id BIGINT NOT NULL REFERENCES licensing.subscription_licence(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  released_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(released_at IS NULL OR released_at >= assigned_at)
);
CREATE UNIQUE INDEX uq_licence_seat_active_user ON licensing.licence_seat(subscription_licence_id, app_user_id)
  WHERE released_at IS NULL AND deleted_at IS NULL;
CREATE TABLE licensing.registered_device (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  device_fingerprint_hash VARCHAR(128) NOT NULL,
  device_label VARCHAR(150),
  registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_registered_device_fingerprint UNIQUE(app_user_id, device_fingerprint_hash)
);
CREATE TABLE licensing.user_session (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  registered_device_id BIGINT NOT NULL REFERENCES licensing.registered_device(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  session_token_hash VARCHAR(128) NOT NULL UNIQUE,
  started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(expires_at >= started_at),
  CHECK(last_activity_at >= started_at),
  CHECK(ended_at IS NULL OR ended_at >= started_at)
);
CREATE TABLE licensing.login_attempt (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  attempted_email master_data.email_address,
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  outcome_code VARCHAR(40) NOT NULL,
  reason_code VARCHAR(80),
  source_ip INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE licensing.session_revocation_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_session_id BIGINT NOT NULL REFERENCES licensing.user_session(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  revoked_by_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  reason_code VARCHAR(80) NOT NULL,
  revoked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- SUBSCRIPTIONS, WALLET, PAYMENTS, DOWNLOAD HISTORY
-- ---------------------------------------------------------------------------
CREATE TABLE billing.subscription_plan (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  plan_code VARCHAR(80) NOT NULL UNIQUE,
  plan_name VARCHAR(150) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE billing.plan_entitlement (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subscription_plan_id BIGINT NOT NULL REFERENCES billing.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  entitlement_code VARCHAR(100) NOT NULL,
  entitlement_value JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_plan_entitlement UNIQUE(subscription_plan_id, entitlement_code)
);
CREATE TABLE billing.subscription_period (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subscription_licence_id BIGINT NOT NULL REFERENCES licensing.subscription_licence(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  subscription_plan_id BIGINT NOT NULL REFERENCES billing.subscription_plan(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  subscription_status_code VARCHAR(40) NOT NULL DEFAULT 'active',
  renewed_from_period_id BIGINT REFERENCES billing.subscription_period(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(period_end > period_start)
);
ALTER TABLE billing.subscription_period
  ADD CONSTRAINT ex_subscription_period_no_overlap
  EXCLUDE USING gist (subscription_licence_id WITH =, tstzrange(period_start, period_end, '[)') WITH &&)
  WHERE (deleted_at IS NULL);
CREATE TABLE billing.payment_order (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_profile_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  subscription_period_id BIGINT REFERENCES billing.subscription_period(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  gateway_code VARCHAR(80) NOT NULL,
  gateway_transaction_reference VARCHAR(200),
  idempotency_key VARCHAR(200) NOT NULL,
  payment_status_code VARCHAR(40) NOT NULL DEFAULT 'pending',
  amount NUMERIC(14,2) NOT NULL CHECK(amount >= 0),
  currency_code master_data.currency_code NOT NULL,
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  settled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_payment_idempotency UNIQUE(gateway_code, idempotency_key),
  CONSTRAINT uq_payment_gateway_reference UNIQUE(gateway_code, gateway_transaction_reference)
);
CREATE TABLE billing.invoice (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  payment_order_id BIGINT NOT NULL UNIQUE REFERENCES billing.payment_order(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  invoice_number VARCHAR(100) NOT NULL UNIQUE,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  amount NUMERIC(14,2) NOT NULL CHECK(amount >= 0),
  currency_code master_data.currency_code NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE billing.refund (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  payment_order_id BIGINT NOT NULL REFERENCES billing.payment_order(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  gateway_refund_reference VARCHAR(200),
  refund_status_code VARCHAR(40) NOT NULL DEFAULT 'pending',
  amount NUMERIC(14,2) NOT NULL CHECK(amount > 0),
  currency_code master_data.currency_code NOT NULL,
  idempotency_key VARCHAR(200) NOT NULL UNIQUE,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  settled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_gateway_refund_reference UNIQUE(gateway_refund_reference)
);
CREATE TABLE billing.wallet (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_profile_id BIGINT NOT NULL UNIQUE REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  currency_code master_data.currency_code NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE billing.wallet_ledger_entry (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  wallet_id BIGINT NOT NULL REFERENCES billing.wallet(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  entry_type_code VARCHAR(60) NOT NULL,
  amount NUMERIC(14,2) NOT NULL CHECK(amount <> 0),
  currency_code master_data.currency_code NOT NULL,
  source_type_code VARCHAR(80) NOT NULL,
  source_reference VARCHAR(200) NOT NULL,
  idempotency_key VARCHAR(200) NOT NULL UNIQUE,
  corrects_ledger_entry_id BIGINT REFERENCES billing.wallet_ledger_entry(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE billing.credit_consumption (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  wallet_id BIGINT NOT NULL REFERENCES billing.wallet(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  action_code VARCHAR(80) NOT NULL,
  amount NUMERIC(14,2) NOT NULL CHECK(amount > 0),
  currency_code master_data.currency_code NOT NULL,
  source_type_code VARCHAR(80) NOT NULL,
  source_id BIGINT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idempotency_key VARCHAR(200) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE billing.profile_download_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  downloaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  credit_consumption_id BIGINT REFERENCES billing.credit_consumption(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  credits_deducted NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK(credits_deducted >= 0),
  currency_code master_data.currency_code NOT NULL,
  download_reference VARCHAR(200),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- NOTIFICATIONS, PREFERENCES, COMMUNITY AND SUPPORT
-- ---------------------------------------------------------------------------
CREATE TABLE engagement.user_preference (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL UNIQUE REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  preferred_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  time_zone_name VARCHAR(80),
  privacy_settings JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.notification_preference (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  channel_code VARCHAR(40) NOT NULL,
  notification_type_code VARCHAR(80) NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_notification_preference UNIQUE(app_user_id, channel_code, notification_type_code)
);
CREATE TABLE engagement.job_alert_preference (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  candidate_profile_id BIGINT NOT NULL REFERENCES profile.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  alert_name VARCHAR(150) NOT NULL,
  search_filters JSONB NOT NULL DEFAULT '{}'::jsonb,
  frequency_code VARCHAR(40) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.notification (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  recipient_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  notification_type_code VARCHAR(80) NOT NULL,
  subject_text VARCHAR(500),
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  related_entity_type VARCHAR(80),
  related_entity_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.notification_delivery (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  notification_id BIGINT NOT NULL REFERENCES engagement.notification(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  provider_code VARCHAR(80) NOT NULL,
  provider_message_reference VARCHAR(200),
  delivery_status_code VARCHAR(40) NOT NULL DEFAULT 'queued',
  attempt_count INTEGER NOT NULL DEFAULT 0 CHECK(attempt_count >= 0),
  attempted_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  safe_error_code VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.community_post (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  author_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  post_body VARCHAR(5000) NOT NULL,
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  moderation_status_code VARCHAR(40) NOT NULL DEFAULT 'pending',
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.community_reaction (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  community_post_id BIGINT NOT NULL REFERENCES engagement.community_post(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  reaction_code VARCHAR(40) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_community_reaction UNIQUE(community_post_id, app_user_id)
);
CREATE TABLE engagement.support_ticket (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  opened_by_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  assigned_to_user_id BIGINT REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  subject VARCHAR(250) NOT NULL,
  description VARCHAR(5000) NOT NULL,
  status_code VARCHAR(40) NOT NULL DEFAULT 'open',
  priority_code VARCHAR(40) NOT NULL DEFAULT 'normal',
  opened_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(closed_at IS NULL OR closed_at >= opened_at)
);
CREATE TABLE engagement.support_ticket_message (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  support_ticket_id BIGINT NOT NULL REFERENCES engagement.support_ticket(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  author_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  message_body VARCHAR(5000) NOT NULL,
  content_language_id BIGINT REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.faq (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  faq_code VARCHAR(100) NOT NULL UNIQUE,
  question_text VARCHAR(1000) NOT NULL,
  answer_text VARCHAR(5000) NOT NULL,
  language_id BIGINT NOT NULL REFERENCES master_data.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE engagement.social_share_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  app_user_id BIGINT NOT NULL REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  destination_code VARCHAR(60) NOT NULL,
  outbound_url VARCHAR(2048) NOT NULL,
  shared_entity_type VARCHAR(80) NOT NULL,
  shared_entity_id BIGINT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- ANALYTICS LAYER (starter star schema; build facts from validated source data)
-- ---------------------------------------------------------------------------
CREATE TABLE analytics.dim_date (
  id INTEGER PRIMARY KEY,
  calendar_date DATE NOT NULL UNIQUE,
  calendar_year SMALLINT NOT NULL,
  calendar_quarter SMALLINT NOT NULL CHECK(calendar_quarter BETWEEN 1 AND 4),
  calendar_month SMALLINT NOT NULL CHECK(calendar_month BETWEEN 1 AND 12),
  day_of_month SMALLINT NOT NULL CHECK(day_of_month BETWEEN 1 AND 31),
  day_of_week SMALLINT NOT NULL CHECK(day_of_week BETWEEN 1 AND 7),
  is_weekend BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);
CREATE TABLE analytics.dim_organisation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_organisation_id BIGINT NOT NULL,
  organisation_name VARCHAR(150) NOT NULL,
  organisation_type_code VARCHAR(60) NOT NULL,
  effective_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  effective_to TIMESTAMPTZ,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ,
  CHECK(effective_to IS NULL OR effective_to >= effective_from)
);
CREATE TABLE analytics.fact_application (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_application_id BIGINT NOT NULL UNIQUE,
  application_date_id INTEGER REFERENCES analytics.dim_date(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  organisation_dimension_id BIGINT REFERENCES analytics.dim_organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  application_status_code VARCHAR(40) NOT NULL,
  application_count INTEGER NOT NULL DEFAULT 1 CHECK(application_count >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by BIGINT, deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------------
-- AUDIT / APPEND-ONLY ENFORCEMENT
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION identity.reject_mutation()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Table %.% is append-only; UPDATE/DELETE is forbidden',
    TG_TABLE_SCHEMA, TG_TABLE_NAME;
END;
$$;

CREATE TRIGGER trg_audit_event_append_only
BEFORE UPDATE OR DELETE ON identity.audit_event
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_wallet_ledger_append_only
BEFORE UPDATE OR DELETE ON billing.wallet_ledger_entry
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_payment_order_history_append_only
BEFORE DELETE ON billing.payment_order
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_profile_download_history_append_only
BEFORE UPDATE OR DELETE ON billing.profile_download_history
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_application_status_history_append_only
BEFORE UPDATE OR DELETE ON hiring.application_status_history
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_candidate_activity_log_append_only
BEFORE UPDATE OR DELETE ON profile.candidate_activity_log
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_login_attempt_append_only
BEFORE UPDATE OR DELETE ON licensing.login_attempt
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

CREATE TRIGGER trg_session_revocation_event_append_only
BEFORE UPDATE OR DELETE ON licensing.session_revocation_event
FOR EACH ROW EXECUTE FUNCTION identity.reject_mutation();

-- Add actor metadata FKs now that identity.app_user exists.
-- ON DELETE RESTRICT preserves the identity referenced by historical records.
DO $$
DECLARE
  t RECORD;
BEGIN
  FOR t IN
    SELECT table_schema, table_name
    FROM information_schema.columns
    WHERE column_name IN ('created_by', 'updated_by')
      AND table_schema IN ('master_data','identity','organisation','profile','hiring',
                           'gig','sourcing','licensing','billing','engagement','analytics')
    GROUP BY table_schema, table_name
  LOOP
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema=t.table_schema AND table_name=t.table_name AND column_name='created_by') THEN
      EXECUTE format('ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (created_by) REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
        t.table_schema, t.table_name, 'fk_' || t.table_name || '_created_by');
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema=t.table_schema AND table_name=t.table_name AND column_name='updated_by') THEN
      EXECUTE format('ALTER TABLE %I.%I ADD CONSTRAINT %I FOREIGN KEY (updated_by) REFERENCES identity.app_user(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
        t.table_schema, t.table_name, 'fk_' || t.table_name || '_updated_by');
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- INDEXES FOR CORE ACCESS PATHS (validate with EXPLAIN ANALYZE and real data)
-- ---------------------------------------------------------------------------
CREATE INDEX idx_candidate_profile_city_id ON profile.candidate_profile(city_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_candidate_profile_last_activity_at ON profile.candidate_profile(last_activity_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_candidate_skill_skill_id ON profile.candidate_skill(skill_id);
CREATE INDEX idx_candidate_experience_candidate_profile_id ON profile.candidate_experience(candidate_profile_id);
CREATE INDEX idx_job_requirement_org_status ON hiring.job_requirement(organisation_id, job_status_code) WHERE deleted_at IS NULL;
CREATE INDEX idx_job_requirement_publish_state ON hiring.job_requirement(publish_state_code, published_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_candidate_application_job_status ON hiring.candidate_application(job_requirement_id, application_status_code);
CREATE INDEX idx_candidate_application_candidate_applied ON hiring.candidate_application(candidate_profile_id, applied_at DESC);
CREATE INDEX idx_application_status_history_application_changed ON hiring.application_status_history(candidate_application_id, changed_at DESC);
CREATE INDEX idx_job_shortlist_job_requirement_id ON hiring.job_shortlist(job_requirement_id);
CREATE INDEX idx_organisation_recruiter_user_validity ON organisation.organisation_recruiter(recruiter_user_id, valid_from, valid_to);
CREATE INDEX idx_user_block_blocked_user_id ON identity.user_block(blocked_user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_audit_event_actor_occurred ON identity.audit_event(actor_user_id, occurred_at DESC);
CREATE INDEX idx_notification_delivery_status_attempted ON engagement.notification_delivery(delivery_status_code, attempted_at);
CREATE INDEX idx_profile_download_candidate_time ON billing.profile_download_history(candidate_profile_id, downloaded_at DESC);
CREATE INDEX idx_gig_request_window ON gig.gig_request(start_at, end_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_gig_application_request_status ON gig.gig_application(gig_request_id, application_status_code);
CREATE INDEX idx_user_session_active_user ON licensing.user_session(app_user_id, expires_at) WHERE ended_at IS NULL AND revoked_at IS NULL;
CREATE INDEX idx_sourcing_request_consultant_status ON sourcing.sourcing_request(consultant_user_id, request_status_code);

-- ---------------------------------------------------------------------------
-- STARTER ROLES AND PERMISSIONS
-- Codes are data, not database ENUMs. Extend through migrations.
-- ---------------------------------------------------------------------------
INSERT INTO identity.role(role_code, role_name) VALUES
 ('super_admin','Super Admin'), ('admin','Admin'), ('account_admin','Account Admin'),
 ('guest','Guest'), ('candidate','Candidate'), ('employer','Employer'),
 ('recruiter','Recruiter'), ('consultant','Consultant'), ('placement_officer','Placement Officer (TPO)')
ON CONFLICT(role_code) DO NOTHING;

INSERT INTO identity.permission(permission_code, description) VALUES
 ('profile.read.public','Read public profile data'),
 ('profile.read.personal','Read candidate personal data when authorized'),
 ('profile.update.own','Update own candidate profile'),
 ('job.create.own_org','Create job requirements for own organisation'),
 ('job.read.own_org','Read job requirements belonging to own organisation'),
 ('application.manage.own_job','Manage applications for authorised job requirements'),
 ('sourcing.consultant.open_only','Work only on requirements open to consultants'),
 ('user.admin','Administer platform users and roles'),
 ('audit.read','Read audit events with explicit authorization')
ON CONFLICT(permission_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- IMPORTANT BUSINESS RULES THAT NEED TRANSACTION-SAFE SERVICE/DB PROCEDURES
-- ---------------------------------------------------------------------------
-- 1. Recruiter scope: every job read/write query must join organisation.organisation_recruiter
--    and verify active effective mapping for the acting recruiter. Enforce with RLS policies
--    or SECURITY DEFINER functions; never trust a client-supplied organisation_id.
-- 2. Consultant scope: sourcing actions must verify job_requirement.is_open_to_consultants = true
--    and the sourcing request belongs to that consultant. Use RLS/policies or controlled functions.
-- 3. Candidate block: before returning profile rows, check identity.user_block against the actor;
--    add a separate organisation-block relation if blocking whole companies is required.
-- 4. Recruiters cannot create candidate profiles. Grant profile INSERT only to a narrowly scoped
--    candidate-registration service role; do not grant it to recruiter role.
-- 5. Device limits: login transaction must lock the licence/user row FOR UPDATE, count non-ended,
--    non-revoked sessions whose expires_at > CURRENT_TIMESTAMP, and reject/log if count reaches
--    max_devices_per_user. Session creation and count check must be in the same transaction.
-- 6. Licence max_users: allocate seats under a lock on subscription_licence and reject when the
--    count of unreleased seats reaches max_users.
-- 7. Wallet balance: derive from ledger entries or maintain a separately locked balance projection;
--    debit and ledger insert must occur atomically. Use idempotency_key to prevent duplicate charges.
-- 8. Retention: implement scheduled deletion/anonymization by entity. Candidate profile, contact,
--    resume, activity and application retention periods must be defined in policy before launch.
-- 9. Notification payloads: do not persist full provider message bodies longer than required for audit.
-- 10. Soft-delete: all default application queries must filter deleted_at IS NULL.
-- 11. This version intentionally does not model sub-roles inside an employer organisation; later
--     extension: organisation-scoped role assignments and permissions for posting/interview/pipeline.
-- 12. This script defines core and supporting entities, but full data dictionary sensitivity tags,
--     competitor coverage matrix, provider failure/outbox workflows, full RLS policies, data generator,
--     all KPI facts, and benchmark evidence remain separate deliverables.


-- ---------------------------------------------------------------------------
-- COLUMN DATA DICTIONARY / SENSITIVITY CLASSIFICATION
-- ---------------------------------------------------------------------------
CREATE TABLE master_data.data_dictionary_column (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  schema_name VARCHAR(80) NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  column_name VARCHAR(100) NOT NULL,
  data_classification VARCHAR(20) NOT NULL
    CHECK (data_classification IN ('public','internal','personal','sensitive')),
  nullable_reason VARCHAR(500) NOT NULL,
  retention_rule VARCHAR(500) NOT NULL,
  protection_note VARCHAR(500) NOT NULL,
  CONSTRAINT uq_data_dictionary_column UNIQUE(schema_name, table_name, column_name)
);

DO $$
DECLARE c RECORD; v_class TEXT; v_nullable_reason TEXT; v_retention TEXT; v_protection TEXT;
BEGIN
  FOR c IN
    SELECT table_schema, table_name, column_name, is_nullable
    FROM information_schema.columns
    WHERE table_schema IN ('master_data','identity','organisation','profile','hiring',
                           'gig','sourcing','licensing','billing','engagement','analytics')
      AND table_name <> 'data_dictionary_column'
  LOOP
    v_class := 'internal';
    v_protection := 'Role-scoped access; do not expose directly without authorization review.';
    IF c.column_name ~* '(password|credential_hash|session_token_hash|identifier_value|identifier_fingerprint|tax|payment_reference|gateway_transaction|bank|national_id|device_fingerprint)' THEN
      v_class := 'sensitive';
      v_protection := 'Hash/tokenize or encrypt with application/KMS key management; mask in logs and exports.';
    ELSIF c.column_name ~* '(email|phone|contact|given_name|family_name|date_of_birth|address|source_ip|candidate|app_user|actor_user|author_user|recipient_user|review_text|message_body|post_body)' OR
          c.table_name ~* '(candidate|consent|user_session|login_attempt|profile_view|activity_log|download_history)' THEN
      v_class := 'personal';
      v_protection := 'Least-privilege access, audit sensitive reads/writes, redact logs, apply retention policy.';
    END IF;
    IF c.is_nullable = 'YES' THEN
      v_nullable_reason := 'Nullable for an unknown, not yet supplied, or not applicable value; never use sentinel values. Column owner must confirm the specific reason before sign-off.';
    ELSE
      v_nullable_reason := 'NOT NULL because required for entity identity, business integrity, or deterministic processing.';
    END IF;
    IF c.table_schema IN ('profile','identity') OR c.table_name IN ('candidate_application','candidate_activity_log','candidate_profile_view','profile_download_history') THEN
      v_retention := 'Retain while account is active and for approved legal/business period; support deletion requests and inactivity review through a privileged scheduled process.';
    ELSIF c.table_schema IN ('billing','licensing') OR c.table_name IN ('audit_event','application_status_history','login_attempt','session_revocation_event') THEN
      v_retention := 'Retain for approved financial/security audit period; immutable history is corrected by compensating entries, not update/delete.';
    ELSE
      v_retention := 'Retain while required for operation; soft-delete where deleted_at exists; apply approved retention schedule.';
    END IF;
    INSERT INTO master_data.data_dictionary_column(
      schema_name, table_name, column_name, data_classification,
      nullable_reason, retention_rule, protection_note
    ) VALUES (
      c.table_schema, c.table_name, c.column_name, v_class,
      v_nullable_reason, v_retention, v_protection
    ) ON CONFLICT(schema_name, table_name, column_name) DO UPDATE
      SET data_classification = EXCLUDED.data_classification,
          nullable_reason = EXCLUDED.nullable_reason,
          retention_rule = EXCLUDED.retention_rule,
          protection_note = EXCLUDED.protection_note;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- ACTOR CONTEXT AND ROLE CHECKS
-- ---------------------------------------------------------------------------
-- The trusted API sets SET LOCAL talentra.user_id = '<authenticated user id>'
-- inside each transaction. Never accept this setting from an untrusted client.
CREATE OR REPLACE FUNCTION identity.current_app_user_id()
RETURNS BIGINT LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('talentra.user_id', true), '')::BIGINT
$$;

CREATE OR REPLACE FUNCTION identity.current_user_has_role(p_role_code TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
  SELECT EXISTS (
    SELECT 1
    FROM identity.user_role ur
    JOIN identity.role r ON r.id = ur.role_id
    WHERE ur.app_user_id = identity.current_app_user_id()
      AND r.role_code = p_role_code
      AND ur.valid_from <= CURRENT_TIMESTAMP
      AND (ur.valid_to IS NULL OR ur.valid_to > CURRENT_TIMESTAMP)
      AND ur.deleted_at IS NULL AND r.deleted_at IS NULL AND r.is_active
  )
$$;

-- Recruiters can access only requirements in organisations with an active mapping.
-- Consultants can discover only jobs explicitly open to consultants.
ALTER TABLE hiring.job_requirement ENABLE ROW LEVEL SECURITY;
ALTER TABLE hiring.job_requirement FORCE ROW LEVEL SECURITY;
CREATE POLICY job_requirement_select_scope ON hiring.job_requirement
FOR SELECT USING (
  created_by_user_id = identity.current_app_user_id()
  OR identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
  OR EXISTS (
    SELECT 1 FROM organisation.organisation_recruiter orc
    WHERE orc.organisation_id = job_requirement.organisation_id
      AND orc.recruiter_user_id = identity.current_app_user_id()
      AND orc.is_active AND orc.valid_from <= CURRENT_TIMESTAMP
      AND (orc.valid_to IS NULL OR orc.valid_to > CURRENT_TIMESTAMP)
      AND orc.deleted_at IS NULL
  )
  OR (job_requirement.is_open_to_consultants = TRUE
      AND identity.current_user_has_role('consultant'))
);
CREATE POLICY job_requirement_insert_scope ON hiring.job_requirement
FOR INSERT WITH CHECK (
  created_by_user_id = identity.current_app_user_id()
  AND (
    identity.current_user_has_role('super_admin')
    OR identity.current_user_has_role('admin')
    OR EXISTS (
      SELECT 1 FROM organisation.organisation_recruiter orc
      WHERE orc.organisation_id = job_requirement.organisation_id
        AND orc.recruiter_user_id = identity.current_app_user_id()
        AND orc.is_active AND orc.valid_from <= CURRENT_TIMESTAMP
        AND (orc.valid_to IS NULL OR orc.valid_to > CURRENT_TIMESTAMP)
        AND orc.deleted_at IS NULL
    )
    OR EXISTS (
      SELECT 1 FROM organisation.account_administrator aa
      JOIN organisation.organisation o ON o.account_profile_id = aa.account_profile_id
      WHERE o.id = job_requirement.organisation_id
        AND aa.app_user_id = identity.current_app_user_id()
        AND aa.valid_from <= CURRENT_TIMESTAMP
        AND (aa.valid_to IS NULL OR aa.valid_to > CURRENT_TIMESTAMP)
        AND aa.deleted_at IS NULL
    )
  )
);
CREATE POLICY job_requirement_update_scope ON hiring.job_requirement
FOR UPDATE USING (
  identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
  OR EXISTS (
    SELECT 1 FROM organisation.organisation_recruiter orc
    WHERE orc.organisation_id = job_requirement.organisation_id
      AND orc.recruiter_user_id = identity.current_app_user_id()
      AND orc.is_active AND orc.valid_from <= CURRENT_TIMESTAMP
      AND (orc.valid_to IS NULL OR orc.valid_to > CURRENT_TIMESTAMP)
      AND orc.deleted_at IS NULL
  )
) WITH CHECK (
  identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
  OR EXISTS (
    SELECT 1 FROM organisation.organisation_recruiter orc
    WHERE orc.organisation_id = job_requirement.organisation_id
      AND orc.recruiter_user_id = identity.current_app_user_id()
      AND orc.is_active AND orc.valid_from <= CURRENT_TIMESTAMP
      AND (orc.valid_to IS NULL OR orc.valid_to > CURRENT_TIMESTAMP)
      AND orc.deleted_at IS NULL
  )
);
CREATE POLICY job_requirement_delete_scope ON hiring.job_requirement
FOR DELETE USING (
  identity.current_user_has_role('super_admin') OR identity.current_user_has_role('admin')
);

-- Candidate access is limited to the candidate, administrators, employer-side users
-- linked to an application, or a consultant's sourcing shortlist. Candidate blocks
-- take precedence over employer-side access.
ALTER TABLE profile.candidate_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile.candidate_profile FORCE ROW LEVEL SECURITY;
CREATE POLICY candidate_profile_select_scope ON profile.candidate_profile
FOR SELECT USING (
  app_user_id = identity.current_app_user_id()
  OR identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
  OR (
    NOT EXISTS (
      SELECT 1 FROM identity.user_block ub
      WHERE ub.blocker_user_id = candidate_profile.app_user_id
        AND ub.blocked_user_id = identity.current_app_user_id()
        AND ub.deleted_at IS NULL
    )
    AND (
      (
        identity.current_user_has_role('recruiter')
        AND EXISTS (
          SELECT 1
          FROM hiring.candidate_application ca
          JOIN hiring.job_requirement jr ON jr.id = ca.job_requirement_id
          JOIN organisation.organisation_recruiter orc ON orc.organisation_id = jr.organisation_id
          WHERE ca.candidate_profile_id = candidate_profile.id
            AND orc.recruiter_user_id = identity.current_app_user_id()
            AND orc.is_active AND orc.valid_from <= CURRENT_TIMESTAMP
            AND (orc.valid_to IS NULL OR orc.valid_to > CURRENT_TIMESTAMP)
            AND orc.deleted_at IS NULL AND ca.deleted_at IS NULL AND jr.deleted_at IS NULL
        )
      )
      OR (
        identity.current_user_has_role('employer')
        AND EXISTS (
          SELECT 1
          FROM hiring.candidate_application ca
          JOIN hiring.job_requirement jr ON jr.id = ca.job_requirement_id
          JOIN organisation.account_administrator aa
            ON aa.account_profile_id = (
              SELECT o.account_profile_id FROM organisation.organisation o
              WHERE o.id = jr.organisation_id
            )
          WHERE ca.candidate_profile_id = candidate_profile.id
            AND aa.app_user_id = identity.current_app_user_id()
            AND aa.valid_from <= CURRENT_TIMESTAMP
            AND (aa.valid_to IS NULL OR aa.valid_to > CURRENT_TIMESTAMP)
            AND aa.deleted_at IS NULL AND ca.deleted_at IS NULL AND jr.deleted_at IS NULL
        )
      )
      OR (
        identity.current_user_has_role('consultant')
        AND EXISTS (
          SELECT 1
          FROM sourcing.candidate_sourcing_shortlist css
          JOIN sourcing.sourcing_request sr ON sr.id = css.sourcing_request_id
          JOIN hiring.job_shortlist js ON js.id = css.job_shortlist_id
          WHERE js.candidate_profile_id = candidate_profile.id
            AND sr.consultant_user_id = identity.current_app_user_id()
            AND sr.request_status_code IN ('pending','accepted')
            AND css.deleted_at IS NULL AND sr.deleted_at IS NULL AND js.deleted_at IS NULL
        )
      )
    )
  )
);
CREATE POLICY candidate_profile_insert_scope ON profile.candidate_profile
FOR INSERT WITH CHECK (
  app_user_id = identity.current_app_user_id()
  AND NOT identity.current_user_has_role('recruiter')
);
CREATE POLICY candidate_profile_update_scope ON profile.candidate_profile
FOR UPDATE USING (
  app_user_id = identity.current_app_user_id()
  OR identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
) WITH CHECK (
  app_user_id = identity.current_app_user_id()
  OR identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
);
CREATE POLICY candidate_profile_delete_scope ON profile.candidate_profile
FOR DELETE USING (
  identity.current_user_has_role('super_admin') OR identity.current_user_has_role('admin')
);

ALTER TABLE sourcing.sourcing_request ENABLE ROW LEVEL SECURITY;
ALTER TABLE sourcing.sourcing_request FORCE ROW LEVEL SECURITY;
CREATE POLICY sourcing_request_select_scope ON sourcing.sourcing_request
FOR SELECT USING (
  consultant_user_id = identity.current_app_user_id()
  OR requested_by_user_id = identity.current_app_user_id()
  OR identity.current_user_has_role('super_admin')
  OR identity.current_user_has_role('admin')
);
CREATE POLICY sourcing_request_insert_scope ON sourcing.sourcing_request
FOR INSERT WITH CHECK (
  requested_by_user_id = identity.current_app_user_id()
  AND EXISTS (
    SELECT 1 FROM hiring.job_requirement jr
    WHERE jr.id = sourcing_request.job_requirement_id
      AND jr.is_open_to_consultants = TRUE AND jr.deleted_at IS NULL
  )
);

-- ---------------------------------------------------------------------------
-- AUDIT TRIGGERS FOR SENSITIVE WRITES (payload excludes PII and secrets)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION identity.audit_sensitive_change()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
DECLARE v_actor BIGINT; v_entity_id BIGINT;
BEGIN
  v_actor := identity.current_app_user_id();
  IF TG_OP = 'DELETE' THEN
    v_entity_id := (to_jsonb(OLD)->>'id')::BIGINT;
  ELSE
    v_entity_id := (to_jsonb(NEW)->>'id')::BIGINT;
  END IF;
  INSERT INTO identity.audit_event(
    actor_user_id, action_code, entity_schema, entity_table,
    entity_id, occurred_at, outcome_code, details
  ) VALUES (
    v_actor, lower(TG_OP), TG_TABLE_SCHEMA, TG_TABLE_NAME,
    v_entity_id, CURRENT_TIMESTAMP, 'success',
    jsonb_build_object('database_trigger', TRUE, 'operation', TG_OP)
  );
  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$;

DO $$
DECLARE t RECORD;
BEGIN
  FOR t IN
    SELECT * FROM (VALUES
      ('profile','candidate_profile'), ('profile','candidate_contact'),
      ('profile','resume'), ('hiring','job_requirement'),
      ('hiring','candidate_application'), ('hiring','job_offer'),
      ('organisation','organisation_identifier'), ('organisation','organisation_recruiter'),
      ('identity','user_role'), ('identity','user_consent'), ('identity','user_block'),
      ('licensing','registered_device'), ('licensing','user_session'),
      ('licensing','licence_seat'), ('sourcing','sourcing_request'),
      ('billing','payment_order'), ('billing','refund'),
      ('billing','credit_consumption'), ('gig','gig_assignment')
    ) AS x(table_schema, table_name)
  LOOP
    EXECUTE format(
      'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON %I.%I FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change()',
      'trg_' || t.table_name || '_audit_sensitive', t.table_schema, t.table_name
    );
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- CONCURRENCY-SAFE LICENCE SEATS AND LOGIN SESSIONS
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION licensing.allocate_licence_seat(
  p_subscription_licence_id BIGINT, p_app_user_id BIGINT
) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, licensing, identity AS $$
DECLARE v_licence licensing.subscription_licence%ROWTYPE; v_count INTEGER; v_id BIGINT;
BEGIN
  IF NOT identity.current_user_has_role('super_admin')
     AND NOT identity.current_user_has_role('admin') THEN
    RAISE EXCEPTION 'Only an administrator may allocate licence seats';
  END IF;
  SELECT * INTO v_licence FROM licensing.subscription_licence
  WHERE id = p_subscription_licence_id AND deleted_at IS NULL FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Licence not found'; END IF;
  SELECT COUNT(*) INTO v_count FROM licensing.licence_seat
  WHERE subscription_licence_id = p_subscription_licence_id
    AND released_at IS NULL AND deleted_at IS NULL;
  IF v_count >= v_licence.max_users THEN RAISE EXCEPTION 'Licence user-seat limit reached'; END IF;
  INSERT INTO licensing.licence_seat(subscription_licence_id, app_user_id)
  VALUES (p_subscription_licence_id, p_app_user_id) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION licensing.start_user_session(
  p_app_user_id BIGINT, p_registered_device_id BIGINT,
  p_session_token_hash VARCHAR(128), p_expires_at TIMESTAMPTZ
) RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, licensing, identity AS $$
DECLARE v_licence licensing.subscription_licence%ROWTYPE; v_active_count INTEGER; v_session_id BIGINT;
BEGIN
  IF p_app_user_id IS DISTINCT FROM identity.current_app_user_id()
     AND NOT identity.current_user_has_role('super_admin')
     AND NOT identity.current_user_has_role('admin') THEN
    RAISE EXCEPTION 'Not authorized to create this session';
  END IF;
  PERFORM 1 FROM identity.app_user WHERE id = p_app_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'User does not exist'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM licensing.registered_device d
    WHERE d.id = p_registered_device_id AND d.app_user_id = p_app_user_id
      AND d.revoked_at IS NULL AND d.deleted_at IS NULL
  ) THEN RAISE EXCEPTION 'Device is missing, revoked, or belongs to another user'; END IF;

  SELECT l.* INTO v_licence
  FROM licensing.subscription_licence l
  JOIN licensing.licence_seat s ON s.subscription_licence_id = l.id
  WHERE s.app_user_id = p_app_user_id AND s.released_at IS NULL AND s.deleted_at IS NULL
    AND l.licence_status_code = 'active' AND l.valid_from <= CURRENT_TIMESTAMP
    AND (l.valid_to IS NULL OR l.valid_to > CURRENT_TIMESTAMP) AND l.deleted_at IS NULL
  ORDER BY l.valid_from DESC, l.id LIMIT 1 FOR UPDATE OF l;
  IF NOT FOUND THEN RAISE EXCEPTION 'No active licence seat for user'; END IF;

  SELECT COUNT(*) INTO v_active_count FROM licensing.user_session ss
  WHERE ss.app_user_id = p_app_user_id AND ss.ended_at IS NULL AND ss.revoked_at IS NULL
    AND ss.expires_at > CURRENT_TIMESTAMP AND ss.deleted_at IS NULL;

  IF v_active_count >= v_licence.max_devices_per_user THEN
    INSERT INTO licensing.login_attempt(app_user_id, attempted_at, outcome_code, reason_code)
    VALUES (p_app_user_id, CURRENT_TIMESTAMP, 'denied', 'device_limit_reached');
    INSERT INTO identity.audit_event(
      actor_user_id, action_code, entity_schema, entity_table, occurred_at, outcome_code, details
    ) VALUES (
      p_app_user_id, 'login_session_denied', 'licensing', 'user_session',
      CURRENT_TIMESTAMP, 'denied',
      jsonb_build_object('reason','device_limit_reached','active_session_count',v_active_count)
    );
    -- Return NULL so the denial log commits; raising here would roll it back.
    RETURN NULL;
  END IF;

  INSERT INTO licensing.user_session(
    app_user_id, registered_device_id, session_token_hash,
    started_at, last_activity_at, expires_at
  ) VALUES (
    p_app_user_id, p_registered_device_id, p_session_token_hash,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_expires_at
  ) RETURNING id INTO v_session_id;
  INSERT INTO licensing.login_attempt(app_user_id, attempted_at, outcome_code, reason_code)
  VALUES (p_app_user_id, CURRENT_TIMESTAMP, 'success', 'session_started');
  RETURN v_session_id;
END;
$$;

-- Gig assignment receives the accepted worker and request window from source rows.
CREATE OR REPLACE FUNCTION gig.populate_assignment_window()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_application gig.gig_application%ROWTYPE; v_request gig.gig_request%ROWTYPE;
BEGIN
  SELECT * INTO v_application FROM gig.gig_application
  WHERE id = NEW.gig_application_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'Gig application not found'; END IF;
  IF v_application.application_status_code <> 'accepted' THEN
    RAISE EXCEPTION 'Only accepted gig applications may be assigned';
  END IF;
  SELECT * INTO v_request FROM gig.gig_request
  WHERE id = v_application.gig_request_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'Gig request not found'; END IF;
  NEW.gig_worker_profile_id := v_application.gig_worker_profile_id;
  NEW.assignment_start_at := v_request.start_at;
  NEW.assignment_end_at := v_request.end_at;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_gig_assignment_populate_window
BEFORE INSERT OR UPDATE OF gig_application_id ON gig.gig_assignment
FOR EACH ROW EXECUTE FUNCTION gig.populate_assignment_window();

-- Wallet ledger rows are append-only; correction is a new row referencing the original.
CREATE OR REPLACE FUNCTION billing.validate_wallet_ledger_currency()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_currency master_data.currency_code;
BEGIN
  SELECT currency_code INTO v_currency FROM billing.wallet WHERE id = NEW.wallet_id;
  IF v_currency IS NULL OR v_currency <> NEW.currency_code THEN
    RAISE EXCEPTION 'Ledger currency must match wallet currency';
  END IF;
  IF NEW.corrects_ledger_entry_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM billing.wallet_ledger_entry WHERE id = NEW.corrects_ledger_entry_id
  ) THEN RAISE EXCEPTION 'Correction must reference an existing ledger entry'; END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER trg_wallet_ledger_validate
BEFORE INSERT ON billing.wallet_ledger_entry
FOR EACH ROW EXECUTE FUNCTION billing.validate_wallet_ledger_currency();

-- IMPORTANT IMPLEMENTATION NOTES:
-- 1. The role matrix, audit, retention, integration, analytics, and performance
--    companion document describes the required controls and remaining validation.
-- 2. Fixed-code columns must be bound to master_data.reference_code and
--    master_data.reference_translation through FKs or validation triggers before sign-off.
-- 3. Partition migration for candidate_application and notification_delivery is a
--    required physical migration and is documented separately; do not claim partitioning
--    is active until that migration and query-plan tests pass.


COMMIT;
