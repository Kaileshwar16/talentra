# 03 Output document — Feature Discovery

The [feature inventory and three-platform comparison](../actors-goals-features.md) are the canonical FEAT-01–12 records. They cover candidate profiles, jobs/applications, access, organisation mapping, gigs, sourcing, seats/sessions, money, notifications, analytics, integration boundaries and validation. Each row links to a requirement, outcome and workflow. The [requirements docket](../requirements.md) records explicit exclusions.

## Delivery sequence and dependencies

| Sequence | Features | Reason and acceptance example |
| --- | --- | --- |
| 1. Identity and core records | FEAT-01–04 | Candidate/job IDs, tenant mapping and blocked-party rules must exist before sourcing; test duplicate application and cross-company denial |
| 2. Operational flows | FEAT-05–09, FEAT-11 | Gig, sourcing, sessions, ledger, alerts and provider callbacks depend on identity and scopes; test retries, refunds, revocation and handoff |
| 3. Evidence | FEAT-10, FEAT-12 | Analytics and validation depend on stable source events; reconcile marts and prove restore/access behavior |

## Acceptance behavior by capability

| Feature | Reviewable behavior | Dependency / unresolved choice |
| --- | --- | --- |
| FEAT-01 | Candidate owns one profile and resume history; duplicate registration is rejected | Identity and consent policy |
| FEAT-02 | Published job accepts at most one active application per candidate; stage history is preserved | Allowed status transitions |
| FEAT-03 | Cross-account or blocked-party access is denied and audited | Product/security access review |
| FEAT-04 | Recruiter mapping is company-scoped, effective-dated and non-overlapping | Organisation verification rule |
| FEAT-05 | Gig bid respects availability and uniqueness; accepted work reconciles with provider | Handoff ownership |
| FEAT-06 | Consultant request and outreach occur only for an eligible open job | Recipient and duplicate-message policy |
| FEAT-07 | Seat/device/session cap holds under concurrent login and revocation | Exact cap policy |
| FEAT-08 | Confirmed payment creates one ledger event; refund creates a compensating entry | Provider reconciliation policy |
| FEAT-09 | Opt-out suppresses delivery; attempts and failures remain traceable | Message retention policy |
| FEAT-10 | Refresh is dated and totals reconcile to source events | KPI definition and freshness target |
| FEAT-11 | Duplicate or untrusted callback cannot create a second business event | Provider signature/key contract |
| FEAT-12 | Seed counts, constraints, timing, isolation and restore evidence are repeatable | Environment and gate acceptance |

**Comparison finding:** official public pages document candidate profile fields and employer hiring features for [Naukri](https://recruit.naukri.com/recruit/resume-database-access-resdex), [Monster](https://hiring.monster.com/help-center/job-postings/managing-your-jobs-and-applicants/applicant-management-with-monster/) and [LinkedIn](https://www.business.linkedin.com/advertise/linkedin-pages). Talentra's proposed schema covers those core domains and separately models gigs and ledger events. We have not measured competitor depth or shown a superior outcome; a field-level data-dictionary audit and owner review remain open.

The workflow-linked acceptance intents are in [WF-01–12](../nfr-workflows.md) and [TC-01–12](../test-case-graph.md). This document is a completed discovery artifact with explicitly unresolved product acceptance, not a claim that all features are implemented.
