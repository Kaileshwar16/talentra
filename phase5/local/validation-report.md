# Local seed validation — 2026-10-21

Target: existing `queryparity-postgres-1` container, PostgreSQL 17.11,
database `talentra_local` on `127.0.0.1:15432`. These results are local and
do not describe the Neon production branch.

| Check | Observed |
| --- | ---: |
| Candidate profiles | 1,000,000 |
| Job requirements | 100,000 |
| Applications | 5,000,000 |
| Application statuses represented | 7 of 7 |
| Non-ASCII synthetic names | 400,000 |
| Orphan applications | 0 |
| PostgreSQL database size after all examples | 5,473 MB |
| Host free space after load | about 3.6 GiB |

Additional examples: 100 gig workers, 100 gig requests, 100 assignments,
10 licences, 10 subscriptions, 10 payments, five refunds, ten outreach
recipients, 1,000 notification deliveries, ten community discussions,
one audit event and ten application funnel rows. Exact current counts can
be checked with [validate.sql](validate.sql).

Rollback-only validation on this seeded database passed:

| Suite | Result |
| --- | --- |
| Phase 1 constraints | 26/26 |
| Phase 2 constraints | 36/36 |
| Phase 3 constraints | 37/37 |
| Phase 4 constraints | 20/20 |

The DBeaver login `talentra_viewer` was tested over localhost: it sees the
1,000,000 candidate rows and 100 gig requests, with `SELECT` on the latter
and no `INSERT` privilege on `candidate_profile`. The password is in the
ignored, mode-600 `phase5/local/.env` file.

This proves the laptop-scale core row counts and selected integrity checks.
It does not prove all reference lookups or profile detail are populated,
that analytics marts reconcile after the final load, or that the performance,
security and recovery gates are complete. The local schema combines physical
Phase 2 tables with required legacy public tables for the Phase 5 examples;
it is not a byte-for-byte copy of Neon production.
