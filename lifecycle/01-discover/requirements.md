# Requirement analysis docket

## Problem and scope

Legacy job, candidate and application records are inconsistent; candidate retention is low; hiring pipeline visibility is fragmented. Talentra must support operational workflows and analytics at a 10 million candidate full-scale target (docket §1). The docket explicitly scopes **database design, seed generation, performance validation, security, analytics and defence**. UI implementation, live external integrations, full laptop loading of 10 million profiles, and legacy ETL are out of scope for this assignment. A later product initiative must authorize those separately.

Priority: `M` mandatory docket behavior; `E` expected Tier 2 data; `S` optional stretch. These labels represent docket obligations, not implementation status. Actor IDs are defined in [actors-goals-features.md](actors-goals-features.md).

| ID | Requirement and acceptance intent | Source | Priority | Actors | Feature / workflow | Current evidence or gap |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-01 | Keep candidate identity, contact, education, experience, skills, languages and resume history, with controlled access. | §2, §4 Tier 1 | M | ACT-01, ACT-08 | FEAT-01 / WF-01 | Phase 1 schema; bulk seed has limited details |
| REQ-02 | Store job requirements, positions, publish state, questionnaires and application status history across the full pipeline. | §2, §4 Tier 1 | M | ACT-01, ACT-02, ACT-03 | FEAT-02 / WF-02 | Phase 1 schema and seven seeded statuses; transition tests need mapping |
| REQ-03 | Enforce actor privileges below the UI; recruiters access only assigned jobs of their own company. | §3 | M | ACT-03, ACT-08 | FEAT-03 / WF-03 | Phase 2 RLS test evidence is from physical test branch; production view behavior needs validation |
| REQ-04 | Consultants act only on jobs open to consultants; candidates can block employers, recruiters or consultants, making their profile invisible to blocked parties. | §3 | M | ACT-01, ACT-03, ACT-04 | FEAT-03 / WF-03 | Consultant trigger exists; production blocked-party read test open |
| REQ-05 | Recruiters may contact candidates but cannot register them; sensitive actions need an audit trail. | §3 | M | ACT-01, ACT-03, ACT-08 | FEAT-03 / WF-03 | Access-layer path and comprehensive audit test open |
| REQ-06 | Model employers, clients, verification, account administrators, hierarchy and effective-dated recruiter mapping. | §4 Tier 1 | M | ACT-02, ACT-03, ACT-08 | FEAT-04 / WF-04 | Phase 2 design; production compatibility views differ |
| REQ-07 | Model separate gig worker profiles, one-way applications, requester acceptance, availability, pricing, assignment, external handoff, reconciliation and ratings. | §2, §4 Tier 1 | M | ACT-02, ACT-06 | FEAT-05 / WF-05 | Phase 2 design and small seed; production overlap rejection untested |
| REQ-08 | Model sourcing, consultant requests, candidate shortlists and bulk outreach. | §2, §4 Tier 1 | M | ACT-02, ACT-03, ACT-04 | FEAT-06 / WF-06 | Phase 3 schema; module query/volume proof open |
| REQ-09 | Enforce licence seats, devices and active-session limits at login under concurrency; record revocation and history. | §4–5 Tier 1 | M | ACT-08, ACT-09 | FEAT-07 / WF-07 | Phase 3 schema; concurrent login test open |
| REQ-10 | Keep subscriptions, payments, invoices, refunds and append-only wallet/download ledger with precise money and idempotency. | §4–5 Tier 1 | M | ACT-02, ACT-08, ACT-10 | FEAT-08 / WF-08 | Phase 3 schema; realistic reconciliation proof open |
| REQ-11 | Keep notification and alert preferences, delivery status, support/community records, and language support. | §2, §4 Tier 1 | M | ACT-01, ACT-02, ACT-08, ACT-10 | FEAT-09 / WF-09 | Phase 4 schema; 1,000 deliveries seeded |
| REQ-12 | Produce hiring, sourcing and financial analytics with refresh rules and measurable KPI definitions. | §4 Tier 1, B49/B58 | M | ACT-02, ACT-08 | FEAT-10 / WF-10 | Mart structures exist; refresh after final seed open |
| REQ-13 | Store external references and failure/idempotency/audit behavior for payment, verification, gig fulfilment, messaging, legacy sync and optional external data. | §6 | M | ACT-08, ACT-10 | FEAT-11 / WF-11 | Boundary contracts incomplete; live integrations excluded |
| REQ-14 | Produce representative seed, fixed/module query results, plans, latency distribution, extrapolation, security tests, backup/restore and sign-off. | B60–B82 | M | ACT-08, ACT-09 | FEAT-12 / WF-12 | Core laptop-scale counts seeded locally; field quality, performance, access, recovery and sign-off open |
| REQ-15 | Record profile views, candidate activity, bookmarks, referral, assessments, enrolment and completion scoring, or justify omission. | §4 Tier 2 | E | ACT-01, ACT-02 | FEAT-01 / WF-01 | Coverage audit needed |
| REQ-16 | Salary benchmarks, company ratings, trending snapshots, dashboard aggregates and feature flags may be added as separately justified stretch scope. | §4 Tier 3 | S | ACT-01, ACT-02 | FEAT-10 / WF-10 | No promise to implement |

## Explicit out-of-scope lines and questions

- **OS-01** UI and live external service integration (§1); database and boundary contracts remain in scope.
- **OS-02** Complete 10 million profile load on a laptop (§1, sizing); measured 1 million profile laptop scale and reasoned full-scale extrapolation are in scope.
- **OS-03** Legacy ETL and migration implementation (§1); field ownership/conflict design remains in scope under §6.
- **OS-04** Employer sub-roles in this version (§3); an extension path must be described.
- **Q-01, high impact:** Who accepts numerical service, availability, privacy retention and recovery targets absent from the supplied brief?
- **Q-02, high impact:** Should production's Phase 2 compatibility views be replaced by the physical Phase 2 design or kept with equivalent access contracts?
- **Q-03, resolved for laptop-scale seed:** Reuse local PostgreSQL for the measured dataset because the Neon branch storage limit prevented full loading. Keep production compatibility/performance questions separate.
- **Q-04, medium impact:** What are the operational definitions and sources for candidate retention and unified pipeline KPIs?

The docket's Tier 1 domain list and rule groups 1–10 are covered by REQ-01–14 at domain level. Field-by-field traceability belongs in playbook step 10 data dictionary and the rule compliance table; this document does not claim that audit is complete.
