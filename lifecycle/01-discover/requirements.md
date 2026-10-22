# Requirement analysis docket

## Problem and scope

Legacy job, candidate and application records are inconsistent; candidate retention is low; hiring pipeline visibility is fragmented. Talentra must support operational workflows and analytics at a 10 million candidate full-scale target (docket section 1). The docket explicitly scopes **database design, seed generation, performance validation, security, analytics and defence**. UI implementation, live external integrations, full laptop loading of 10 million profiles, and legacy ETL are out of scope for this assignment. A later product initiative must authorize those separately.

Priority: `M` mandatory docket behavior; `E` expected Tier 2 data; `S` optional stretch. These labels represent docket obligations, not implementation status. Actor IDs are defined in [actors-goals-features.md](actors-goals-features.md).

| ID | Requirement and acceptance intent | Source | Priority | Actors | Feature / workflow | Current evidence or gap |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-01 | Keep candidate identity, contact, education, experience, skills, languages and resume history, with controlled access. | section 2, section 4 Tier 1 | M | ACT-01, ACT-08 | FEAT-01 / WF-01 | Phase 1 schema; bulk seed has limited details |
| REQ-02 | Store job requirements, positions, publish state, questionnaires and application status history across the full pipeline. | section 2, section 4 Tier 1 | M | ACT-01, ACT-02, ACT-03 | FEAT-02 / WF-02 | Phase 1 schema and seven seeded statuses; transition tests need mapping |
| REQ-03 | Enforce actor privileges below the UI; recruiters access only assigned jobs of their own company. | section 3 | M | ACT-03, ACT-14, ACT-15 | FEAT-03 / WF-03 | Phase 2 RLS test evidence is from physical test branch; production view behavior needs validation |
| REQ-04 | Consultants act only on jobs open to consultants; candidates can block employers, recruiters or consultants, making their profile invisible to blocked parties. | section 3 | M | ACT-01, ACT-03, ACT-04 | FEAT-03 / WF-03 | Consultant trigger exists; production blocked-party read test open |
| REQ-05 | Recruiters may contact candidates but cannot register them; sensitive actions need an audit trail. | section 3 | M | ACT-01, ACT-03, ACT-14, ACT-15 | FEAT-03 / WF-03 | Access-layer path and comprehensive audit test open |
| REQ-06 | Model employers, clients, verification, account administrators, hierarchy and effective-dated recruiter mapping. | section 4 Tier 1 | M | ACT-02, ACT-03, ACT-08 | FEAT-04 / WF-04 | Phase 2 design; production compatibility views differ |
| REQ-07 | Model separate gig worker profiles, one-way applications, requester acceptance, availability, pricing, assignment, external handoff, reconciliation and ratings. | section 2, section 4 Tier 1 | M | ACT-02, ACT-06 | FEAT-05 / WF-05 | Phase 2 design and small seed; production overlap rejection untested |
| REQ-08 | Model sourcing, consultant requests, candidate shortlists and bulk outreach. | section 2, section 4 Tier 1 | M | ACT-02, ACT-03, ACT-04 | FEAT-06 / WF-06 | Phase 3 schema; module query/volume proof open |
| REQ-09 | Enforce licence seats, devices and active-session limits at login under concurrency; record revocation and history. | sections 4–5 Tier 1 | M | ACT-08, ACT-09 | FEAT-07 / WF-07 | Phase 3 schema; concurrent login test open |
| REQ-10 | Keep subscriptions, payments, invoices, refunds and append-only wallet/download ledger with precise money and idempotency. | sections 4–5 Tier 1 | M | ACT-02, ACT-08, ACT-10 | FEAT-08 / WF-08 | Phase 3 schema; realistic reconciliation proof open |
| REQ-11 | Keep notification and alert preferences, delivery status, support/community records, and language support. | section 2, section 4 Tier 1 | M | ACT-01, ACT-02, ACT-10, ACT-12, ACT-14 | FEAT-09 / WF-09 | Phase 4 schema; 1,000 deliveries seeded |
| REQ-12 | Produce hiring, sourcing and financial analytics with refresh rules and measurable KPI definitions. | section 4 Tier 1, B49/B58 | M | ACT-02, ACT-08 | FEAT-10 / WF-10 | Mart structures exist; refresh after final seed open |
| REQ-13 | Store external references and failure/idempotency/audit behavior for payment, verification, gig fulfilment, messaging, legacy sync and optional external data. | section 6 | M | ACT-08, ACT-10 | FEAT-11 / WF-11 | Boundary contracts incomplete; live integrations excluded |
| REQ-14 | Produce the required three-platform coverage benchmark, representative seed, fixed/module query results, plans, latency distribution, extrapolation, security tests, backup/restore and sign-off. | section 4 benchmark; B60–B82 | M | ACT-09, ACT-13, ACT-14, ACT-15, ACT-16 | FEAT-12 / WF-12 | Core laptop-scale counts seeded locally; competitor depth, field quality, performance, access, recovery and sign-off open |
| REQ-15 | Record profile views, candidate activity, bookmarks, referral, assessments, enrolment and completion scoring, or justify omission. | section 4 Tier 2 | E | ACT-01, ACT-02 | FEAT-01 / WF-01 | Coverage audit needed |
| REQ-16 | Salary benchmarks, company ratings, trending snapshots, dashboard aggregates and feature flags may be added as separately justified stretch scope. | section 4 Tier 3 | S | ACT-01, ACT-02 | FEAT-10 / WF-10 | No promise to implement |
| REQ-17 | Apply or explicitly justify deviations from all ten data-standard rule groups, including naming, keys, domains, lifecycle, nullability, sensitivity, multilingual data, physical names, sessions and money/history. | section 5 | M | ACT-09, ACT-14, ACT-15, ACT-16 | FEAT-12 / WF-12 | Per-rule compliance table and independent audit open |
| REQ-18 | Produce and validate each module's entities, relationships, columns and constraints in milestone order; record provider and module/owner decisions. | section 7 B1–B59 | M | ACT-09, ACT-14, ACT-15, ACT-16 | FEAT-12 / WF-12 | Backlog-by-backlog trace open |

