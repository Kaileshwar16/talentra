# Decisions, evidence and G1 gate

| ID | Decision / assumption | Reason and evidence | Consequence or owner |
| --- | --- | --- | --- |
| DEC-01 | Use PostgreSQL 18 on Neon for this assignment. | Docket allows PostgreSQL/MySQL; existing migrations and Neon project use PostgreSQL 18. | Keep SQL portable only where useful; PostgreSQL constraints are authoritative. |
| DEC-02 | Keep gig work separate from core job/application records, joined in reporting. | Different actors, availability windows, bid direction and external fulfilment (section 2); existing `gig` schema reflects this. | Define cross-domain KPI mapping; enforce gig integrity separately. |
| DEC-03 | Treat source docket as obligations and playbook/student notes as method. | Their phase numbering and example scales differ. | Do not replace docket targets with teaching examples. |
| DEC-04 | Treat production seed and test-branch schema as distinct evidence. | [Phase 5 status](../../phase5/README.md) reports compatibility views; live Neon read found 1 `identity` base table and 15 views on production. | Reconcile Phase 2 design before claiming production RLS equivalence. |
| DEC-05 | Keep proposed service targets unapproved. | Docket gives scale and measurement deliverables but no accepted p95, RTO or retention durations. | Product/security owner must decide NFR-06–10. |
| DEC-06 | Use the existing local PostgreSQL container for the laptop-scale seed. | [Local validation](../../phase5/local/validation-report.md) records the full core counts and constraint-suite results; Neon branch capacity blocked the same load there. | Preserve Neon production as separate evidence; local counts do not establish production RLS or performance. |

## Live Neon observation

Read-only query on 2026-10-17 15:07:56 UTC, project `jolly-pond-45332483`, branch `br-jolly-dawn-azv4gh54`, database `neondb`: 250,000 candidate profiles; 25,000 jobs; 1,250,000 applications; `pg_database_size` 843,079,680 bytes. Branch listing reported 867,188,736 logical bytes against 1,073,741,824 limit, a different metric from `pg_database_size`. A second read found 10 `analytics_application_funnel_daily` rows (latest `report_date` 2026-10-16), 1,000 notification deliveries, and zero applications with null candidate/job IDs. [Query](neon-observation.sql) and [result](neon-observation.json) preserve the observation. These are observations, not a complete quality audit.

## Gate register

| Item | Status | Closure evidence |
| --- | --- | --- |
| Docket problem, scope and core requirements | Reviewable artifacts prepared | Domain owner checks sentence-level mapping, especially Tier 2 and rule groups |
| Actor linkage and feature/workflow linkage | Reviewable artifacts prepared | Product/security review of TPO, guest, account-admin and blocked-party semantics |
| Three-platform feature benchmark | Reviewable artifact prepared | Official-source comparison exists; validate field-level Talentra coverage and avoid an unsupported exceed claim |
| Numeric NFR targets | Partial | Accept or replace proposed latency, availability, RTO/RPO, retention and freshness targets |
| Independent challenge/review | Open | Named reviewer comments on schema, field meaning, omissions and actual sample data; record resolution |
| G1 Problem understood | **Open** | All above closed; every requirement has actor, every accepted NFR has metric/test, each must-have feature has workflow |

Next work after G1: complete the playbook model dictionary/privacy register against current tables, map existing SQL tests to `TC` IDs, then execute remaining Phase 5 validation against the local full-scale seed and separately confirm production compatibility on Neon. Do not apply the old [all-module draft](../../sources/talentra_schema.sql) to production.
