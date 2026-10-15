# Talentra Phase 2: Administration, organisation and gig marketplace

Phase 2 implements Milestones 7–10, backlogs **B24–B35**, in the [hackathon docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf). The module overview labels Gig marketplace as Phase 3, but the explicit Phase 2 milestone and B26/B29/B32/B35 place it here; this deliverable follows the milestone. The three module owners in the docket are Member A, Member B and Member C. No named human assignment or sign-off is claimed.

The migrations were applied to the existing **Nithin / Talentra / production / neondb** Neon project, after [Phase 1](../phase1/TALENTRA_SCHEMA.md). They expand `public.user_account` and `public.organisation` in place, retain all 103 Phase 1 public tables, and add 45 tables under `identity`, `organisation`, and `gig`. The nine Neon Auth tables remain unchanged. The installed catalog and tests are summarized in [validation-report.json](docs/validation-report.json).

The [relationship diagrams](RELATIONSHIPS.md) provide a readable view of the three modules; the CSV inventory remains the complete foreign-key record.

## Deliverables

| Backlog | Deliverable | Evidence |
| --- | --- | --- |
| B24 | Administration entities: identity bindings, credentials, sessions, roles, permissions, consent, blocks, audit and error log | [entities.csv](docs/entities.csv), `identity.*` in [migration 002](migrations/002_phase2.sql) |
| B25 | Organisation/account entities: account, hierarchy, locations, identifiers, verification, members, recruiters and administrators | Entity inventory, `organisation.*` and expanded `public.organisation` |
| B26 | Gig entities: worker profile, services, availability, requests, applications, assignments, lists, rating and fulfilment events | Entity inventory, `gig.*` |
| B27–B29 | Enforced role/permission, account/recruiter/job, and gig worker/request/application/assignment relationships | [relationships.csv](docs/relationships.csv), composite FKs and integration tests |
| B30–B32 | Types, domains, nullability and suggested sensitive data classes for all three modules | [columns.csv](docs/columns.csv) |
| B33 | Database role and permission checks, row access policies, append-only audit | [policies.csv](docs/policies.csv), [security_functions.csv](docs/security_functions.csv), [tests](tests/phase2_constraints.sql) |
| B34 | Account hierarchy, recruiter mapping, job assignment and effective dates | Exclusion and composite constraints in [constraints.csv](docs/constraints.csv); mapping tests |
| B35 | Gig price/window/decision rules; no overlapping worker assignments | Exclusion constraints and accepted-application, window, rating and idempotency tests |

All tables use BIGINT identity primary keys, snake_case names, `created_at`, `created_by`, `updated_at`, `updated_by`, and `deleted_at`. Actor fields are nullable for system and seed actions but are foreign keys when supplied. Other nullable columns are explained in the column inventory. Foreign keys restrict parent deletion and key updates. Business entities are soft-deleted; audit, consent, fulfilment events and error logs reject UPDATE, DELETE and TRUNCATE. Every change to a Phase 1 table classified as Personal or Sensitive, and the principal Phase 2 business tables, generates a separate append-only audit event containing the actor, table, row ID, action and transaction ID. It does not copy secrets, identifiers or whole records.

## Administration and access

`public.user_account` remains the application account anchor. `neon_auth.user` is the external source for browser identity; its optional UUID link is preserved. `identity.credential` stores only a platform-issued Argon2id/bcrypt hash or an external reference, never a password or token in clear text. `identity.session_record` stores a SHA-256 session digest and optional Neon Auth session UUID. Its device and seat limits are Phase 3 work.

Nine docket actor roles are seeded: super admin, admin, account admin, guest, candidate, employer, recruiter, consultant and placement officer. Roles have explicit permissions and effective-dated user assignments. The database has one `talentra_runtime` **NOLOGIN** group role. Each future application account that needs direct database access must receive its own PostgreSQL LOGIN role, membership in `talentra_runtime`, and a `identity.db_principal` mapping to `user_account`. A privileged provisioning service must create that mapping and assign roles. No login roles or passwords are provisioned by these migrations. `identity.actor_user_id()` uses the authenticated PostgreSQL login/current role and the protected mapping, rather than a client-writable custom setting. The Neon owner has `BYPASSRLS`; it is for migration/maintenance and must never be an end-user connection.

The runtime role has narrow grants. Row policies on candidate profiles, job requirements, organisations and core gig tables enforce who may see them. A recruiter sees and updates only a job assigned to them within their active mapping to that job's organisation. A candidate can read and edit their own profile. Recruiters cannot insert candidate profiles or assign themselves roles. A candidate's block hides that candidate from the blocked person or organisation even when an application exists. Consultants can read only jobs explicitly open to consultants. Employers/account administrators are scoped to their organisation/account. Other tables have no direct runtime grant; writes to them need a trusted service transaction with explicit authorization. The [function grants migration](migrations/003_restrict_security_functions.sql) removes public access to internal security functions and grants the runtime role only ten policy entry points.

