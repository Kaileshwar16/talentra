# 04 Output document — NFR Discovery

## Why these targets matter

A model can have the right tables and still fail if searches slow down at realistic size, one employer sees another employer's candidates, a refund changes a balance without a trail, or a restore loses too much work. This register says what to measure and where each number came from. **Docket** means the source asks for it. **Proposal** means the team has put forward a number so it can be debated and tested. A proposed number is not a signed-off service promise.

| ID | Quality question | Numeric target and basis | How to measure it | Current state |
| --- | --- | --- | --- | --- |
| NFR-01 | Can the local model hold the required demonstration volume? | **1m** candidates, **100k** jobs, **5m** applications; docket section 6 | Count rows, check distributions, duplicates and orphan records after load | Core counts reached locally; representativeness remains to review |
| NFR-02 | Can the design be reasoned about at intended full size? | **10m** candidates, **1m** jobs, **100m** applications; docket section 6 | Extrapolate measured plans, index/storage size and cache behavior; name the first failing query | Model target, not a full-size test |
| NFR-03 | Are important queries measured repeatably? | **12** fixed query cases; **top 10** with plans and repeated p50/p95/p99; backlog B65/B70 | Save exact SQL, row counts, PostgreSQL settings, run count and timings | Evidence is incomplete for sign-off |
| NFR-04 | Does access isolation work? | **0** unauthorized reads/writes in the enumerated role tests; every sensitive action audited; docket section 3 and backlog B79 | Use separate principals and account IDs, blocked candidates and expired assignments; inspect deny and audit events | Policy is documented; live role/RLS proof remains open |
| NFR-05 | Are relationships trustworthy? | **0** unvalidated constraints and **0** orphan applications; docket section 5 and backlog B66 | Catalog query plus orphan and duplicate checks after seed | Local constraint suites passed; production differs |
| NFR-06 | Can operations recover? | Proposed RTO **4 hours**, RPO **1 hour**; docket asks for recovery evidence but supplies no number | Time isolated restore and compare latest recovered event with backup point | Exercise and owner approval pending |
| NFR-07 | Is a common lookup responsive at seed size? | Proposed p95 **≤500 ms** for agreed candidate/job query mix at NFR-01 volume | Repeated warm/cold runs under documented concurrency and hardware | Query mix and measured result pending |
| NFR-08 | Are reports current and correct? | Proposed mart age **≤24 hours** and **0** unexplained total mismatches | Check refresh timestamp and reconcile each published total to source events | Post-load reconciliation pending |
| NFR-09 | Is the eventual service available? | Proposed **99.9%** monthly request availability, about **43.2 minutes** unavailable in a 30-day month | User-visible request SLI with a defined maintenance policy | Future application target; no live SLI yet |
| NFR-10 | Is personal data kept for a defined time? | **100%** of personal-data entities need an approved numeric retention rule; candidate inactivity review at **24 months** is only a proposal | Inventory entities and approved triggers/periods; dry-run expiry, exceptions and deletion | Per-entity periods and exceptions unapproved |
| NFR-11 | Can users understand the interface? | **100%** user-facing labels have translation key, default value and fallback; future UI proposal: WCAG **2.2 AA**, **0** critical release failures | Query translation coverage; audit future UI against applicable WCAG criteria | Data rule can be checked; UI is outside current build |
| NFR-12 | Can a privacy request be handled predictably? | Proposed **100%** eligible erasure decisions within **30 days**, and approved action within **30 further days** | Sample requests, inspect timestamps, data propagation and lawful exceptions | Internal target, not a statutory deadline; owner review pending |
| NFR-13 | Does the model tolerate a plausible peak? | Proposed **60 reads/second** for **30 minutes**, p95 **≤500 ms**, errors **<1%** | Replay signed-off query mix; record p50/p95/p99, errors and machine details | Assumptions and load test pending |

