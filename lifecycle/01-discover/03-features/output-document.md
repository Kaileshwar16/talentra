# 03 Output document — Feature Discovery

## What the product needs to do

Talentra needs a dependable record of a person looking for work, an organisation offering work, and what happened between them. A candidate should be able to build a profile and apply once to an open job. The employer should see only the applications it is entitled to see. Recruiters and consultants need narrower, time-bound access. Gigs, payments and provider callbacks add separate state changes that must remain explainable after a retry, cancellation or refund. The feature list below turns those needs into reviewable capabilities. It describes the intended data and behavior; it does not claim that every capability already works.

**Priority rule.** “Must” comes from a mandatory docket rule or Tier 1 domain. “Should” is the reader-friendly name for the shared register's `Expected` Tier 2 detail, subject to owner review. “Differentiator hypothesis” is an opportunity to test, not a promise; the shared register calls optional domains `Stretch`. The full [feature register](../actors-goals-features.md) keeps the shared IDs and source links.

| ID | Capability and user benefit | Priority | Trace | What a reviewer should see |
| --- | --- | --- | --- | --- |
| FEAT-01 | Candidate profile, skills, resume versions and history: the candidate can present current information without losing the previous record | Must; Tier 2 history should | REQ-01, REQ-15; ACT-01; WF-01 | One candidate identity, versioned resume reference and explicit consent/visibility state |
| FEAT-02 | Jobs, questions and applications: employer and candidate share one understandable hiring status | Must | REQ-02; ACT-01/02; WF-02 | Published/open job accepts one active application per candidate; every stage change is traceable |
| FEAT-03 | Access, blocking, consent and audit: candidate data reaches only entitled people | Must | REQ-03–05; ACT-01/03/04/09; WF-03 | A blocked company or unrelated recruiter is denied, with actor and reason recorded |
| FEAT-04 | Organisation and recruiter mapping: an employer can delegate work without giving platform-wide access | Must | REQ-06; ACT-02/08/14; WF-04 | Verified organisation and dated assignment determine the recruiter's current scope |
| FEAT-05 | Gig marketplace and fulfilment: short work has its own bid, assignment and completion record | Must | REQ-07; ACT-02/06/10; WF-05 | Overlapping or duplicate bids are rejected; handoff and outcome reconcile |
| FEAT-06 | Sourcing and outreach: a consultant or recruiter can work only an eligible requirement | Must | REQ-08; ACT-02/03/04; WF-06 | Job openness, assignment and recipient policy checked before contact |
| FEAT-07 | Licences, seats, devices and sessions: a paid account can control active access | Must | REQ-09; ACT-08/14; WF-07 | Concurrent login cannot bypass the seat cap; revocation ends access |
| FEAT-08 | Subscription, wallet, invoice and refund ledger: money changes can be explained and reconciled | Must | REQ-10; ACT-02/08/10/12; WF-08 | Payment confirmation applies once; refund is a new compensating entry |
| FEAT-09 | Preferences, notifications and support: people receive relevant updates with a visible failure trail | Must; community detail should | REQ-11; ACT-01/02/12; WF-09 | Opt-out suppresses delivery; attempts and final state are recorded |
| FEAT-10 | Analytics and reference insights: owners can see a dated, reconciled hiring funnel | Must; salary/rating insight optional | REQ-12, REQ-16; ACT-08/11; WF-10 | Mart totals match source events and stale figures are labelled |
| FEAT-11 | Provider boundaries: external payments, messages and gig status cannot silently duplicate business events | Must | REQ-13; ACT-10/11; WF-11 | Signed, keyed callbacks are accepted once or quarantined with a reason |
| FEAT-12 | Seed, validation, performance and recovery evidence: reviewers can test whether the model survives realistic volume | Must | REQ-14; ACT-09/11; WF-12 | Counts, constraints, fixed query plans, access tests and restore result are reproducible |

For example, FEAT-02 is more than an `application` table: a candidate sees a clear current state, an employer can make an allowed decision, and the previous state remains in history. FEAT-08 is more than a balance column: the payment, credit use, cancellation and refund have separate records so support can explain the amount.

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

## Publicly documented competitor coverage

`Yes` means the linked public product material describes the capability. `Unverified` means this review did not find reliable public evidence; it does not mean the competitor lacks it. Talentra entries are design scope, not verified product behavior.

| Capability / priority | Talentra | Naukri | Monster | LinkedIn |
| --- | --- | --- | --- | --- |
| Candidate profile, skills and resume / Must | FEAT-01 | [Yes](https://recruit.naukri.com/recruit/resume-database-access-resdex) | [Yes](https://hiring.monster.com/help-center/job-postings/managing-your-jobs-and-applicants/applicant-management-with-monster/) | [Yes](https://socialimpact.linkedin.com/content/dam/me/socialimpact-linkedin-com/lifg-resources/linkedin-training-content/linkedin-profile-tip-sheet.pdf) |
| Employer posting and applicant pipeline / Must | FEAT-02 | [Yes](https://recruit.naukri.com/recruit/job-posting) | [Yes](https://hiring.monster.com/help-center/job-postings/managing-your-jobs-and-applicants/applicant-management-with-monster/) | [Yes](https://business.linkedin.com/in/en/hire/company-career-pages/features) |
| Candidate block and recruiter assignment enforcement / Must | FEAT-03–04 | Unverified | Unverified | Unverified |
| Separate gig bid, handoff and earnings reference / Must | FEAT-05 | Unverified | Unverified | Unverified |
| Append-only wallet, credits and refund ledger / Must | FEAT-08 | Unverified | Unverified | Unverified |
| Community, assessments and profile history / Should-have | REQ-15 | Unverified | Unverified | [Profile sections documented](https://socialimpact.linkedin.com/content/dam/me/socialimpact-linkedin-com/lifg-resources/linkedin-training-content/linkedin-profile-tip-sheet.pdf) |
| Salary benchmarks and company ratings / Differentiator candidate | REQ-16, optional | Unverified | Unverified | Unverified |

The likely opportunity is a *single auditable record* from sourcing and application through gig handoff and financial settlement. This matters because disconnected status and money records make reconciliation and candidate visibility harder. It is a design hypothesis: public pages cannot establish that competitors lack an internal integration or that Talentra has achieved the outcome.

The workflow-linked acceptance intents are in [WF-01–12](../nfr-workflows.md) and [TC-01–12](../test-case-graph.md). This document is a completed discovery artifact with explicitly unresolved product acceptance, not a claim that all features are implemented.