Access to candidate contact, documents, applications and other Phase 1 personal tables is intentionally not granted to runtime logins. A future service must expose only needed fields through authorized operations and log sensitive reads. The schema does not provide a complete user-facing API or a production identity-provisioning path. Existing Neon Auth connections must not be assumed to carry a mapped per-user PostgreSQL role without that provisioning layer.

## Organisation and account

Every organisation belongs to an account. The parent organisation, when present, must belong to the same account. A database trigger locks the account while checking the ancestor chain, preventing cycles under concurrent hierarchy edits. Existing Phase 1 organisations, if any, receive an account during migration; new inserts that use the Phase 1 shape get an account automatically. New accounts default to employer type and pending verification when no type/status was supplied; operators should correct those inferred values from source records.

Locations refer to curated cities when available. Tax/registration identifiers carry country and type FKs, encrypted bytes, and a SHA-256 fingerprint for uniqueness. The application/KMS owns encryption, normalization, verification and key rotation; this schema deliberately has no plaintext identifier column. Provider outcomes and references are stored in verification records.

Account administrators, organisation members, recruiter-company mappings and recruiter-job assignments have half-open `[from, to)` time windows. GiST exclusion constraints reject overlapping live memberships/mappings. A recruiter can be mapped to only one company at a time. Job assignment has composite FKs tying together the job's organisation, the recruiter's mapping, and the recruiter. Triggers require the assignment to fit inside the mapping's validity period and prevent shortening a mapping past an existing assignment. A current recruiter role must cover the assignment. Time-bound membership is checked again at read time.

## Gig marketplace

Gigs are a separate subsystem. A gig worker has a profile apart from `candidate_profile`; workers apply to requester-created gig requests. Requesters accept or reject those applications. There is no reverse bidding flow. Services carry a rate and currency, while each request has a positive time window, pricing model, nonnegative amount and currency. Worker availability windows cannot overlap.

An assignment requires an accepted application and a worker availability window covering the whole gig. Its worker, request and exact time window are tied to the application and request with composite FKs. A GiST exclusion constraint prevents two live assignments for the same worker from overlapping; adjacent end/start times are allowed. Once applications exist, a request's window cannot change. Accepted applications cannot later become rejected while an assignment exists. A requester may mark a worker favourite or blacklisted; a blacklisted worker cannot submit a new application. Ratings require a completed assignment and an authorised requester.

Fulfilment is external. The database holds a unique external system/handoff reference, reconciled status, and optional externally supplied estimated, total and projected earnings with separate currency FKs. `gig.fulfilment_event` deduplicates external event IDs and is append-only. The external provider remains the source of truth for actual fulfilment and earnings; the platform caches its last reconciled values and does not execute the work. An integration worker must retry unavailable provider calls using the event ID as the idempotency key and log each accepted event/assignment change. No live provider connection was built in Phase 2.

## Validation, standards and limits

Both migrations were checked on Neon using rollback-only transactions before installation. The 36 Phase 2 integrity/access checks and all 26 Phase 1 regression checks pass on the installed database. Checks cover role scoping, blocked candidates, cross-company recruiter assignments, hierarchy cycles, mapping overlap, immutable audit, gig acceptance/availability/overlap, ratings, provider-event deduplication, and Phase 1 insert compatibility. Test accounts, roles, organisations, gigs and applications were rolled back; only lookup/permission seed rows remain. There is no concurrent-client benchmark or full-scale synthetic data in Phase 2. The [report](docs/validation-report.json) records catalog counts and these limits. B24–B35 have technical deliverables; human Member A/B/C review remains pending.

| Docket standard | Phase 2 disposition |
| --- | --- |
| Naming and keys | Snake case, singular entity names, BIGINT identity PKs and enforced FKs. Constraint names generated by PostgreSQL may differ from the docket's preferred naming pattern; [constraints.csv](docs/constraints.csv) gives exact names. |
| Dates, amounts, unknown values | TIMESTAMPTZ for instants, DATE for calendar dates, NUMERIC plus currency FK for money, NULL for absent values, no sentinel amounts. |
| Enumerations and translation | Typed lookup rows link to `public.reference_code` and English `reference_translation`; UI translation remains Phase 1. |
| Audit and lifecycle | Sensitive writes have minimal audit records; read audit awaits the access layer. Append-only history rejects mutation. Retention/purge automation is deferred. |
| Privileges | Database role mappings, permissions, grants and row policies enforce the documented direct-read/write surface. Service transaction authorization remains an integration task. |
| Gig and company boundaries | External IDs, encrypted company identifiers and event deduplication are modeled; real providers and KMS are not connected. |
| Licences, payments and analytics | Later milestones, outside Phase 2. |

To reproduce in a fresh Neon database that already has Phase 1:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f phase2/migrations/002_phase2.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f phase2/migrations/003_restrict_security_functions.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f phase2/tests/phase2_constraints.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f phase1/tests/phase1_constraints.sql
```

Run the scripts from the repository root as the database owner. The migrations are one-time baselines and fail if run twice. The tests roll back fixtures but can advance identity sequences. Keep credentials out of the repository.
