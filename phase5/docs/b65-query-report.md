# B65 fixed query set — production observation

Run on 2026-10-17 against Neon project `jolly-pond-45332483`, branch `br-jolly-dawn-azv4gh54` (`production`), database `neondb`. [The exact SQL](../queries/b65_fixed_queries.sql) and [full result/plan bundle](b65-query-results.json) are the deliverables. All twelve queries are `SELECT`; Q01–Q10 have `EXPLAIN` plans with `analyze=false`. Plans are optimizer estimates, **not measured latency**. No indexes or rows were changed.

| Query | Purpose | Result | Plan headline |
| --- | --- | --- | --- |
| Q01 | Candidate lookup | One synthetic candidate (ID 46) | Primary-key index scan |
| Q02 | Recent published jobs | 20 rows | Sequential scan and sort on 25k jobs; measure before tuning |
| Q03 | Candidate application history | Five applications | Candidate FK index scan plus sort/join |
| Q04 | Job pipeline | 108 applications across seven statuses for job 29 | Pipeline index-only scan plus status lookup |
| Q05 | Recruiter assignment | Mapping exists, **zero assigned jobs** | Recruiter index bitmap scan; empty assignment table |
| Q06 | Gig assignment status | 20 request/assignment rows | Small-table sequential scans |
| Q07 | Consultant eligibility | One request; linked job is consultant-open | Consultant scan plus job PK lookup |
| Q08 | Wallet/ledger | One wallet, one ledger entry, zero credits | Wallet PK and ledger FK index scans |
| Q09 | Outreach deliveries | Ten batch rows, each with one delivered recipient | Small-table scans and join |
| Q10 | Notification delivery | 900 delivered, 100 failed | Scan/group of 1,000 rows |
| Q11 | Funnel mart freshness | Ten rows, latest report date 2026-10-16, 500 applied | No plan requested; mart does not represent the 1.25m application seed |
| Q12 | Application integrity | 1.25m applications, zero null candidate/job IDs | No plan requested; this is not a full orphan check |

The sample IDs were selected from live rows after the first attempt showed IDs 1 were absent from candidate/job tables. Q05 intentionally exposes the missing recruiter-job assignment fixture. Delivery statuses in this seed are uppercase; Q09 uses `DELIVERED`. These corrections are reflected in the final SQL and result bundle.

**B65 status: complete at the current partial seed size.** B60/B61 scale remains 25% of target, and B66–B69 still need module-level validation. B70 requires repeated latency samples (p50/p95/p99), hardware/compute details, and a controlled run method. Do not treat the `EXPLAIN` cost or MCP round-trip time as that baseline.
