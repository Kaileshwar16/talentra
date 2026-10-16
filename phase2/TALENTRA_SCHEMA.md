# Talentra Phase 2: Administration, Organisation & Gig Marketplace (Modules 4–6)

This document provides the complete data dictionary, architectural design specifications, constraint rules, and security model for Phase 2, implementing Milestones 7–10 and backlogs **B24–B35** from the [hackathon docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf).

---

## 1. Module Overview & Schema Organization

Phase 2 introduces 45 production-grade tables partitioned into three dedicated PostgreSQL schemas, extending the Phase 1 relational foundation:

| Schema | Module | Tables | Functional Scope |
| --- | --- | --- | --- |
| `identity` | Module 4: Administration & RBAC | 16 | Authentication credentials, session tracking, platform roles, granular permissions, user consents, blocking policies, security principals, and tamper-evident audit trails. |
| `organisation` | Module 5: Organisation & Account | 12 | Corporate account profiles, multi-tier legal entity hierarchies, verified business locations, encrypted tax identifiers, compliance verifications, member rosters, recruiter mappings, and job recruiter assignments. |
| `gig` | Module 6: Gig Marketplace | 17 | Specialized gig worker profiles, rate cards/services, availability intervals, client gig requests, worker applications, confirmed assignments, external provider fulfilment reconciliations, client ratings, and worker shortlists. |

---

## 2. Administration & RBAC (`identity` Schema)

### Core Entities & Data Dictionary

1. **`identity.app_role`**: Defines system authorization roles.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `code VARCHAR(50) NOT NULL UNIQUE`: Canonical role identifier (`SUPER_ADMIN`, `ADMIN`, `ACCOUNT_ADMIN`, `GUEST`, `CANDIDATE`, `EMPLOYER`, `RECRUITER`, `CONSULTANT`, `PLACEMENT_OFFICER`).
   - `name VARCHAR(100) NOT NULL`, `description TEXT`, `is_system BOOLEAN DEFAULT true`.

2. **`identity.permission`**: Fine-grained authorization operations.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `code VARCHAR(100) NOT NULL UNIQUE`: Action resource string (e.g., `job:create`, `candidate:read_contact`).
   - `module VARCHAR(50) NOT NULL`, `action VARCHAR(50) NOT NULL`.

3. **`identity.role_permission`**: Maps permissions to application roles.
   - `role_id BIGINT REFERENCES identity.app_role(id) ON DELETE RESTRICT`
   - `permission_id BIGINT REFERENCES identity.permission(id) ON DELETE RESTRICT`
   - `PRIMARY KEY (role_id, permission_id)`.

4. **`identity.user_role`**: Temporal assignment of roles to user accounts.
   - `user_account_id BIGINT REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `role_id BIGINT REFERENCES identity.app_role(id) ON DELETE RESTRICT`
   - `valid_from TIMESTAMPTZ NOT NULL`, `valid_to TIMESTAMPTZ`
   - `EXCLUDE USING gist (user_account_id WITH =, role_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&)`: Rejects overlapping assignment intervals for the same user and role.

5. **`identity.credential`**: Protected authentication secrets.
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `credential_type VARCHAR(50) NOT NULL` (`PASSWORD_HASH`, `OIDC_SUB`, `API_KEY`).
   - `secret_hash VARCHAR(255)`: Encrypted hash (Argon2id/bcrypt). Plaintext secrets are strictly prohibited.

6. **`identity.session_record`**: Active browser and API session state.
   - `session_digest VARCHAR(64) NOT NULL UNIQUE`: SHA-256 session token digest.
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `ip_address INET`, `user_agent TEXT`, `expires_at TIMESTAMPTZ NOT NULL`.

7. **`identity.user_consent`**: Immutable GDPR/privacy consent records.
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `consent_type VARCHAR(100) NOT NULL`, `consent_version VARCHAR(20) NOT NULL`.
   - `granted BOOLEAN NOT NULL`, `recorded_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - Append-only: Rejects UPDATE, DELETE, and TRUNCATE via database triggers.

