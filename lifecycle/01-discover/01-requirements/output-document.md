# 01 Output document — Requirement Analysis Docket

This is the working problem statement and requirements docket for the database assignment. It is written from the [12-page Talentra source docket](../../../sources/Talentra-Database-Design-Hackathon-Docket.pdf), not from the existing schema alone. The detailed [ID register](../requirements.md) holds downstream links and implementation evidence. **Status: prepared for domain review; source-sentence sign-off is still open.**

## The problem in plain language

Northbridge has candidate profiles, job requirements and applications in several legacy systems with inconsistent formats. Candidates do not stay engaged on the existing channels, and staff cannot see one reliable hiring pipeline. Talentra needs a connected operational and analytical **database** for the hiring, gig, account and financial flows described in the docket. Success means the team can explain where each record belongs, enforce access and business rules, and demonstrate the design with realistic data and measured queries. The assignment does not itself build the user interface or live provider integrations.

## Goals, scope and assumptions

| Type | Decision in this discovery pack | Why it matters |
| --- | --- | --- |
| Goal GOAL-01 | One consistent candidate, job and application record model | Avoid duplicates, broken references and incompatible status values. |
| Goal GOAL-02 | A traceable hiring pipeline | Count and explain applications from applied through joined, rejected or withdrawn. |
| Goal GOAL-03 | Support better retention decisions | Define retention cohorts and engagement signals before claiming improvement. The source gives no numeric retention uplift target. |
| Goal GOAL-04 | Safe account-scoped access | A recruiter, consultant or blocked employer must see only permitted records. |
| Goal GOAL-05 | Reconcile gig and financial events | Keep provider handoffs, wallet changes, refunds and audit history explainable. |
| In scope | Logical/physical schema, synthetic seed, access design, analytics model, licences/devices, payments/subscriptions, multilingual data, performance and panel evidence | These are the database assignment deliverables in docket section 1. |
| Out of scope OS-01 | UI implementation and live provider integration | Store integration references and failure states, but do not claim a live service is connected. |
| Out of scope OS-02 | Loading 10 million profiles on the laptop | Load 1 million locally; extrapolate to 10 million profiles, 1 million jobs and 100 million applications. |
| Out of scope OS-03 | Legacy ETL and migration implementation | Define field ownership and conflicts; loading old data is a separate requirement. |
| Out of scope OS-04 | Employer sub-roles within an organisation | Keep an extension path for posting/interview/pipeline sub-roles. |
| Assumption A-01 | PostgreSQL is the chosen engine | Existing phased migrations and the local/Neon environments use PostgreSQL; the docket allowed PostgreSQL or MySQL. |
| Assumption A-02 | Gig work is a separate data subsystem linked for reporting | Its one-way bid, time window and external fulfilment rules differ from permanent-job applications. |
| Assumption A-03 | Proposed latency, availability and retention values are review candidates | The source requires measurement but does not supply accepted numbers for all service qualities. |

## Requirements docket

`M` means mandatory source obligation, `E` means expected Tier 2 coverage or justified omission, and `S` means optional stretch. The ambiguity column names a question that affects design; it does not weaken the source requirement. All rows have an actor in the [actor trace](../requirements.md).

| ID | Statement in human terms | Source | Priority | Ambiguity to resolve |
| --- | --- | --- | :---: | --- |
| REQ-01 | A candidate controls one profile, contact/education/work/skill/language details and resume history. | section 2; section 4 Tier 1 | M | Consent and retention policy. |
| REQ-02 | An employer publishes a job with positions and questions; a candidate applies and the complete status history remains explainable. | section 2; section 4 Tier 1 | M | Allowed stage transitions. |
| REQ-03 | Enforce role permissions below the interface; a recruiter acts only on assigned jobs of their company. | section 3 | M | Mapping expiry and production read path. |
| REQ-04 | A consultant works only on consultant-open jobs; a candidate's block hides them from the blocked employer/recruiter/consultant. | section 3 | M | Historic visibility after a block. |
| REQ-05 | Recruiters may contact candidates but cannot register them; sensitive actions are audited. | section 3 | M | Complete audit-action list. |
| REQ-06 | Store verified organisations, account hierarchy, administrators and dated recruiter mappings. | section 4 Tier 1 | M | Verification authority and account scope. |
| REQ-07 | Keep gig worker profiles, one-way applications, pricing/windows, assignment, external handoff, earnings reference and ratings. | section 2; section 4 Tier 1 | M | Timeout and earnings reconciliation owner. |
| REQ-08 | Record sourcing requests, consultant decisions, shortlists and bulk outreach. | section 2; section 4 Tier 1 | M | Consent and recipient deduplication. |
| REQ-09 | Enforce positive seat/device limits and active-session caps at login, including concurrent attempts and revocation. | sections 4–5 | M | Exact cap and session expiry policy. |
| REQ-10 | Keep plans, payments, refunds, wallet credits/debits, invoices and download history as precise, append-only events. | sections 4–5 | M | Refund and provider reconciliation timing. |
| REQ-11 | Keep notification preferences, deliveries, support/community data and language settings. | section 2; section 4 Tier 1 | M | Opt-out and message retention rules. |
| REQ-12 | Produce reconcilable hiring, sourcing and financial analytics. | section 4; B49/B58 | M | KPI denominator and refresh frequency. |
| REQ-13 | Define what each external boundary stores, owns, retries and audits. | section 6 | M | Per-provider source of truth and idempotency key. |
| REQ-14 | Demonstrate the design with competitor comparison, seed, query plans, timings, scale projection, access and restore evidence. | section 4 benchmark; B60–B82 | M | Exact acceptance workload and reviewer. |
| REQ-15 | Model Tier 2 histories, assessment, learning, support and referral data, or justify each omission. | section 4 Tier 2 | E | Which omissions are acceptable? |
| REQ-16 | Treat salary benchmarks, company ratings, trends, aggregates and flags as explicitly selected stretch scope. | section 4 Tier 3 | S | No implementation promise yet. |
| REQ-17 | Follow ten data-standard rule groups or document each deviation, reason and risk. | section 5 | M | Per-rule compliance audit. |
| REQ-18 | Produce and validate entities, relationships, columns and constraints in the specified milestone order. | section 7 B1–B59 | M | Backlog-to-artifact sign-off. |

