-- Talentra connected ER diagram implementation, PostgreSQL 18.
-- Source: Talentra_Connected_ER_Diagram (1).png and PDF Phase 1 (B1-B23).
-- Optional campus extension and later phase modules are excluded.
-- A new baseline migration; intentionally fails if a target table already exists.
-- All writes are atomic. Does not modify Neon Auth tables or the older SQL draft.
-- Missing diagram details and scope limitations are documented in TALENTRA_SCHEMA.md.

BEGIN;

SET LOCAL lock_timeout = '5s';

SET LOCAL statement_timeout = '120s';

CREATE TABLE public.job_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_job_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.work_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_work_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.employment_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_employment_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.proficiency_level (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_proficiency_level_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.question_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_question_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_application_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.interview_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_interview_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.offer_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_offer_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.activity_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_activity_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.experience_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_experience_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.verification_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_verification_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.accomplishment_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_accomplishment_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.social_platform (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_social_platform_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_event_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_job_event_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.hiring_stage_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_hiring_stage_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.education_level (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_education_level_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.score_scale (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_score_scale_6 UNIQUE (reference_code_id),
  maximum_score NUMERIC(7,3) NOT NULL DEFAULT 100 CHECK (maximum_score > 0),
  CONSTRAINT uq_score_scale_8 UNIQUE (id, maximum_score),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.eligibility_decision (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_eligibility_decision_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.stage_decision (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_stage_decision_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.withdrawal_outcome (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_withdrawal_outcome_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.document_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_document_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.salary_period (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_salary_period_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.course_enrolment_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_course_enrolment_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_activity_type (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_candidate_activity_type_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.referral_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_referral_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_position_status (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  reference_code_id BIGINT,
  CONSTRAINT uq_job_position_status_6 UNIQUE (reference_code_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.country (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code CHAR(2) NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{2}$'),
  display_name VARCHAR(150) NOT NULL,
  phone_calling_code VARCHAR(8),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.state (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(20),
  display_name VARCHAR(150) NOT NULL,
  country_id BIGINT NOT NULL,
  CONSTRAINT uq_state_4 UNIQUE (country_id, code),
  CONSTRAINT uq_state_5 UNIQUE (country_id, display_name),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.city (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display_name VARCHAR(150) NOT NULL,
  state_id BIGINT NOT NULL,
  CONSTRAINT uq_city_3 UNIQUE (state_id, display_name),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.language (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(35) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.currency (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code CHAR(3) NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{3}$'),
  display_name VARCHAR(150) NOT NULL,
  minor_unit SMALLINT NOT NULL DEFAULT 2 CHECK (minor_unit BETWEEN 0 AND 4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.qualification (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.skill (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.subject (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.organisation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  website_url VARCHAR(2048),
  city_id BIGINT,
  industry_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.user_account (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE CHECK (email = lower(email) AND email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  neon_auth_user_id UUID UNIQUE,
  language_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.institution (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  city_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.academic_program (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  institution_id BIGINT NOT NULL,
  qualification_id BIGINT NOT NULL,
  CONSTRAINT uq_academic_program_4 UNIQUE (institution_id, qualification_id, name),
  CONSTRAINT uq_academic_program_5 UNIQUE (id, qualification_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_profile (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  headline VARCHAR(300),
  summary VARCHAR(4000),
  date_of_birth DATE,
  available_from DATE,
  user_account_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_profile_6 UNIQUE (user_account_id),
  city_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.resume_template (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  template_reference VARCHAR(2048) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_skill (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  years_experience NUMERIC(4,1) CHECK (years_experience BETWEEN 0 AND 80),
  candidate_profile_id BIGINT NOT NULL,
  skill_id BIGINT NOT NULL,
  proficiency_level_id BIGINT,
  CONSTRAINT uq_candidate_skill_5 UNIQUE (candidate_profile_id, skill_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_education (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  start_date DATE,
  end_date DATE,
  graduation_year SMALLINT CHECK (graduation_year BETWEEN 1900 AND 2200),
  candidate_profile_id BIGINT NOT NULL,
  qualification_id BIGINT NOT NULL,
  academic_program_id BIGINT,
  CONSTRAINT uq_candidate_education_7 UNIQUE (id, candidate_profile_id),
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_volunteer_experience (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  organisation_name VARCHAR(150) NOT NULL,
  role VARCHAR(150) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  description VARCHAR(4000),
  candidate_profile_id BIGINT NOT NULL,
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_extracurricular_activity (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  start_date DATE,
  end_date DATE,
  description VARCHAR(4000),
  candidate_profile_id BIGINT NOT NULL,
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  activity_type_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_experience (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  employer_name VARCHAR(150) NOT NULL,
  job_title VARCHAR(150) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  description VARCHAR(4000),
  candidate_profile_id BIGINT NOT NULL,
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  experience_type_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_project (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  project_role VARCHAR(150) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  project_url VARCHAR(2048),
  outcome VARCHAR(4000),
  candidate_profile_id BIGINT NOT NULL,
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_language (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  can_read BOOLEAN NOT NULL DEFAULT FALSE,
  can_write BOOLEAN NOT NULL DEFAULT FALSE,
  can_speak BOOLEAN NOT NULL DEFAULT FALSE,
  candidate_profile_id BIGINT NOT NULL,
  language_id BIGINT NOT NULL,
  proficiency_level_id BIGINT,
  CONSTRAINT uq_candidate_language_7 UNIQUE (candidate_profile_id, language_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_social_link (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  url VARCHAR(2048) NOT NULL,
  candidate_profile_id BIGINT NOT NULL,
  social_platform_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_social_link_4 UNIQUE (candidate_profile_id, url),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_contact (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  phone_e164 VARCHAR(16) NOT NULL CHECK (phone_e164 ~ '^\+[1-9][0-9]{1,14}$'),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  candidate_profile_id BIGINT NOT NULL,
  country_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_contact_6 UNIQUE (candidate_profile_id, phone_e164),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_accomplishment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  issuer VARCHAR(150),
  issued_on DATE,
  expires_on DATE,
  credential_reference VARCHAR(500),
  candidate_profile_id BIGINT NOT NULL,
  accomplishment_type_id BIGINT NOT NULL,
  CHECK (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.resume_version (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  version_number INTEGER NOT NULL CHECK (version_number > 0),
  private_storage_reference VARCHAR(2048) NOT NULL,
  content_sha256 CHAR(64) CHECK (content_sha256 ~ '^[a-f0-9]{64}$'),
  candidate_profile_id BIGINT NOT NULL,
  resume_template_id BIGINT,
  language_id BIGINT,
  CONSTRAINT uq_resume_version_7 UNIQUE (candidate_profile_id, version_number),
  CONSTRAINT uq_resume_version_8 UNIQUE (id, candidate_profile_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.education_verification (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  verified_at TIMESTAMPTZ,
  frozen BOOLEAN NOT NULL DEFAULT FALSE,
  notes VARCHAR(2000),
  candidate_education_id BIGINT NOT NULL,
  verification_status_id BIGINT NOT NULL,
  verifier_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_subject (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  semester SMALLINT NOT NULL CHECK (semester > 0),
  candidate_education_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_subject_4 UNIQUE (candidate_education_id, subject_id, semester),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_backlog (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  semester SMALLINT NOT NULL CHECK (semester > 0),
  identified_on DATE NOT NULL,
  cleared_on DATE,
  candidate_education_id BIGINT NOT NULL,
  subject_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_backlog_6 UNIQUE (candidate_education_id, subject_id, semester),
  CHECK (cleared_on IS NULL OR cleared_on >= identified_on),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_academic_result (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  semester SMALLINT NOT NULL CHECK (semester > 0),
  score NUMERIC(7,3) NOT NULL CHECK (score >= 0),
  maximum_score NUMERIC(7,3) NOT NULL CHECK (maximum_score > 0),
  candidate_education_id BIGINT NOT NULL,
  score_scale_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_academic_result_6 UNIQUE (candidate_education_id, semester, score_scale_id),
  CHECK (score <= maximum_score),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_document (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  private_storage_reference VARCHAR(2048) NOT NULL,
  content_sha256 CHAR(64) CHECK (content_sha256 ~ '^[a-f0-9]{64}$'),
  candidate_profile_id BIGINT NOT NULL,
  candidate_education_id BIGINT,
  document_type_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_document_7 UNIQUE (id, candidate_profile_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_requirement (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  salary_min NUMERIC(18,2) CHECK (salary_min >= 0),
  salary_max NUMERIC(18,2) CHECK (salary_max >= 0),
  deadline TIMESTAMPTZ,
  positions INTEGER NOT NULL DEFAULT 1 CHECK (positions > 0),
  published_at TIMESTAMPTZ,
  open_to_consultants BOOLEAN NOT NULL DEFAULT FALSE,
  organisation_id BIGINT NOT NULL,
  job_status_id BIGINT NOT NULL,
  work_type_id BIGINT NOT NULL,
  employment_type_id BIGINT NOT NULL,
  currency_id BIGINT,
  salary_period_id BIGINT,
  language_id BIGINT,
  CHECK (salary_min IS NULL OR salary_max IS NULL OR salary_min <= salary_max),
  CHECK ((salary_min IS NULL AND salary_max IS NULL) OR (currency_id IS NOT NULL AND salary_period_id IS NOT NULL)),
  CHECK (deadline IS NULL OR published_at IS NULL OR deadline >= published_at),
  job_role_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_location (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL,
  city_id BIGINT NOT NULL,
  CONSTRAINT uq_job_location_3 UNIQUE (job_requirement_id, city_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_status_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason VARCHAR(2000),
  job_requirement_id BIGINT NOT NULL,
  job_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_qualification_requirement (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_requirement_id BIGINT NOT NULL,
  qualification_id BIGINT NOT NULL,
  CONSTRAINT uq_job_qualification_requirement_3 UNIQUE (job_requirement_id, qualification_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_skill_requirement (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  required BOOLEAN NOT NULL DEFAULT TRUE,
  minimum_years NUMERIC(4,1) CHECK (minimum_years BETWEEN 0 AND 80),
  job_requirement_id BIGINT NOT NULL,
  skill_id BIGINT NOT NULL,
  proficiency_level_id BIGINT,
  CONSTRAINT uq_job_skill_requirement_6 UNIQUE (job_requirement_id, skill_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_application_policy (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  resume_required BOOLEAN NOT NULL DEFAULT TRUE,
  withdrawal_allowed BOOLEAN NOT NULL DEFAULT TRUE,
  withdrawal_requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
  withdrawal_deadline TIMESTAMPTZ,
  job_requirement_id BIGINT NOT NULL,
  CONSTRAINT uq_job_application_policy_6 UNIQUE (job_requirement_id),
  CHECK (withdrawal_allowed OR NOT withdrawal_requires_approval),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_event (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  source_timezone VARCHAR(100) NOT NULL DEFAULT 'UTC',
  venue VARCHAR(500),
  meeting_url VARCHAR(2048),
  job_requirement_id BIGINT NOT NULL,
  job_event_type_id BIGINT NOT NULL,
  CHECK (ends_at >= starts_at),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_attachment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  private_storage_reference VARCHAR(2048) NOT NULL,
  job_requirement_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_external_ats (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  provider VARCHAR(150) NOT NULL,
  application_url VARCHAR(2048) NOT NULL,
  external_job_reference VARCHAR(500),
  job_requirement_id BIGINT NOT NULL,
  CONSTRAINT uq_job_external_ats_5 UNIQUE (job_requirement_id, provider),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_eligibility_policy (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  version_number INTEGER NOT NULL CHECK (version_number > 0),
  maximum_active_backlogs INTEGER CHECK (maximum_active_backlogs >= 0),
  maximum_gap_months INTEGER CHECK (maximum_gap_months >= 0),
  valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_until TIMESTAMPTZ,
  job_requirement_id BIGINT NOT NULL,
  CONSTRAINT uq_job_eligibility_policy_7 UNIQUE (job_requirement_id, version_number),
  CONSTRAINT uq_job_eligibility_policy_8 UNIQUE (id, job_requirement_id),
  CHECK (valid_until IS NULL OR valid_until > valid_from),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_hiring_stage (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  sequence INTEGER NOT NULL CHECK (sequence > 0),
  job_requirement_id BIGINT NOT NULL,
  hiring_stage_type_id BIGINT NOT NULL,
  CONSTRAINT uq_job_hiring_stage_5 UNIQUE (job_requirement_id, sequence),
  CONSTRAINT uq_job_hiring_stage_6 UNIQUE (id, job_requirement_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_academic_criterion (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  minimum_score NUMERIC(7,3) NOT NULL CHECK (minimum_score >= 0),
  maximum_score NUMERIC(7,3) NOT NULL CHECK (maximum_score > 0),
  job_eligibility_policy_id BIGINT NOT NULL,
  education_level_id BIGINT NOT NULL,
  score_scale_id BIGINT NOT NULL,
  CONSTRAINT uq_job_academic_criterion_6 UNIQUE (job_eligibility_policy_id, education_level_id, score_scale_id),
  CHECK (minimum_score <= maximum_score),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_eligible_program (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  job_eligibility_policy_id BIGINT NOT NULL,
  academic_program_id BIGINT NOT NULL,
  CONSTRAINT uq_job_eligible_program_3 UNIQUE (job_eligibility_policy_id, academic_program_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.questionnaire (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  version_number INTEGER NOT NULL CHECK (version_number > 0),
  job_requirement_id BIGINT NOT NULL,
  CONSTRAINT uq_questionnaire_4 UNIQUE (job_requirement_id, version_number),
  CONSTRAINT uq_questionnaire_5 UNIQUE (id, job_requirement_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.question (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question_text VARCHAR(4000) NOT NULL,
  required BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  questionnaire_id BIGINT NOT NULL,
  question_type_id BIGINT NOT NULL,
  CONSTRAINT uq_question_6 UNIQUE (id, questionnaire_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.question_option (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  option_text VARCHAR(2000) NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  question_id BIGINT NOT NULL,
  CONSTRAINT uq_question_option_4 UNIQUE (question_id, option_text),
  CONSTRAINT uq_question_option_5 UNIQUE (id, question_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_job_eligibility_check (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  checked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_profile_id BIGINT NOT NULL,
  job_requirement_id BIGINT NOT NULL,
  job_eligibility_policy_id BIGINT NOT NULL,
  eligibility_decision_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.eligibility_check_result (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  criterion VARCHAR(150) NOT NULL,
  observed_value VARCHAR(1000),
  required_value VARCHAR(1000),
  explanation VARCHAR(2000),
  candidate_job_eligibility_check_id BIGINT NOT NULL,
  eligibility_decision_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cover_letter VARCHAR(4000),
  candidate_profile_id BIGINT NOT NULL,
  job_requirement_id BIGINT NOT NULL,
  application_status_id BIGINT NOT NULL,
  resume_version_id BIGINT,
  questionnaire_id BIGINT,
  CONSTRAINT uq_application_8 UNIQUE (candidate_profile_id, job_requirement_id),
  CONSTRAINT uq_application_9 UNIQUE (id, candidate_profile_id),
  CONSTRAINT uq_application_10 UNIQUE (id, job_requirement_id),
  CONSTRAINT uq_application_11 UNIQUE (id, questionnaire_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_stage_result (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  attempt_number INTEGER NOT NULL DEFAULT 1 CHECK (attempt_number > 0),
  score NUMERIC(7,3) CHECK (score >= 0),
  maximum_score NUMERIC(7,3) CHECK (maximum_score > 0),
  feedback VARCHAR(4000),
  completed_at TIMESTAMPTZ,
  application_id BIGINT NOT NULL,
  job_hiring_stage_id BIGINT NOT NULL,
  job_requirement_id BIGINT NOT NULL,
  stage_decision_id BIGINT NOT NULL,
  CONSTRAINT uq_application_stage_result_10 UNIQUE (application_id, job_hiring_stage_id, attempt_number),
  CHECK ((score IS NULL AND maximum_score IS NULL) OR (score IS NOT NULL AND maximum_score IS NOT NULL AND score <= maximum_score)),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_withdrawal (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason VARCHAR(2000) NOT NULL,
  resolved_at TIMESTAMPTZ,
  application_id BIGINT NOT NULL,
  withdrawal_outcome_id BIGINT NOT NULL,
  resolved_by BIGINT,
  CHECK (resolved_at IS NULL OR resolved_at >= requested_at),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_profile_snapshot (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  profile_version INTEGER NOT NULL CHECK (profile_version > 0),
  profile_data JSONB NOT NULL CHECK (jsonb_typeof(profile_data) = 'object'),
  captured_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  application_id BIGINT NOT NULL,
  CONSTRAINT uq_application_profile_snapshot_5 UNIQUE (application_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_status_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason VARCHAR(2000),
  application_id BIGINT NOT NULL,
  application_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.interview (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  round INTEGER NOT NULL CHECK (round > 0),
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ,
  source_timezone VARCHAR(100) NOT NULL DEFAULT 'UTC',
  location VARCHAR(500),
  meeting_url VARCHAR(2048),
  feedback VARCHAR(4000),
  application_id BIGINT NOT NULL,
  interview_status_id BIGINT NOT NULL,
  interviewer_id BIGINT,
  CHECK (ends_at IS NULL OR ends_at >= starts_at),
  CONSTRAINT uq_interview_12 UNIQUE (application_id, round),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.offer (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  version_number INTEGER NOT NULL CHECK (version_number > 0),
  amount NUMERIC(18,2) NOT NULL CHECK (amount >= 0),
  issued_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  expected_start_date DATE,
  private_storage_reference VARCHAR(2048),
  application_id BIGINT NOT NULL,
  offer_status_id BIGINT NOT NULL,
  currency_id BIGINT NOT NULL,
  salary_period_id BIGINT NOT NULL,
  CONSTRAINT uq_offer_11 UNIQUE (application_id, version_number),
  CONSTRAINT uq_offer_12 UNIQUE (id, application_id),
  CHECK (expires_at IS NULL OR issued_at IS NULL OR expires_at >= issued_at),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.joining_record (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  joined_on DATE NOT NULL,
  external_reference VARCHAR(500),
  application_id BIGINT NOT NULL,
  offer_id BIGINT NOT NULL,
  CONSTRAINT uq_joining_record_5 UNIQUE (application_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_document (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id BIGINT NOT NULL,
  candidate_document_id BIGINT NOT NULL,
  candidate_profile_id BIGINT NOT NULL,
  CONSTRAINT uq_application_document_4 UNIQUE (application_id, candidate_document_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.application_answer (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  answer_text VARCHAR(10000),
  answer_number NUMERIC(20,6),
  answer_date DATE,
  answer_boolean BOOLEAN,
  application_id BIGINT NOT NULL,
  question_id BIGINT NOT NULL,
  questionnaire_id BIGINT NOT NULL,
  question_option_id BIGINT,
  CHECK (num_nonnulls(answer_text, answer_number, answer_date, answer_boolean, question_option_id) = 1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.industry (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_role (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  display_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.reference_code (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  domain_code VARCHAR(80) NOT NULL,
  code VARCHAR(80) NOT NULL,
  display_name VARCHAR(150) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT uq_reference_code_6 UNIQUE (domain_code, code),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.reference_translation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  display_name VARCHAR(150) NOT NULL,
  reference_code_id BIGINT NOT NULL,
  language_id BIGINT NOT NULL,
  CONSTRAINT uq_reference_translation_4 UNIQUE (reference_code_id, language_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.ui_translation (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  translation_key VARCHAR(160) NOT NULL,
  translated_text VARCHAR(2000) NOT NULL,
  language_id BIGINT NOT NULL,
  CONSTRAINT uq_ui_translation_4 UNIQUE (translation_key, language_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.assessment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  provider VARCHAR(150),
  maximum_score NUMERIC(10,3) NOT NULL CHECK (maximum_score > 0),
  skill_id BIGINT,
  CONSTRAINT uq_assessment_6 UNIQUE (id, maximum_score),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.assessment_result (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  attempt_number INTEGER NOT NULL DEFAULT 1 CHECK (attempt_number > 0),
  score NUMERIC(10,3) NOT NULL CHECK (score >= 0),
  maximum_score NUMERIC(10,3) NOT NULL CHECK (maximum_score > 0),
  taken_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_profile_id BIGINT NOT NULL,
  assessment_id BIGINT NOT NULL,
  CONSTRAINT uq_assessment_result_7 UNIQUE (candidate_profile_id, assessment_id, attempt_number),
  CHECK (score <= maximum_score),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.course (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  provider VARCHAR(150) NOT NULL,
  course_url VARCHAR(2048),
  skill_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.course_enrolment (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enrolled_on DATE NOT NULL,
  completed_on DATE,
  certificate_reference VARCHAR(2048),
  candidate_profile_id BIGINT NOT NULL,
  course_id BIGINT NOT NULL,
  course_enrolment_status_id BIGINT NOT NULL,
  CONSTRAINT uq_course_enrolment_7 UNIQUE (candidate_profile_id, course_id),
  CHECK (completed_on IS NULL OR completed_on >= enrolled_on),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.profile_completion_score (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  score_percent NUMERIC(5,2) NOT NULL CHECK (score_percent BETWEEN 0 AND 100),
  rules_version INTEGER NOT NULL CHECK (rules_version > 0),
  calculated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_profile_id BIGINT NOT NULL,
  CONSTRAINT uq_profile_completion_score_5 UNIQUE (candidate_profile_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.profile_view_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_profile_id BIGINT NOT NULL,
  viewer_id BIGINT NOT NULL,
  organisation_id BIGINT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_activity_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  description VARCHAR(2000),
  candidate_profile_id BIGINT NOT NULL,
  candidate_activity_type_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_bookmark (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  bookmarked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_profile_id BIGINT NOT NULL,
  bookmarked_by BIGINT NOT NULL,
  organisation_id BIGINT NOT NULL,
  CONSTRAINT uq_candidate_bookmark_5 UNIQUE (candidate_profile_id, bookmarked_by),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_bookmark_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  is_bookmarked BOOLEAN NOT NULL DEFAULT TRUE,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  candidate_bookmark_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.referral_tracking (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  referral_code VARCHAR(80) NOT NULL UNIQUE,
  referred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  referrer_id BIGINT NOT NULL,
  candidate_profile_id BIGINT,
  referral_status_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_position (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  position_reference VARCHAR(80) NOT NULL,
  filled_at TIMESTAMPTZ,
  job_requirement_id BIGINT NOT NULL,
  job_position_status_id BIGINT NOT NULL,
  CONSTRAINT uq_job_position_5 UNIQUE (job_requirement_id, position_reference),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.job_shortlist (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  shortlisted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  job_requirement_id BIGINT NOT NULL,
  candidate_profile_id BIGINT NOT NULL,
  shortlisted_by BIGINT NOT NULL,
  CONSTRAINT uq_job_shortlist_5 UNIQUE (job_requirement_id, candidate_profile_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.shortlist_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  is_shortlisted BOOLEAN NOT NULL DEFAULT TRUE,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  job_shortlist_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.candidate_job_search_history (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  searched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  search_text VARCHAR(1000),
  filters JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(filters) = 'object'),
  candidate_profile_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by BIGINT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by BIGINT,
  deleted_at TIMESTAMPTZ
);

ALTER TABLE public.state ADD FOREIGN KEY (country_id) REFERENCES public.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_state_country_id ON public.state (country_id);

ALTER TABLE public.city ADD FOREIGN KEY (state_id) REFERENCES public.state(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_city_state_id ON public.city (state_id);

ALTER TABLE public.organisation ADD FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_city_id ON public.organisation (city_id);

ALTER TABLE public.user_account ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_account_language_id ON public.user_account (language_id);

ALTER TABLE public.institution ADD FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_institution_city_id ON public.institution (city_id);

ALTER TABLE public.academic_program ADD FOREIGN KEY (institution_id) REFERENCES public.institution(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_academic_program_institution_id ON public.academic_program (institution_id);

ALTER TABLE public.academic_program ADD FOREIGN KEY (qualification_id) REFERENCES public.qualification(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_academic_program_qualification_id ON public.academic_program (qualification_id);

ALTER TABLE public.candidate_profile ADD FOREIGN KEY (user_account_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_profile_user_account_id ON public.candidate_profile (user_account_id);

ALTER TABLE public.candidate_profile ADD FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_profile_city_id ON public.candidate_profile (city_id);

ALTER TABLE public.candidate_skill ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_skill_candidate_profile_id ON public.candidate_skill (candidate_profile_id);

ALTER TABLE public.candidate_skill ADD FOREIGN KEY (skill_id) REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_skill_skill_id ON public.candidate_skill (skill_id);

ALTER TABLE public.candidate_skill ADD FOREIGN KEY (proficiency_level_id) REFERENCES public.proficiency_level(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_skill_proficiency_level_id ON public.candidate_skill (proficiency_level_id);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_education_candidate_profile_id ON public.candidate_education (candidate_profile_id);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (qualification_id) REFERENCES public.qualification(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_education_qualification_id ON public.candidate_education (qualification_id);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (academic_program_id) REFERENCES public.academic_program(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_education_academic_program_id ON public.candidate_education (academic_program_id);

ALTER TABLE public.candidate_volunteer_experience ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_volunteer_experience_candidate_profile_id ON public.candidate_volunteer_experience (candidate_profile_id);

ALTER TABLE public.candidate_extracurricular_activity ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_extracurricular_activity_candidate_profile_id ON public.candidate_extracurricular_activity (candidate_profile_id);

ALTER TABLE public.candidate_experience ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_experience_candidate_profile_id ON public.candidate_experience (candidate_profile_id);

ALTER TABLE public.candidate_project ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_project_candidate_profile_id ON public.candidate_project (candidate_profile_id);

ALTER TABLE public.candidate_extracurricular_activity ADD FOREIGN KEY (activity_type_id) REFERENCES public.activity_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_extracurricular_activity_activity_type_id ON public.candidate_extracurricular_activity (activity_type_id);

ALTER TABLE public.candidate_experience ADD FOREIGN KEY (experience_type_id) REFERENCES public.experience_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_experience_experience_type_id ON public.candidate_experience (experience_type_id);

ALTER TABLE public.candidate_language ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_language_candidate_profile_id ON public.candidate_language (candidate_profile_id);

ALTER TABLE public.candidate_language ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_language_language_id ON public.candidate_language (language_id);

ALTER TABLE public.candidate_language ADD FOREIGN KEY (proficiency_level_id) REFERENCES public.proficiency_level(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_language_proficiency_level_id ON public.candidate_language (proficiency_level_id);

ALTER TABLE public.candidate_social_link ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_social_link_candidate_profile_id ON public.candidate_social_link (candidate_profile_id);

ALTER TABLE public.candidate_social_link ADD FOREIGN KEY (social_platform_id) REFERENCES public.social_platform(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_social_link_social_platform_id ON public.candidate_social_link (social_platform_id);

ALTER TABLE public.candidate_contact ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_contact_candidate_profile_id ON public.candidate_contact (candidate_profile_id);

ALTER TABLE public.candidate_contact ADD FOREIGN KEY (country_id) REFERENCES public.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_contact_country_id ON public.candidate_contact (country_id);

ALTER TABLE public.candidate_accomplishment ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_accomplishment_candidate_profile_id ON public.candidate_accomplishment (candidate_profile_id);

ALTER TABLE public.candidate_accomplishment ADD FOREIGN KEY (accomplishment_type_id) REFERENCES public.accomplishment_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_accomplishment_accomplishment_type_id ON public.candidate_accomplishment (accomplishment_type_id);

ALTER TABLE public.resume_version ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_version_candidate_profile_id ON public.resume_version (candidate_profile_id);

ALTER TABLE public.resume_version ADD FOREIGN KEY (resume_template_id) REFERENCES public.resume_template(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_version_resume_template_id ON public.resume_version (resume_template_id);

ALTER TABLE public.resume_version ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_version_language_id ON public.resume_version (language_id);

ALTER TABLE public.education_verification ADD FOREIGN KEY (candidate_education_id) REFERENCES public.candidate_education(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_verification_candidate_education_id ON public.education_verification (candidate_education_id);

ALTER TABLE public.education_verification ADD FOREIGN KEY (verification_status_id) REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_verification_verification_status_id ON public.education_verification (verification_status_id);

ALTER TABLE public.education_verification ADD FOREIGN KEY (verifier_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_verification_verifier_id ON public.education_verification (verifier_id);

ALTER TABLE public.candidate_subject ADD FOREIGN KEY (candidate_education_id) REFERENCES public.candidate_education(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_subject_candidate_education_id ON public.candidate_subject (candidate_education_id);

ALTER TABLE public.candidate_subject ADD FOREIGN KEY (subject_id) REFERENCES public.subject(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_subject_subject_id ON public.candidate_subject (subject_id);

ALTER TABLE public.candidate_backlog ADD FOREIGN KEY (candidate_education_id) REFERENCES public.candidate_education(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_backlog_candidate_education_id ON public.candidate_backlog (candidate_education_id);

ALTER TABLE public.candidate_backlog ADD FOREIGN KEY (subject_id) REFERENCES public.subject(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_backlog_subject_id ON public.candidate_backlog (subject_id);

ALTER TABLE public.candidate_academic_result ADD FOREIGN KEY (candidate_education_id) REFERENCES public.candidate_education(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_academic_result_candidate_education_id ON public.candidate_academic_result (candidate_education_id);

ALTER TABLE public.candidate_academic_result ADD FOREIGN KEY (score_scale_id) REFERENCES public.score_scale(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_academic_result_score_scale_id ON public.candidate_academic_result (score_scale_id);

ALTER TABLE public.candidate_document ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_document_candidate_profile_id ON public.candidate_document (candidate_profile_id);

ALTER TABLE public.candidate_document ADD FOREIGN KEY (candidate_education_id) REFERENCES public.candidate_education(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_document_candidate_education_id ON public.candidate_document (candidate_education_id);

ALTER TABLE public.candidate_document ADD FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_document_document_type_id ON public.candidate_document (document_type_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_organisation_id ON public.job_requirement (organisation_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (job_status_id) REFERENCES public.job_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_job_status_id ON public.job_requirement (job_status_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (work_type_id) REFERENCES public.work_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_work_type_id ON public.job_requirement (work_type_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (employment_type_id) REFERENCES public.employment_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_employment_type_id ON public.job_requirement (employment_type_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_currency_id ON public.job_requirement (currency_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (salary_period_id) REFERENCES public.salary_period(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_salary_period_id ON public.job_requirement (salary_period_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_language_id ON public.job_requirement (language_id);

ALTER TABLE public.job_location ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_location_job_requirement_id ON public.job_location (job_requirement_id);

ALTER TABLE public.job_location ADD FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_location_city_id ON public.job_location (city_id);

ALTER TABLE public.job_status_history ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_history_job_requirement_id ON public.job_status_history (job_requirement_id);

ALTER TABLE public.job_status_history ADD FOREIGN KEY (job_status_id) REFERENCES public.job_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_history_job_status_id ON public.job_status_history (job_status_id);

ALTER TABLE public.job_qualification_requirement ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_qualification_requirement_job_requirement_id ON public.job_qualification_requirement (job_requirement_id);

ALTER TABLE public.job_qualification_requirement ADD FOREIGN KEY (qualification_id) REFERENCES public.qualification(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_qualification_requirement_qualification_id ON public.job_qualification_requirement (qualification_id);

ALTER TABLE public.job_skill_requirement ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_skill_requirement_job_requirement_id ON public.job_skill_requirement (job_requirement_id);

ALTER TABLE public.job_skill_requirement ADD FOREIGN KEY (skill_id) REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_skill_requirement_skill_id ON public.job_skill_requirement (skill_id);

ALTER TABLE public.job_skill_requirement ADD FOREIGN KEY (proficiency_level_id) REFERENCES public.proficiency_level(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_skill_requirement_proficiency_level_id ON public.job_skill_requirement (proficiency_level_id);

ALTER TABLE public.job_application_policy ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_application_policy_job_requirement_id ON public.job_application_policy (job_requirement_id);

ALTER TABLE public.job_event ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_job_requirement_id ON public.job_event (job_requirement_id);

ALTER TABLE public.job_event ADD FOREIGN KEY (job_event_type_id) REFERENCES public.job_event_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_job_event_type_id ON public.job_event (job_event_type_id);

ALTER TABLE public.job_attachment ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_attachment_job_requirement_id ON public.job_attachment (job_requirement_id);

ALTER TABLE public.job_external_ats ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_external_ats_job_requirement_id ON public.job_external_ats (job_requirement_id);

ALTER TABLE public.job_eligibility_policy ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligibility_policy_job_requirement_id ON public.job_eligibility_policy (job_requirement_id);

ALTER TABLE public.job_hiring_stage ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_hiring_stage_job_requirement_id ON public.job_hiring_stage (job_requirement_id);

ALTER TABLE public.job_hiring_stage ADD FOREIGN KEY (hiring_stage_type_id) REFERENCES public.hiring_stage_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_hiring_stage_hiring_stage_type_id ON public.job_hiring_stage (hiring_stage_type_id);

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (job_eligibility_policy_id) REFERENCES public.job_eligibility_policy(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_academic_criterion_job_eligibility_policy_id ON public.job_academic_criterion (job_eligibility_policy_id);

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (education_level_id) REFERENCES public.education_level(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_academic_criterion_education_level_id ON public.job_academic_criterion (education_level_id);

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (score_scale_id) REFERENCES public.score_scale(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_academic_criterion_score_scale_id ON public.job_academic_criterion (score_scale_id);

ALTER TABLE public.job_eligible_program ADD FOREIGN KEY (job_eligibility_policy_id) REFERENCES public.job_eligibility_policy(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligible_program_job_eligibility_policy_id ON public.job_eligible_program (job_eligibility_policy_id);

ALTER TABLE public.job_eligible_program ADD FOREIGN KEY (academic_program_id) REFERENCES public.academic_program(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligible_program_academic_program_id ON public.job_eligible_program (academic_program_id);

ALTER TABLE public.questionnaire ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_questionnaire_job_requirement_id ON public.questionnaire (job_requirement_id);

ALTER TABLE public.question ADD FOREIGN KEY (questionnaire_id) REFERENCES public.questionnaire(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_questionnaire_id ON public.question (questionnaire_id);

ALTER TABLE public.question ADD FOREIGN KEY (question_type_id) REFERENCES public.question_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_question_type_id ON public.question (question_type_id);

ALTER TABLE public.question_option ADD FOREIGN KEY (question_id) REFERENCES public.question(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_option_question_id ON public.question_option (question_id);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_candidate_profile_id ON public.candidate_job_eligibility_check (candidate_profile_id);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_job_requirement_id ON public.candidate_job_eligibility_check (job_requirement_id);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (job_eligibility_policy_id) REFERENCES public.job_eligibility_policy(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_job_eligibility_policy_id ON public.candidate_job_eligibility_check (job_eligibility_policy_id);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (eligibility_decision_id) REFERENCES public.eligibility_decision(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_eligibility_decision_id ON public.candidate_job_eligibility_check (eligibility_decision_id);

ALTER TABLE public.eligibility_check_result ADD FOREIGN KEY (candidate_job_eligibility_check_id) REFERENCES public.candidate_job_eligibility_check(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_check_result_candidate_job_eligibility_check_id ON public.eligibility_check_result (candidate_job_eligibility_check_id);

ALTER TABLE public.eligibility_check_result ADD FOREIGN KEY (eligibility_decision_id) REFERENCES public.eligibility_decision(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_check_result_eligibility_decision_id ON public.eligibility_check_result (eligibility_decision_id);

ALTER TABLE public.application ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_candidate_profile_id ON public.application (candidate_profile_id);

ALTER TABLE public.application ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_job_requirement_id ON public.application (job_requirement_id);

ALTER TABLE public.application ADD FOREIGN KEY (application_status_id) REFERENCES public.application_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_application_status_id ON public.application (application_status_id);

ALTER TABLE public.application ADD FOREIGN KEY (resume_version_id) REFERENCES public.resume_version(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_resume_version_id ON public.application (resume_version_id);

ALTER TABLE public.application ADD FOREIGN KEY (questionnaire_id) REFERENCES public.questionnaire(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_questionnaire_id ON public.application (questionnaire_id);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_application_id ON public.application_stage_result (application_id);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (job_hiring_stage_id) REFERENCES public.job_hiring_stage(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_job_hiring_stage_id ON public.application_stage_result (job_hiring_stage_id);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_job_requirement_id ON public.application_stage_result (job_requirement_id);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (stage_decision_id) REFERENCES public.stage_decision(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_stage_decision_id ON public.application_stage_result (stage_decision_id);

ALTER TABLE public.application_withdrawal ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_withdrawal_application_id ON public.application_withdrawal (application_id);

ALTER TABLE public.application_withdrawal ADD FOREIGN KEY (withdrawal_outcome_id) REFERENCES public.withdrawal_outcome(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_withdrawal_withdrawal_outcome_id ON public.application_withdrawal (withdrawal_outcome_id);

ALTER TABLE public.application_withdrawal ADD FOREIGN KEY (resolved_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_withdrawal_resolved_by ON public.application_withdrawal (resolved_by);

ALTER TABLE public.application_profile_snapshot ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_profile_snapshot_application_id ON public.application_profile_snapshot (application_id);

ALTER TABLE public.application_status_history ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_history_application_id ON public.application_status_history (application_id);

ALTER TABLE public.application_status_history ADD FOREIGN KEY (application_status_id) REFERENCES public.application_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_history_application_status_id ON public.application_status_history (application_status_id);

ALTER TABLE public.interview ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_application_id ON public.interview (application_id);

ALTER TABLE public.interview ADD FOREIGN KEY (interview_status_id) REFERENCES public.interview_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_interview_status_id ON public.interview (interview_status_id);

ALTER TABLE public.interview ADD FOREIGN KEY (interviewer_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_interviewer_id ON public.interview (interviewer_id);

ALTER TABLE public.offer ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_application_id ON public.offer (application_id);

ALTER TABLE public.offer ADD FOREIGN KEY (offer_status_id) REFERENCES public.offer_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_offer_status_id ON public.offer (offer_status_id);

ALTER TABLE public.offer ADD FOREIGN KEY (currency_id) REFERENCES public.currency(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_currency_id ON public.offer (currency_id);

ALTER TABLE public.offer ADD FOREIGN KEY (salary_period_id) REFERENCES public.salary_period(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_salary_period_id ON public.offer (salary_period_id);

ALTER TABLE public.joining_record ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_joining_record_application_id ON public.joining_record (application_id);

ALTER TABLE public.joining_record ADD FOREIGN KEY (offer_id) REFERENCES public.offer(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_joining_record_offer_id ON public.joining_record (offer_id);

ALTER TABLE public.application_document ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_document_application_id ON public.application_document (application_id);

ALTER TABLE public.application_document ADD FOREIGN KEY (candidate_document_id) REFERENCES public.candidate_document(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_document_candidate_document_id ON public.application_document (candidate_document_id);

ALTER TABLE public.application_document ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_document_candidate_profile_id ON public.application_document (candidate_profile_id);

ALTER TABLE public.application_answer ADD FOREIGN KEY (application_id) REFERENCES public.application(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_application_id ON public.application_answer (application_id);

ALTER TABLE public.application_answer ADD FOREIGN KEY (question_id) REFERENCES public.question(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_question_id ON public.application_answer (question_id);

ALTER TABLE public.application_answer ADD FOREIGN KEY (questionnaire_id) REFERENCES public.questionnaire(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_questionnaire_id ON public.application_answer (questionnaire_id);

ALTER TABLE public.application_answer ADD FOREIGN KEY (question_option_id) REFERENCES public.question_option(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_question_option_id ON public.application_answer (question_option_id);

ALTER TABLE public.organisation ADD FOREIGN KEY (industry_id) REFERENCES public.industry(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_industry_id ON public.organisation (industry_id);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (job_role_id) REFERENCES public.job_role(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_job_role_id ON public.job_requirement (job_role_id);

ALTER TABLE public.reference_translation ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_translation_reference_code_id ON public.reference_translation (reference_code_id);

ALTER TABLE public.reference_translation ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_translation_language_id ON public.reference_translation (language_id);

ALTER TABLE public.ui_translation ADD FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_ui_translation_language_id ON public.ui_translation (language_id);

ALTER TABLE public.assessment ADD FOREIGN KEY (skill_id) REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_skill_id ON public.assessment (skill_id);

ALTER TABLE public.assessment_result ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_result_candidate_profile_id ON public.assessment_result (candidate_profile_id);

ALTER TABLE public.assessment_result ADD FOREIGN KEY (assessment_id) REFERENCES public.assessment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_result_assessment_id ON public.assessment_result (assessment_id);

ALTER TABLE public.course ADD FOREIGN KEY (skill_id) REFERENCES public.skill(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_skill_id ON public.course (skill_id);

ALTER TABLE public.course_enrolment ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_candidate_profile_id ON public.course_enrolment (candidate_profile_id);

ALTER TABLE public.course_enrolment ADD FOREIGN KEY (course_id) REFERENCES public.course(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_course_id ON public.course_enrolment (course_id);

ALTER TABLE public.course_enrolment ADD FOREIGN KEY (course_enrolment_status_id) REFERENCES public.course_enrolment_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_course_enrolment_status_id ON public.course_enrolment (course_enrolment_status_id);

ALTER TABLE public.profile_completion_score ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_completion_score_candidate_profile_id ON public.profile_completion_score (candidate_profile_id);

ALTER TABLE public.profile_view_history ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_view_history_candidate_profile_id ON public.profile_view_history (candidate_profile_id);

ALTER TABLE public.profile_view_history ADD FOREIGN KEY (viewer_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_view_history_viewer_id ON public.profile_view_history (viewer_id);

ALTER TABLE public.profile_view_history ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_view_history_organisation_id ON public.profile_view_history (organisation_id);

ALTER TABLE public.candidate_activity_log ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_log_candidate_profile_id ON public.candidate_activity_log (candidate_profile_id);

ALTER TABLE public.candidate_activity_log ADD FOREIGN KEY (candidate_activity_type_id) REFERENCES public.candidate_activity_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_log_candidate_activity_type_id ON public.candidate_activity_log (candidate_activity_type_id);

ALTER TABLE public.candidate_bookmark ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_candidate_profile_id ON public.candidate_bookmark (candidate_profile_id);

ALTER TABLE public.candidate_bookmark ADD FOREIGN KEY (bookmarked_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_bookmarked_by ON public.candidate_bookmark (bookmarked_by);

ALTER TABLE public.candidate_bookmark ADD FOREIGN KEY (organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_organisation_id ON public.candidate_bookmark (organisation_id);

ALTER TABLE public.candidate_bookmark_history ADD FOREIGN KEY (candidate_bookmark_id) REFERENCES public.candidate_bookmark(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_history_candidate_bookmark_id ON public.candidate_bookmark_history (candidate_bookmark_id);

ALTER TABLE public.referral_tracking ADD FOREIGN KEY (referrer_id) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_tracking_referrer_id ON public.referral_tracking (referrer_id);

ALTER TABLE public.referral_tracking ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_tracking_candidate_profile_id ON public.referral_tracking (candidate_profile_id);

ALTER TABLE public.referral_tracking ADD FOREIGN KEY (referral_status_id) REFERENCES public.referral_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_tracking_referral_status_id ON public.referral_tracking (referral_status_id);

ALTER TABLE public.job_position ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_job_requirement_id ON public.job_position (job_requirement_id);

ALTER TABLE public.job_position ADD FOREIGN KEY (job_position_status_id) REFERENCES public.job_position_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_job_position_status_id ON public.job_position (job_position_status_id);

ALTER TABLE public.job_shortlist ADD FOREIGN KEY (job_requirement_id) REFERENCES public.job_requirement(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_shortlist_job_requirement_id ON public.job_shortlist (job_requirement_id);

ALTER TABLE public.job_shortlist ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_shortlist_candidate_profile_id ON public.job_shortlist (candidate_profile_id);

ALTER TABLE public.job_shortlist ADD FOREIGN KEY (shortlisted_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_shortlist_shortlisted_by ON public.job_shortlist (shortlisted_by);

ALTER TABLE public.shortlist_history ADD FOREIGN KEY (job_shortlist_id) REFERENCES public.job_shortlist(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_shortlist_history_job_shortlist_id ON public.shortlist_history (job_shortlist_id);

ALTER TABLE public.candidate_job_search_history ADD FOREIGN KEY (candidate_profile_id) REFERENCES public.candidate_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_search_history_candidate_profile_id ON public.candidate_job_search_history (candidate_profile_id);

ALTER TABLE public.job_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_reference_code_id ON public.job_status (reference_code_id);

ALTER TABLE public.work_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_work_type_reference_code_id ON public.work_type (reference_code_id);

ALTER TABLE public.employment_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_employment_type_reference_code_id ON public.employment_type (reference_code_id);

ALTER TABLE public.proficiency_level ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_proficiency_level_reference_code_id ON public.proficiency_level (reference_code_id);

ALTER TABLE public.question_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_type_reference_code_id ON public.question_type (reference_code_id);

ALTER TABLE public.application_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_reference_code_id ON public.application_status (reference_code_id);

ALTER TABLE public.interview_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_status_reference_code_id ON public.interview_status (reference_code_id);

ALTER TABLE public.offer_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_status_reference_code_id ON public.offer_status (reference_code_id);

ALTER TABLE public.activity_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_activity_type_reference_code_id ON public.activity_type (reference_code_id);

ALTER TABLE public.experience_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_experience_type_reference_code_id ON public.experience_type (reference_code_id);

ALTER TABLE public.verification_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_status_reference_code_id ON public.verification_status (reference_code_id);

ALTER TABLE public.accomplishment_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_accomplishment_type_reference_code_id ON public.accomplishment_type (reference_code_id);

ALTER TABLE public.social_platform ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_social_platform_reference_code_id ON public.social_platform (reference_code_id);

ALTER TABLE public.job_event_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_type_reference_code_id ON public.job_event_type (reference_code_id);

ALTER TABLE public.hiring_stage_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hiring_stage_type_reference_code_id ON public.hiring_stage_type (reference_code_id);

ALTER TABLE public.education_level ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_level_reference_code_id ON public.education_level (reference_code_id);

ALTER TABLE public.score_scale ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_score_scale_reference_code_id ON public.score_scale (reference_code_id);

ALTER TABLE public.eligibility_decision ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_decision_reference_code_id ON public.eligibility_decision (reference_code_id);

ALTER TABLE public.stage_decision ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_stage_decision_reference_code_id ON public.stage_decision (reference_code_id);

ALTER TABLE public.withdrawal_outcome ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_withdrawal_outcome_reference_code_id ON public.withdrawal_outcome (reference_code_id);

ALTER TABLE public.document_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_document_type_reference_code_id ON public.document_type (reference_code_id);

ALTER TABLE public.salary_period ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_salary_period_reference_code_id ON public.salary_period (reference_code_id);

ALTER TABLE public.course_enrolment_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_status_reference_code_id ON public.course_enrolment_status (reference_code_id);

ALTER TABLE public.candidate_activity_type ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_type_reference_code_id ON public.candidate_activity_type (reference_code_id);

ALTER TABLE public.referral_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_status_reference_code_id ON public.referral_status (reference_code_id);

ALTER TABLE public.job_position_status ADD FOREIGN KEY (reference_code_id) REFERENCES public.reference_code(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_status_reference_code_id ON public.job_position_status (reference_code_id);

ALTER TABLE public.job_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_created_by ON public.job_status (created_by);

ALTER TABLE public.job_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_updated_by ON public.job_status (updated_by);

ALTER TABLE public.work_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_work_type_created_by ON public.work_type (created_by);

ALTER TABLE public.work_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_work_type_updated_by ON public.work_type (updated_by);

ALTER TABLE public.employment_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_employment_type_created_by ON public.employment_type (created_by);

ALTER TABLE public.employment_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_employment_type_updated_by ON public.employment_type (updated_by);

ALTER TABLE public.proficiency_level ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_proficiency_level_created_by ON public.proficiency_level (created_by);

ALTER TABLE public.proficiency_level ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_proficiency_level_updated_by ON public.proficiency_level (updated_by);

ALTER TABLE public.question_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_type_created_by ON public.question_type (created_by);

ALTER TABLE public.question_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_type_updated_by ON public.question_type (updated_by);

ALTER TABLE public.application_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_created_by ON public.application_status (created_by);

ALTER TABLE public.application_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_updated_by ON public.application_status (updated_by);

ALTER TABLE public.interview_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_status_created_by ON public.interview_status (created_by);

ALTER TABLE public.interview_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_status_updated_by ON public.interview_status (updated_by);

ALTER TABLE public.offer_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_status_created_by ON public.offer_status (created_by);

ALTER TABLE public.offer_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_status_updated_by ON public.offer_status (updated_by);

ALTER TABLE public.activity_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_activity_type_created_by ON public.activity_type (created_by);

ALTER TABLE public.activity_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_activity_type_updated_by ON public.activity_type (updated_by);

ALTER TABLE public.experience_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_experience_type_created_by ON public.experience_type (created_by);

ALTER TABLE public.experience_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_experience_type_updated_by ON public.experience_type (updated_by);

ALTER TABLE public.verification_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_status_created_by ON public.verification_status (created_by);

ALTER TABLE public.verification_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_verification_status_updated_by ON public.verification_status (updated_by);

ALTER TABLE public.accomplishment_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_accomplishment_type_created_by ON public.accomplishment_type (created_by);

ALTER TABLE public.accomplishment_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_accomplishment_type_updated_by ON public.accomplishment_type (updated_by);

ALTER TABLE public.social_platform ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_social_platform_created_by ON public.social_platform (created_by);

ALTER TABLE public.social_platform ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_social_platform_updated_by ON public.social_platform (updated_by);

ALTER TABLE public.job_event_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_type_created_by ON public.job_event_type (created_by);

ALTER TABLE public.job_event_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_type_updated_by ON public.job_event_type (updated_by);

ALTER TABLE public.hiring_stage_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hiring_stage_type_created_by ON public.hiring_stage_type (created_by);

ALTER TABLE public.hiring_stage_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_hiring_stage_type_updated_by ON public.hiring_stage_type (updated_by);

ALTER TABLE public.education_level ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_level_created_by ON public.education_level (created_by);

ALTER TABLE public.education_level ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_level_updated_by ON public.education_level (updated_by);

ALTER TABLE public.score_scale ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_score_scale_created_by ON public.score_scale (created_by);

ALTER TABLE public.score_scale ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_score_scale_updated_by ON public.score_scale (updated_by);

ALTER TABLE public.eligibility_decision ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_decision_created_by ON public.eligibility_decision (created_by);

ALTER TABLE public.eligibility_decision ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_decision_updated_by ON public.eligibility_decision (updated_by);

ALTER TABLE public.stage_decision ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_stage_decision_created_by ON public.stage_decision (created_by);

ALTER TABLE public.stage_decision ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_stage_decision_updated_by ON public.stage_decision (updated_by);

ALTER TABLE public.withdrawal_outcome ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_withdrawal_outcome_created_by ON public.withdrawal_outcome (created_by);

ALTER TABLE public.withdrawal_outcome ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_withdrawal_outcome_updated_by ON public.withdrawal_outcome (updated_by);

ALTER TABLE public.document_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_document_type_created_by ON public.document_type (created_by);

ALTER TABLE public.document_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_document_type_updated_by ON public.document_type (updated_by);

ALTER TABLE public.salary_period ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_salary_period_created_by ON public.salary_period (created_by);

ALTER TABLE public.salary_period ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_salary_period_updated_by ON public.salary_period (updated_by);

ALTER TABLE public.course_enrolment_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_status_created_by ON public.course_enrolment_status (created_by);

ALTER TABLE public.course_enrolment_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_status_updated_by ON public.course_enrolment_status (updated_by);

ALTER TABLE public.candidate_activity_type ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_type_created_by ON public.candidate_activity_type (created_by);

ALTER TABLE public.candidate_activity_type ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_type_updated_by ON public.candidate_activity_type (updated_by);

ALTER TABLE public.referral_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_status_created_by ON public.referral_status (created_by);

ALTER TABLE public.referral_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_status_updated_by ON public.referral_status (updated_by);

ALTER TABLE public.job_position_status ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_status_created_by ON public.job_position_status (created_by);

ALTER TABLE public.job_position_status ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_status_updated_by ON public.job_position_status (updated_by);

ALTER TABLE public.country ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_country_created_by ON public.country (created_by);

ALTER TABLE public.country ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_country_updated_by ON public.country (updated_by);

ALTER TABLE public.state ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_state_created_by ON public.state (created_by);

ALTER TABLE public.state ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_state_updated_by ON public.state (updated_by);

ALTER TABLE public.city ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_city_created_by ON public.city (created_by);

ALTER TABLE public.city ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_city_updated_by ON public.city (updated_by);

ALTER TABLE public.language ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_language_created_by ON public.language (created_by);

ALTER TABLE public.language ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_language_updated_by ON public.language (updated_by);

ALTER TABLE public.currency ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_currency_created_by ON public.currency (created_by);

ALTER TABLE public.currency ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_currency_updated_by ON public.currency (updated_by);

ALTER TABLE public.qualification ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_qualification_created_by ON public.qualification (created_by);

ALTER TABLE public.qualification ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_qualification_updated_by ON public.qualification (updated_by);

ALTER TABLE public.skill ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_skill_created_by ON public.skill (created_by);

ALTER TABLE public.skill ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_skill_updated_by ON public.skill (updated_by);

ALTER TABLE public.subject ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_subject_created_by ON public.subject (created_by);

ALTER TABLE public.subject ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_subject_updated_by ON public.subject (updated_by);

ALTER TABLE public.organisation ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_created_by ON public.organisation (created_by);

ALTER TABLE public.organisation ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_organisation_updated_by ON public.organisation (updated_by);

ALTER TABLE public.user_account ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_account_created_by ON public.user_account (created_by);

ALTER TABLE public.user_account ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_user_account_updated_by ON public.user_account (updated_by);

ALTER TABLE public.institution ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_institution_created_by ON public.institution (created_by);

ALTER TABLE public.institution ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_institution_updated_by ON public.institution (updated_by);

ALTER TABLE public.academic_program ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_academic_program_created_by ON public.academic_program (created_by);

ALTER TABLE public.academic_program ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_academic_program_updated_by ON public.academic_program (updated_by);

ALTER TABLE public.candidate_profile ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_profile_created_by ON public.candidate_profile (created_by);

ALTER TABLE public.candidate_profile ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_profile_updated_by ON public.candidate_profile (updated_by);

ALTER TABLE public.resume_template ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_template_created_by ON public.resume_template (created_by);

ALTER TABLE public.resume_template ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_template_updated_by ON public.resume_template (updated_by);

ALTER TABLE public.candidate_skill ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_skill_created_by ON public.candidate_skill (created_by);

ALTER TABLE public.candidate_skill ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_skill_updated_by ON public.candidate_skill (updated_by);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_education_created_by ON public.candidate_education (created_by);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_education_updated_by ON public.candidate_education (updated_by);

ALTER TABLE public.candidate_volunteer_experience ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_volunteer_experience_created_by ON public.candidate_volunteer_experience (created_by);

ALTER TABLE public.candidate_volunteer_experience ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_volunteer_experience_updated_by ON public.candidate_volunteer_experience (updated_by);

ALTER TABLE public.candidate_extracurricular_activity ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_extracurricular_activity_created_by ON public.candidate_extracurricular_activity (created_by);

ALTER TABLE public.candidate_extracurricular_activity ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_extracurricular_activity_updated_by ON public.candidate_extracurricular_activity (updated_by);

ALTER TABLE public.candidate_experience ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_experience_created_by ON public.candidate_experience (created_by);

ALTER TABLE public.candidate_experience ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_experience_updated_by ON public.candidate_experience (updated_by);

ALTER TABLE public.candidate_project ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_project_created_by ON public.candidate_project (created_by);

ALTER TABLE public.candidate_project ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_project_updated_by ON public.candidate_project (updated_by);

ALTER TABLE public.candidate_language ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_language_created_by ON public.candidate_language (created_by);

ALTER TABLE public.candidate_language ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_language_updated_by ON public.candidate_language (updated_by);

ALTER TABLE public.candidate_social_link ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_social_link_created_by ON public.candidate_social_link (created_by);

ALTER TABLE public.candidate_social_link ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_social_link_updated_by ON public.candidate_social_link (updated_by);

ALTER TABLE public.candidate_contact ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_contact_created_by ON public.candidate_contact (created_by);

ALTER TABLE public.candidate_contact ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_contact_updated_by ON public.candidate_contact (updated_by);

ALTER TABLE public.candidate_accomplishment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_accomplishment_created_by ON public.candidate_accomplishment (created_by);

ALTER TABLE public.candidate_accomplishment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_accomplishment_updated_by ON public.candidate_accomplishment (updated_by);

ALTER TABLE public.resume_version ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_version_created_by ON public.resume_version (created_by);

ALTER TABLE public.resume_version ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_resume_version_updated_by ON public.resume_version (updated_by);

ALTER TABLE public.education_verification ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_verification_created_by ON public.education_verification (created_by);

ALTER TABLE public.education_verification ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_education_verification_updated_by ON public.education_verification (updated_by);

ALTER TABLE public.candidate_subject ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_subject_created_by ON public.candidate_subject (created_by);

ALTER TABLE public.candidate_subject ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_subject_updated_by ON public.candidate_subject (updated_by);

ALTER TABLE public.candidate_backlog ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_backlog_created_by ON public.candidate_backlog (created_by);

ALTER TABLE public.candidate_backlog ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_backlog_updated_by ON public.candidate_backlog (updated_by);

ALTER TABLE public.candidate_academic_result ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_academic_result_created_by ON public.candidate_academic_result (created_by);

ALTER TABLE public.candidate_academic_result ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_academic_result_updated_by ON public.candidate_academic_result (updated_by);

ALTER TABLE public.candidate_document ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_document_created_by ON public.candidate_document (created_by);

ALTER TABLE public.candidate_document ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_document_updated_by ON public.candidate_document (updated_by);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_created_by ON public.job_requirement (created_by);

ALTER TABLE public.job_requirement ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_requirement_updated_by ON public.job_requirement (updated_by);

ALTER TABLE public.job_location ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_location_created_by ON public.job_location (created_by);

ALTER TABLE public.job_location ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_location_updated_by ON public.job_location (updated_by);

ALTER TABLE public.job_status_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_history_created_by ON public.job_status_history (created_by);

ALTER TABLE public.job_status_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_status_history_updated_by ON public.job_status_history (updated_by);

ALTER TABLE public.job_qualification_requirement ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_qualification_requirement_created_by ON public.job_qualification_requirement (created_by);

ALTER TABLE public.job_qualification_requirement ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_qualification_requirement_updated_by ON public.job_qualification_requirement (updated_by);

ALTER TABLE public.job_skill_requirement ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_skill_requirement_created_by ON public.job_skill_requirement (created_by);

ALTER TABLE public.job_skill_requirement ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_skill_requirement_updated_by ON public.job_skill_requirement (updated_by);

ALTER TABLE public.job_application_policy ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_application_policy_created_by ON public.job_application_policy (created_by);

ALTER TABLE public.job_application_policy ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_application_policy_updated_by ON public.job_application_policy (updated_by);

ALTER TABLE public.job_event ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_created_by ON public.job_event (created_by);

ALTER TABLE public.job_event ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_event_updated_by ON public.job_event (updated_by);

ALTER TABLE public.job_attachment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_attachment_created_by ON public.job_attachment (created_by);

ALTER TABLE public.job_attachment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_attachment_updated_by ON public.job_attachment (updated_by);

ALTER TABLE public.job_external_ats ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_external_ats_created_by ON public.job_external_ats (created_by);

ALTER TABLE public.job_external_ats ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_external_ats_updated_by ON public.job_external_ats (updated_by);

ALTER TABLE public.job_eligibility_policy ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligibility_policy_created_by ON public.job_eligibility_policy (created_by);

ALTER TABLE public.job_eligibility_policy ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligibility_policy_updated_by ON public.job_eligibility_policy (updated_by);

ALTER TABLE public.job_hiring_stage ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_hiring_stage_created_by ON public.job_hiring_stage (created_by);

ALTER TABLE public.job_hiring_stage ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_hiring_stage_updated_by ON public.job_hiring_stage (updated_by);

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_academic_criterion_created_by ON public.job_academic_criterion (created_by);

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_academic_criterion_updated_by ON public.job_academic_criterion (updated_by);

ALTER TABLE public.job_eligible_program ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligible_program_created_by ON public.job_eligible_program (created_by);

ALTER TABLE public.job_eligible_program ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_eligible_program_updated_by ON public.job_eligible_program (updated_by);

ALTER TABLE public.questionnaire ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_questionnaire_created_by ON public.questionnaire (created_by);

ALTER TABLE public.questionnaire ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_questionnaire_updated_by ON public.questionnaire (updated_by);

ALTER TABLE public.question ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_created_by ON public.question (created_by);

ALTER TABLE public.question ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_updated_by ON public.question (updated_by);

ALTER TABLE public.question_option ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_option_created_by ON public.question_option (created_by);

ALTER TABLE public.question_option ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_question_option_updated_by ON public.question_option (updated_by);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_created_by ON public.candidate_job_eligibility_check (created_by);

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_eligibility_check_updated_by ON public.candidate_job_eligibility_check (updated_by);

ALTER TABLE public.eligibility_check_result ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_check_result_created_by ON public.eligibility_check_result (created_by);

ALTER TABLE public.eligibility_check_result ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_eligibility_check_result_updated_by ON public.eligibility_check_result (updated_by);

ALTER TABLE public.application ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_created_by ON public.application (created_by);

ALTER TABLE public.application ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_updated_by ON public.application (updated_by);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_created_by ON public.application_stage_result (created_by);

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_stage_result_updated_by ON public.application_stage_result (updated_by);

ALTER TABLE public.application_withdrawal ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_withdrawal_created_by ON public.application_withdrawal (created_by);

ALTER TABLE public.application_withdrawal ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_withdrawal_updated_by ON public.application_withdrawal (updated_by);

ALTER TABLE public.application_profile_snapshot ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_profile_snapshot_created_by ON public.application_profile_snapshot (created_by);

ALTER TABLE public.application_profile_snapshot ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_profile_snapshot_updated_by ON public.application_profile_snapshot (updated_by);

ALTER TABLE public.application_status_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_history_created_by ON public.application_status_history (created_by);

ALTER TABLE public.application_status_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_status_history_updated_by ON public.application_status_history (updated_by);

ALTER TABLE public.interview ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_created_by ON public.interview (created_by);

ALTER TABLE public.interview ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_interview_updated_by ON public.interview (updated_by);

ALTER TABLE public.offer ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_created_by ON public.offer (created_by);

ALTER TABLE public.offer ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_offer_updated_by ON public.offer (updated_by);

ALTER TABLE public.joining_record ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_joining_record_created_by ON public.joining_record (created_by);

ALTER TABLE public.joining_record ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_joining_record_updated_by ON public.joining_record (updated_by);

ALTER TABLE public.application_document ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_document_created_by ON public.application_document (created_by);

ALTER TABLE public.application_document ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_document_updated_by ON public.application_document (updated_by);

ALTER TABLE public.application_answer ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_created_by ON public.application_answer (created_by);

ALTER TABLE public.application_answer ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_application_answer_updated_by ON public.application_answer (updated_by);

ALTER TABLE public.industry ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_industry_created_by ON public.industry (created_by);

ALTER TABLE public.industry ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_industry_updated_by ON public.industry (updated_by);

ALTER TABLE public.job_role ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_role_created_by ON public.job_role (created_by);

ALTER TABLE public.job_role ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_role_updated_by ON public.job_role (updated_by);

ALTER TABLE public.reference_code ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_code_created_by ON public.reference_code (created_by);

ALTER TABLE public.reference_code ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_code_updated_by ON public.reference_code (updated_by);

ALTER TABLE public.reference_translation ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_translation_created_by ON public.reference_translation (created_by);

ALTER TABLE public.reference_translation ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_reference_translation_updated_by ON public.reference_translation (updated_by);

ALTER TABLE public.ui_translation ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_ui_translation_created_by ON public.ui_translation (created_by);

ALTER TABLE public.ui_translation ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_ui_translation_updated_by ON public.ui_translation (updated_by);

ALTER TABLE public.assessment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_created_by ON public.assessment (created_by);

ALTER TABLE public.assessment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_updated_by ON public.assessment (updated_by);

ALTER TABLE public.assessment_result ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_result_created_by ON public.assessment_result (created_by);

ALTER TABLE public.assessment_result ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_assessment_result_updated_by ON public.assessment_result (updated_by);

ALTER TABLE public.course ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_created_by ON public.course (created_by);

ALTER TABLE public.course ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_updated_by ON public.course (updated_by);

ALTER TABLE public.course_enrolment ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_created_by ON public.course_enrolment (created_by);

ALTER TABLE public.course_enrolment ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_course_enrolment_updated_by ON public.course_enrolment (updated_by);

ALTER TABLE public.profile_completion_score ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_completion_score_created_by ON public.profile_completion_score (created_by);

ALTER TABLE public.profile_completion_score ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_completion_score_updated_by ON public.profile_completion_score (updated_by);

ALTER TABLE public.profile_view_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_view_history_created_by ON public.profile_view_history (created_by);

ALTER TABLE public.profile_view_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_profile_view_history_updated_by ON public.profile_view_history (updated_by);

ALTER TABLE public.candidate_activity_log ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_log_created_by ON public.candidate_activity_log (created_by);

ALTER TABLE public.candidate_activity_log ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_activity_log_updated_by ON public.candidate_activity_log (updated_by);

ALTER TABLE public.candidate_bookmark ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_created_by ON public.candidate_bookmark (created_by);

ALTER TABLE public.candidate_bookmark ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_updated_by ON public.candidate_bookmark (updated_by);

ALTER TABLE public.candidate_bookmark_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_history_created_by ON public.candidate_bookmark_history (created_by);

ALTER TABLE public.candidate_bookmark_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_bookmark_history_updated_by ON public.candidate_bookmark_history (updated_by);

ALTER TABLE public.referral_tracking ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_tracking_created_by ON public.referral_tracking (created_by);

ALTER TABLE public.referral_tracking ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_referral_tracking_updated_by ON public.referral_tracking (updated_by);

ALTER TABLE public.job_position ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_created_by ON public.job_position (created_by);

ALTER TABLE public.job_position ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_position_updated_by ON public.job_position (updated_by);

ALTER TABLE public.job_shortlist ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_shortlist_created_by ON public.job_shortlist (created_by);

ALTER TABLE public.job_shortlist ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_job_shortlist_updated_by ON public.job_shortlist (updated_by);

ALTER TABLE public.shortlist_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_shortlist_history_created_by ON public.shortlist_history (created_by);

ALTER TABLE public.shortlist_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_shortlist_history_updated_by ON public.shortlist_history (updated_by);

ALTER TABLE public.candidate_job_search_history ADD FOREIGN KEY (created_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_search_history_created_by ON public.candidate_job_search_history (created_by);

ALTER TABLE public.candidate_job_search_history ADD FOREIGN KEY (updated_by) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE INDEX idx_candidate_job_search_history_updated_by ON public.candidate_job_search_history (updated_by);

ALTER TABLE public.candidate_education ADD FOREIGN KEY (academic_program_id, qualification_id) REFERENCES public.academic_program (id, qualification_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.candidate_document ADD FOREIGN KEY (candidate_education_id, candidate_profile_id) REFERENCES public.candidate_education (id, candidate_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.candidate_job_eligibility_check ADD FOREIGN KEY (job_eligibility_policy_id, job_requirement_id) REFERENCES public.job_eligibility_policy (id, job_requirement_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application ADD FOREIGN KEY (resume_version_id, candidate_profile_id) REFERENCES public.resume_version (id, candidate_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application ADD FOREIGN KEY (questionnaire_id, job_requirement_id) REFERENCES public.questionnaire (id, job_requirement_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (application_id, job_requirement_id) REFERENCES public.application (id, job_requirement_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_stage_result ADD FOREIGN KEY (job_hiring_stage_id, job_requirement_id) REFERENCES public.job_hiring_stage (id, job_requirement_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_document ADD FOREIGN KEY (application_id, candidate_profile_id) REFERENCES public.application (id, candidate_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_document ADD FOREIGN KEY (candidate_document_id, candidate_profile_id) REFERENCES public.candidate_document (id, candidate_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.joining_record ADD FOREIGN KEY (offer_id, application_id) REFERENCES public.offer (id, application_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_answer ADD FOREIGN KEY (application_id, questionnaire_id) REFERENCES public.application (id, questionnaire_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_answer ADD FOREIGN KEY (question_id, questionnaire_id) REFERENCES public.question (id, questionnaire_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.application_answer ADD FOREIGN KEY (question_option_id, question_id) REFERENCES public.question_option (id, question_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.assessment_result ADD FOREIGN KEY (assessment_id, maximum_score) REFERENCES public.assessment (id, maximum_score) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.candidate_academic_result ADD FOREIGN KEY (score_scale_id, maximum_score) REFERENCES public.score_scale (id, maximum_score) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE public.job_academic_criterion ADD FOREIGN KEY (score_scale_id, maximum_score) REFERENCES public.score_scale (id, maximum_score) ON UPDATE RESTRICT ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_candidate_contact_primary ON public.candidate_contact(candidate_profile_id) WHERE is_primary AND deleted_at IS NULL;

CREATE UNIQUE INDEX uq_application_answer_scalar ON public.application_answer(application_id, question_id) WHERE question_option_id IS NULL;

CREATE UNIQUE INDEX uq_application_answer_option ON public.application_answer(application_id, question_id, question_option_id) WHERE question_option_id IS NOT NULL;

CREATE INDEX idx_job_requirement_search ON public.job_requirement(job_status_id, work_type_id, employment_type_id, deadline) WHERE deleted_at IS NULL;

CREATE INDEX idx_application_pipeline ON public.application(job_requirement_id, application_status_id, applied_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_application_status_history_timeline ON public.application_status_history(application_id, changed_at);

CREATE INDEX idx_job_status_history_timeline ON public.job_status_history(job_requirement_id, changed_at);

CREATE FUNCTION public.talentra_set_updated_at() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.talentra_reject_mutation() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% is append-only', TG_TABLE_NAME USING ERRCODE = '55000';
END;
$$;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.work_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.employment_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.proficiency_level FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.question_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.interview_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.offer_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.activity_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.experience_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.verification_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.accomplishment_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.social_platform FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_event_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.hiring_stage_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.education_level FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.score_scale FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.eligibility_decision FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.stage_decision FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.withdrawal_outcome FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.document_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.salary_period FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.course_enrolment_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_activity_type FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.referral_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_position_status FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.country FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.state FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.city FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.language FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.currency FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.qualification FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.skill FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.subject FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.organisation FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.user_account FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.institution FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.academic_program FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_profile FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.resume_template FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_skill FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_education FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_volunteer_experience FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_extracurricular_activity FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_experience FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_project FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_language FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_social_link FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_contact FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_accomplishment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.resume_version FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.resume_version FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.education_verification FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_subject FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_backlog FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_academic_result FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_document FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_requirement FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_location FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.job_status_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.job_status_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_qualification_requirement FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_skill_requirement FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_application_policy FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_event FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_attachment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_external_ats FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_eligibility_policy FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_hiring_stage FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_academic_criterion FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_eligible_program FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.questionnaire FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.question FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.question_option FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_job_eligibility_check FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.eligibility_check_result FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application_stage_result FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application_withdrawal FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.application_profile_snapshot FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.application_profile_snapshot FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.application_status_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.application_status_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.interview FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.offer FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.joining_record FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application_document FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.application_answer FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.industry FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_role FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.reference_code FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.reference_translation FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.ui_translation FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.assessment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.assessment_result FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.course FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.course_enrolment FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profile_completion_score FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.profile_view_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.profile_view_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.candidate_activity_log FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.candidate_activity_log FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidate_bookmark FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.candidate_bookmark_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.candidate_bookmark_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.referral_tracking FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_position FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.job_shortlist FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.shortlist_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.shortlist_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON public.candidate_job_search_history FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON public.candidate_job_search_history FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE FUNCTION public.talentra_validate_answer() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE kind VARCHAR(80);
BEGIN
  PERFORM 1 FROM public.application WHERE id = NEW.application_id FOR UPDATE;
  SELECT qt.code INTO kind FROM public.question q JOIN public.question_type qt ON qt.id = q.question_type_id WHERE q.id = NEW.question_id;
  IF kind IS NULL THEN
    RAISE EXCEPTION 'Unknown question' USING ERRCODE = '23503';
  END IF;
  IF (kind IN ('short_text', 'long_text') AND NEW.answer_text IS NULL)
    OR (kind = 'number' AND NEW.answer_number IS NULL)
    OR (kind = 'date' AND NEW.answer_date IS NULL)
    OR (kind = 'boolean' AND NEW.answer_boolean IS NULL)
    OR (kind IN ('single_choice', 'multiple_choice') AND NEW.question_option_id IS NULL) THEN
    RAISE EXCEPTION 'Answer does not match question type' USING ERRCODE = '23514';
  END IF;
  IF kind <> 'multiple_choice' AND EXISTS (
    SELECT 1 FROM public.application_answer a
    WHERE a.application_id = NEW.application_id AND a.question_id = NEW.question_id AND a.id <> NEW.id
  ) THEN
    RAISE EXCEPTION 'Question accepts only one answer' USING ERRCODE = '23505';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER validate_answer BEFORE INSERT OR UPDATE ON public.application_answer FOR EACH ROW EXECUTE FUNCTION public.talentra_validate_answer();

CREATE FUNCTION public.talentra_record_application_status() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' OR NEW.application_status_id IS DISTINCT FROM OLD.application_status_id THEN
    INSERT INTO public.application_status_history (application_id, application_status_id, created_by, updated_by)
    VALUES (NEW.id, NEW.application_status_id, COALESCE(NEW.updated_by, NEW.created_by), COALESCE(NEW.updated_by, NEW.created_by));
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER record_status AFTER INSERT OR UPDATE OF application_status_id ON public.application FOR EACH ROW EXECUTE FUNCTION public.talentra_record_application_status();

CREATE FUNCTION public.talentra_record_job_requirement_status() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' OR NEW.job_status_id IS DISTINCT FROM OLD.job_status_id THEN
    INSERT INTO public.job_status_history (job_requirement_id, job_status_id, created_by, updated_by)
    VALUES (NEW.id, NEW.job_status_id, COALESCE(NEW.updated_by, NEW.created_by), COALESCE(NEW.updated_by, NEW.created_by));
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER record_status AFTER INSERT OR UPDATE OF job_status_id ON public.job_requirement FOR EACH ROW EXECUTE FUNCTION public.talentra_record_job_requirement_status();

INSERT INTO public.job_status (code, display_name, sort_order) VALUES
  ('draft', 'Draft', 0),
  ('published', 'Published', 1),
  ('paused', 'Paused', 2),
  ('closed', 'Closed', 3),
  ('cancelled', 'Cancelled', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'job_status', code, display_name, active, sort_order FROM public.job_status;

UPDATE public.job_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'job_status' AND r.code = l.code;

ALTER TABLE public.job_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.work_type (code, display_name, sort_order) VALUES
  ('onsite', 'Onsite', 0),
  ('hybrid', 'Hybrid', 1),
  ('remote', 'Remote', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'work_type', code, display_name, active, sort_order FROM public.work_type;

UPDATE public.work_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'work_type' AND r.code = l.code;

ALTER TABLE public.work_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.employment_type (code, display_name, sort_order) VALUES
  ('permanent', 'Permanent', 0),
  ('contract', 'Contract', 1),
  ('temporary', 'Temporary', 2),
  ('apprenticeship', 'Apprenticeship', 3),
  ('internship', 'Internship', 4),
  ('gig', 'Gig', 5);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'employment_type', code, display_name, active, sort_order FROM public.employment_type;

UPDATE public.employment_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'employment_type' AND r.code = l.code;

ALTER TABLE public.employment_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.proficiency_level (code, display_name, sort_order) VALUES
  ('beginner', 'Beginner', 0),
  ('intermediate', 'Intermediate', 1),
  ('advanced', 'Advanced', 2),
  ('expert', 'Expert', 3),
  ('native', 'Native', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'proficiency_level', code, display_name, active, sort_order FROM public.proficiency_level;

UPDATE public.proficiency_level l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'proficiency_level' AND r.code = l.code;

ALTER TABLE public.proficiency_level ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.question_type (code, display_name, sort_order) VALUES
  ('short_text', 'Short Text', 0),
  ('long_text', 'Long Text', 1),
  ('single_choice', 'Single Choice', 2),
  ('multiple_choice', 'Multiple Choice', 3),
  ('number', 'Number', 4),
  ('date', 'Date', 5),
  ('boolean', 'Boolean', 6);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'question_type', code, display_name, active, sort_order FROM public.question_type;

UPDATE public.question_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'question_type' AND r.code = l.code;

ALTER TABLE public.question_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.application_status (code, display_name, sort_order) VALUES
  ('applied', 'Applied', 0),
  ('shortlisted', 'Shortlisted', 1),
  ('interviewing', 'Interviewing', 2),
  ('offered', 'Offered', 3),
  ('joined', 'Joined', 4),
  ('rejected', 'Rejected', 5),
  ('withdrawn', 'Withdrawn', 6);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'application_status', code, display_name, active, sort_order FROM public.application_status;

UPDATE public.application_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'application_status' AND r.code = l.code;

ALTER TABLE public.application_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.interview_status (code, display_name, sort_order) VALUES
  ('scheduled', 'Scheduled', 0),
  ('completed', 'Completed', 1),
  ('cancelled', 'Cancelled', 2),
  ('no_show', 'No Show', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'interview_status', code, display_name, active, sort_order FROM public.interview_status;

UPDATE public.interview_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'interview_status' AND r.code = l.code;

ALTER TABLE public.interview_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.offer_status (code, display_name, sort_order) VALUES
  ('draft', 'Draft', 0),
  ('issued', 'Issued', 1),
  ('accepted', 'Accepted', 2),
  ('declined', 'Declined', 3),
  ('expired', 'Expired', 4),
  ('withdrawn', 'Withdrawn', 5);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'offer_status', code, display_name, active, sort_order FROM public.offer_status;

UPDATE public.offer_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'offer_status' AND r.code = l.code;

ALTER TABLE public.offer_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.activity_type (code, display_name, sort_order) VALUES
  ('sports', 'Sports', 0),
  ('cultural', 'Cultural', 1),
  ('club', 'Club', 2),
  ('leadership', 'Leadership', 3),
  ('other', 'Other', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'activity_type', code, display_name, active, sort_order FROM public.activity_type;

UPDATE public.activity_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'activity_type' AND r.code = l.code;

ALTER TABLE public.activity_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.experience_type (code, display_name, sort_order) VALUES
  ('employment', 'Employment', 0),
  ('internship', 'Internship', 1),
  ('apprenticeship', 'Apprenticeship', 2),
  ('freelance', 'Freelance', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'experience_type', code, display_name, active, sort_order FROM public.experience_type;

UPDATE public.experience_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'experience_type' AND r.code = l.code;

ALTER TABLE public.experience_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.verification_status (code, display_name, sort_order) VALUES
  ('pending', 'Pending', 0),
  ('verified', 'Verified', 1),
  ('rejected', 'Rejected', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'verification_status', code, display_name, active, sort_order FROM public.verification_status;

UPDATE public.verification_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'verification_status' AND r.code = l.code;

ALTER TABLE public.verification_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.accomplishment_type (code, display_name, sort_order) VALUES
  ('award', 'Award', 0),
  ('certification', 'Certification', 1),
  ('publication', 'Publication', 2),
  ('patent', 'Patent', 3),
  ('other', 'Other', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'accomplishment_type', code, display_name, active, sort_order FROM public.accomplishment_type;

UPDATE public.accomplishment_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'accomplishment_type' AND r.code = l.code;

ALTER TABLE public.accomplishment_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.social_platform (code, display_name, sort_order) VALUES
  ('linkedin', 'Linkedin', 0),
  ('github', 'Github', 1),
  ('portfolio', 'Portfolio', 2),
  ('other', 'Other', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'social_platform', code, display_name, active, sort_order FROM public.social_platform;

UPDATE public.social_platform l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'social_platform' AND r.code = l.code;

ALTER TABLE public.social_platform ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.job_event_type (code, display_name, sort_order) VALUES
  ('information_session', 'Information Session', 0),
  ('assessment', 'Assessment', 1),
  ('interview', 'Interview', 2),
  ('recruitment_drive', 'Recruitment Drive', 3),
  ('other', 'Other', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'job_event_type', code, display_name, active, sort_order FROM public.job_event_type;

UPDATE public.job_event_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'job_event_type' AND r.code = l.code;

ALTER TABLE public.job_event_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.hiring_stage_type (code, display_name, sort_order) VALUES
  ('screening', 'Screening', 0),
  ('assessment', 'Assessment', 1),
  ('interview', 'Interview', 2),
  ('offer', 'Offer', 3),
  ('joining', 'Joining', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'hiring_stage_type', code, display_name, active, sort_order FROM public.hiring_stage_type;

UPDATE public.hiring_stage_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'hiring_stage_type' AND r.code = l.code;

ALTER TABLE public.hiring_stage_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.education_level (code, display_name, sort_order) VALUES
  ('secondary', 'Secondary', 0),
  ('higher_secondary', 'Higher Secondary', 1),
  ('diploma', 'Diploma', 2),
  ('undergraduate', 'Undergraduate', 3),
  ('postgraduate', 'Postgraduate', 4),
  ('doctorate', 'Doctorate', 5);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'education_level', code, display_name, active, sort_order FROM public.education_level;

UPDATE public.education_level l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'education_level' AND r.code = l.code;

ALTER TABLE public.education_level ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.score_scale (code, display_name, sort_order) VALUES
  ('percentage', 'Percentage', 0),
  ('gpa_4', 'Gpa 4', 1),
  ('gpa_10', 'Gpa 10', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'score_scale', code, display_name, active, sort_order FROM public.score_scale;

UPDATE public.score_scale l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'score_scale' AND r.code = l.code;

ALTER TABLE public.score_scale ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.eligibility_decision (code, display_name, sort_order) VALUES
  ('eligible', 'Eligible', 0),
  ('ineligible', 'Ineligible', 1),
  ('review_required', 'Review Required', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'eligibility_decision', code, display_name, active, sort_order FROM public.eligibility_decision;

UPDATE public.eligibility_decision l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'eligibility_decision' AND r.code = l.code;

ALTER TABLE public.eligibility_decision ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.stage_decision (code, display_name, sort_order) VALUES
  ('pending', 'Pending', 0),
  ('passed', 'Passed', 1),
  ('failed', 'Failed', 2),
  ('on_hold', 'On Hold', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'stage_decision', code, display_name, active, sort_order FROM public.stage_decision;

UPDATE public.stage_decision l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'stage_decision' AND r.code = l.code;

ALTER TABLE public.stage_decision ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.withdrawal_outcome (code, display_name, sort_order) VALUES
  ('requested', 'Requested', 0),
  ('approved', 'Approved', 1),
  ('rejected', 'Rejected', 2),
  ('cancelled', 'Cancelled', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'withdrawal_outcome', code, display_name, active, sort_order FROM public.withdrawal_outcome;

UPDATE public.withdrawal_outcome l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'withdrawal_outcome' AND r.code = l.code;

ALTER TABLE public.withdrawal_outcome ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.document_type (code, display_name, sort_order) VALUES
  ('resume', 'Resume', 0),
  ('transcript', 'Transcript', 1),
  ('certificate', 'Certificate', 2),
  ('identity', 'Identity', 3),
  ('other', 'Other', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'document_type', code, display_name, active, sort_order FROM public.document_type;

UPDATE public.document_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'document_type' AND r.code = l.code;

ALTER TABLE public.document_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.salary_period (code, display_name, sort_order) VALUES
  ('hour', 'Hour', 0),
  ('day', 'Day', 1),
  ('month', 'Month', 2),
  ('year', 'Year', 3),
  ('project', 'Project', 4);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'salary_period', code, display_name, active, sort_order FROM public.salary_period;

UPDATE public.salary_period l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'salary_period' AND r.code = l.code;

ALTER TABLE public.salary_period ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.course_enrolment_status (code, display_name, sort_order) VALUES
  ('enrolled', 'Enrolled', 0),
  ('in_progress', 'In Progress', 1),
  ('completed', 'Completed', 2),
  ('dropped', 'Dropped', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'course_enrolment_status', code, display_name, active, sort_order FROM public.course_enrolment_status;

UPDATE public.course_enrolment_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'course_enrolment_status' AND r.code = l.code;

ALTER TABLE public.course_enrolment_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.candidate_activity_type (code, display_name, sort_order) VALUES
  ('login', 'Login', 0),
  ('profile_update', 'Profile Update', 1),
  ('resume_download', 'Resume Download', 2),
  ('application_submitted', 'Application Submitted', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'candidate_activity_type', code, display_name, active, sort_order FROM public.candidate_activity_type;

UPDATE public.candidate_activity_type l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'candidate_activity_type' AND r.code = l.code;

ALTER TABLE public.candidate_activity_type ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.referral_status (code, display_name, sort_order) VALUES
  ('invited', 'Invited', 0),
  ('registered', 'Registered', 1),
  ('qualified', 'Qualified', 2),
  ('rewarded', 'Rewarded', 3);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'referral_status', code, display_name, active, sort_order FROM public.referral_status;

UPDATE public.referral_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'referral_status' AND r.code = l.code;

ALTER TABLE public.referral_status ALTER COLUMN reference_code_id SET NOT NULL;

INSERT INTO public.job_position_status (code, display_name, sort_order) VALUES
  ('open', 'Open', 0),
  ('filled', 'Filled', 1),
  ('cancelled', 'Cancelled', 2);

INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT 'job_position_status', code, display_name, active, sort_order FROM public.job_position_status;

UPDATE public.job_position_status l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = 'job_position_status' AND r.code = l.code;

ALTER TABLE public.job_position_status ALTER COLUMN reference_code_id SET NOT NULL;

UPDATE public.score_scale SET maximum_score = CASE code WHEN 'gpa_4' THEN 4 WHEN 'gpa_10' THEN 10 ELSE 100 END;

INSERT INTO public.language (code, display_name) VALUES ('en', 'English');

INSERT INTO public.currency (code, display_name) VALUES ('INR', 'Indian Rupee'), ('USD', 'US Dollar');

INSERT INTO public.reference_translation (reference_code_id, language_id, display_name) SELECT r.id, l.id, r.display_name FROM public.reference_code r CROSS JOIN public.language l WHERE l.code = 'en';

INSERT INTO public.ui_translation (translation_key, language_id, translated_text) SELECT v.key, l.id, v.label FROM (VALUES ('job.apply', 'Apply'), ('profile.save', 'Save profile'), ('application.status', 'Application status')) v(key, label) CROSS JOIN public.language l WHERE l.code = 'en';

ALTER TABLE public.user_account ADD CONSTRAINT fk_user_account_neon_auth FOREIGN KEY (neon_auth_user_id) REFERENCES neon_auth."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

COMMIT;