8. **`identity.user_block`**: Candidate blocking controls.
   - `candidate_profile_id BIGINT NOT NULL REFERENCES public.candidate_profile(id) ON DELETE RESTRICT`
   - `blocked_user_account_id BIGINT REFERENCES public.user_account(id)`
   - `blocked_organisation_id BIGINT REFERENCES public.organisation(id)`
   - `CHECK ((blocked_user_account_id IS NOT NULL AND blocked_organisation_id IS NULL) OR (blocked_user_account_id IS NULL AND blocked_organisation_id IS NOT NULL))`: Enforces mutual exclusivity.
   - Row-level security filters out blocked candidates from recruiter and company discovery queries.

9. **`identity.audit_event`**: Append-only security audit journal.
   - `actor_user_id BIGINT REFERENCES public.user_account(id)`
   - `target_schema VARCHAR(63) NOT NULL`, `target_table VARCHAR(63) NOT NULL`, `target_record_id BIGINT NOT NULL`.
   - `action_type VARCHAR(20) NOT NULL` (`INSERT`, `UPDATE`, `DELETE`, `LOGIN`, `ACCESS`).
   - `recorded_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - Immutable: Protected by `identity.reject_mutation()` trigger.

10. **`identity.db_principal`**: Connects PostgreSQL database login roles with platform user accounts.
    - `db_role_name VARCHAR(63) NOT NULL UNIQUE`
    - `user_account_id BIGINT NOT NULL UNIQUE REFERENCES public.user_account(id) ON DELETE RESTRICT`

---

## 3. Organisation & Account (`organisation` Schema)

### Core Entities & Data Dictionary

1. **`organisation.account_profile`**: Top-level commercial billing and account container.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `name VARCHAR(200) NOT NULL`, `account_type VARCHAR(50) NOT NULL DEFAULT 'EMPLOYER'`.
   - `verification_status VARCHAR(50) NOT NULL DEFAULT 'PENDING'`.

2. **`organisation.organisation`** (and extended `public.organisation`):
   - `account_id BIGINT NOT NULL REFERENCES organisation.account_profile(id) ON DELETE RESTRICT`
   - `parent_organisation_id BIGINT REFERENCES public.organisation(id) ON DELETE RESTRICT`
   - Recursive hierarchy cycle check enforced via `organisation.check_hierarchy_cycle()` trigger.

3. **`organisation.organisation_location`**: Operating and registered office locations.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`
   - `city_id BIGINT REFERENCES public.city(id) ON DELETE RESTRICT`
   - `address_line1 VARCHAR(255) NOT NULL`, `postal_code VARCHAR(20) NOT NULL`.
   - `is_headquarters BOOLEAN NOT NULL DEFAULT false`.