**Example trace:** the docket's sentence that recruiters may only act on assigned jobs of their own company becomes `REQ-03`; recruiter `ACT-03` is the actor; access control `FEAT-03` is the feature; `WF-03` is the decision flow; the test must try an assigned job and a different-company job with separate principals.

## What the ten mandatory data rules mean here

All ten groups come from docket section 5 and are covered by REQ-17. This table turns their long text into a concrete review question; it is a **requirement interpretation**, not a completed compliance audit.

| Rule group | Concrete Talentra decision or check | Evidence still needed |
| --- | --- | --- |
| 1 Naming | Singular `snake_case` table names, `id` primary keys, named foreign keys and consistent index/unique names; check reserved words for the chosen engine | Physical catalog audit and documented exceptions |
| 2 Keys and constraints | Surrogate IDs; natural identifiers unique; FKs with update/delete policy; date and salary checks; seat/device limits enforced transactionally | Catalog and concurrent-login tests |
| 3 Standard domains | Names up to 150 UTF-8 characters; email up to 254 and lowercase; E.164 phone; decimal money with currency; UTC timestamps; lookup-backed enums and translated labels | Column-by-column dictionary review |
| 4 Audit and lifecycle | Creator/updater fields on business tables; declared soft/hard deletion; append-only audit; candidate retention per entity | Table inventory, audit mutation denial and approved retention periods |
| 5 Nullability | Explain each nullable field; distinguish unknown from not applicable; do not use zero, `NA` or empty string as missing | Nullability inventory and seed-quality checks |
| 6 Sensitive classes | Mark every column Public, Internal, Personal or Sensitive; encrypt, tokenize or mask sensitive values | Data dictionary and access/security tests |
| 7 Multilingual | UTF-8 end to end; translation key/language rows and fallback; user content stored once with language where known | Translation coverage and non-ASCII tests |
| 8 Physical objects | State patterns for partitions/views/materialized views and prefix analytical objects | Physical catalog inspection |
| 9 Licences/devices | Positive seat/device caps, active sessions with device and timestamps, revoked/expired sessions excluded; denied login audited | Concurrent-login and revocation tests |
| 10 Money/history | Append-only wallet/payment correction, non-overlapping subscription periods, immutable view/download history with actor and credit deduction | Ledger replay, overlap and history mutation tests |

## External systems: what this database owns

Section 6 of the docket lists nine boundaries. REQ-13 requires a source-of-truth, stored/reference, failure, idempotency and audit decision for each. The intended default is to keep a local **reference and outcome**, not the provider's private internals. These are working design decisions requiring integration-owner review.

| Boundary | Store or reference locally | On timeout or duplicate | Review point |
| --- | --- | --- | --- |
| Payment gateway | Order, provider transaction ID, amount, currency and status; no card or bank details | Keep pending, reconcile by provider ID; apply credit once | Refund/settlement source of truth |
| Identity verification | Token, outcome and timestamp; no clear-text national ID | Pending verification; same request key prevents duplicate result | Token retention and allowed use |
| Company/tax verification | Lookup identifiers and verification result | Keep company unverified until confirmed | Identifier masking and recheck interval |
| Gig fulfilment | Handoff reference, assignment status and reconciled earnings reference | Pending handoff with retry key; no duplicate assignment | Who resolves disputed earnings |
| Legacy job/candidate systems | Source IDs, field provenance and sync/conflict metadata; no migration execution in this assignment | Flag unresolved conflict rather than silently overwriting | Per-field sync direction and precedence |
| Messaging providers | Preference, delivery reference, attempt and status; minimal message content | Retry with stable key and stop at opt-out | Retention of delivery metadata |
| Social sharing | Outbound share event and link reference; no external post body | Record failed outbound attempt; avoid repeated event count | Link expiry/privacy |
| Maps/geolocation | Optional coordinates/place reference and source | Preserve entered location; mark enrichment pending | Precision and source trust |
| Company review/salary data | Source attribution, retrieved date and reference value if selected | Keep dated stale marker; do not present as fresh | Optional Tier 3 scope and refresh policy |