## Ambiguity notes by requirement

These notes complete the docket's ambiguity field without hiding unresolved points inside the statement. `None found` means no ambiguity was identified in this pass; it is not owner acceptance.

| ID | Ambiguity note or decision needed |
| --- | --- |
| REQ-01 | Candidate retention period, consent grounds and resume-version policy need privacy review. |
| REQ-02 | Valid application stage transitions and questionnaire response retention need product approval. |
| REQ-03 | Assignment expiry, account hierarchy and read-time enforcement on production views need testing. |
| REQ-04 | Whether block applies to historic applications and shared accounts needs a domain decision. |
| REQ-05 | Define the full sensitive-action catalogue and audit payload minimization. |
| REQ-06 | Verification authority, parent-child account scope and mapping ownership need approval. |
| REQ-07 | Define provider timeout ownership, earnings source freshness and rating eligibility. |
| REQ-08 | Define outreach recipient deduplication, consent and bulk batch limits. |
| REQ-09 | Exact licence values, active-session expiry and race behavior need approval. |
| REQ-10 | Refund timing, currency conversion and ledger reconciliation policy need approval. |
| REQ-11 | Channel opt-out precedence, message retention and support access need approval. |
| REQ-12 | Candidate-retention denominator, pipeline stage meaning and mart freshness need approval. |
| REQ-13 | Source of truth, failure behavior and idempotency key for each of nine boundaries remain open. |
| REQ-14 | Query workload, target environment, RTO/RPO and proof criteria need approval. |
| REQ-15 | Tier 2 omissions must be listed one by one with a reason. |
| REQ-16 | Optional scope only; no delivery commitment until explicitly selected. |
| REQ-17 | Every rule group needs a compliance/deviation row and evidence. |
| REQ-18 | B1–B59 artifact-to-backlog trace and owner validation remain open. |

## Explicit out-of-scope lines and questions

- **OS-01** UI and live external service integration (section 1); database and boundary contracts remain in scope.
- **OS-02** Complete 10 million profile load on a laptop (section 1, sizing); measured 1 million profile laptop scale and reasoned full-scale extrapolation are in scope.
- **OS-03** Legacy ETL and migration implementation (section 1); field ownership/conflict design remains in scope under section 6.
- **OS-04** Employer sub-roles in this version (section 3); an extension path must be described.
- **Q-01, high impact:** Who accepts numerical service, availability, privacy retention and recovery targets absent from the supplied brief?
- **Q-02, high impact:** Should production's Phase 2 compatibility views be replaced by the physical Phase 2 design or kept with equivalent access contracts?
- **Q-03, resolved for laptop-scale seed:** Reuse local PostgreSQL for the measured dataset because the Neon branch storage limit prevented full loading. Keep production compatibility/performance questions separate.
- **Q-04, medium impact:** What are the operational definitions and sources for candidate retention and unified pipeline KPIs?

The docket's Tier 1 domains are covered by REQ-01–14 at domain level; REQ-17 names rule groups 1–10 and REQ-18 names the module design backlogs. Field-by-field and sentence-by-sentence traceability belongs in the data dictionary and source audit. This document does not claim that audit is complete.