4. **`organisation.organisation_identifier`**: Tax registration and corporate legal IDs.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`
   - `identifier_type VARCHAR(50) NOT NULL` (e.g., `EIN`, `GSTIN`, `VAT`, `CRN`).
   - `encrypted_value BYTEA NOT NULL`: Application-encrypted bytes.
   - `fingerprint_sha256 VARCHAR(64) NOT NULL UNIQUE`: Cryptographic hash for collision detection.

5. **`organisation.organisation_recruiter`**: Recruiter employment mappings.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`
   - `recruiter_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `valid_from TIMESTAMPTZ NOT NULL`, `valid_to TIMESTAMPTZ`
   - `EXCLUDE USING gist (recruiter_user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&)`: Guarantees that a recruiter can represent only one active organisation at any instant in time.

6. **`organisation.job_recruiter_assignment`**: Specific job delegation for recruiters.
   - `job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON DELETE RESTRICT`
   - `organisation_recruiter_id BIGINT NOT NULL REFERENCES organisation.organisation_recruiter(id) ON DELETE RESTRICT`
   - Composite trigger validates that the job belongs to the same organisation as the recruiter's active mapping.

---

## 4. Gig Marketplace (`gig` Schema)

### Core Entities & Data Dictionary

1. **`gig.gig_worker_profile`**: Specialized freelance service profile.
   - `user_account_id BIGINT NOT NULL UNIQUE REFERENCES public.user_account(id) ON DELETE RESTRICT`
   - `headline VARCHAR(200) NOT NULL`, `hourly_rate NUMERIC(12,2)`, `currency_id BIGINT REFERENCES public.currency(id)`.
   - `rating_average NUMERIC(3,2) DEFAULT 0.00`, `total_assignments_completed INTEGER DEFAULT 0`.

2. **`gig.gig_availability`**: Time calendar windows for gig execution.
   - `gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON DELETE RESTRICT`
   - `available_from TIMESTAMPTZ NOT NULL`, `available_to TIMESTAMPTZ NOT NULL`
   - `EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(available_from, available_to, '[)') WITH &&)`: Prevents overlapping availability schedules.

3. **`gig.gig_request`**: Employer work orders / scopes of work.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`
   - `title VARCHAR(200) NOT NULL`, `pricing_model VARCHAR(50) NOT NULL` (`FIXED_PRICE`, `HOURLY`, `MILESTONE`).
   - `budget_amount NUMERIC(14,2) NOT NULL CHECK (budget_amount >= 0)`.
   - `starts_at TIMESTAMPTZ NOT NULL`, `ends_at TIMESTAMPTZ NOT NULL CHECK (ends_at > starts_at)`.

4. **`gig.gig_application`**: Freelancer proposal for a gig request.
   - `gig_request_id BIGINT NOT NULL REFERENCES gig.gig_request(id) ON DELETE RESTRICT`
   - `gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON DELETE RESTRICT`
   - `application_status VARCHAR(50) NOT NULL DEFAULT 'PENDING'` (`PENDING`, `ACCEPTED`, `REJECTED`, `WITHDRAWN`).
   - `UNIQUE (gig_request_id, gig_worker_profile_id)`: Exactly one proposal per worker per request.

5. **`gig.gig_assignment`**: Binding contract upon client acceptance.
   - `gig_request_id BIGINT NOT NULL REFERENCES gig.gig_request(id) ON DELETE RESTRICT`
   - `gig_worker_profile_id BIGINT NOT NULL REFERENCES gig.gig_worker_profile(id) ON DELETE RESTRICT`
   - `assigned_from TIMESTAMPTZ NOT NULL`, `assigned_to TIMESTAMPTZ NOT NULL`
   - `EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(assigned_from, assigned_to, '[)') WITH &&)`: Strictly guarantees that a gig worker cannot be double-booked across overlapping assignment windows.

6. **`gig.fulfilment_event`**: Append-only integration journal with external delivery providers.
   - `gig_assignment_id BIGINT NOT NULL REFERENCES gig.gig_assignment(id) ON DELETE RESTRICT`
   - `external_event_id VARCHAR(100) NOT NULL UNIQUE`: Provider idempotency tracking.
   - `event_type VARCHAR(50) NOT NULL`, `reconciled_earnings NUMERIC(12,2)`.
   - Immutable: Protected against UPDATE and DELETE.

---

## 5. Security & Row-Level Security (RLS) Policies

1. **Runtime Role**: `talentra_runtime` NOLOGIN group role with restricted data access.
2. **Actor Resolution**: `identity.actor_user_id()` securely returns the logged-in user account ID based on `SESSION_USER` matched against `identity.db_principal`.
3. **RLS Policies**:
   - `candidate_profile`: Candidates read/update only their own record; recruiters only see unblocked candidates.
   - `job_requirement`: Recruiters only see and update jobs assigned to them within their active organisation mapping.
   - `organisation`: Members and administrators access only organisations within their own corporate account.
   - `gig_assignment`: Workers view only their assigned work; employers view only their posted gigs.
