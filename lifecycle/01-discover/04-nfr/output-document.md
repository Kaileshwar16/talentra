# 04 Output document — NFR Discovery

The canonical [NFR-01–10 register](../nfr-workflows.md) provides metrics, targets, basis and verification methods. Docket obligations are scale (1m candidates, 100k jobs, 5m applications for the laptop-scale seed; a 10m/1m/100m full-scale model), fixed-query plans/timing evidence, isolation/audit, referential integrity and recovery evidence. The register marks latency, RTO/RPO, mart freshness and service availability as **team proposals** pending acceptance. Personal-data retention duration is **undetermined**.

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

Owner titles identify who must decide; no individual has accepted these targets yet.
