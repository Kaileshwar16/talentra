# Talentra Phase 1 foundation

Scope: Phase 1, Milestones 1–6, backlogs B1–B23 in `Talentra-Database-Design-Hackathon-Docket.pdf`. The attached `Talentra_Connected_ER_Diagram (1).png` supplies the core relationship model. The PDF's common module list supplies additional Phase 1 entities that the diagram does not show.

## Provider and target

PostgreSQL 18 on Neon is the selected provider. It provides transactional DDL, foreign keys (including composite ownership constraints), exact decimal types, identity columns, partial indexes, JSONB snapshots, and trigger enforcement. The existing Neon project already runs PostgreSQL 18.6, so no provider migration is needed. This design targets PostgreSQL only.

| Setting | Value |
| --- | --- |
| Neon organization | Nithin (`org-long-pine-78141863`) |
| Project | Talentra (`jolly-pond-45332483`) |
| Branch | production (`br-jolly-dawn-azv4gh54`) |
| Database | neondb |
| Application schema | public |
| Existing authentication schema | neon_auth; preserved |

The user called Talentra an organization; live inspection identified it as a project within Nithin. It has a single branch. Before this migration, the database contained nine Neon Auth tables and no public application tables.

## Scope and ownership

All three common modules are assigned to **Team**, as the PDF specifies. No individual team member assignments or human approvals are invented.

| Module | Phase 1 coverage |
| --- | --- |
| Master data | Geography, languages, currencies, skills, qualifications, industries, job roles, typed enumerations, reference codes and translations, UI translations |
| Profile | Account/profile anchor, contact, education and academic evidence, experience, skills, languages, projects, resumes, assessments, courses, completion score, views, activities, bookmarks and history, referral tracking |
| Jobs and Applications | Requirements, positions, locations, publishing/status, eligibility, questionnaires, applications and answers, stage results, snapshots, status history, withdrawals, shortlists and history, interviews, offers and joins, search history |

There are **103 tables**: 65 from the non-campus diagram, 19 supporting lookup/master tables, and 19 additional Phase 1 coverage tables. The entity inventory identifies the origin of each table.

`user_account` and `organisation` are minimal dependency anchors already shown in the diagram. Candidate identity/contact needs an account key; jobs need an employer key. Full Administration and Organisation/account design is deferred. `user_account.neon_auth_user_id` is an optional unique UUID foreign key to the existing `neon_auth.user.id`; all application surrogate primary keys remain BIGINT. Account provisioning and synchronization with Neon Auth are not implemented by this migration.

The diagram's optional `placement_cycle`, `job_placement_cycle`, and `candidate_placement_enrolment` tables are deferred. Academic programs and institutions remain because candidate education and job eligibility reference them.

Later phases are deferred: credentials/roles/permissions/consent/blocking and full audit, company verification/recruiter mappings, gigs, licensing/devices, sourcing, wallets/payments/subscriptions, notifications/community, analytics, bulk synthetic seeding, performance benchmarks, security enforcement and backup/restore exercises. The earlier `talentra_schema.sql` is a separate all-module draft and was not executed or modified.

## Design decisions and relationships

- Every entity has `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`. Natural keys remain unique constraints. Names follow the diagram, including `application`, `offer`, `job_skill_requirement`, and `question`.
- The diagram abbreviates columns. Physical names use explicit suffixes (`starts_at`, `end_date`, `version_number`, `private_storage_reference`); inferred fields are visible in the data dictionary. Additional context keys on stage results, answers, and application documents enforce composite ownership constraints.
- A user has zero or one candidate profile. A candidate has many skills, contacts, education records, experiences, projects, documents, and immutable resume versions. An academic program belongs to an institution and qualification; an education record's qualification must agree with its selected program.
- A job belongs to one organisation and has multiple locations, skills, qualifications, stages, events, eligibility policy versions, and questionnaire versions. A job has zero or one application policy. Employment type and work type are separate lookups.
- A candidate may apply once to a job. Reapplication to the same requirement is not enabled by soft deletion. An application's resume must belong to its candidate, and its questionnaire must belong to its job.
- Answers must belong to the application's questionnaire. An option must belong to its question. Scalar/single-choice questions allow one answer; multiple-choice questions use one row per selected option. An answer trigger locks the parent application during validation and checks representation and cardinality. Required-question completeness is an application submission rule, not a database-wide row invariant.
- Stage results must refer to a stage of the same job as the application. Attached candidate documents must belong to that application's candidate. A joining record has a unique application and must reference an offer for that application.
- Current job/application status changes automatically append history in the same transaction. Status lookup membership is enforced; transition permissions and business workflow authorization remain for the access layer.
- Profile snapshots, resume versions, status histories, view/activity/search histories, and shortlist/bookmark histories reject UPDATE, DELETE and TRUNCATE. Bookmark/shortlist history tables exist; the application must record their events transactionally. General sensitive-action auditing is a later-phase deliverable.
- FK UPDATE and DELETE actions are RESTRICT. No cascading deletion of candidate or application history is introduced. Normal business entities use soft deletion with `deleted_at`; application queries must filter it. Append-only entities retain the shared metadata columns but cannot be soft-deleted by an ordinary update. Privileged retention/purge workflows require a later design.
- FK columns have indexes. Additional indexes cover active job filtering, application pipelines and status timelines. These are initial index choices, not measured performance claims.

