# Production Phase 2 schema and access reconciliation

Read-only Neon catalog inspection on 2026-10-17, project `jolly-pond-45332483`, production branch `br-jolly-dawn-azv4gh54`, database `neondb`.

| Namespace | Base tables | Views | RLS-enabled objects among them |
| --- | ---: | ---: | ---: |
| `identity` | 1 | 15 | 0 |
| `organisation` | 0 | 12 | 0 |
| `gig` | 0 | 17 | 0 |

The inspected `identity.user_block`, `identity.audit_event`, `organisation.job_recruiter_assignment` and `gig.gig_assignment` views directly select from like-named `public` tables. They are owner (`neondb_owner`) views without `security_invoker` or `security_barrier` reloptions. The inspected `public.candidate_profile`, `application`, `job_requirement`, `user_block`, recruiter mapping, gig assignment and audit tables have `relrowsecurity=false`; there are zero policies on the inspected candidate/application/job/block tables. This production shape is materially different from the physical Phase 2 migration and its test-branch RLS evidence.

`talentra_runtime` is `NOLOGIN`/`NOBYPASSRLS`. Catalog privilege checks show it has `USAGE` on `public` and `SELECT` on `public.candidate_profile`, while it lacks `SELECT` on `public.application` and `identity.user_block`. `neondb_owner` is a member of `talentra_runtime` with `inherit_option=false` and `set_option=false`; a read-only attempt to `SET LOCAL ROLE talentra_runtime` returned `permission denied to set role`. Thus this inspection **does not prove an active login can read all candidates through that role**, but neither does it demonstrate the docket's candidate/block/recruiter isolation in production. An access-layer implementation was not present in this repository snapshot for verification.

## Required before B79/security sign-off

1. Decide whether to retain the compatibility-view layout or migrate to the physical Phase 2 design on an isolated Neon branch. Preserve existing seed and references while comparing object contracts.
2. Establish the actual application login/role and its grants. Run role-scoped tests for candidate ownership, blocked-party invisibility, recruiter company/assignment scope and consultant-open jobs using two accounts and seeded negative cases.
3. Check direct `public` table access as well as the compatibility views. Add or verify RLS/access-layer enforcement and audit traces, then rerun Phase 1–4 regression tests and B79 scenarios.
4. Record a reviewed migration/diff and a rollback path before any production change.

No production DDL or access grants were changed during this inspection.
