# Local PostgreSQL seed for DBeaver

The local Talentra database is `talentra_local` in the **existing**
`queryparity-postgres-1` PostgreSQL 17 container. Docker publishes it on
`127.0.0.1:15432`. The container's QueryParity databases are separate.
The password for the dedicated read-only login is stored in this directory's
ignored `.env` file; do not commit or share it.

In DBeaver, choose PostgreSQL and use host `127.0.0.1`, port `15432`, database
`talentra_local`, user `talentra_viewer`, and the `TALENTRA_DB_PASSWORD` value
from `phase5/local/.env`. The login can read all synthetic schemas and bypasses
row security solely for inspecting this local seed. It has no write grants.

Useful checks in DBeaver:

```sql
SELECT count(*) FROM public.candidate_profile;
SELECT count(*) FROM public.job_requirement;
SELECT count(*) FROM public.application;
SELECT pg_size_pretty(pg_database_size(current_database()));
SELECT c.id, u.email, u.full_name
FROM public.candidate_profile AS c
JOIN public.user_account AS u ON u.id = c.user_account_id
WHERE u.email = 'seed5-00000001@talentra.example';
SELECT id, title FROM public.job_requirement
WHERE title = 'Phase 5 Job 000001';
```

## Why local compatibility SQL is needed

The phased migrations were written for Neon PostgreSQL 18. On a fresh local
database, Phase 1 and 2 need the two `neon_auth` foreign-key targets in
`000_neon_auth_fk_stubs.sql`. These empty tables are only FK targets; they do
not implement authentication.

Phase 3 refers to a legacy `public.account_profile` table that Phase 2 does
not create, and its gap-closure migration refers to subscription window
columns omitted by its own base migration. The `001` and `002` local scripts
fill those prerequisites. The Phase 5 account generator assumes the Neon
production compatibility-view layout; `003_accounts_physical_phase2.sql`
creates matching rows in the two physical account tables used locally.
These compatibility files are scoped to this local database and do not alter
Neon.

The core seed uses `phase5/seeds/generate_core.py`. It is synthetic, with
`.example` addresses. `seed_core.sh` resumes the verified 100,000 candidate /
10,000 job / 500,000 application checkpoint toward the docket's laptop-scale
1,000,000 / 100,000 / 5,000,000 target. Each batch is a transaction and is
safe to rerun. The script stops starting new batches when less than 2 GiB is
free on the host filesystem. This protects the reused container and other
local work. Check the final counts before claiming the target is met.

## Verified local result — 2026-10-21

The final [validation query](validate.sql) returned **1,000,000** candidates,
**100,000** jobs and **5,000,000** applications in `talentra_local`. All seven
application statuses have rows, 400,000 synthetic names contain non-ASCII
characters, and no application lacked its candidate or job. The database was
5,473 MB after all seed files. There were about 3.6 GiB free on the host.

The small all-module examples also loaded: 100 gig workers, requests and
assignments; 10 subscriptions, licences and payments; five refunds; ten
outreach recipients and community discussions; 1,000 notification deliveries;
one audit event; and ten funnel rows. These are representative examples,
not complete B60–B64 coverage: reference taxonomies and candidate detail are
still sparse, gig overlap attempts need explicit validation, and marts need
refresh/reconciliation after the full core load.

The repository's `002_administration_gig.sql` runs after the public legacy
tables from `migrations/004_organisation_hierarchy_and_recruitment.sql`,
`006_gig_marketplace.sql`, and the public-table portion (lines 1–616) of
`008_complete_modules_4_to_11_enterprise_entities.sql`. The latter's
compatibility-view section must not be applied over physical Phase 2 tables.
`migrations/003_administration_and_rbac.sql` and
`004_user_credential.sql` provide public audit, consent and credential tables.
The full legacy `007` migration conflicts with Phase 4's notification table.

The original `003_commercial.sql` and `004_notifications_shared.sql` assume
the Neon production compatibility layout. Their reviewed local equivalents
are [003_commercial_physical.sql](003_commercial_physical.sql) and
[004_notifications_shared_physical.sql](004_notifications_shared_physical.sql).
The local setup also uses [005_licence_legacy_columns.sql](005_licence_legacy_columns.sql)
to supply two fields referenced by the Phase 3 trigger but omitted by its
base migration.

All four rollback-only phase suites passed on the seeded local database:
Phase 1 26/26, Phase 2 36/36, Phase 3 37/37, and Phase 4 20/20.
The tests needed portable fixture columns and owner-role handling, plus
missing uniqueness on notification idempotency, ticket reference, and two
analytics rollup keys. Those unique indexes are now in the Phase 4 migration
and installed locally. They were not applied to Neon in this work.
