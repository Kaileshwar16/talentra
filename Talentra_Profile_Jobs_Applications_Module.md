# Talentra Database Module Specification

**Scope:** Candidate Profile, Jobs, Applications & Hiring Pipeline, shared master data, and the proposed Government Identity Verification extension.

**Source of truth:** This document is generated from the uploaded PostgreSQL 18 baseline SQL (`Pasted text(7).txt`). Existing columns, constraints, foreign keys, indexes, RLS declarations, and triggers below are source-derived. Rules labelled **Recommended application rule** are design requirements and may need additional implementation; they are not automatically enforced by the uploaded SQL.

> **Important:** This is a schema reference, not a migration. Do not execute generated table definitions or create duplicates. Compare against the live Neon database first. The uploaded baseline excludes optional campus extensions and later-phase modules, and does not include `neon_auth` table definitions. `neon_auth` is intentionally outside this document.

## Contents

- [Profile & Candidate Core](#profile-candidate-core)
- [Jobs & Employer Job Management](#jobs-employer-job-management)
- [Applications & Hiring Pipeline](#applications-hiring-pipeline)
- [Master Data & Shared Dependencies](#master-data-shared-dependencies)
- [Global rules and security requirements](#global-rules-and-security-requirements)
- [Government identity verification extension](#government-identity-verification-extension)
- [Implementation checklist](#implementation-checklist)

## How to read this document

- **Column definitions** reproduce the column type, nullability, defaults, and inline constraints from the uploaded baseline where available.
- **PK / UNIQUE / CHECK** lists table-level constraints from the source definition.
- **Foreign keys** lists `ALTER TABLE ... ADD FOREIGN KEY` relationships found in the source.
- **Indexes** lists explicit indexes from the source file.
- **Triggers / RLS** records source-defined trigger and row-level security declarations.
- A `CHECK` constraint generally permits NULL unless `NOT NULL` is also present; do not assume it makes a nullable column required.

## Profile & Candidate Core

Entities in this section: **26**.

### `candidate_profile`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `headline` | `VARCHAR(300)` |
| `summary` | `VARCHAR(4000)` |
| `date_of_birth` | `DATE` |
| `available_from` | `DATE` |
| `user_account_id` | `BIGINT NOT NULL` |
| `city_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_profile_6 UNIQUE (user_account_id)`

**Explicit indexes:**

- `idx_candidate_profile_user_account_id` on (user_account_id)
- `idx_candidate_profile_city_id` on (city_id)
- `idx_candidate_profile_created_by` on (created_by)
- `idx_candidate_profile_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_profile` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_contact`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `phone_e164` | `VARCHAR(16) NOT NULL CHECK (phone_e164 ~ '^\+[1-9][0-9]{1,14}$')` |
| `is_primary` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `verified_at` | `TIMESTAMPTZ` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `country_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_contact_6 UNIQUE (candidate_profile_id, phone_e164)`

**Explicit indexes:**

- `idx_candidate_contact_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_contact_country_id` on (country_id)
- `idx_candidate_contact_created_by` on (created_by)
- `idx_candidate_contact_updated_by` on (updated_by)
- UNIQUE `uq_candidate_contact_primary` on (candidate_profile_id) WHERE is_primary AND deleted_at IS NULL

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_contact` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_skill`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `years_experience` | `NUMERIC(4,1) CHECK (years_experience BETWEEN 0 AND 80)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `skill_id` | `BIGINT NOT NULL` |
| `proficiency_level_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_skill_5 UNIQUE (candidate_profile_id, skill_id)`

**Explicit indexes:**

- `idx_candidate_skill_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_skill_skill_id` on (skill_id)
- `idx_candidate_skill_proficiency_level_id` on (proficiency_level_id)
- `idx_candidate_skill_created_by` on (created_by)
- `idx_candidate_skill_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_skill` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_education`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `start_date` | `DATE` |
| `end_date` | `DATE` |
| `graduation_year` | `SMALLINT CHECK (graduation_year BETWEEN 1900 AND 2200)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `qualification_id` | `BIGINT NOT NULL` |
| `academic_program_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_education_7 UNIQUE (id, candidate_profile_id)`
- `CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)`

**Explicit indexes:**

- `idx_candidate_education_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_education_qualification_id` on (qualification_id)
- `idx_candidate_education_academic_program_id` on (academic_program_id)
- `idx_candidate_education_created_by` on (created_by)
- `idx_candidate_education_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_education` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_subject`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `semester` | `SMALLINT NOT NULL CHECK (semester > 0)` |
| `candidate_education_id` | `BIGINT NOT NULL` |
| `subject_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_subject_4 UNIQUE (candidate_education_id, subject_id, semester)`

**Explicit indexes:**

- `idx_candidate_subject_candidate_education_id` on (candidate_education_id)
- `idx_candidate_subject_subject_id` on (subject_id)
- `idx_candidate_subject_created_by` on (created_by)
- `idx_candidate_subject_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_subject` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_backlog`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `semester` | `SMALLINT NOT NULL CHECK (semester > 0)` |
| `identified_on` | `DATE NOT NULL` |
| `cleared_on` | `DATE` |
| `candidate_education_id` | `BIGINT NOT NULL` |
| `subject_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_backlog_6 UNIQUE (candidate_education_id, subject_id, semester)`
- `CHECK (cleared_on IS NULL OR cleared_on >= identified_on)`

**Explicit indexes:**

- `idx_candidate_backlog_candidate_education_id` on (candidate_education_id)
- `idx_candidate_backlog_subject_id` on (subject_id)
- `idx_candidate_backlog_created_by` on (created_by)
- `idx_candidate_backlog_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_backlog` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_academic_result`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `semester` | `SMALLINT NOT NULL CHECK (semester > 0)` |
| `score` | `NUMERIC(7,3) NOT NULL CHECK (score >= 0)` |
| `maximum_score` | `NUMERIC(7,3) NOT NULL CHECK (maximum_score > 0)` |
| `candidate_education_id` | `BIGINT NOT NULL` |
| `score_scale_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_academic_result_6 UNIQUE (candidate_education_id, semester, score_scale_id)`
- `CHECK (score <= maximum_score)`

**Explicit indexes:**

- `idx_candidate_academic_result_candidate_education_id` on (candidate_education_id)
- `idx_candidate_academic_result_score_scale_id` on (score_scale_id)
- `idx_candidate_academic_result_created_by` on (created_by)
- `idx_candidate_academic_result_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_academic_result` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_experience`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `employer_name` | `VARCHAR(150) NOT NULL` |
| `job_title` | `VARCHAR(150) NOT NULL` |
| `start_date` | `DATE NOT NULL` |
| `end_date` | `DATE` |
| `description` | `VARCHAR(4000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `experience_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)`

**Explicit indexes:**

- `idx_candidate_experience_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_experience_experience_type_id` on (experience_type_id)
- `idx_candidate_experience_created_by` on (created_by)
- `idx_candidate_experience_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_experience` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_project`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `project_role` | `VARCHAR(150) NOT NULL` |
| `start_date` | `DATE NOT NULL` |
| `end_date` | `DATE` |
| `project_url` | `VARCHAR(2048)` |
| `outcome` | `VARCHAR(4000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)`

**Explicit indexes:**

- `idx_candidate_project_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_project_created_by` on (created_by)
- `idx_candidate_project_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_project` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_language`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `can_read` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `can_write` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `can_speak` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `language_id` | `BIGINT NOT NULL` |
| `proficiency_level_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_language_7 UNIQUE (candidate_profile_id, language_id)`

**Explicit indexes:**

- `idx_candidate_language_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_language_language_id` on (language_id)
- `idx_candidate_language_proficiency_level_id` on (proficiency_level_id)
- `idx_candidate_language_created_by` on (created_by)
- `idx_candidate_language_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_language` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_social_link`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `url` | `VARCHAR(2048) NOT NULL` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `social_platform_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_social_link_4 UNIQUE (candidate_profile_id, url)`

**Explicit indexes:**

- `idx_candidate_social_link_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_social_link_social_platform_id` on (social_platform_id)
- `idx_candidate_social_link_created_by` on (created_by)
- `idx_candidate_social_link_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_social_link` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_accomplishment`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `issuer` | `VARCHAR(150)` |
| `issued_on` | `DATE` |
| `expires_on` | `DATE` |
| `credential_reference` | `VARCHAR(500)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `accomplishment_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on)`

**Explicit indexes:**

- `idx_candidate_accomplishment_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_accomplishment_accomplishment_type_id` on (accomplishment_type_id)
- `idx_candidate_accomplishment_created_by` on (created_by)
- `idx_candidate_accomplishment_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_accomplishment` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_volunteer_experience`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `organisation_name` | `VARCHAR(150) NOT NULL` |
| `role` | `VARCHAR(150) NOT NULL` |
| `start_date` | `DATE NOT NULL` |
| `end_date` | `DATE` |
| `description` | `VARCHAR(4000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)`

**Explicit indexes:**

- `idx_candidate_volunteer_experience_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_volunteer_experience_created_by` on (created_by)
- `idx_candidate_volunteer_experience_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_volunteer_experience` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_extracurricular_activity`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `start_date` | `DATE` |
| `end_date` | `DATE` |
| `description` | `VARCHAR(4000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `activity_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)`

**Explicit indexes:**

- `idx_candidate_extracurricular_activity_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_extracurricular_activity_activity_type_id` on (activity_type_id)
- `idx_candidate_extracurricular_activity_created_by` on (created_by)
- `idx_candidate_extracurricular_activity_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_extracurricular_activity` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_document`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `private_storage_reference` | `VARCHAR(2048) NOT NULL` |
| `content_sha256` | `CHAR(64) CHECK (content_sha256 ~ '^[a-f0-9]{64}$')` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `candidate_education_id` | `BIGINT` |
| `document_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_document_7 UNIQUE (id, candidate_profile_id)`

**Explicit indexes:**

- `idx_candidate_document_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_document_candidate_education_id` on (candidate_education_id)
- `idx_candidate_document_document_type_id` on (document_type_id)
- `idx_candidate_document_created_by` on (created_by)
- `idx_candidate_document_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_document` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `resume_template`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `template_reference` | `VARCHAR(2048) NOT NULL UNIQUE` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_resume_template_created_by` on (created_by)
- `idx_resume_template_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `resume_template` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `resume_version`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `version_number` | `INTEGER NOT NULL CHECK (version_number > 0)` |
| `private_storage_reference` | `VARCHAR(2048) NOT NULL` |
| `content_sha256` | `CHAR(64) CHECK (content_sha256 ~ '^[a-f0-9]{64}$')` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `resume_template_id` | `BIGINT` |
| `language_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_resume_version_7 UNIQUE (candidate_profile_id, version_number)`
- `CONSTRAINT uq_resume_version_8 UNIQUE (id, candidate_profile_id)`

**Explicit indexes:**

- `idx_resume_version_candidate_profile_id` on (candidate_profile_id)
- `idx_resume_version_resume_template_id` on (resume_template_id)
- `idx_resume_version_language_id` on (language_id)
- `idx_resume_version_created_by` on (created_by)
- `idx_resume_version_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `resume_version` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `resume_version` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `education_verification`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `verified_at` | `TIMESTAMPTZ` |
| `frozen` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `notes` | `VARCHAR(2000)` |
| `candidate_education_id` | `BIGINT NOT NULL` |
| `verification_status_id` | `BIGINT NOT NULL` |
| `verifier_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_education_verification_candidate_education_id` on (candidate_education_id)
- `idx_education_verification_verification_status_id` on (verification_status_id)
- `idx_education_verification_verifier_id` on (verifier_id)
- `idx_education_verification_created_by` on (created_by)
- `idx_education_verification_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `education_verification` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `assessment_result`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `attempt_number` | `INTEGER NOT NULL DEFAULT 1 CHECK (attempt_number > 0)` |
| `score` | `NUMERIC(10,3) NOT NULL CHECK (score >= 0)` |
| `maximum_score` | `NUMERIC(10,3) NOT NULL CHECK (maximum_score > 0)` |
| `taken_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `assessment_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_assessment_result_7 UNIQUE (candidate_profile_id, assessment_id, attempt_number)`
- `CHECK (score <= maximum_score)`

**Explicit indexes:**

- `idx_assessment_result_candidate_profile_id` on (candidate_profile_id)
- `idx_assessment_result_assessment_id` on (assessment_id)
- `idx_assessment_result_created_by` on (created_by)
- `idx_assessment_result_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `assessment_result` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `course_enrolment`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `enrolled_on` | `DATE NOT NULL` |
| `completed_on` | `DATE` |
| `certificate_reference` | `VARCHAR(2048)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `course_id` | `BIGINT NOT NULL` |
| `course_enrolment_status_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_course_enrolment_7 UNIQUE (candidate_profile_id, course_id)`
- `CHECK (completed_on IS NULL OR completed_on >= enrolled_on)`

**Explicit indexes:**

- `idx_course_enrolment_candidate_profile_id` on (candidate_profile_id)
- `idx_course_enrolment_course_id` on (course_id)
- `idx_course_enrolment_course_enrolment_status_id` on (course_enrolment_status_id)
- `idx_course_enrolment_created_by` on (created_by)
- `idx_course_enrolment_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `course_enrolment` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `profile_completion_score`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `score_percent` | `NUMERIC(5,2) NOT NULL CHECK (score_percent BETWEEN 0 AND 100)` |
| `rules_version` | `INTEGER NOT NULL CHECK (rules_version > 0)` |
| `calculated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_profile_completion_score_5 UNIQUE (candidate_profile_id)`

**Explicit indexes:**

- `idx_profile_completion_score_candidate_profile_id` on (candidate_profile_id)
- `idx_profile_completion_score_created_by` on (created_by)
- `idx_profile_completion_score_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `profile_completion_score` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `profile_view_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `viewed_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `viewer_id` | `BIGINT NOT NULL` |
| `organisation_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_profile_view_history_candidate_profile_id` on (candidate_profile_id)
- `idx_profile_view_history_viewer_id` on (viewer_id)
- `idx_profile_view_history_organisation_id` on (organisation_id)
- `idx_profile_view_history_created_by` on (created_by)
- `idx_profile_view_history_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `profile_view_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `profile_view_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `candidate_activity_log`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `occurred_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `description` | `VARCHAR(2000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `candidate_activity_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_candidate_activity_log_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_activity_log_candidate_activity_type_id` on (candidate_activity_type_id)
- `idx_candidate_activity_log_created_by` on (created_by)
- `idx_candidate_activity_log_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `candidate_activity_log` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `candidate_activity_log` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `candidate_bookmark`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `bookmarked_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `bookmarked_by` | `BIGINT NOT NULL` |
| `organisation_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_bookmark_5 UNIQUE (candidate_profile_id, bookmarked_by)`

**Explicit indexes:**

- `idx_candidate_bookmark_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_bookmark_bookmarked_by` on (bookmarked_by)
- `idx_candidate_bookmark_organisation_id` on (organisation_id)
- `idx_candidate_bookmark_created_by` on (created_by)
- `idx_candidate_bookmark_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_bookmark` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_bookmark_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `is_bookmarked` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `changed_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_bookmark_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_candidate_bookmark_history_candidate_bookmark_id` on (candidate_bookmark_id)
- `idx_candidate_bookmark_history_created_by` on (created_by)
- `idx_candidate_bookmark_history_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `candidate_bookmark_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `candidate_bookmark_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `candidate_job_search_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `searched_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `search_text` | `VARCHAR(1000)` |
| `filters` | `JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(filters) = 'object')` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_candidate_job_search_history_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_job_search_history_created_by` on (created_by)
- `idx_candidate_job_search_history_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `candidate_job_search_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `candidate_job_search_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

## Jobs & Employer Job Management

Entities in this section: **17**.

### `organisation`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `website_url` | `VARCHAR(2048)` |
| `city_id` | `BIGINT` |
| `industry_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_organisation_city_id` on (city_id)
- `idx_organisation_industry_id` on (industry_id)
- `idx_organisation_created_by` on (created_by)
- `idx_organisation_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `organisation` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_requirement`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `description` | `TEXT` |
| `salary_min` | `NUMERIC(18,2) CHECK (salary_min >= 0)` |
| `salary_max` | `NUMERIC(18,2) CHECK (salary_max >= 0)` |
| `deadline` | `TIMESTAMPTZ` |
| `positions` | `INTEGER NOT NULL DEFAULT 1 CHECK (positions > 0)` |
| `published_at` | `TIMESTAMPTZ` |
| `open_to_consultants` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `organisation_id` | `BIGINT NOT NULL` |
| `job_status_id` | `BIGINT NOT NULL` |
| `work_type_id` | `BIGINT NOT NULL` |
| `employment_type_id` | `BIGINT NOT NULL` |
| `currency_id` | `BIGINT` |
| `salary_period_id` | `BIGINT` |
| `language_id` | `BIGINT` |
| `job_role_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (salary_min IS NULL OR salary_max IS NULL OR salary_min <= salary_max)`
- `CHECK ((salary_min IS NULL AND salary_max IS NULL) OR (currency_id IS NOT NULL AND salary_period_id IS NOT NULL))`
- `CHECK (deadline IS NULL OR published_at IS NULL OR deadline >= published_at)`

**Explicit indexes:**

- `idx_job_requirement_organisation_id` on (organisation_id)
- `idx_job_requirement_job_status_id` on (job_status_id)
- `idx_job_requirement_work_type_id` on (work_type_id)
- `idx_job_requirement_employment_type_id` on (employment_type_id)
- `idx_job_requirement_currency_id` on (currency_id)
- `idx_job_requirement_salary_period_id` on (salary_period_id)
- `idx_job_requirement_language_id` on (language_id)
- `idx_job_requirement_job_role_id` on (job_role_id)
- `idx_job_requirement_created_by` on (created_by)
- `idx_job_requirement_updated_by` on (updated_by)
- `idx_job_requirement_search` on (job_status_id, work_type_id, employment_type_id, deadline) WHERE deleted_at IS NULL

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_requirement` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()
- `record_status`: AFTER INSERT OR UPDATE OF job_status_id ON `job_requirement` FOR EACH ROW EXECUTE FUNCTION public.talentra_record_job_requirement_status()

### `job_location`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `city_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_location_3 UNIQUE (job_requirement_id, city_id)`

**Explicit indexes:**

- `idx_job_location_job_requirement_id` on (job_requirement_id)
- `idx_job_location_city_id` on (city_id)
- `idx_job_location_created_by` on (created_by)
- `idx_job_location_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_location` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_status_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `changed_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `reason` | `VARCHAR(2000)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `job_status_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_job_status_history_job_requirement_id` on (job_requirement_id)
- `idx_job_status_history_job_status_id` on (job_status_id)
- `idx_job_status_history_created_by` on (created_by)
- `idx_job_status_history_updated_by` on (updated_by)
- `idx_job_status_history_timeline` on (job_requirement_id, changed_at)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `job_status_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `job_status_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `job_qualification_requirement`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `qualification_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_qualification_requirement_3 UNIQUE (job_requirement_id, qualification_id)`

**Explicit indexes:**

- `idx_job_qualification_requirement_job_requirement_id` on (job_requirement_id)
- `idx_job_qualification_requirement_qualification_id` on (qualification_id)
- `idx_job_qualification_requirement_created_by` on (created_by)
- `idx_job_qualification_requirement_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_qualification_requirement` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_skill_requirement`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `required` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `minimum_years` | `NUMERIC(4,1) CHECK (minimum_years BETWEEN 0 AND 80)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `skill_id` | `BIGINT NOT NULL` |
| `proficiency_level_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_skill_requirement_6 UNIQUE (job_requirement_id, skill_id)`

**Explicit indexes:**

- `idx_job_skill_requirement_job_requirement_id` on (job_requirement_id)
- `idx_job_skill_requirement_skill_id` on (skill_id)
- `idx_job_skill_requirement_proficiency_level_id` on (proficiency_level_id)
- `idx_job_skill_requirement_created_by` on (created_by)
- `idx_job_skill_requirement_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_skill_requirement` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_application_policy`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `resume_required` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `withdrawal_allowed` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `withdrawal_requires_approval` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `withdrawal_deadline` | `TIMESTAMPTZ` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_application_policy_6 UNIQUE (job_requirement_id)`
- `CHECK (withdrawal_allowed OR NOT withdrawal_requires_approval)`

**Explicit indexes:**

- `idx_job_application_policy_job_requirement_id` on (job_requirement_id)
- `idx_job_application_policy_created_by` on (created_by)
- `idx_job_application_policy_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_application_policy` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_event`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `starts_at` | `TIMESTAMPTZ NOT NULL` |
| `ends_at` | `TIMESTAMPTZ NOT NULL` |
| `source_timezone` | `VARCHAR(100) NOT NULL DEFAULT 'UTC'` |
| `venue` | `VARCHAR(500)` |
| `meeting_url` | `VARCHAR(2048)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `job_event_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (ends_at >= starts_at)`

**Explicit indexes:**

- `idx_job_event_job_requirement_id` on (job_requirement_id)
- `idx_job_event_job_event_type_id` on (job_event_type_id)
- `idx_job_event_created_by` on (created_by)
- `idx_job_event_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_event` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_attachment`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `private_storage_reference` | `VARCHAR(2048) NOT NULL` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_job_attachment_job_requirement_id` on (job_requirement_id)
- `idx_job_attachment_created_by` on (created_by)
- `idx_job_attachment_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_attachment` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_external_ats`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `provider` | `VARCHAR(150) NOT NULL` |
| `application_url` | `VARCHAR(2048) NOT NULL` |
| `external_job_reference` | `VARCHAR(500)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_external_ats_5 UNIQUE (job_requirement_id, provider)`

**Explicit indexes:**

- `idx_job_external_ats_job_requirement_id` on (job_requirement_id)
- `idx_job_external_ats_created_by` on (created_by)
- `idx_job_external_ats_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_external_ats` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_eligibility_policy`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `version_number` | `INTEGER NOT NULL CHECK (version_number > 0)` |
| `maximum_active_backlogs` | `INTEGER CHECK (maximum_active_backlogs >= 0)` |
| `maximum_gap_months` | `INTEGER CHECK (maximum_gap_months >= 0)` |
| `valid_from` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `valid_until` | `TIMESTAMPTZ` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_eligibility_policy_7 UNIQUE (job_requirement_id, version_number)`
- `CONSTRAINT uq_job_eligibility_policy_8 UNIQUE (id, job_requirement_id)`
- `CHECK (valid_until IS NULL OR valid_until > valid_from)`

**Explicit indexes:**

- `idx_job_eligibility_policy_job_requirement_id` on (job_requirement_id)
- `idx_job_eligibility_policy_created_by` on (created_by)
- `idx_job_eligibility_policy_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_eligibility_policy` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_hiring_stage`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `sequence` | `INTEGER NOT NULL CHECK (sequence > 0)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `hiring_stage_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_hiring_stage_5 UNIQUE (job_requirement_id, sequence)`
- `CONSTRAINT uq_job_hiring_stage_6 UNIQUE (id, job_requirement_id)`

**Explicit indexes:**

- `idx_job_hiring_stage_job_requirement_id` on (job_requirement_id)
- `idx_job_hiring_stage_hiring_stage_type_id` on (hiring_stage_type_id)
- `idx_job_hiring_stage_created_by` on (created_by)
- `idx_job_hiring_stage_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_hiring_stage` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_academic_criterion`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `minimum_score` | `NUMERIC(7,3) NOT NULL CHECK (minimum_score >= 0)` |
| `maximum_score` | `NUMERIC(7,3) NOT NULL CHECK (maximum_score > 0)` |
| `job_eligibility_policy_id` | `BIGINT NOT NULL` |
| `education_level_id` | `BIGINT NOT NULL` |
| `score_scale_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_academic_criterion_6 UNIQUE (job_eligibility_policy_id, education_level_id, score_scale_id)`
- `CHECK (minimum_score <= maximum_score)`

**Explicit indexes:**

- `idx_job_academic_criterion_job_eligibility_policy_id` on (job_eligibility_policy_id)
- `idx_job_academic_criterion_education_level_id` on (education_level_id)
- `idx_job_academic_criterion_score_scale_id` on (score_scale_id)
- `idx_job_academic_criterion_created_by` on (created_by)
- `idx_job_academic_criterion_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_academic_criterion` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_eligible_program`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `job_eligibility_policy_id` | `BIGINT NOT NULL` |
| `academic_program_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_eligible_program_3 UNIQUE (job_eligibility_policy_id, academic_program_id)`

**Explicit indexes:**

- `idx_job_eligible_program_job_eligibility_policy_id` on (job_eligibility_policy_id)
- `idx_job_eligible_program_academic_program_id` on (academic_program_id)
- `idx_job_eligible_program_created_by` on (created_by)
- `idx_job_eligible_program_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_eligible_program` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_position`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `position_reference` | `VARCHAR(80) NOT NULL` |
| `filled_at` | `TIMESTAMPTZ` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `job_position_status_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_position_5 UNIQUE (job_requirement_id, position_reference)`

**Explicit indexes:**

- `idx_job_position_job_requirement_id` on (job_requirement_id)
- `idx_job_position_job_position_status_id` on (job_position_status_id)
- `idx_job_position_created_by` on (created_by)
- `idx_job_position_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_position` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_shortlist`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `shortlisted_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `shortlisted_by` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_shortlist_5 UNIQUE (job_requirement_id, candidate_profile_id)`

**Explicit indexes:**

- `idx_job_shortlist_job_requirement_id` on (job_requirement_id)
- `idx_job_shortlist_candidate_profile_id` on (candidate_profile_id)
- `idx_job_shortlist_shortlisted_by` on (shortlisted_by)
- `idx_job_shortlist_created_by` on (created_by)
- `idx_job_shortlist_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_shortlist` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `shortlist_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `is_shortlisted` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `changed_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `job_shortlist_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_shortlist_history_job_shortlist_id` on (job_shortlist_id)
- `idx_shortlist_history_created_by` on (created_by)
- `idx_shortlist_history_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `shortlist_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `shortlist_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

## Applications & Hiring Pipeline

Entities in this section: **16**.

### `application`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `applied_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `cover_letter` | `VARCHAR(4000)` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `application_status_id` | `BIGINT NOT NULL` |
| `resume_version_id` | `BIGINT` |
| `questionnaire_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_application_8 UNIQUE (candidate_profile_id, job_requirement_id)`
- `CONSTRAINT uq_application_9 UNIQUE (id, candidate_profile_id)`
- `CONSTRAINT uq_application_10 UNIQUE (id, job_requirement_id)`
- `CONSTRAINT uq_application_11 UNIQUE (id, questionnaire_id)`

**Explicit indexes:**

- `idx_application_candidate_profile_id` on (candidate_profile_id)
- `idx_application_job_requirement_id` on (job_requirement_id)
- `idx_application_application_status_id` on (application_status_id)
- `idx_application_resume_version_id` on (resume_version_id)
- `idx_application_questionnaire_id` on (questionnaire_id)
- `idx_application_created_by` on (created_by)
- `idx_application_updated_by` on (updated_by)
- `idx_application_pipeline` on (job_requirement_id, application_status_id, applied_at) WHERE deleted_at IS NULL

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()
- `record_status`: AFTER INSERT OR UPDATE OF application_status_id ON `application` FOR EACH ROW EXECUTE FUNCTION public.talentra_record_application_status()

### `application_stage_result`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `attempt_number` | `INTEGER NOT NULL DEFAULT 1 CHECK (attempt_number > 0)` |
| `score` | `NUMERIC(7,3) CHECK (score >= 0)` |
| `maximum_score` | `NUMERIC(7,3) CHECK (maximum_score > 0)` |
| `feedback` | `VARCHAR(4000)` |
| `completed_at` | `TIMESTAMPTZ` |
| `application_id` | `BIGINT NOT NULL` |
| `job_hiring_stage_id` | `BIGINT NOT NULL` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `stage_decision_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_application_stage_result_10 UNIQUE (application_id, job_hiring_stage_id, attempt_number)`
- `CHECK ((score IS NULL AND maximum_score IS NULL) OR (score IS NOT NULL AND maximum_score IS NOT NULL AND score <= maximum_score))`

**Explicit indexes:**

- `idx_application_stage_result_application_id` on (application_id)
- `idx_application_stage_result_job_hiring_stage_id` on (job_hiring_stage_id)
- `idx_application_stage_result_job_requirement_id` on (job_requirement_id)
- `idx_application_stage_result_stage_decision_id` on (stage_decision_id)
- `idx_application_stage_result_created_by` on (created_by)
- `idx_application_stage_result_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application_stage_result` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `application_withdrawal`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `requested_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `reason` | `VARCHAR(2000) NOT NULL` |
| `resolved_at` | `TIMESTAMPTZ` |
| `application_id` | `BIGINT NOT NULL` |
| `withdrawal_outcome_id` | `BIGINT NOT NULL` |
| `resolved_by` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (resolved_at IS NULL OR resolved_at >= requested_at)`

**Explicit indexes:**

- `idx_application_withdrawal_application_id` on (application_id)
- `idx_application_withdrawal_withdrawal_outcome_id` on (withdrawal_outcome_id)
- `idx_application_withdrawal_resolved_by` on (resolved_by)
- `idx_application_withdrawal_created_by` on (created_by)
- `idx_application_withdrawal_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application_withdrawal` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `application_profile_snapshot`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `profile_version` | `INTEGER NOT NULL CHECK (profile_version > 0)` |
| `profile_data` | `JSONB NOT NULL CHECK (jsonb_typeof(profile_data) = 'object')` |
| `captured_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `application_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_application_profile_snapshot_5 UNIQUE (application_id)`

**Explicit indexes:**

- `idx_application_profile_snapshot_application_id` on (application_id)
- `idx_application_profile_snapshot_created_by` on (created_by)
- `idx_application_profile_snapshot_updated_by` on (updated_by)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `application_profile_snapshot` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `application_profile_snapshot` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `application_status_history`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `changed_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `reason` | `VARCHAR(2000)` |
| `application_id` | `BIGINT NOT NULL` |
| `application_status_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_application_status_history_application_id` on (application_id)
- `idx_application_status_history_application_status_id` on (application_status_id)
- `idx_application_status_history_created_by` on (created_by)
- `idx_application_status_history_updated_by` on (updated_by)
- `idx_application_status_history_timeline` on (application_id, changed_at)

**Triggers:**

- `reject_mutation`: BEFORE UPDATE OR DELETE ON `application_status_history` FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()
- `reject_truncate`: BEFORE TRUNCATE ON `application_status_history` FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()

### `interview`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `round` | `INTEGER NOT NULL CHECK (round > 0)` |
| `starts_at` | `TIMESTAMPTZ NOT NULL` |
| `ends_at` | `TIMESTAMPTZ` |
| `source_timezone` | `VARCHAR(100) NOT NULL DEFAULT 'UTC'` |
| `location` | `VARCHAR(500)` |
| `meeting_url` | `VARCHAR(2048)` |
| `feedback` | `VARCHAR(4000)` |
| `application_id` | `BIGINT NOT NULL` |
| `interview_status_id` | `BIGINT NOT NULL` |
| `interviewer_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (ends_at IS NULL OR ends_at >= starts_at)`
- `CONSTRAINT uq_interview_12 UNIQUE (application_id, round)`

**Explicit indexes:**

- `idx_interview_application_id` on (application_id)
- `idx_interview_interview_status_id` on (interview_status_id)
- `idx_interview_interviewer_id` on (interviewer_id)
- `idx_interview_created_by` on (created_by)
- `idx_interview_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `interview` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `offer`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `version_number` | `INTEGER NOT NULL CHECK (version_number > 0)` |
| `amount` | `NUMERIC(18,2) NOT NULL CHECK (amount >= 0)` |
| `issued_at` | `TIMESTAMPTZ` |
| `expires_at` | `TIMESTAMPTZ` |
| `expected_start_date` | `DATE` |
| `private_storage_reference` | `VARCHAR(2048)` |
| `application_id` | `BIGINT NOT NULL` |
| `offer_status_id` | `BIGINT NOT NULL` |
| `currency_id` | `BIGINT NOT NULL` |
| `salary_period_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_offer_11 UNIQUE (application_id, version_number)`
- `CONSTRAINT uq_offer_12 UNIQUE (id, application_id)`
- `CHECK (expires_at IS NULL OR issued_at IS NULL OR expires_at >= issued_at)`

**Explicit indexes:**

- `idx_offer_application_id` on (application_id)
- `idx_offer_offer_status_id` on (offer_status_id)
- `idx_offer_currency_id` on (currency_id)
- `idx_offer_salary_period_id` on (salary_period_id)
- `idx_offer_created_by` on (created_by)
- `idx_offer_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `offer` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `joining_record`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `joined_on` | `DATE NOT NULL` |
| `external_reference` | `VARCHAR(500)` |
| `application_id` | `BIGINT NOT NULL` |
| `offer_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_joining_record_5 UNIQUE (application_id)`

**Explicit indexes:**

- `idx_joining_record_application_id` on (application_id)
- `idx_joining_record_offer_id` on (offer_id)
- `idx_joining_record_created_by` on (created_by)
- `idx_joining_record_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `joining_record` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `application_document`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `application_id` | `BIGINT NOT NULL` |
| `candidate_document_id` | `BIGINT NOT NULL` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_application_document_4 UNIQUE (application_id, candidate_document_id)`

**Explicit indexes:**

- `idx_application_document_application_id` on (application_id)
- `idx_application_document_candidate_document_id` on (candidate_document_id)
- `idx_application_document_candidate_profile_id` on (candidate_profile_id)
- `idx_application_document_created_by` on (created_by)
- `idx_application_document_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application_document` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `application_answer`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `answer_text` | `VARCHAR(10000)` |
| `answer_number` | `NUMERIC(20,6)` |
| `answer_date` | `DATE` |
| `answer_boolean` | `BOOLEAN` |
| `application_id` | `BIGINT NOT NULL` |
| `question_id` | `BIGINT NOT NULL` |
| `questionnaire_id` | `BIGINT NOT NULL` |
| `question_option_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CHECK (num_nonnulls(answer_text, answer_number, answer_date, answer_boolean, question_option_id) = 1)`

**Explicit indexes:**

- `idx_application_answer_application_id` on (application_id)
- `idx_application_answer_question_id` on (question_id)
- `idx_application_answer_questionnaire_id` on (questionnaire_id)
- `idx_application_answer_question_option_id` on (question_option_id)
- `idx_application_answer_created_by` on (created_by)
- `idx_application_answer_updated_by` on (updated_by)
- UNIQUE `uq_application_answer_scalar` on (application_id, question_id) WHERE question_option_id IS NULL
- UNIQUE `uq_application_answer_option` on (application_id, question_id, question_option_id) WHERE question_option_id IS NOT NULL

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application_answer` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()
- `validate_answer`: BEFORE INSERT OR UPDATE ON `application_answer` FOR EACH ROW EXECUTE FUNCTION public.talentra_validate_answer()

### `questionnaire`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `title` | `VARCHAR(150) NOT NULL` |
| `version_number` | `INTEGER NOT NULL CHECK (version_number > 0)` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_questionnaire_4 UNIQUE (job_requirement_id, version_number)`
- `CONSTRAINT uq_questionnaire_5 UNIQUE (id, job_requirement_id)`

**Explicit indexes:**

- `idx_questionnaire_job_requirement_id` on (job_requirement_id)
- `idx_questionnaire_created_by` on (created_by)
- `idx_questionnaire_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `questionnaire` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `question`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `question_text` | `VARCHAR(4000) NOT NULL` |
| `required` | `BOOLEAN NOT NULL DEFAULT FALSE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `questionnaire_id` | `BIGINT NOT NULL` |
| `question_type_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_question_6 UNIQUE (id, questionnaire_id)`

**Explicit indexes:**

- `idx_question_questionnaire_id` on (questionnaire_id)
- `idx_question_question_type_id` on (question_type_id)
- `idx_question_created_by` on (created_by)
- `idx_question_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `question` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `question_option`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `option_text` | `VARCHAR(2000) NOT NULL` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `question_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_question_option_4 UNIQUE (question_id, option_text)`
- `CONSTRAINT uq_question_option_5 UNIQUE (id, question_id)`

**Explicit indexes:**

- `idx_question_option_question_id` on (question_id)
- `idx_question_option_created_by` on (created_by)
- `idx_question_option_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `question_option` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_job_eligibility_check`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `checked_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `candidate_profile_id` | `BIGINT NOT NULL` |
| `job_requirement_id` | `BIGINT NOT NULL` |
| `job_eligibility_policy_id` | `BIGINT NOT NULL` |
| `eligibility_decision_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_candidate_job_eligibility_check_candidate_profile_id` on (candidate_profile_id)
- `idx_candidate_job_eligibility_check_job_requirement_id` on (job_requirement_id)
- `idx_candidate_job_eligibility_check_job_eligibility_policy_id` on (job_eligibility_policy_id)
- `idx_candidate_job_eligibility_check_eligibility_decision_id` on (eligibility_decision_id)
- `idx_candidate_job_eligibility_check_created_by` on (created_by)
- `idx_candidate_job_eligibility_check_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_job_eligibility_check` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `eligibility_check_result`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `criterion` | `VARCHAR(150) NOT NULL` |
| `observed_value` | `VARCHAR(1000)` |
| `required_value` | `VARCHAR(1000)` |
| `explanation` | `VARCHAR(2000)` |
| `candidate_job_eligibility_check_id` | `BIGINT NOT NULL` |
| `eligibility_decision_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_eligibility_check_result_candidate_job_eligibility_check_id` on (candidate_job_eligibility_check_id)
- `idx_eligibility_check_result_eligibility_decision_id` on (eligibility_decision_id)
- `idx_eligibility_check_result_created_by` on (created_by)
- `idx_eligibility_check_result_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `eligibility_check_result` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `referral_tracking`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `referral_code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `referred_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `referrer_id` | `BIGINT NOT NULL` |
| `candidate_profile_id` | `BIGINT` |
| `referral_status_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_referral_tracking_referrer_id` on (referrer_id)
- `idx_referral_tracking_candidate_profile_id` on (candidate_profile_id)
- `idx_referral_tracking_referral_status_id` on (referral_status_id)
- `idx_referral_tracking_created_by` on (created_by)
- `idx_referral_tracking_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `referral_tracking` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

## Master Data & Shared Dependencies

Entities in this section: **44**.

### `job_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_job_status_reference_code_id` on (reference_code_id)
- `idx_job_status_created_by` on (created_by)
- `idx_job_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `work_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_work_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_work_type_reference_code_id` on (reference_code_id)
- `idx_work_type_created_by` on (created_by)
- `idx_work_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `work_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `employment_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_employment_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_employment_type_reference_code_id` on (reference_code_id)
- `idx_employment_type_created_by` on (created_by)
- `idx_employment_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `employment_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `proficiency_level`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_proficiency_level_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_proficiency_level_reference_code_id` on (reference_code_id)
- `idx_proficiency_level_created_by` on (created_by)
- `idx_proficiency_level_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `proficiency_level` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `question_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_question_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_question_type_reference_code_id` on (reference_code_id)
- `idx_question_type_created_by` on (created_by)
- `idx_question_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `question_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `application_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_application_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_application_status_reference_code_id` on (reference_code_id)
- `idx_application_status_created_by` on (created_by)
- `idx_application_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `application_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `interview_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_interview_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_interview_status_reference_code_id` on (reference_code_id)
- `idx_interview_status_created_by` on (created_by)
- `idx_interview_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `interview_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `offer_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_offer_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_offer_status_reference_code_id` on (reference_code_id)
- `idx_offer_status_created_by` on (created_by)
- `idx_offer_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `offer_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `activity_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_activity_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_activity_type_reference_code_id` on (reference_code_id)
- `idx_activity_type_created_by` on (created_by)
- `idx_activity_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `activity_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `experience_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_experience_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_experience_type_reference_code_id` on (reference_code_id)
- `idx_experience_type_created_by` on (created_by)
- `idx_experience_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `experience_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `verification_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_verification_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_verification_status_reference_code_id` on (reference_code_id)
- `idx_verification_status_created_by` on (created_by)
- `idx_verification_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `verification_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `accomplishment_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_accomplishment_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_accomplishment_type_reference_code_id` on (reference_code_id)
- `idx_accomplishment_type_created_by` on (created_by)
- `idx_accomplishment_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `accomplishment_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `social_platform`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_social_platform_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_social_platform_reference_code_id` on (reference_code_id)
- `idx_social_platform_created_by` on (created_by)
- `idx_social_platform_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `social_platform` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_event_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_event_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_job_event_type_reference_code_id` on (reference_code_id)
- `idx_job_event_type_created_by` on (created_by)
- `idx_job_event_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_event_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `hiring_stage_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_hiring_stage_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_hiring_stage_type_reference_code_id` on (reference_code_id)
- `idx_hiring_stage_type_created_by` on (created_by)
- `idx_hiring_stage_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `hiring_stage_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `education_level`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_education_level_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_education_level_reference_code_id` on (reference_code_id)
- `idx_education_level_created_by` on (created_by)
- `idx_education_level_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `education_level` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `score_scale`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `maximum_score` | `NUMERIC(7,3) NOT NULL DEFAULT 100 CHECK (maximum_score > 0)` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_score_scale_6 UNIQUE (reference_code_id)`
- `CONSTRAINT uq_score_scale_8 UNIQUE (id, maximum_score)`

**Explicit indexes:**

- `idx_score_scale_reference_code_id` on (reference_code_id)
- `idx_score_scale_created_by` on (created_by)
- `idx_score_scale_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `score_scale` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `eligibility_decision`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_eligibility_decision_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_eligibility_decision_reference_code_id` on (reference_code_id)
- `idx_eligibility_decision_created_by` on (created_by)
- `idx_eligibility_decision_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `eligibility_decision` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `stage_decision`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_stage_decision_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_stage_decision_reference_code_id` on (reference_code_id)
- `idx_stage_decision_created_by` on (created_by)
- `idx_stage_decision_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `stage_decision` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `withdrawal_outcome`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_withdrawal_outcome_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_withdrawal_outcome_reference_code_id` on (reference_code_id)
- `idx_withdrawal_outcome_created_by` on (created_by)
- `idx_withdrawal_outcome_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `withdrawal_outcome` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `document_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_document_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_document_type_reference_code_id` on (reference_code_id)
- `idx_document_type_created_by` on (created_by)
- `idx_document_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `document_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `salary_period`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_salary_period_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_salary_period_reference_code_id` on (reference_code_id)
- `idx_salary_period_created_by` on (created_by)
- `idx_salary_period_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `salary_period` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `course_enrolment_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_course_enrolment_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_course_enrolment_status_reference_code_id` on (reference_code_id)
- `idx_course_enrolment_status_created_by` on (created_by)
- `idx_course_enrolment_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `course_enrolment_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `candidate_activity_type`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_candidate_activity_type_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_candidate_activity_type_reference_code_id` on (reference_code_id)
- `idx_candidate_activity_type_created_by` on (created_by)
- `idx_candidate_activity_type_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `candidate_activity_type` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `referral_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_referral_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_referral_status_reference_code_id` on (reference_code_id)
- `idx_referral_status_created_by` on (created_by)
- `idx_referral_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `referral_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_position_status`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `reference_code_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_job_position_status_6 UNIQUE (reference_code_id)`

**Explicit indexes:**

- `idx_job_position_status_reference_code_id` on (reference_code_id)
- `idx_job_position_status_created_by` on (created_by)
- `idx_job_position_status_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_position_status` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `country`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `CHAR(2) NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{2}$')` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `phone_calling_code` | `VARCHAR(8)` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_country_created_by` on (created_by)
- `idx_country_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `country` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `state`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(20)` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `country_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_state_4 UNIQUE (country_id, code)`
- `CONSTRAINT uq_state_5 UNIQUE (country_id, display_name)`

**Explicit indexes:**

- `idx_state_country_id` on (country_id)
- `idx_state_created_by` on (created_by)
- `idx_state_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `state` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `city`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `state_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_city_3 UNIQUE (state_id, display_name)`

**Explicit indexes:**

- `idx_city_state_id` on (state_id)
- `idx_city_created_by` on (created_by)
- `idx_city_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `city` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `language`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(35) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_language_created_by` on (created_by)
- `idx_language_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `language` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `currency`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `CHAR(3) NOT NULL UNIQUE CHECK (code ~ '^[A-Z]{3}$')` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `minor_unit` | `SMALLINT NOT NULL DEFAULT 2 CHECK (minor_unit BETWEEN 0 AND 4)` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_currency_created_by` on (created_by)
- `idx_currency_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `currency` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `qualification`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_qualification_created_by` on (created_by)
- `idx_qualification_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `qualification` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `skill`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_skill_created_by` on (created_by)
- `idx_skill_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `skill` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `subject`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_subject_created_by` on (created_by)
- `idx_subject_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `subject` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `user_account`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `full_name` | `VARCHAR(150) NOT NULL` |
| `email` | `VARCHAR(254) NOT NULL UNIQUE CHECK (email = lower(email) AND email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')` |
| `neon_auth_user_id` | `UUID UNIQUE` |
| `language_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_user_account_language_id` on (language_id)
- `idx_user_account_created_by` on (created_by)
- `idx_user_account_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `user_account` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `institution`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `city_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_institution_city_id` on (city_id)
- `idx_institution_created_by` on (created_by)
- `idx_institution_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `institution` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `academic_program`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(150) NOT NULL` |
| `institution_id` | `BIGINT NOT NULL` |
| `qualification_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_academic_program_4 UNIQUE (institution_id, qualification_id, name)`
- `CONSTRAINT uq_academic_program_5 UNIQUE (id, qualification_id)`

**Explicit indexes:**

- `idx_academic_program_institution_id` on (institution_id)
- `idx_academic_program_qualification_id` on (qualification_id)
- `idx_academic_program_created_by` on (created_by)
- `idx_academic_program_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `academic_program` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `industry`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_industry_created_by` on (created_by)
- `idx_industry_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `industry` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `job_role`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_job_role_created_by` on (created_by)
- `idx_job_role_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `job_role` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `reference_code`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `domain_code` | `VARCHAR(80) NOT NULL` |
| `code` | `VARCHAR(80) NOT NULL` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `active` | `BOOLEAN NOT NULL DEFAULT TRUE` |
| `sort_order` | `INTEGER NOT NULL DEFAULT 0` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_reference_code_6 UNIQUE (domain_code, code)`

**Explicit indexes:**

- `idx_reference_code_created_by` on (created_by)
- `idx_reference_code_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `reference_code` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `reference_translation`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `display_name` | `VARCHAR(150) NOT NULL` |
| `reference_code_id` | `BIGINT NOT NULL` |
| `language_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_reference_translation_4 UNIQUE (reference_code_id, language_id)`

**Explicit indexes:**

- `idx_reference_translation_reference_code_id` on (reference_code_id)
- `idx_reference_translation_language_id` on (language_id)
- `idx_reference_translation_created_by` on (created_by)
- `idx_reference_translation_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `reference_translation` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `ui_translation`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `translation_key` | `VARCHAR(160) NOT NULL` |
| `translated_text` | `VARCHAR(2000) NOT NULL` |
| `language_id` | `BIGINT NOT NULL` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_ui_translation_4 UNIQUE (translation_key, language_id)`

**Explicit indexes:**

- `idx_ui_translation_language_id` on (language_id)
- `idx_ui_translation_created_by` on (created_by)
- `idx_ui_translation_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `ui_translation` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `assessment`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `name` | `VARCHAR(150) NOT NULL` |
| `provider` | `VARCHAR(150)` |
| `maximum_score` | `NUMERIC(10,3) NOT NULL CHECK (maximum_score > 0)` |
| `skill_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Inline/table constraints:**

- `CONSTRAINT uq_assessment_6 UNIQUE (id, maximum_score)`

**Explicit indexes:**

- `idx_assessment_skill_id` on (skill_id)
- `idx_assessment_created_by` on (created_by)
- `idx_assessment_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `assessment` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

### `course`

| Column | Definition from baseline |
|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `code` | `VARCHAR(80) NOT NULL UNIQUE` |
| `name` | `VARCHAR(150) NOT NULL` |
| `provider` | `VARCHAR(150) NOT NULL` |
| `course_url` | `VARCHAR(2048)` |
| `skill_id` | `BIGINT` |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `created_by` | `BIGINT` |
| `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `updated_by` | `BIGINT` |
| `deleted_at` | `TIMESTAMPTZ` |

**Explicit indexes:**

- `idx_course_skill_id` on (skill_id)
- `idx_course_created_by` on (created_by)
- `idx_course_updated_by` on (updated_by)

**Triggers:**

- `set_updated_at`: BEFORE UPDATE ON `course` FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()

## Global rules and security requirements

### Rules enforced by the uploaded SQL baseline

- Identity primary keys use `BIGINT GENERATED ALWAYS AS IDENTITY` for most entities.
- Most mutable entities use `created_at`, `created_by`, `updated_at`, `updated_by`, and `deleted_at` audit columns. Check individual tables because not every table has all fields.
- Foreign keys use `ON UPDATE RESTRICT ON DELETE RESTRICT` in the uploaded baseline, so referenced rows cannot be deleted while referenced.
- The `talentra_set_updated_at()` trigger refreshes `updated_at` on updates for tables where `set_updated_at` is installed.
- Append-only triggers reject update/delete/truncate operations on selected history/snapshot tables, including `resume_version`, `job_status_history`, `application_profile_snapshot`, `application_status_history`, `profile_view_history`, `candidate_activity_log`, `candidate_bookmark_history`, `shortlist_history`, and `candidate_job_search_history`.
- `application_answer` has a trigger (`talentra_validate_answer`) and checks to validate answer shape and questionnaire relationships.
- Application and job status changes are recorded through triggers that write history rows.
- The source SQL enables RLS on `candidate_profile` and `job_requirement`; verify that actual policies exist in the target database before relying on RLS.

### Rules to enforce in application services and/or database policies

1. **Ownership:** candidates can read/write only their own profile, documents, resumes, preferences and activity; employer/recruiter access must be scoped to jobs and candidates they are authorized to manage.
2. **Organisation isolation:** recruiter/job operations must be scoped to the recruiter’s organisation. Consultants can work only on jobs where `open_to_consultants = TRUE` and are otherwise authorized.
3. **Blocked parties:** if blocking is in scope, enforce block lists on search, profile views, contact, shortlist and sourcing APIs—not only in the UI.
4. **No recruiter impersonation:** recruiters cannot create candidate accounts or submit applications on behalf of candidates unless an explicitly approved workflow is introduced.
5. **Job lifecycle:** only authorized organisation users can create/update jobs; publication requires mandatory job fields and valid status transitions; closed/expired jobs cannot accept new applications.
6. **Application uniqueness:** baseline enforces one application per candidate/job via `UNIQUE(candidate_profile_id, job_requirement_id)`. Decide whether re-application after withdrawal is forbidden or whether a separate re-application policy is needed.
7. **Cross-table consistency:** composite FKs already exist for several relationships, such as application/resume ownership, application/questionnaire job consistency, stage/job consistency, application document ownership, and offer/joining consistency. Preserve these constraints.
8. **History integrity:** treat status histories, profile snapshots, view/activity logs and shortlist histories as append-only. Use service roles with narrowly scoped permissions.
9. **Soft deletion:** queries must filter `deleted_at IS NULL` where appropriate. Unique constraints on nullable/soft-deleted data may need partial unique indexes if a deleted record should not block a new active record.
10. **Sensitive data:** store uploaded files using private storage references, never public permanent URLs. Apply authorization to signed URL issuance and short expiry.
11. **Audit:** every sensitive action (profile access, identity-document access, job status change, application status change, manual verification, offer decision) must have an actor, timestamp and contextual reference.
12. **Data validation:** validate dates, numeric ranges, URL formats, email normalization, phone E.164 format, score ranges and status transitions both at the API boundary and, where practical, in the database.
13. **Transactions:** create an application and its immutable profile snapshot atomically; update a status and its history in one transaction.
14. **RLS:** test policies with candidate, employer, recruiter, consultant, admin and unauthenticated roles. RLS must not rely on user-supplied candidate/organisation IDs without validating the authenticated principal.

## Government identity verification extension

The supplied baseline has `document_type`, `verification_status`, and `candidate_document`, but the newer uploaded baseline does **not** define a `candidate_identity_verification` table. The older SQL draft referenced a table of that name, but do not assume it exists in the current baseline. If PAN/Aadhaar verification is in scope, add a dedicated extension after schema comparison.

### Proposed entities (not present in the uploaded baseline)

#### `candidate_identity_document`

| Column | Recommended type | Rule |
|---|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` | Stable document record ID |
| `candidate_profile_id` | `BIGINT NOT NULL REFERENCES public.candidate_profile(id)` | Owner |
| `document_type_id` | `BIGINT NOT NULL REFERENCES public.document_type(id)` | Reuse existing master; seed PAN/AADHAAR/PASSPORT/VOTER_ID/DRIVING_LICENCE codes if approved |
| `candidate_document_id` | `BIGINT NULL REFERENCES public.candidate_document(id)` | Optional private file reference; enforce same-candidate ownership with composite FK where practical |
| `issuing_country_id` | `BIGINT NOT NULL REFERENCES public.country(id)` | Issuing country |
| `document_number_ciphertext` | `BYTEA NULL` | Encrypt using application/KMS-managed key; do not store plaintext |
| `document_number_fingerprint` | `BYTEA NULL` | Optional keyed HMAC for duplicate detection; never plain hash of predictable IDs |
| `masked_document_number` | `VARCHAR(40) NULL` | Safe display only |
| `name_on_document` | `VARCHAR(150) NULL` | Store only if needed for verification |
| `issued_on` | `DATE NULL` | Optional issue date |
| `expires_on` | `DATE NULL` | Required only for document types that expire |
| `document_status` | `VARCHAR(20) NOT NULL` | Controlled values: ACTIVE, REPLACED, REVOKED, EXPIRED, WITHDRAWN |
| `created_at`, `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` | Audit timestamps; install updated_at trigger |
| `created_by`, `updated_by` | `BIGINT NULL REFERENCES public.user_account(id)` | Audit actor |
| `deleted_at` | `TIMESTAMPTZ NULL` | Retention-controlled soft deletion |

Constraints: primary key; FKs listed above; `CHECK (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on)`; controlled status values; conditional unique index on `(issuing_country_id, document_type_id, document_number_fingerprint)` only where fingerprint is non-null and policy permits it. Avoid forcing collection of full Aadhaar/PAN if the authorized provider can verify without retaining it.

#### `identity_verification`

| Column | Recommended type | Rule |
|---|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` | PK |
| `candidate_identity_document_id` | `BIGINT NOT NULL REFERENCES public.candidate_identity_document(id)` | Document being verified |
| `verification_status_id` | `BIGINT NOT NULL REFERENCES public.verification_status(id)` | Reuse existing status master |
| `verification_reference` | `UUID NOT NULL UNIQUE` | Internal correlation reference |
| `verification_method` | `VARCHAR(30) NOT NULL` | PROVIDER_API, MANUAL, DIGITAL_CREDENTIAL |
| `provider_code` | `VARCHAR(80) NULL` | Provider identifier, no secrets |
| `provider_reference` | `VARCHAR(255) NULL` | External transaction reference |
| `submitted_at`, `started_at`, `completed_at`, `verified_at` | `TIMESTAMPTZ NULL` | Event timestamps; completion cannot precede start |
| `reviewed_by` | `BIGINT NULL REFERENCES public.user_account(id)` | Required for manual review outcomes |
| `rejection_code` | `VARCHAR(80) NULL` | Controlled, non-sensitive reason |
| `rejection_reason` | `VARCHAR(1000) NULL` | Sanitized message only |
| `last_checked_at` | `TIMESTAMPTZ NULL` | Last provider/status check |
| `created_at`, `updated_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` | Audit timestamps |
| `created_by`, `updated_by` | `BIGINT NULL REFERENCES public.user_account(id)` | Audit actor |

Rules: unique internal reference; `completed_at >= started_at` when both exist; `VERIFIED` requires `verified_at`; a failed/pending state must not claim verification success; only one active/pending verification per document (partial unique index after defining exact open statuses); status transitions must be validated in service logic or a trigger.

#### `identity_verification_attempt`

| Column | Recommended type | Rule |
|---|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` | PK |
| `identity_verification_id` | `BIGINT NOT NULL REFERENCES public.identity_verification(id)` | Parent request |
| `attempt_number` | `INTEGER NOT NULL CHECK (attempt_number > 0)` | Attempt sequence |
| `attempt_status` | `VARCHAR(20) NOT NULL` | STARTED, PENDING, SUCCESS, FAILED, CANCELLED |
| `provider_code` | `VARCHAR(80) NULL` | Provider ID |
| `provider_reference` | `VARCHAR(255) NULL` | Provider transaction ID |
| `failure_code` | `VARCHAR(80) NULL` | Sanitized code |
| `failure_reason` | `VARCHAR(1000) NULL` | No raw PII/provider payload |
| `started_at` | `TIMESTAMPTZ NOT NULL` | Start time |
| `completed_at` | `TIMESTAMPTZ NULL` | Must be >= start time |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` | Audit timestamp |

Constraints: `UNIQUE(identity_verification_id, attempt_number)`; positive attempt number; completion time not before start; successful attempts require a completion timestamp. Treat attempt rows as append-only.

#### `identity_verification_consent`

| Column | Recommended type | Rule |
|---|---|---|
| `id` | `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` | PK |
| `candidate_profile_id` | `BIGINT NOT NULL REFERENCES public.candidate_profile(id)` | Candidate granting consent |
| `candidate_identity_document_id` | `BIGINT NOT NULL REFERENCES public.candidate_identity_document(id)` | Document in scope |
| `identity_verification_id` | `BIGINT NULL REFERENCES public.identity_verification(id)` | Related verification request |
| `purpose_code` | `VARCHAR(80) NOT NULL` | Specific purpose |
| `consent_text_version` | `VARCHAR(50) NOT NULL` | Version of notice shown |
| `consent_status` | `VARCHAR(20) NOT NULL` | GRANTED, DECLINED, WITHDRAWN |
| `consented_at`, `withdrawn_at` | `TIMESTAMPTZ NULL` | Enforce status/timestamp consistency |
| `capture_method` | `VARCHAR(30) NOT NULL` | WEB, MOBILE, ADMIN_ASSISTED |
| `created_at` | `TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP` | Audit timestamp |

Rules: document must belong to the candidate; consent must be purpose-specific; required consent must exist before verification begins; preserve consent/withdrawal history according to the applicable retention policy.

#### Audit events

Prefer the existing centralized audit/event mechanism if available. Otherwise add `identity_verification_audit_log` with `id`, `identity_verification_id`, `candidate_identity_document_id`, `actor_user_id`, `actor_type`, `action_code`, `old_status_id`, `new_status_id`, `reason_code`, `correlation_id`, and `created_at`. Make it append-only for application roles. Never log full document numbers, OTPs, secrets, document contents, or raw provider payloads.

### India-specific security rules

- PAN and Aadhaar require different lawful and authorized verification pathways; do not treat a valid format as proof of authenticity.
- Review applicable UIDAI requirements and relevant Indian data-protection obligations before collecting, authenticating, storing, or sharing Aadhaar data.
- Prefer masked identifiers and provider references. Encrypt any necessary sensitive value with keys managed outside PostgreSQL.
- Employers and recruiters should receive only the minimum authorized verification result, not unrestricted identity numbers or document scans.
- Define retention, consent withdrawal, deletion, and re-verification policies before production.

## Implementation checklist

- [ ] Diff this documented baseline against the live Neon database before migration.
- [ ] Confirm whether any newer tables, constraints, RLS policies, or audit infrastructure already exist.
- [ ] Validate every FK and composite FK, especially ownership and job/application consistency.
- [ ] Confirm RLS policies exist and test them for every actor role.
- [ ] Ensure all history/snapshot tables have append-only protections and permissions.
- [ ] Add missing indexes based on actual query plans; do not duplicate existing indexes.
- [ ] Seed reference/master data using stable codes and idempotent migrations.
- [ ] Test invalid inputs and state transitions at both API and database levels where practical.
- [ ] Keep private files outside public storage; test authorization and signed URL expiry.
- [ ] Verify that no identity numbers, secrets, or provider payloads are emitted in logs.
- [ ] Run migrations transactionally, with rollback strategy and backups.

## Source notes

- Schema definitions and constraints are extracted from the supplied `Pasted text(7).txt` PostgreSQL 18 baseline.
- This file documents what the source SQL contains and separately labels recommended business/security rules. It does not claim that every recommended rule is already enforced.
- Government identity verification tables are a proposed extension, not part of the supplied baseline.