The **60 reads/second** proposal is a calculation, not a measured demand: 1% of the 1m-candidate seed active per day × 50 reads per active candidate ÷ 86,400 seconds × a 10× peak factor ≈ 58, rounded to 60. Product owners need to validate the 1%, 50-read and peak assumptions. The 500 ms, recovery and availability targets come from team judgment and require acceptance; volume alone does not set a useful latency or outage budget.

## Current evidence and decision queue

| NFR | Present evidence | Remaining acceptance work |
| --- | --- | --- |
| NFR-01, NFR-05 | [Local seed validation](../../../phase5/local/validation-report.md) records 1m candidates, 100k jobs and 5m applications, with four constraint suites passing | Review distribution, field depth and provenance before calling fixture representative |
| NFR-02, NFR-03, NFR-07 | Fixed SQL and performance work exists in the repository | Capture exact environment and repeated p50/p95/p99 measurements; model larger scale |
| NFR-04 | Role intents and test cases defined | Test actual roles and RLS with separate account principals |
| NFR-06 | Restore method specified | Approve RTO/RPO and time a restore exercise |
| NFR-08 | Reconciliation method specified | Refresh marts after final load, verify source totals and age |
| NFR-09 | Proposed application SLO only | Confirm whether service availability belongs in this database-stage acceptance |
| NFR-10 | Retention decision documented | Owner approves per-entity periods and deletion exceptions |
| NFR-11 | Translation-key rule and proposed future-UI WCAG 2.2 AA target | Audit every label/fallback; UI implementation is outside the docket |
| NFR-12 | Proposed 30-day decision and 30-day execution targets for erasure requests | Privacy owner decides applicability and tests deletion propagation |
| NFR-13 | Proposed 60 reads/second, 30-minute workload derived from explicit activity assumptions | Validate assumptions, then report latency/error distribution |

The [decision register](../decisions-and-gaps.md) tracks G1. A full local seed is evidence of NFR-01 counts; it is not evidence of full-scale performance, live access policy or accepted service targets.

## Decision owners and measurement context

| NFR | Proposed decision owner | Measurement context |
| --- | --- | --- |
| 01–03, 05, 07 | Database lead | Exact PostgreSQL version, machine, indexes, row distribution, query text and repeated timings |
| 04 | Product/security owner | Separate login roles and account IDs; blocked-party and denied-write audit |
| 06 | Operations owner | Isolated backup and restore, measured recovery time and data loss |
| 08 | Analytics owner | Final source events, refresh run ID, source-to-mart totals |
| 09 | Product/operations owner | User-facing request SLI and maintenance policy, if in scope |
| 10 | Privacy/product owner | Per-entity retention table and deletion/exception rehearsal |
| 11 | Product/accessibility owner | Language-key coverage and future WCAG 2.2 AA audit |
| 12 | Privacy/legal owner | Request sample, decisions, deletion/exception timestamps |
| 13 | Product/database owner | Signed-off activity assumptions, query mix and 30-minute load run |

Owner titles identify who must decide; no individual has accepted these targets yet.

## Regulatory and standard applicability

The [Digital Personal Data Protection Act, 2023](https://www.meity.gov.in/static/uploads/2024/02/Digital-Personal-Data-Protection-Act-2023.pdf) and [Digital Personal Data Protection Rules, 2025](https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf) are the named Indian privacy framework. Their [commencement notification](https://www.meity.gov.in/static/uploads/2025/11/c56ceae6c383460ca69577428d36828b.pdf) phases provisions in, so the privacy owner must map processing activities and effective dates before asserting compliance. The 30-day/30-day targets are internal service goals, not legal deadlines. [WCAG 2.2](https://www.w3.org/TR/WCAG22/) is proposed for a future UI; the current database assignment can test translation data but cannot certify a UI. Payment card data is excluded by the docket's gateway boundary; future card handling needs a separate PCI DSS scope decision.

NFR-13 uses the docket's 1-million-candidate seed: 1% daily active × 50 reads per active candidate ÷ 86,400 seconds × 10 peak factor ≈ 58 reads/second, rounded to 60. All usage assumptions are **unverified** and require product-owner review. The 500 ms p95 is likewise a proposed product target.
