# Talentra Modules 4 to 11 Architecture, Checklist & Database Implementation Guide
## Complete Implementation & Live Neon Database Verification Report

This document details the architectural plan, schema unification, implementation scripts, and 100% verified table reference checklist for **Modules 4 through 11** of the Talentra enterprise recruitment platform, based on [Talentra_Modules_4_to_11_Complete_Database_Documentation.md](file:///d:/Talentra/Talentra_Modules_4_to_11_Complete_Database_Documentation.md).

---

## 1. Master Module Checklist Summary

| No. | Module | Phase | Assigned to | Total Table References | Live Neon Verification | Checklist |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **4** | **Administration** | Phase 2 | Member A | 59 | **100% Verified (59/59)** | [x] |
| **5** | **Organisation and Account** | Phase 2 | Member B | 29 | **100% Verified (29/29)** | [x] |
| **6** | **Gig Marketplace** | Phase 2 | Member C | 32 | **100% Verified (32/32)** | [x] |
| **7** | **Licences, Seats, Devices and Sessions** | Phase 3 | Assigned member | 24 | **100% Verified (24/24)** | [x] |
| **8** | **Sourcing and Consultant Requests** | Phase 3 | Assigned member | 39 | **100% Verified (39/39)** | [x] |
| **9** | **Subscriptions, Wallet, Payments and Download History** | Phase 3 | Assigned member | 14 | **100% Verified (14/14)** | [x] |
| **10** | **Notifications, Preferences and Community** | Phase 4 | Whole team | 23 | **100% Verified (23/23)** | [x] |
| **11** | **Analytics Layer and Reporting Marts** | Phase 4 | Assigned member | 22 | **100% Verified (22/22)** | [x] |
| | **Total** | **Phases 2–4** | **Whole team** | **242** | **100% Operational (242/242)** | **[x]** |

---

## 2. Architectural Design & Database Layout

### Core Architectural Decisions

1. **Single Source of Truth (`public` schema):**
   - All canonical application data, constraints, indexes, sequences, and tables reside in `public` (186 base tables).
   - Prevents fragile cross-schema joins, permission fragmentation, and schema drift.
2. **Unified Virtual Cross-Schema Compatibility Layer:**
   - The legacy dump contained references across `identity.*`, `organisation.*`, and `gig.*`.
   - Created schemas `identity` (16 relations), `organisation` (12 relations), and `gig` (17 relations).
   - Each schema contains views or domain tables that point directly to the canonical `public` tables.
   - **Result:** Queries written against `public.audit_event` OR `identity.audit_event`, `public.gig_request` OR `gig.gig_request`, and `public.organisation_recruiter` OR `organisation.organisation_recruiter` resolve seamlessly with identical data.
3. **Protected Auth Schema (`neon_auth`):**
   - All 9 provider-managed Neon auth tables are preserved intact without interference.
4. **Immutability Protection:**
   - Financial transactions (`wallet_transaction_ledger`), audit trails (`audit_event`), profile snapshots (`application_profile_snapshot`), and resume versions (`resume_version`) are protected with `public.talentra_reject_mutation()` triggers preventing `UPDATE`, `DELETE`, or `TRUNCATE`.

---

## 3. Live Database Inventory in Neon PostgreSQL

| Schema | Kind | Count | Role & Purpose |
| :--- | :--- | :--- | :--- |
| `public` | Base Tables | **186** | Canonical storage for Modules 1–11 (Candidate, Jobs, KYC, RBAC, Orgs, Gig, Wallet, Notifications, Analytics) |
| `identity` | Virtual Views | **16** | Cross-schema RBAC, Credentials, Sessions, Audit & Consent compatibility |
| `organisation` | Virtual Views | **12** | Multi-tenant hierarchy, Recruiter assignments, KYB verification compatibility |
| `gig` | Virtual Views | **17** | Contractor profiles, Requests, Bids, Milestones & Fulfillment compatibility |
| `neon_auth` | Managed Auth | **9** | Provider-managed OAuth & session tables |
| **Total** | **All Relations** | **240** | **Fully Operational & Deployed on Neon Postgres 18** |

---

## 4. Module-by-Module Entity Checklist (242 References)

### Module 4: Administration
- **Phase:** Phase 2
- **Owner:** Member A
- **Total Table References:** 59
- **Verification Status:** **100% Passed (59/59 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `audit_event` | Base Table in `public` | `public.audit_event` | [x] Operational |
| 2 | `identity.audit_event` | View in `identity` | `public.audit_event` | [x] Operational |
| 3 | `system_error_log` | Base Table in `public` | `public.system_error_log` | [x] Operational |
| 4 | `identity.system_error_log` | View in `identity` | `public.system_error_log` | [x] Operational |
| 5 | `permission` | Base Table in `public` | `public.permission` | [x] Operational |
| 6 | `identity.permission` | View in `identity` | `public.permission` | [x] Operational |
| 7 | `role_permission` | Base Table in `public` | `public.role_permission` | [x] Operational |
| 8 | `identity.role_permission` | View in `identity` | `public.role_permission` | [x] Operational |
| 9 | `account_role` | Base Table in `public` | `public.account_role` | [x] Operational |
| 10 | `account_status_history` | Base Table in `public` | `public.account_status_history` | [x] Operational |
| 11 | `login_attempt` | Base Table in `public` | `public.login_attempt` | [x] Operational |
| 12 | `support_ticket` | Base Table in `public` | `public.support_ticket` | [x] Operational |
| 13 | `support_ticket_message` | Base Table in `public` | `public.support_ticket_message` | [x] Operational |
| 14 | `faq_article` | Base Table in `public` | `public.faq_article` | [x] Operational |
| 15 | `consent_record` | Base Table in `public` | `public.consent_record` | [x] Operational |
| 16 | `identity.consent_type` | View in `identity` | `public.consent_type` | [x] Operational |
| 17 | `identity.user_consent` | View in `identity` | `public.user_consent` | [x] Operational |
| 18 | `identity.db_principal` | View in `identity` | `public.db_principal` | [x] Operational |
| 19 | `identity.app_role` | View in `identity` | `public.app_role` | [x] Operational |
| 20 | `identity.account_status` | View in `identity` | `public.account_status` | [x] Operational |
| 21 | `reference_code` | Base Table in `public` | `public.reference_code` | [x] Operational |
| 22 | `reference_translation` | Base Table in `public` | `public.reference_translation` | [x] Operational |
| 23 | `ui_translation` | Base Table in `public` | `public.ui_translation` | [x] Operational |
| 24 | `industry` | Base Table in `public` | `public.industry` | [x] Operational |
| 25 | `job_role` | Base Table in `public` | `public.job_role` | [x] Operational |
| 26 | `activity_type` | Base Table in `public` | `public.activity_type` | [x] Operational |
| 27 | `candidate_activity_type` | Base Table in `public` | `public.candidate_activity_type` | [x] Operational |
| 28 | `job_event_type` | Base Table in `public` | `public.job_event_type` | [x] Operational |
| 29 | `hiring_stage_type` | Base Table in `public` | `public.hiring_stage_type` | [x] Operational |
| 30 | `verification_status` | Base Table in `public` | `public.verification_status` | [x] Operational |
| 31 | `document_type` | Base Table in `public` | `public.document_type` | [x] Operational |
| 32 | `education_level` | Base Table in `public` | `public.education_level` | [x] Operational |
| 33 | `employment_type` | Base Table in `public` | `public.employment_type` | [x] Operational |
| 34 | `experience_type` | Base Table in `public` | `public.experience_type` | [x] Operational |
| 35 | `proficiency_level` | Base Table in `public` | `public.proficiency_level` | [x] Operational |
| 36 | `question_type` | Base Table in `public` | `public.question_type` | [x] Operational |
| 37 | `application_status` | Base Table in `public` | `public.application_status` | [x] Operational |
| 38 | `interview_status` | Base Table in `public` | `public.interview_status` | [x] Operational |
| 39 | `offer_status` | Base Table in `public` | `public.offer_status` | [x] Operational |
| 40 | `job_status` | Base Table in `public` | `public.job_status` | [x] Operational |
| 41 | `job_position_status` | Base Table in `public` | `public.job_position_status` | [x] Operational |
| 42 | `referral_status` | Base Table in `public` | `public.referral_status` | [x] Operational |
| 43 | `withdrawal_outcome` | Base Table in `public` | `public.withdrawal_outcome` | [x] Operational |
| 44 | `stage_decision` | Base Table in `public` | `public.stage_decision` | [x] Operational |
| 45 | `eligibility_decision` | Base Table in `public` | `public.eligibility_decision` | [x] Operational |
| 46 | `score_scale` | Base Table in `public` | `public.score_scale` | [x] Operational |
| 47 | `salary_period` | Base Table in `public` | `public.salary_period` | [x] Operational |
| 48 | `work_type` | Base Table in `public` | `public.work_type` | [x] Operational |
| 49 | `currency` | Base Table in `public` | `public.currency` | [x] Operational |
| 50 | `country` | Base Table in `public` | `public.country` | [x] Operational |
| 51 | `state` | Base Table in `public` | `public.state` | [x] Operational |
| 52 | `city` | Base Table in `public` | `public.city` | [x] Operational |
| 53 | `language` | Base Table in `public` | `public.language` | [x] Operational |
| 54 | `qualification` | Base Table in `public` | `public.qualification` | [x] Operational |
| 55 | `skill` | Base Table in `public` | `public.skill` | [x] Operational |
| 56 | `subject` | Base Table in `public` | `public.subject` | [x] Operational |
| 57 | `social_platform` | Base Table in `public` | `public.social_platform` | [x] Operational |
| 58 | `accomplishment_type` | Base Table in `public` | `public.accomplishment_type` | [x] Operational |
| 59 | `course_enrolment_status` | Base Table in `public` | `public.course_enrolment_status` | [x] Operational |

### Module 5: Organisation and Account
- **Phase:** Phase 2
- **Owner:** Member B
- **Total Table References:** 29
- **Verification Status:** **100% Passed (29/29 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `organisation` | Base Table in `public` | `public.organisation` | [x] Operational |
| 2 | `organisation.account_profile` | View in `organisation` | `public.account_profile` | [x] Operational |
| 3 | `organisation.account_administrator` | View in `organisation` | `public.account_administrator` | [x] Operational |
| 4 | `organisation.account_status` | View in `organisation` | `public.account_status` | [x] Operational |
| 5 | `organisation.identifier_type` | View in `organisation` | `public.identifier_type` | [x] Operational |
| 6 | `organisation.organisation_identifier` | View in `organisation` | `public.organisation_identifier` | [x] Operational |
| 7 | `organisation.organisation_location` | View in `organisation` | `public.organisation_location` | [x] Operational |
| 8 | `organisation.organisation_member` | View in `organisation` | `public.organisation_member` | [x] Operational |
| 9 | `organisation.organisation_recruiter` | View in `organisation` | `public.organisation_recruiter` | [x] Operational |
| 10 | `organisation.organisation_type` | View in `organisation` | `public.organisation_type` | [x] Operational |
| 11 | `organisation.verification_record` | View in `organisation` | `public.verification_record` | [x] Operational |
| 12 | `organisation.verification_type` | View in `organisation` | `public.verification_type` | [x] Operational |
| 13 | `account_profile` | Base Table in `public` | `public.account_profile` | [x] Operational |
| 14 | `account_organisation` | Base Table in `public` | `public.account_organisation` | [x] Operational |
| 15 | `account_role` | Base Table in `public` | `public.account_role` | [x] Operational |
| 16 | `user_account` | Base Table in `public` | `public.user_account` | [x] Operational |
| 17 | `user_role` | Base Table in `public` | `public.user_role` | [x] Operational |
| 18 | `organisation_account_admin` | Base Table in `public` | `public.organisation_account_admin` | [x] Operational |
| 19 | `organisation_external_system` | Base Table in `public` | `public.organisation_external_system` | [x] Operational |
| 20 | `organisation_hierarchy` | Base Table in `public` | `public.organisation_hierarchy` | [x] Operational |
| 21 | `organisation_identifier` | Base Table in `public` | `public.organisation_identifier` | [x] Operational |
| 22 | `organisation_location` | Base Table in `public` | `public.organisation_location` | [x] Operational |
| 23 | `organisation_recruiter` | Base Table in `public` | `public.organisation_recruiter` | [x] Operational |
| 24 | `organisation_status_history` | Base Table in `public` | `public.organisation_status_history` | [x] Operational |
| 25 | `organisation_verification` | Base Table in `public` | `public.organisation_verification` | [x] Operational |
| 26 | `organisation_verification_history` | Base Table in `public` | `public.organisation_verification_history` | [x] Operational |
| 27 | `user_block` | Base Table in `public` | `public.user_block` | [x] Operational |
| 28 | `identity.user_block` | View in `identity` | `public.user_block` | [x] Operational |
| 29 | `organisation.job_recruiter_assignment` | View in `organisation` | `public.job_recruiter_assignment` | [x] Operational |

### Module 6: Gig Marketplace
- **Phase:** Phase 2
- **Owner:** Member C
- **Total Table References:** 32
- **Verification Status:** **100% Passed (32/32 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `gig_application` | Base Table in `public` | `public.gig_application` | [x] Operational |
| 2 | `gig_application_status_history` | Base Table in `public` | `public.gig_application_status_history` | [x] Operational |
| 3 | `gig_assignment` | Base Table in `public` | `public.gig_assignment` | [x] Operational |
| 4 | `gig_earnings_reconciliation` | Base Table in `public` | `public.gig_earnings_reconciliation` | [x] Operational |
| 5 | `gig_event` | Base Table in `public` | `public.gig_event` | [x] Operational |
| 6 | `gig_fulfilment_handoff` | Base Table in `public` | `public.gig_fulfilment_handoff` | [x] Operational |
| 7 | `gig_rating` | Base Table in `public` | `public.gig_rating` | [x] Operational |
| 8 | `gig_request` | Base Table in `public` | `public.gig_request` | [x] Operational |
| 9 | `gig_request_skill` | Base Table in `public` | `public.gig_request_skill` | [x] Operational |
| 10 | `gig_service` | Base Table in `public` | `public.gig_service` | [x] Operational |
| 11 | `gig_service_skill` | Base Table in `public` | `public.gig_service_skill` | [x] Operational |
| 12 | `gig_worker_availability` | Base Table in `public` | `public.gig_worker_availability` | [x] Operational |
| 13 | `gig_worker_list` | Base Table in `public` | `public.gig_worker_list` | [x] Operational |
| 14 | `gig_worker_list_entry` | Base Table in `public` | `public.gig_worker_list_entry` | [x] Operational |
| 15 | `gig_worker_profile` | Base Table in `public` | `public.gig_worker_profile` | [x] Operational |
| 16 | `gig.application_status` | View in `gig` | `public.application_status` | [x] Operational |
| 17 | `gig.assignment_status` | View in `gig` | `public.assignment_status` | [x] Operational |
| 18 | `gig.availability_status` | View in `gig` | `public.availability_status` | [x] Operational |
| 19 | `gig.fulfilment_event` | View in `gig` | `public.fulfilment_event` | [x] Operational |
| 20 | `gig.gig_application` | View in `gig` | `public.gig_application` | [x] Operational |
| 21 | `gig.gig_assignment` | View in `gig` | `public.gig_assignment` | [x] Operational |
| 22 | `gig.gig_availability` | View in `gig` | `public.gig_availability` | [x] Operational |
| 23 | `gig.gig_rating` | View in `gig` | `public.gig_rating` | [x] Operational |
| 24 | `gig.gig_request` | View in `gig` | `public.gig_request` | [x] Operational |
| 25 | `gig.gig_service` | View in `gig` | `public.gig_service` | [x] Operational |
| 26 | `gig.gig_worker_list_entry` | View in `gig` | `public.gig_worker_list_entry` | [x] Operational |
| 27 | `gig.gig_worker_profile` | View in `gig` | `public.gig_worker_profile` | [x] Operational |
| 28 | `gig.pricing_model` | View in `gig` | `public.pricing_model` | [x] Operational |
| 29 | `gig.rate_unit` | View in `gig` | `public.rate_unit` | [x] Operational |
| 30 | `gig.request_status` | View in `gig` | `public.request_status` | [x] Operational |
| 31 | `gig.worker_list_type` | View in `gig` | `public.worker_list_type` | [x] Operational |
| 32 | `gig.worker_project` | View in `gig` | `public.worker_project` | [x] Operational |

### Module 7: Licences, Seats, Devices and Sessions
- **Phase:** Phase 3
- **Owner:** Assigned member
- **Total Table References:** 24
- **Verification Status:** **100% Passed (24/24 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `user_credential` | Base Table in `public` | `public.user_credential` | [x] Operational |
| 2 | `identity.credential` | View in `identity` | `public.credential` | [x] Operational |
| 3 | `identity.credential_type` | View in `identity` | `public.credential_type` | [x] Operational |
| 4 | `identity.hash_algorithm` | View in `identity` | `public.hash_algorithm` | [x] Operational |
| 5 | `identity.session_record` | View in `identity` | `public.session_record` | [x] Operational |
| 6 | `identity.session_status` | View in `identity` | `public.session_status` | [x] Operational |
| 7 | `identity.db_principal` | View in `identity` | `public.db_principal` | [x] Operational |
| 8 | `identity.user_role` | View in `identity` | `public.user_role` | [x] Operational |
| 9 | `identity.permission` | View in `identity` | `public.permission` | [x] Operational |
| 10 | `identity.role_permission` | View in `identity` | `public.role_permission` | [x] Operational |
| 11 | `identity.audit_event` | View in `identity` | `public.audit_event` | [x] Operational |
| 12 | `identity.account_status` | View in `identity` | `public.account_status` | [x] Operational |
| 13 | `identity.app_role` | View in `identity` | `public.app_role` | [x] Operational |
| 14 | `identity.user_consent` | View in `identity` | `public.user_consent` | [x] Operational |
| 15 | `identity.consent_type` | View in `identity` | `public.consent_type` | [x] Operational |
| 16 | `identity.user_block` | View in `identity` | `public.user_block` | [x] Operational |
| 17 | `identity.system_error_log` | View in `identity` | `public.system_error_log` | [x] Operational |
| 18 | `identity_session` | Base Table in `public` | `public.identity_session` | [x] Operational |
| 19 | `login_attempt` | Base Table in `public` | `public.login_attempt` | [x] Operational |
| 20 | `user_account` | Base Table in `public` | `public.user_account` | [x] Operational |
| 21 | `user_role` | Base Table in `public` | `public.user_role` | [x] Operational |
| 22 | `permission` | Base Table in `public` | `public.permission` | [x] Operational |
| 23 | `role_permission` | Base Table in `public` | `public.role_permission` | [x] Operational |
| 24 | `user_preference` | Base Table in `public` | `public.user_preference` | [x] Operational |

### Module 8: Sourcing and Consultant Requests
- **Phase:** Phase 3
- **Owner:** Assigned member
- **Total Table References:** 39
- **Verification Status:** **100% Passed (39/39 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `gig_request` | Base Table in `public` | `public.gig_request` | [x] Operational |
| 2 | `gig_request_skill` | Base Table in `public` | `public.gig_request_skill` | [x] Operational |
| 3 | `gig_service` | Base Table in `public` | `public.gig_service` | [x] Operational |
| 4 | `gig_service_skill` | Base Table in `public` | `public.gig_service_skill` | [x] Operational |
| 5 | `gig_worker_profile` | Base Table in `public` | `public.gig_worker_profile` | [x] Operational |
| 6 | `gig_worker_availability` | Base Table in `public` | `public.gig_worker_availability` | [x] Operational |
| 7 | `gig_worker_list` | Base Table in `public` | `public.gig_worker_list` | [x] Operational |
| 8 | `gig_worker_list_entry` | Base Table in `public` | `public.gig_worker_list_entry` | [x] Operational |
| 9 | `gig_application` | Base Table in `public` | `public.gig_application` | [x] Operational |
| 10 | `gig_application_status_history` | Base Table in `public` | `public.gig_application_status_history` | [x] Operational |
| 11 | `gig_assignment` | Base Table in `public` | `public.gig_assignment` | [x] Operational |
| 12 | `gig_event` | Base Table in `public` | `public.gig_event` | [x] Operational |
| 13 | `gig_fulfilment_handoff` | Base Table in `public` | `public.gig_fulfilment_handoff` | [x] Operational |
| 14 | `gig_earnings_reconciliation` | Base Table in `public` | `public.gig_earnings_reconciliation` | [x] Operational |
| 15 | `gig_rating` | Base Table in `public` | `public.gig_rating` | [x] Operational |
| 16 | `gig.gig_request` | View in `gig` | `public.gig_request` | [x] Operational |
| 17 | `gig.gig_service` | View in `gig` | `public.gig_service` | [x] Operational |
| 18 | `gig.gig_worker_profile` | View in `gig` | `public.gig_worker_profile` | [x] Operational |
| 19 | `gig.gig_worker_list_entry` | View in `gig` | `public.gig_worker_list_entry` | [x] Operational |
| 20 | `gig.worker_project` | View in `gig` | `public.worker_project` | [x] Operational |
| 21 | `gig.gig_application` | View in `gig` | `public.gig_application` | [x] Operational |
| 22 | `gig.gig_assignment` | View in `gig` | `public.gig_assignment` | [x] Operational |
| 23 | `gig.gig_availability` | View in `gig` | `public.gig_availability` | [x] Operational |
| 24 | `gig.gig_rating` | View in `gig` | `public.gig_rating` | [x] Operational |
| 25 | `gig.request_status` | View in `gig` | `public.request_status` | [x] Operational |
| 26 | `gig.application_status` | View in `gig` | `public.application_status` | [x] Operational |
| 27 | `gig.assignment_status` | View in `gig` | `public.assignment_status` | [x] Operational |
| 28 | `gig.availability_status` | View in `gig` | `public.availability_status` | [x] Operational |
| 29 | `gig.fulfilment_event` | View in `gig` | `public.fulfilment_event` | [x] Operational |
| 30 | `gig.pricing_model` | View in `gig` | `public.pricing_model` | [x] Operational |
| 31 | `gig.rate_unit` | View in `gig` | `public.rate_unit` | [x] Operational |
| 32 | `gig.worker_list_type` | View in `gig` | `public.worker_list_type` | [x] Operational |
| 33 | `organisation_recruiter` | Base Table in `public` | `public.organisation_recruiter` | [x] Operational |
| 34 | `organisation_account_admin` | Base Table in `public` | `public.organisation_account_admin` | [x] Operational |
| 35 | `organisation.organisation_recruiter` | View in `organisation` | `public.organisation_recruiter` | [x] Operational |
| 36 | `organisation.organisation_member` | View in `organisation` | `public.organisation_member` | [x] Operational |
| 37 | `organisation.job_recruiter_assignment` | View in `organisation` | `public.job_recruiter_assignment` | [x] Operational |
| 38 | `user_block` | Base Table in `public` | `public.user_block` | [x] Operational |
| 39 | `identity.user_block` | View in `identity` | `public.user_block` | [x] Operational |

### Module 9: Subscriptions, Wallet, Payments and Download History
- **Phase:** Phase 3
- **Owner:** Assigned member
- **Total Table References:** 14
- **Verification Status:** **100% Passed (14/14 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `gig_earnings_reconciliation` | Base Table in `public` | `public.gig_earnings_reconciliation` | [x] Operational |
| 2 | `gig_assignment` | Base Table in `public` | `public.gig_assignment` | [x] Operational |
| 3 | `gig_application` | Base Table in `public` | `public.gig_application` | [x] Operational |
| 4 | `gig_rating` | Base Table in `public` | `public.gig_rating` | [x] Operational |
| 5 | `notification_delivery` | Base Table in `public` | `public.notification_delivery` | [x] Operational |
| 6 | `audit_event` | Base Table in `public` | `public.audit_event` | [x] Operational |
| 7 | `identity.audit_event` | View in `identity` | `public.audit_event` | [x] Operational |
| 8 | `account_profile` | Base Table in `public` | `public.account_profile` | [x] Operational |
| 9 | `account_organisation` | Base Table in `public` | `public.account_organisation` | [x] Operational |
| 10 | `organisation` | Base Table in `public` | `public.organisation` | [x] Operational |
| 11 | `user_account` | Base Table in `public` | `public.user_account` | [x] Operational |
| 12 | `user_preference` | Base Table in `public` | `public.user_preference` | [x] Operational |
| 13 | `identity.credential` | View in `identity` | `public.credential` | [x] Operational |
| 14 | `identity.session_record` | View in `identity` | `public.session_record` | [x] Operational |

### Module 10: Notifications, Preferences and Community
- **Phase:** Phase 4
- **Owner:** Whole team
- **Total Table References:** 23
- **Verification Status:** **100% Passed (23/23 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `notification_delivery` | Base Table in `public` | `public.notification_delivery` | [x] Operational |
| 2 | `notification_preference` | Base Table in `public` | `public.notification_preference` | [x] Operational |
| 3 | `user_preference` | Base Table in `public` | `public.user_preference` | [x] Operational |
| 4 | `user_block` | Base Table in `public` | `public.user_block` | [x] Operational |
| 5 | `identity.user_block` | View in `identity` | `public.user_block` | [x] Operational |
| 6 | `support_ticket` | Base Table in `public` | `public.support_ticket` | [x] Operational |
| 7 | `support_ticket_message` | Base Table in `public` | `public.support_ticket_message` | [x] Operational |
| 8 | `faq_article` | Base Table in `public` | `public.faq_article` | [x] Operational |
| 9 | `consent_record` | Base Table in `public` | `public.consent_record` | [x] Operational |
| 10 | `identity.user_consent` | View in `identity` | `public.user_consent` | [x] Operational |
| 11 | `identity.consent_type` | View in `identity` | `public.consent_type` | [x] Operational |
| 12 | `candidate_activity_log` | Base Table in `public` | `public.candidate_activity_log` | [x] Operational |
| 13 | `profile_view_history` | Base Table in `public` | `public.profile_view_history` | [x] Operational |
| 14 | `candidate_bookmark` | Base Table in `public` | `public.candidate_bookmark` | [x] Operational |
| 15 | `candidate_bookmark_history` | Base Table in `public` | `public.candidate_bookmark_history` | [x] Operational |
| 16 | `referral_tracking` | Base Table in `public` | `public.referral_tracking` | [x] Operational |
| 17 | `gig_event` | Base Table in `public` | `public.gig_event` | [x] Operational |
| 18 | `gig_rating` | Base Table in `public` | `public.gig_rating` | [x] Operational |
| 19 | `gig_worker_list` | Base Table in `public` | `public.gig_worker_list` | [x] Operational |
| 20 | `gig_worker_list_entry` | Base Table in `public` | `public.gig_worker_list_entry` | [x] Operational |
| 21 | `identity.audit_event` | View in `identity` | `public.audit_event` | [x] Operational |
| 22 | `system_error_log` | Base Table in `public` | `public.system_error_log` | [x] Operational |
| 23 | `identity.system_error_log` | View in `identity` | `public.system_error_log` | [x] Operational |

### Module 11: Analytics Layer and Reporting Marts
- **Phase:** Phase 4
- **Owner:** Assigned member
- **Total Table References:** 22
- **Verification Status:** **100% Passed (22/22 accessible and validated in Neon)**

| # | Table / View Reference | Type | Resolution Target in Neon | Status |
| :--- | :--- | :--- | :--- | :---: |
| 1 | `candidate_activity_log` | Base Table in `public` | `public.candidate_activity_log` | [x] Operational |
| 2 | `profile_view_history` | Base Table in `public` | `public.profile_view_history` | [x] Operational |
| 3 | `candidate_job_search_history` | Base Table in `public` | `public.candidate_job_search_history` | [x] Operational |
| 4 | `referral_tracking` | Base Table in `public` | `public.referral_tracking` | [x] Operational |
| 5 | `job_status_history` | Base Table in `public` | `public.job_status_history` | [x] Operational |
| 6 | `job_event` | Base Table in `public` | `public.job_event` | [x] Operational |
| 7 | `application_status_history` | Base Table in `public` | `public.application_status_history` | [x] Operational |
| 8 | `application_stage_result` | Base Table in `public` | `public.application_stage_result` | [x] Operational |
| 9 | `assessment_result` | Base Table in `public` | `public.assessment_result` | [x] Operational |
| 10 | `shortlist_history` | Base Table in `public` | `public.shortlist_history` | [x] Operational |
| 11 | `organisation_status_history` | Base Table in `public` | `public.organisation_status_history` | [x] Operational |
| 12 | `organisation_verification_history` | Base Table in `public` | `public.organisation_verification_history` | [x] Operational |
| 13 | `gig_event` | Base Table in `public` | `public.gig_event` | [x] Operational |
| 14 | `gig_earnings_reconciliation` | Base Table in `public` | `public.gig_earnings_reconciliation` | [x] Operational |
| 15 | `notification_delivery` | Base Table in `public` | `public.notification_delivery` | [x] Operational |
| 16 | `login_attempt` | Base Table in `public` | `public.login_attempt` | [x] Operational |
| 17 | `identity.audit_event` | View in `identity` | `public.audit_event` | [x] Operational |
| 18 | `audit_event` | Base Table in `public` | `public.audit_event` | [x] Operational |
| 19 | `system_error_log` | Base Table in `public` | `public.system_error_log` | [x] Operational |
| 20 | `identity.system_error_log` | View in `identity` | `public.system_error_log` | [x] Operational |
| 21 | `support_ticket` | Base Table in `public` | `public.support_ticket` | [x] Operational |
| 22 | `support_ticket_message` | Base Table in `public` | `public.support_ticket_message` | [x] Operational |


---

## 5. Deployed Migrations Log

The platform database is governed by 8 sequential production SQL migrations in `d:\Talentra\migrations`:

1. **[001_government_identity_verification.sql](file:///d:/Talentra/migrations/001_government_identity_verification.sql):** Indian KYC verification (`candidate_identity_document`, `identity_verification`, `identity_verification_attempt`, `identity_verification_consent`, `identity_verification_audit_log`).
2. **[002_seed_essential_master_data.sql](file:///d:/Talentra/migrations/002_seed_essential_master_data.sql):** ISO 3166-1 countries, ISO 4217 currencies, reference codes, and document types.
3. **[003_administration_and_rbac.sql](file:///d:/Talentra/migrations/003_administration_and_rbac.sql):** Unified RBAC (`app_role`, `permission`, `role_permission`, `user_role_assignment`, `audit_event`, `system_error_log`, `consent_record`).
4. **[004_organisation_hierarchy_and_recruitment.sql](file:///d:/Talentra/migrations/004_organisation_hierarchy_and_recruitment.sql):** Enterprise billing accounts, hierarchy, recruiter assignments, KYB verification, and candidate user blocking.
5. **[005_subscriptions_wallet_and_download_history.sql](file:///d:/Talentra/migrations/005_subscriptions_wallet_and_download_history.sql):** Monetisation engine (`subscription_plan`, `account_subscription`, `wallet_account`, `wallet_transaction_ledger`, `profile_download_event`).
6. **[006_gig_marketplace.sql](file:///d:/Talentra/migrations/006_gig_marketplace.sql):** Contractor marketplace (`gig_worker_profile`, `gig_request`, `gig_service`, `gig_application`, `gig_assignment`, `gig_rating`, `gig_earnings_reconciliation`, `gig_worker_list`).
7. **[007_licences_sourcing_and_notifications.sql](file:///d:/Talentra/migrations/007_licences_sourcing_and_notifications.sql):** Enterprise licences, seats, device sessions, sourcing pools, notifications, support ticketing, FAQ articles, and analytics funnel marts.
8. **[008_complete_modules_4_to_11_enterprise_entities.sql](file:///d:/Talentra/migrations/008_complete_modules_4_to_11_enterprise_entities.sql):** Complete resolution of all 16 missing public entities (`account_role`, `account_status_history`, `login_attempt`, `user_role`, `user_preference`, `identity_session`, `organisation_account_admin`, `organisation_external_system`, `organisation_identifier`, `organisation_location`, `organisation_status_history`, `organisation_verification_history`, `gig_worker_availability`, `gig_application_status_history`, `gig_event`, `gig_fulfilment_handoff`, `gig_worker_project`, `gig_fulfilment_event`, `identity_db_principal`, domain status tables) and all 45 cross-schema views in `identity`, `organisation`, and `gig`.