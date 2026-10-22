# NFR register and workflows

## Quality targets

`Docket` targets are acceptance obligations. `Proposal` targets are measurable candidates requiring stakeholder approval; they are not presented as existing SLOs. Every metric has a measurement method.

| ID | Metric and target | Basis | Test method / evidence |
| --- | --- | --- | --- |
| NFR-01 | Measured laptop-scale seed: 1m candidates, 100k jobs, 5m applications | Docket sizing, B60–B61 | Counts, distribution and quality checks after seed |
| NFR-02 | Full-scale model: 10m candidates, 1m jobs, 100m applications | Docket sizing, B74 | Extrapolate from measured query plans, index size and cache behavior; identify first failing query |
| NFR-03 | 12 fixed query cases, top 10 with plans and repeated p50/p95/p99 timings | B65, B70 | Save exact SQL, run count, environment and latency samples |
| NFR-04 | Zero unauthorized cross-account reads/writes in enumerated roles; every sensitive action auditable | section 3, B79 | Role matrix tests with separate accounts, blocked-party and audit assertions |
| NFR-05 | Zero unvalidated constraints and zero orphan applications in seed | section 5, B66; project quality target | Catalog check and FK/orphan queries after load |
| NFR-06 | Restore time objective: **proposed 4 hours**, recovery point objective: **proposed 1 hour** | Team proposal; docket B80 requires RTO but supplies no number in available text | Isolated restore exercise with start/end timestamps and recovery point comparison |
| NFR-07 | Candidate/job lookup p95 **proposed 500 ms** at NFR-01 data size | Team proposal | Warm and cold measurements, concurrency and hardware documented; confirm exact query mix |
| NFR-08 | Mart freshness **proposed 24 hours** and totals reconcile to source tables | Team proposal | `max(report_date)`, refresh log and source-to-mart counts after final seed |
| NFR-09 | Service availability **proposed 99.9% monthly** | Team proposal for eventual application, outside current database hackathon sign-off | SLI from user-visible request monitoring, excluded maintenance policy defined |
| NFR-10 | **100%** of personal-data entities must have an owner-approved numeric retention period before policy sign-off. Candidate inactivity review at **24 months** is a provisional planning value, not an approved deletion rule. | section 5 requires a per-entity policy but gives no duration; 24 months is a team proposal requiring privacy/product approval | Inventory every personal-data entity; check approved period and trigger; dry-run expiry, deletion and exception handling |
| NFR-11 | **Proposed:** 100% of user-facing labels have a translation key, default-language value and fallback; any future UI targets WCAG 2.2 AA, with 0 critical accessibility failures at release | Docket section 5 multilingual rule; WCAG is a proposed future-UI standard, not a database acceptance obligation | Check key/translation completeness and fallback on every supported language; audit future UI against all applicable WCAG 2.2 AA criteria |
| NFR-12 | **Proposed privacy operations:** 100% of eligible erasure requests reach a recorded decision within 30 calendar days; execute approved deletion or exception within 30 more days | Team service target, not a claimed statutory deadline; final per-entity retention periods remain Q-01 | Seed eligible/ineligible requests, measure timestamps and verify deletion propagation, backups and lawful exception evidence |
| NFR-13 | **Proposed load:** 60 read requests/second against the NFR-01 seed for 30 minutes; candidate/job lookup p95 ≤500 ms and error rate <1% | Planning model: 1% of 1m candidates active/day × 50 reads/day ÷ 86,400 seconds × 10 peak factor ≈58 reads/s, rounded to 60. All usage assumptions need product validation | Record query mix, hardware, cache state and per-request latency/error samples; run 30-minute load and report p50/p95/p99 |

The 2026-10-17 live read shows 250k candidates, 25k jobs, 1.25m applications, database size 843,079,680 bytes and a 1 GiB Neon branch limit. These are 25% of NFR-01 counts and do not validate NFR-02 or NFR-07. The physical schema differs on production, so the access tests in NFR-04 must target production behavior separately.

The [local PostgreSQL validation](../../phase5/local/validation-report.md) subsequently reached all NFR-01 core row counts in the existing container and passed four constraint suites. That result is environment-specific and does not establish field representativeness, production RLS or NFR-02/03/07 performance.

## Workflow catalogue

Each row gives trigger → decisions → output and an exception path. The IDs link to every must-have feature in [the inventory](actors-goals-features.md).

| ID | Trigger, actors and core flow | Failure/exception to test |
| --- | --- | --- |
| WF-01 | Candidate registers (ACT-01) → consents → enters profile and resume → records history (FEAT-01) | Duplicate identity, withdrawn consent, deletion request, missing optional details |
| WF-02 | Employer publishes job (ACT-02) → candidate searches/applies (ACT-01) → application moves through stages (FEAT-02) | Closed/unpublished job, duplicate application, illegal transition, withdrawal |
| WF-03 | Recruiter/consultant requests candidate or job access (ACT-03/04) → resolve company mapping, assignment, block and openness → audit allow/deny (FEAT-03) | Expired mapping, cross-company job, candidate block, attempted recruiter registration, missing audit |
| WF-04 | Account admin creates/verifies organisation (ACT-08) → assigns recruiter with effective dates (FEAT-04) | Hierarchy cycle, overlapping assignment, unverified/blocked company |
| WF-05 | Worker offers availability (ACT-06) → requester posts priced gig (ACT-02) → worker applies → requester accepts → external handoff reconciles and rating follows (FEAT-05) | Overlapping window, duplicate bid, rejected bid, provider timeout/retry, duplicate fulfilment event |
| WF-06 | Employer opens sourcing request (ACT-02) → consultant accepts/declines (ACT-04) → recruiter sends outreach (ACT-03) → recipient status stored (FEAT-06) | Job closed to consultants, stale mapping, duplicate recipient, provider failure |
| WF-07 | Account allocates licence and seat (ACT-08) → user registers device and logs in → session counts against limit (FEAT-07) | Two simultaneous logins at cap, revoked seat, device replacement, expired session release |
| WF-08 | Employer subscribes/recharges (ACT-02) → gateway confirms (ACT-10) → ledger credits/debits for posting/download → invoice/refund (FEAT-08) | Duplicate webhook, partial refund, gateway timeout, insufficient balance, compensating entry |
| WF-09 | User chooses preferences (ACT-01/02) → worker queues alert → provider delivers → support ticket if needed (FEAT-09) | Opt-out, duplicate callback, retry exhaustion, privacy-safe message retention |
| WF-10 | Scheduled worker refreshes marts (ACT-11) → admin reviews funnel, sourcing and finance metrics (ACT-08) (FEAT-10) | Late source events, stale mart, mismatched totals, null KPI denominator |
| WF-11 | External provider responds (ACT-10) → reference, status and audit recorded (FEAT-11) | Duplicate/out-of-order callback, provider outage, untrusted signature, reconciliation gap |
| WF-12 | Engineer loads synthetic seed (ACT-16) → checks quality → captures plans/timings → tests access and restores snapshot → auditor (ACT-09) reviews evidence (FEAT-12) | Capacity ceiling, skewed data, failed query, restore beyond RTO, incomplete evidence |
