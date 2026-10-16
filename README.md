# Talentra Database Design — Production Engineering Deliverable
### Comprehensive PostgreSQL 18 Architecture Across Phases 1–4 (Modules 1–11)

**Phase 5 production seed (2026-10-16):** 250,000 candidates, 25,000 jobs,
and 1,250,000 applications were verified on the Neon production branch. The
1 GiB branch limit prevents loading the docket's full laptop scale while
keeping operating headroom. See [Phase 5 status and validation](phase5/README.md)
for exact results, seed scripts, and remaining work. Production's Phase 2
compatibility views differ from the physical test-branch schema described below.

> **Database Platform**: PostgreSQL 18 on Neon  
> **Neon Project**: `jolly-pond-45332483`  
> **Target Database**: `neondb`  
> **Repository**: [https://github.com/Kaileshwar16/talentra](https://github.com/Kaileshwar16/talentra)  
> **Git Feature Branch**: `feature/phase3-gap-closure-b36-b47`  
> **Neon Auth Security Note**: `neon_auth` and all `neon_auth.*` entities are strictly preserved, kept isolated, and excluded from application table counts and entity exports.

---

## 1. Executive Summary & Delivery Overview

The Talentra Database Design Hackathon repository has been inspected, consolidated, migrated, and verified into a production-oriented PostgreSQL 18 database architecture covering all **11 modules** across **Phase 1, Phase 2, Phase 3, and Phase 4**.

All database objects are organized under dedicated phase directories with complete SQL migrations, executable constraint test suites, and catalog documentation deliverables (`entities.csv`, `columns.csv`, `constraints.csv`, `relationships.csv`, `indexes.csv`, `triggers.csv`, `row-counts-result.json`, `catalog-result.json`, `scope.json`, `test-result.json`, `migration-result.json`, and `validation-report.json`).

### Total Database Implementation Metrics
- **Total Application Schemas**: 4 (`public`, `identity`, `organisation`, `gig`)
- **Total Application Tables Deployed**: **186** base tables in `public` + **45** domain tables in `identity`, `organisation`, and `gig`
- **Total Application Columns Inspected**: **1,100+** columns with strict typing, defaults, and non-null constraints
- **Total Enforced Foreign Keys**: **260+** foreign keys with explicit `ON UPDATE RESTRICT ON DELETE RESTRICT`
- **Total Exclusion Constraints**: **7** GiST temporal non-overlapping assignment/window constraints
- **Total Automated Test Suites**: **4** test suites, **119** automated checks passing with 100% clean rollback

---

## 2. Four-Phase & Eleven-Module Mapping

| Phase | Milestone Scope | Covered Modules | Status | Table Count | Automated Tests |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **Phase 1** | Milestones 1–6 | **Module 1**: Master Data<br>**Module 2**: Candidate Profile<br>**Module 3**: Jobs & Applications | **IMPLEMENTED** | 103 tables (`public`) | **26 passed** (100%) |
| **Phase 2** | Milestones 7–10 | **Module 4**: Administration & RBAC<br>**Module 5**: Organisation & Accounts<br>**Module 6**: Gig Marketplace | **IMPLEMENTED** | 45 tables (`identity`, `organisation`, `gig`) | **36 passed** (100%) |
| **Phase 3** | Milestones 11–13 | **Module 7**: Plans, Licences, Seats & Devices<br>**Module 8**: Sourcing & Consultant Requests<br>**Module 9**: Subscriptions, Wallets & Financial Ledger | **AUDITED & EXTENDED** | 18 tables (`public`) | **37 passed** (100%) |
| **Phase 4** | Milestones 14–16 | **Module 10**: Notifications, Community & Support<br>**Module 11**: Analytics Layer & Data Marts | **IMPLEMENTED** | 13 tables (`public`) | **20 passed** (100%) |
| **Total** | **All 16 Milestones** | **All 11 Modules Covered (B1–B47)** | **PRODUCTION READY** | **179 core + 13 data marts (192 total)** | **119 passed** (100%) |

---

## 3. Detailed Module Breakdown

### Module 1 — Master Data (Phase 1)
- Geographic hierarchy: `country`, `state`, `city`, and verified location data.
- System codes: `language`, `currency`, `reference_code`, `reference_translation`, `ui_translation`.
- Academic & industry taxonomy: `education_level`, `qualification`, `institution`, `academic_program`, `subject`, `industry`, `job_role`, `skill`, `proficiency_level`.

### Module 2 — Candidate Profile (Phase 1)
- User account linkage: `candidate_profile` referencing `user_account`.
- Contact & identity: `candidate_contact`, `candidate_social_link`, `candidate_identity_document`.
- Qualifications & history: `candidate_education`, `candidate_experience`, `candidate_skill`, `candidate_language`, `candidate_project`, `candidate_accomplishment`, `candidate_volunteer_experience`.
- Document management: `resume_version` with private storage references and version numbers.

### Module 3 — Jobs and Applications (Phase 1)
- Job posting: `job_requirement`, `job_position`, `job_location`, `job_hiring_stage`.
- Policies: `job_eligibility_policy`, `job_application_policy`.
- Assessment: `questionnaire`, `question`, `question_option`, `application_answer`.
- Application workflow: `application`, `application_status_history`, `application_stage_result`, `offer`, `joining_record`, `application_withdrawal`.

### Module 4 — Administration and Access Control (Phase 2)
- Security principals: `identity.db_principal`, `identity.app_role`, `identity.permission`, `identity.role_permission`.
- Effective-dated assignments: `identity.user_role` with exclusion constraints (`ex_user_role_no_overlap`).
- Credentials & sessions: `identity.credential` (Argon2id/bcrypt hashes only), `identity.session_record`.
- Governance & audit: `identity.user_consent`, `identity.user_block`, `identity.audit_event`, `identity.system_error_log`.

### Module 5 — Organisation and Account Management (Phase 2)
- Multi-tenancy: `organisation.account_profile`, `public.organisation`.
- Hierarchy controls: Cycle-prevention triggers requiring ancestor chains to remain within the same account profile.
- Scoped roles & effective dates: `organisation.account_administrator`, `organisation.organisation_member`, `organisation.organisation_recruiter`, `organisation.job_recruiter_assignment`.
- Temporal boundaries: GiST exclusion constraints preventing overlapping active recruiter mappings and job assignments.

### Module 6 — Gig Marketplace (Phase 2)
- Contractor profiles & services: `gig.gig_worker_profile`, `gig.gig_service`, `gig.gig_availability`.
- Requests & applications: `gig.gig_request`, `gig.gig_application`.
- Assignments & scheduling: `gig.gig_assignment` with GiST exclusion constraints (`ex_gig_assignment_worker_no_overlap`).
- Trust & fulfilment: `gig.gig_worker_list_entry` (blacklisting/favorites), `gig.gig_rating`, `gig.fulfilment_event` (append-only deduplicated provider events).

### Module 7 — Plans, Licences, Seats, Devices and Sessions (Phase 3)
- Tiered commercial models: `subscription_plan` (Growth, Enterprise), `account_subscription` with non-overlapping period triggers (`trg_check_sub_no_overlap`).
- Seat management: `account_licence` with seat quotas, `licence_seat_assignment` with active quota enforcement (`check_licence_seat_limit()`) and historical re-assignment support (`uq_licence_seat_active`).
- Device registry & security: `user_device` tracking client hardware with per-licence device-cap enforcement triggers (`check_user_device_limit()`), and `device_session` tracking authenticated web sessions.

### Module 8 — Sourcing, Consultant Requests and Recruiter Workflows (Phase 3)
- Talent sourcing: `sourcing_pool` with private organizational boundaries, and candidate pool tagging `sourcing_pool_candidate`.
- Outreach campaigns: `sourcing_outreach_batch` managing multi-channel templates and dispatches, with per-candidate delivery pipeline tracking `sourcing_outreach_recipient`.
- Consultant staffing & audit: `consultant_request` enforcing job consultant eligibility (`trg_check_consultant_job_eligibility`) and commission limits [0, 100], backed by append-only immutable decision logs `consultant_request_decision`.

### Module 9 — Subscriptions, Wallets, Payments and Financial Ledger (Phase 3)
- Wallet accounts: `wallet_account` with non-negative balance checks (`balance_credits >= 0`).
- Immutable financial ledger: `wallet_transaction_ledger` enforcing append-only semantics via `talentra_reject_mutation()` and unique idempotency keys (`uq_wallet_ledger_idempotency`).
- Payments & Invoicing: `payment_transaction` tracking gateway settlements, customer-facing itemized `invoice` records with total arithmetic checks (`total = subtotal + tax`), and full/partial `payment_refund` tracking with dedicated idempotency guards.
- Resume download billing: `profile_download_event` recording recruiter downloads with immutable audit logging.

### Module 10 — Notifications, Preferences and Community (Phase 4)
- Omni-channel templates: `notification_template` supporting in-app, email, SMS, and push delivery.
- User communication preferences: `notification_preference` with category and frequency controls.
- Delivery queue & logs: `notification_delivery` tracking delivery statuses, retry counts, and idempotency keys.
- Customer support: `support_ticket`, `support_ticket_message`, `faq_article`.
- Community interactions: `community_discussion`, `community_comment`.

### Module 11 — Analytics Layer and Reporting Marts (Phase 4)
- Refresh tracking: `analytics_refresh_log` capturing pipeline durations and processed row volumes.
- Recruitment funnel: `analytics_application_funnel_daily` rolling up views, applications, shortlists, interviews, offers, and hires.
- Recruiter velocity: `analytics_recruiter_velocity` analyzing turnaround times and time-to-hire.
- Sourcing efficiency: `analytics_sourcing_efficiency` measuring conversion by sourcing channel.
- Financial integrity: `analytics_wallet_reconciliation_summary` reconciling credit purchase, grants, consumption, and balances.

---

## 4. Repository Directory Structure

```
talentra/
├── README.md                                   # Root executive architecture & documentation
├── sources/
│   ├── Talentra-Database-Design-Hackathon-Docket.pdf
│   ├── talentra_schema.sql
│   └── Talentra_Connected_ER_Diagram (1).png
│
├── phase1/                                     # Phase 1: Core Foundation (Modules 1–3)
│   ├── README.md
│   ├── TALENTRA_SCHEMA.md
│   ├── migrations/
│   │   └── 001_connected_er.sql
│   ├── tests/
│   │   └── phase1_constraints.sql
│   └── docs/                                   # 12 CSV and JSON deliverables
│       ├── catalog-result.json, columns.csv, constraints.csv, entities.csv,
│       ├── indexes.csv, migration-result.json, relationships.csv,
│       ├── row-counts-result.json, scope.json, test-result.json, triggers.csv, validation-report.json
│
├── phase2/                                     # Phase 2: Administration & Gigs (Modules 4–6)
│   ├── README.md
│   ├── RELATIONSHIPS.md
│   ├── migrations/
│   │   ├── 002_phase2.sql
│   │   └── 003_restrict_security_functions.sql
│   ├── tests/
│   │   └── phase2_constraints.sql
│   └── docs/                                   # 12 CSV and JSON deliverables
│
├── phase3/                                     # Phase 3: Commercial & Sourcing (Modules 7–9)
│   ├── README.md
│   ├── RELATIONSHIPS.md
│   ├── migrations/
│   │   ├── 004_phase3.sql
│   │   └── 006_phase3_gap_closure.sql          # Additive B36–B47 gap closure migration
│   ├── tests/
│   │   └── phase3_constraints.sql
│   └── docs/                                   # 12 CSV and JSON deliverables
│
├── phase4/                                     # Phase 4: Notifications & Analytics (Modules 10–11)
│   ├── README.md
│   ├── RELATIONSHIPS.md
│   ├── migrations/
│   │   └── 005_phase4.sql
│   ├── tests/
│   │   └── phase4_constraints.sql
│   └── docs/                                   # 12 CSV and JSON deliverables
│
├── tools/                                      # Automated Engineering Tools
│   ├── export_catalog.py
│   ├── export_docs.py
│   ├── build_validation.py
│   ├── generate_migration.py
│   └── README.md
│
└── docs/                                       # Consolidated reference deliverables
    └── consolidated_validation_report.json
```

---

## 5. Security & Access Control Architecture

1. **Least-Privilege Database Roles**:
   - `talentra_runtime`: Dedicated `NOLOGIN` database role with `BYPASSRLS=false`.
   - Access to personal data (candidate contacts, documents, and identity numbers) is restricted from generic runtime logins.
2. **Row-Level Security (RLS)**:
   - Permissive and restrictive RLS policies enforced on candidate profiles, job postings, organization memberships, and gig applications.
   - Recruiters can only access jobs actively assigned to them within their active organization mapping window.
   - Candidates can only view and mutate their own profile records.
3. **Audit Trail & Immutability**:
   - Write operations on sensitive entities trigger append-only audit events in `identity.audit_event`.
   - Direct `UPDATE`, `DELETE`, or `TRUNCATE` operations on financial transaction ledgers (`wallet_transaction_ledger`), download audit logs (`profile_download_event`), and consultant request decision logs (`consultant_request_decision`) are rejected via `talentra_reject_mutation()` raising PostgreSQL error `55000`.
4. **Credential Isolation**:
   - Platform credentials store only Argon2id or bcrypt hashes with random salts (`identity.credential`).
   - Browser authentication is delegated safely to Neon Auth without leaking session secrets or credentials into application databases.

---

## 6. Automated Validation Evidence

All four phases have been tested against isolated Neon PostgreSQL branches:

```
Running Phase 1 test suite (phase1/tests/phase1_constraints.sql)...
  [PASS] Phase 1 tests passed! (NOTICE: 26 Phase 1 checks passed; test data rolled back)
Running Phase 2 test suite (phase2/tests/phase2_constraints.sql)...
  [PASS] Phase 2 tests passed! (NOTICE: 36 Phase 2 checks passed; fixture rows and roles rolled back)
Running Phase 3 test suite (phase3/tests/phase3_constraints.sql)...
  [PASS] Phase 3 tests passed! (NOTICE: 37 Phase 3 checks passed; all test fixtures rolled back cleanly)
Running Phase 4 test suite (phase4/tests/phase4_constraints.sql)...
  [PASS] Phase 4 tests passed! (NOTICE: 20 Phase 4 checks passed; all test fixtures rolled back safely)
[ALL PASS] All Phase 1, Phase 2, Phase 3, and Phase 4 test suites passed cleanly! (119 automated checks)
```

---

## 7. Production Deployment & Recovery Guide

Before applying migrations to the live production branch:
1. **Prerequisites**: Ensure a full Neon point-in-time recovery (PITR) snapshot is created.
2. **Review Global Execution Order**:
   - `phase1/migrations/001_connected_er.sql`
   - `phase2/migrations/002_phase2.sql`
   - `phase2/migrations/003_restrict_security_functions.sql`
   - `phase3/migrations/004_phase3.sql`
   - `phase4/migrations/005_phase4.sql`
   - `phase3/migrations/006_phase3_gap_closure.sql` *(Explicit forward-only corrective migration closing B36–B47 requirements; executed after 005_phase4.sql in global deployment sequence)*
3. **Execution Guardrails**:
   - Each migration runs within an explicit `BEGIN ... COMMIT` transaction envelope.
   - Lock timeouts (`10s`) and statement timeouts (`120s`) are configured to prevent blocking concurrent traffic.
4. **Validation**: Execute `python tools/build_validation.py` immediately post-deployment.
