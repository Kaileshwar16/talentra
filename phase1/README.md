# Talentra Phase 1: Core Foundation (Modules 1–3)

Phase 1 establishes the relational foundation of the Talentra Platform covering Milestones 1–6 in the [hackathon docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf).

## Module Scope
- **Module 1 — Master Data**: Geographic reference hierarchy (countries, states, cities), languages, currencies, qualification degrees, institutions, academic programs, standardized industries, job roles, skills, and centralized enumeration lookup codes (`reference_code`, `reference_translation`, `ui_translation`).
- **Module 2 — Candidate Profile**: User account linkage, personal profiles, contact channels, social profiles, identity documents, education history, work experience, accomplishments, projects, volunteer records, languages, skills, and immutable resume versioning with private storage references.
- **Module 3 — Jobs and Applications**: Job requirements, hiring stages, job locations, candidate eligibility policies, customizable questionnaires with multiple question types, candidate applications, questionnaire answers, application document references, stage results, offers, and joining records.

## Repository & Deployed Artifacts
- **Migration**: [001_connected_er.sql](migrations/001_connected_er.sql)
- **Data Dictionary**: [TALENTRA_SCHEMA.md](TALENTRA_SCHEMA.md)
- **Test Suite**: [phase1_constraints.sql](tests/phase1_constraints.sql) (26 automated constraint and integrity checks, 100% pass rate)
- **Catalog Deliverables**:
  - [entities.csv](docs/entities.csv): 103 base tables in `public`
  - [columns.csv](docs/columns.csv): 486 ordinal column definitions
  - [constraints.csv](docs/constraints.csv): Primary keys, unique constraints, check constraints, foreign keys
  - [relationships.csv](docs/relationships.csv): Foreign key constraints and referenced targets
  - [indexes.csv](docs/indexes.csv): B-tree indexes supporting lookup and foreign key performance
  - [triggers.csv](docs/triggers.csv): Updated-at and audit triggers
  - [validation-report.json](docs/validation-report.json): Automated test validation and SHA-256 verification

## Architectural Principles
1. **Primary Keys**: Every application entity utilizes a 64-bit `BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`.
2. **Naming Conventions**: Strict PostgreSQL snake_case identifiers, singular table nouns, and explicit foreign key suffixes (`_id`).
3. **Audit & Lifecycles**: Standard `created_at`, `created_by`, `updated_at`, `updated_by`, and `deleted_at` fields for non-destructive soft-deletion and trace retention.
4. **Referential Integrity**: All relational associations enforce explicit `ON UPDATE RESTRICT ON DELETE RESTRICT` constraints to guarantee data consistency.
5. **Neon Auth Isolation**: External authentication tables under `neon_auth.*` are anchored non-destructively through optional UUID identifiers without contaminating the application data dictionary.