## Columns, domains and defaults

The catalog-derived column inventory records each physical type, nullability, default, identity status, suggested data class and a nullability reason. The relationships and constraints inventories contain the database's actual definitions, including composite keys and CHECK constraints.

- Timestamps use TIMESTAMPTZ; calendar dates use DATE. Interviews/events retain a source time-zone name for display.
- Amounts use NUMERIC with a currency foreign key. A disclosed job salary also requires its pay period. The currency's ISO code is stored once in the currency table, instead of repeating a currency-code column beside every amount; joins resolve the code.
- Percentage completion is restricted to 0–100. Academic score scales have explicit maximum values, enforced with a composite FK. Assessment results cannot exceed the assessment's defined maximum score.
- Emails are lowercase, syntactically checked and unique per account. Phone numbers follow E.164 and have a separate country FK. Email verification and phone-country dialing consistency are outside these structural checks.
- Names are bounded VARCHAR(150); other text has explicit limits. Job descriptions are intentionally TEXT for rich job content. Profile snapshots and saved search filters are JSON objects because they store versioned snapshots/query criteria, not relational entity substitutes.
- All business tables include `created_at`, `created_by`, `updated_at`, `updated_by`, `deleted_at`. Actor keys are nullable for reference seeding/system actions; supplied actors must exist. Update triggers maintain `updated_at` for mutable tables. Deletion timestamps mean the entity is active when null.
- Optional fields remain NULL until supplied or applicable. Nullability reasons are documented per column. Unknown salary remains NULL; it is never represented by zero. Where this Phase 1 model does not distinguish unknown from not applicable, that limitation is explicit in the dictionary.
- Fixed enums use lookup tables with code, display name, active flag and sort order. Each is linked to `reference_code` for multilingual labels through `reference_translation`; the English display name is the fallback. Future enum provisioning must create/link the reference record too. Reference code and typed lookup codes are linked by ID; maintaining matching code/display text remains a reference-data administration responsibility.
- Document/resume fields contain private object references, not file contents or public download URLs. Signed access and encryption are application/storage concerns for the security phase.

Only initial lookup values, English labels and INR/USD currencies are seeded. No candidate, employer, job or application business records are retained from tests. Geography, skills, industries and qualifications await curated reference data. This is not Phase 5's laptop-scale dataset.

## Deliverables B1–B23

| Backlog | Deliverable and evidence |
| --- | --- |
| B1 | PostgreSQL provider decision and reasons above; live Neon version in validation report |
| B2 | Module scope and deferred modules above |
| B3 | Common modules assigned to Team above |
| B4–B5 | Profile entity inventory in `docs/phase1/entities.csv`; existence checked against live catalog |
| B6–B7 | Jobs and Applications entity inventory in the same file; existence checked against live catalog |
| B8–B9 | Profile relationship definitions in `docs/phase1/relationships.csv`; FK and ownership checks |
| B10–B11 | Jobs and Applications relationships in the same file; cross-job and cross-candidate rejection tests |
| B12–B13 | Profile column definitions in `docs/phase1/columns.csv`; live PostgreSQL types/defaults/nullability |
| B14–B15 | Jobs and Applications column definitions in the same file |
| B16–B17 | Combined Profile design in `migrations/001_connected_er.sql`, model above, catalog and test evidence |
| B18–B19 | Combined Jobs and Applications design in the same migration and evidence |
| B20–B21 | Profile keys/constraints in `docs/phase1/constraints.csv`; uniqueness, FK, date and immutability tests |
| B22–B23 | Jobs and Applications keys/constraints in the same file; structural validation and sign-off status below |

## Validation and sign-off

The migration was first executed together with 26 integrity checks inside a rollback-only transaction on the actual target PostgreSQL engine. An initial dry run identified a TEXT/UUID mismatch against Neon Auth; this was corrected to the catalog's UUID type. The test suite also uses PostgreSQL 18's `23001` SQLSTATE for a RESTRICT deletion. Both failed dry runs rolled back all objects.

`tests/phase1_constraints.sql` is repeatable and rolls back all fixture records. PostgreSQL identity sequences can advance during tests; no assumption of contiguous identifiers is made. It checks both a valid linked application flow and rejected duplicate, orphan, ownership, answer, money, date, score and history operations. Concurrency and load benchmarks are not claimed.

Final installation status and catalog counts are recorded in `docs/phase1/validation-report.json`. Source MCP responses for the migration and verification are saved beside it. Human team review/signature for B23 remains **pending**; automated validation is not a substitute for that signature. No human acceptance is claimed.

To reproduce in a new database with the same Neon Auth UUID user table:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f migrations/001_connected_er.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f tests/phase1_constraints.sql
```

This is a one-time baseline: rerunning it on the installed schema fails and rolls back. Do not run the old all-module draft afterward. The tests may be rerun independently. Application grants/RLS, blocked-party visibility, credential policy, retention automation and production security sign-off belong to later phases and are not represented as complete here.
