# Phase 5 — production seed status

For the separate local PostgreSQL container and DBeaver connection, see
[local/README.md](local/README.md). Its physical Phase 2 schema requires
local-only compatibility SQL; local row counts are independent of Neon.

This directory contains the synthetic seed used for Milestone 19 (B60–B64) of
the [docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf). The
production target is Neon project `jolly-pond-45332483`, branch
`br-jolly-dawn-azv4gh54` (`production`), database `neondb`.

## Verified production result — 2026-10-16 06:47 UTC

| Area | Seeded result | Docket target |
| --- | ---: | ---: |
| Candidate profiles | 250,000 | 1,000,000 |
| Job requirements | 25,000 | 100,000 |
| Applications | 1,250,000 | 5,000,000 |
| Synthetic accounts / organisations | 100 / 100 | Examples across modules |

All seven application status IDs have records. The seed includes repeated and
Hindi, Arabic, Chinese, and Russian names. It also includes 100 gig workers,
requests, and assignments; 20 recruiter mappings; 10 subscriptions and
payments; five refunds; 1,000 notification deliveries; and small examples for
the other B62–B64 entities. See [validation-report.json](docs/validation-report.json)
for exact counts and checks.

The project currently has a 1 GiB branch limit. At the verified size,
`pg_database_size(neondb)` was 843,079,680 bytes. This PostgreSQL measurement
is a capacity indicator, not Neon's current billable logical-size reading.
The bulk seed stops at 25% of the docket's laptop scale to leave room for
normal writes and later validation.

## Apply the seed

The seed files are ordered and repeatable. Run them against an isolated branch
first, then the target branch. Apply each SQL file as one transaction. Generate
the core stages with `python3 phase5/seeds/generate_core.py STAGE` and execute
its output as SQL. Use this order:

1. `phase5/seeds/001_reference.sql`
2. `generate_core.py accounts --accounts 100`
3. `generate_core.py users --start 1 --end 200000`
4. `generate_core.py candidates --start 1 --end 200000`
5. `generate_core.py jobs --start 1 --end 20000 --accounts 100`
6. `generate_core.py applications --start 1 --end 200000 --jobs 20000 --applications-per-candidate 5`
7. `phase5/seeds/002_administration_gig.sql`
8. `phase5/seeds/003_commercial.sql`
9. `phase5/seeds/004_notifications_shared.sql`
10. `generate_core.py users --start 200001 --end 250000`
11. `generate_core.py candidates --start 200001 --end 250000`
12. `generate_core.py jobs --start 20001 --end 25000 --accounts 100`
13. `generate_core.py applications --start 200001 --end 250000 --jobs 25000 --applications-per-candidate 5`

For Neon MCP, split each SQL file into statements and pass them to
`run_sql_transaction`; use `run_sql` for each generated core batch. The
production run used 10,000-candidate application batches. The application
generation formula requires `--jobs` to match the job count used when creating
that batch. Re-running a previously executed batch is safe because marked
records have conflict or existence guards.

## Remaining Phase 5 work

**Milestone 20 update (2026-10-17):** [B65 fixed queries](queries/b65_fixed_queries.sql), [outputs and top-ten plans](docs/b65-query-results.json), and [query report](docs/b65-query-report.md) are available for the current partial production seed. The [B66 seed validation report](docs/b66-seed-validation.md) records measured quality checks and the gap register. [B67–B69 module validation](docs/b67-b69-module-validation.md) records module-specific results and missing fixtures. [Production Phase 2 reconciliation](docs/production-phase2-reconciliation.md) records catalog-level access gaps and the blocked role test. Milestone 20 artifacts exist but the seed and access gaps prevent sign-off; B65 plans are not latency measurements.

- B60/B61: The full 1M / 100K / 5M scale needs more capacity. The reference
  set is representative, not a complete taxonomy. Candidate profiles currently
  have names and headlines, with no large-scale education, skills, or resumes.
- B62: The 100 gig assignments are non-overlapping examples; overlap rejection
  was not exercised as part of this production seed.
- B64: The analytics rows are small synthetic examples created before the last
  core expansion. Refresh and validate marts before using them for reporting.
- Milestone 20: B65–B69 query and validation artifacts exist for the partial
  seed, but the listed coverage gaps prevent milestone sign-off.
- Milestones 21–23: Performance baselines, security review, recovery exercise,
  and final handoff remain separate work.

Production has the Phase 3–4 migrations `004_phase3.sql`, `005_phase4.sql`, and
`006_phase3_gap_closure.sql`. Its Phase 2 `identity`, `organisation`, and `gig`
objects differ from the test branch: most are compatibility views over public
tables, not the physical Phase 2 tables used by the repository's Phase 2 test
suite. The full Phase 2 migration could not be applied to production without
reconciling those existing views. Do not read prior test-branch results as
production validation of that physical schema.
