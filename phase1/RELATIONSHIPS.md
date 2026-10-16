# Talentra Phase 1: Entity Relationships & ER Diagrams

This document details the relational architecture, foreign key constraints, and entity diagrams for Modules 1, 2, and 3 (Phase 1 Foundation). Complete tabular foreign key definitions are catalogued in [relationships.csv](docs/relationships.csv).

---

## 1. Module 1: Master Data & Global Lookups

```mermaid
erDiagram
    country ||--o{ state : contains
    state ||--o{ city : contains
    qualification_degree ||--o{ academic_program : offers
    academic_institution ||--o{ academic_program : conducts
    industry ||--o{ job_role : categorises
    reference_code ||--o{ reference_translation : translates
    reference_code ||--o{ ui_translation : localises

    country {
        bigint id PK
        varchar iso_code_2 UK
        varchar iso_code_3 UK
        varchar name
        varchar phone_code
    }
    state {
        bigint id PK
        bigint country_id FK
        varchar code
        varchar name
    }
    city {
        bigint id PK
        bigint state_id FK
        varchar name
    }
    currency {
        bigint id PK
        varchar code UK
        varchar name
        varchar symbol
    }
    reference_code {
        bigint id PK
        varchar domain
        varchar code UK
        varchar default_label
    }
```

The master data module establishes standardized ISO references for geographies (countries, administrative states, cities), official currencies, languages, industries, job roles, skills, and multilingual lookup codes. All reference tables provide natural uniqueness keys and link through `reference_code` to support multi-language localizations.

---

## 2. Module 2: Candidate Profile & Experience

```mermaid
erDiagram
    user_account ||--o| candidate_profile : owns
    candidate_profile ||--o{ candidate_contact : reaches
    candidate_profile ||--o{ candidate_social_link : links
    candidate_profile ||--o{ candidate_identity_document : verifies
    candidate_profile ||--o{ candidate_education : achieves
    candidate_profile ||--o{ candidate_experience : works
    candidate_profile ||--o{ candidate_skill : possesses
    candidate_profile ||--o{ candidate_language : speaks
    candidate_profile ||--o{ candidate_project : executes
    candidate_profile ||--o{ candidate_accomplishment : earns
    candidate_profile ||--o{ candidate_document : attaches
    candidate_profile ||--o{ resume_version : versions
    candidate_education }o--|| academic_institution : studied_at
    candidate_education }o--|| qualification_degree : graduated_with
    candidate_skill }o--|| skill : categorised_as

    candidate_profile {
        bigint id PK
        bigint user_account_id FK,UK
        varchar first_name
        varchar last_name
        date birth_date
        integer profile_completion_score
    }
    candidate_education {
        bigint id PK
        bigint candidate_profile_id FK
        bigint academic_institution_id FK
        bigint qualification_degree_id FK
        date start_date
        date end_date
        numeric score_value
    }
    resume_version {
        bigint id PK
        bigint candidate_profile_id FK
        integer version_number
        varchar private_storage_reference
        timestamptz created_at
    }
```

The candidate profile module anchors candidate personal data, educational credentials, work histories, verified skills, and multimedia portfolio projects. Resumes are stored as immutable, incrementing versions referencing private encrypted cloud object storage. Academic scores enforce valid grading scales and institution cross-references.

---

## 3. Module 3: Jobs and Applications Pipeline

```mermaid
erDiagram
    organisation ||--o{ job_requirement : posts
    job_requirement ||--o{ job_location : located_at
    job_requirement ||--o{ job_skill_requirement : requires
    job_requirement ||--o{ hiring_stage : defines
    job_requirement ||--o{ questionnaire : configures
    questionnaire ||--o{ question : includes
    question ||--o{ question_option : provides
    job_requirement ||--o{ application : receives
    candidate_profile ||--o{ application : submits
    resume_version ||--o{ application : attaches
    application ||--o{ application_answer : records
    question ||--o{ application_answer : answers
    application ||--o{ application_stage_result : progresses
    hiring_stage ||--o{ application_stage_result : evaluates
    application ||--o| offer : extends
    offer ||--o| joining : concludes

    job_requirement {
        bigint id PK
        bigint organisation_id FK
        varchar title
        varchar employment_status
        numeric minimum_salary
        numeric maximum_salary
    }
    application {
        bigint id PK
        bigint job_requirement_id FK
        bigint candidate_profile_id FK
        bigint resume_version_id FK
        varchar application_status
        timestamptz submitted_at
    }
    application_stage_result {
        bigint id PK
        bigint application_id FK
        bigint hiring_stage_id FK
        varchar stage_decision
        numeric stage_score
    }
```

The job and application pipeline governs the full recruitment lifecycle:
1. **Job Definition**: Requirements, multi-location assignments, mandatory skills, customizable hiring workflow stages, and dynamic candidate screening questionnaires.
2. **Application Processing**: One application per candidate per job requirement. Applications enforce composite ownership: candidate resume versions must belong to the applying candidate, and questionnaire answers must correspond to questions of the target job requirement.
3. **Pipeline Progress**: Sequential stage transitions append immutable history. Accepted candidates receive formalized offers leading to verified onboarding joinings.

---

## 4. Referential & Constraint Summary

- **Foreign Key Actions**: All foreign keys strictly enforce `ON UPDATE RESTRICT ON DELETE RESTRICT`. No cascading deletes of candidate history, educational records, or job applications are permitted.
- **Audit Columns**: Every table includes `created_at`, `created_by`, `updated_at`, `updated_by`, and `deleted_at`.
- **Primary Keys**: 64-bit `BIGINT GENERATED ALWAYS AS IDENTITY`.
- **Soft Deletion**: Logical deletions set `deleted_at`; immutable snapshots and event histories reject mutations outright via trigger guards.
