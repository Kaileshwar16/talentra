# 01 Output document — Requirement Analysis Docket

The full [requirements docket](../requirements.md) is the output record. It states the legacy data and pipeline problem, in/out scope, 16 numbered requirements, four explicit exclusions and four ranked open questions. Requirements include source section, priority, actor, linked feature/workflow and current evidence or gap. The docket's database target is 10 million candidate profiles at full scale; laptop proof uses 1 million candidates, 100,000 jobs and 5 million applications.

## Review map

| Docket area | Requirement IDs | Review focus |
| --- | --- | --- |
| Candidate, job and application data | REQ-01–02, REQ-15 | Tier 1/2 field coverage, state history and privacy |
| Access, organisation and gig | REQ-03–07 | Recruiter scope, blocking, audit, external gig boundary |
| Commercial and shared modules | REQ-08–13 | Sourcing, seat/device caps, financial ledger, notifications, analytics, integrations |
| Proof and optional scope | REQ-14, REQ-16 | Seed, timings, security, recovery, stretch exclusions |

## Open decisions

- Q-01: product/security owner accepts numeric service, retention and recovery targets.
- Q-02: database owner chooses how Neon production compatibility views reconcile with the physical Phase 2 model.
- Q-03: delivery owner records the local PostgreSQL environment for laptop-scale proof; [local seed evidence](../../../phase5/local/validation-report.md) now proves the core row counts, with quality and performance work still open.
- Q-04: product owner defines candidate-retention and pipeline KPI formulas.

The docket is ready for source-by-source review. Acceptance is pending the listed owners and the Tier 2/rule-group audit; that pending review is recorded in [the gate register](../decisions-and-gaps.md).