This resolves the apparent tension between “legacy sync direction” in section 6 and “ETL implementation out of scope” in section 1: the design must say which source wins and how conflicts appear, while the assignment does not run a migration pipeline.

## Review map

| Docket area | Requirement IDs | Review focus |
| --- | --- | --- |
| Candidate, job and application data | REQ-01–02, REQ-15 | Tier 1/2 field coverage, state history and privacy |
| Access, organisation and gig | REQ-03–07 | Recruiter scope, blocking, audit, external gig boundary |
| Commercial and shared modules | REQ-08–13 | Sourcing, seat/device caps, financial ledger, notifications, analytics, integrations |
| Proof, standards and optional scope | REQ-14, REQ-16–18 | Seed, timings, security, recovery, rule compliance, milestone trace and stretch exclusions |

## Source coverage and ambiguity review

These IDs map source blocks at the level available in this pack. A block can contain multiple sentences, so this is a **review index**, not completed sentence-level proof. The owner must annotate each sentence and every B1–B82 backlog row before G1 acceptance.

| Docket source | Routed IDs | Ambiguity or pending check |
| --- | --- | --- |
| section 1 purpose, problem, scope | REQ-01–02, REQ-12, REQ-14, OS-01–03 | Retention and pipeline success measures absent |
| section 2 categories, gig rules, core workflows | REQ-01–02, REQ-07–11, REQ-13 | Central versus secondary workflows, external handoff owner |
| section 3 actors and access rules | REQ-03–05, OS-04 | TPO and exceptional-admin grants; blocked-party semantics |
| section 4 Tier 1 domains | REQ-01–13 | Field-level coverage and missing domains need audit |
| section 4 Tier 2 and Tier 3 | REQ-15–16 | Each Tier 2 omission needs explicit justification |
| section 4 competitor benchmark | REQ-14, FEAT-01–12 | Field-level match/exceed/fall-short remains open |
| section 5 ten rule groups and compliance table | REQ-09–10, REQ-17 | Per-rule compliance and deviation evidence open |
| section 6 nine integration boundaries | REQ-13 | Source of truth, failure and idempotency by boundary open |
| section 6 sizing and seed | REQ-14, NFR-01–03, OS-02 | Full-scale extrapolation requires measured basis |
| section 7 B1–B59 design backlogs | REQ-18 | Backlog-by-backlog artifact trace open |
| section 7 B60–B82 validation backlogs | REQ-14 | Query, performance, access, backup and sign-off evidence open |

The docket PDF in this repository ends after section 7/B82, although some backlog text refers to later sections. Any acceptance value said to be in an unavailable section remains unresolved until the missing source is supplied.

## Open questions ranked by design impact

| Rank | Question | Why the answer changes the design | Decision owner |
| ---: | --- | --- | --- |
| 1 | Q-01: What per-entity retention periods, deletion exceptions and accepted response/recovery targets apply? | Determines lifecycle columns, scheduled deletion, backup handling, partitions and capacity. | Product, privacy/security and operations owners |
| 2 | Q-02: Will production use physical Phase 2 tables or compatibility views with equivalent access behavior? | Changes where RLS, triggers and cross-schema foreign keys can be enforced. | Database/security owners |
| 3 | Q-04: What counts as an active/retained candidate and a pipeline conversion? | Changes source events, mart dimensions and KPI denominators. | Product/analytics owners |
| Resolved locally | Q-03: Which environment holds the laptop-scale proof? | The existing local PostgreSQL seed reached the core counts; it does not settle production compatibility. | Delivery owner |

The words “fast” and “many” are not useful acceptance criteria. In the [NFR register](../nfr-workflows.md), scale is expressed as row counts; a **proposed** lookup target is p95 ≤500 ms under a **proposed** 60-read/second workload. The workload assumptions and service target need approval. The [local seed evidence](../../../phase5/local/validation-report.md) proves row counts, not that performance target.

**Gate decision:** the docket is ready for domain review, but G1 stays open until a reviewer signs the sentence-level source trace, Tier 2 omissions and ten-rule compliance audit. The [gate register](../decisions-and-gaps.md) names the other review items.
