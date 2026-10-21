# 02 Output document — Stakeholders, Personas and Roles

The [actor register](../actors-goals-features.md) links ACT-01–11 to goals, frequency, requirements and workflows. This document expands the docket's nine human roles into task-focused persona cards and a proposed permission matrix. Permission entries are design intent, not proof of current Neon grants.

## Persona cards

| Persona / actor | Trigger and main task | Pain or risk | Success signal |
| --- | --- | --- | --- |
| Candidate (ACT-01) | Register, control profile, apply and track | Duplicate identity, unwanted contact, opaque status | One owned profile and visible application history |
| Employer (ACT-02) | Verify company, post job, decide applicants | Fragmented pipeline and wrong-company access | Own jobs and candidates reviewed within policy |
| Recruiter (ACT-03) | Source/contact for assigned company jobs | Stale mapping or blocked candidate | Authorized outreach with audit; no candidate registration |
| Consultant (ACT-04) | Accept request and source for an open job | Job not open to consultants, revoked approval | Scoped sourcing with commission decision recorded |
| Placement officer / TPO (ACT-05) | Coordinate campus candidates and roles | Campus ownership and consent ambiguity | Campus-scoped access approved and logged |
| Guest (ACT-07) | Browse permitted public jobs | Accidental personal-data exposure | Published jobs only, no private candidate records |
| Account Admin (ACT-08) | Maintain one account, seats and recruiters | Scope leakage to another account | Account-scoped changes with audit trail |
| Admin (ACT-08) | Resolve support and operating issues | Excessive access to identity/payment data | Task-scoped action and sensitive-action log |
| Super Admin (ACT-08) | Govern platform-wide policy | Privilege misuse | Controlled elevation and independent audit |
| Gig worker (ACT-06) | Publish availability, bid, complete gig | Overlap, duplicate bid, external handoff failure | One valid assignment and reconciled status |
| Security reviewer (ACT-09) | Review access, recovery and audit evidence | Owner-level access masks policy defects | Separate-role test evidence |
| External provider (ACT-10) | Return payment/fulfilment/delivery result | Duplicate or out-of-order callback | Idempotent accepted event or recorded rejection |
| Scheduled worker (ACT-11) | Refresh marts and reconcile | Stale totals or overbroad service role | Scoped job, timestamped refresh, source reconciliation |

## Proposed role–permission matrix

`Own`, `account`, `assignment` and `public` are scope predicates, not blanket grants. `Review` means no access rule can be finalized without the owner.

| Role | Profile write | Candidate read/contact | Job create/decide | Gig apply/decide | Admin/finance/audit |
| --- | --- | --- | --- | --- | --- |
| Guest | Deny | Deny | Public published read only | Public listing only | Deny |
| Candidate | Own | Own; block others | Apply/withdraw own | Review if also gig worker | Deny |
| Gig worker | Own gig profile | Own | Deny | Own bid; requester decides | Own earnings reference |
| Employer | Deny | Scoped applicants, blocked-party filter | Own organisation | Requester on own gig | Own account invoices |
| Recruiter | **Deny registration** | Contact only if assignment + same company + no block | Assigned jobs only | Deny unless separately authorized | Deny financial admin |
| Consultant | Deny | Approved request + no block | Consultant-open job only | Deny | Own commission record |
| TPO | Review campus-owned records | Review scoped campus consent | Review campus jobs | Deny | Deny |
| Account Admin | Deny | Scoped account policy only | Own account governance | Own account governance | Own seats/subscriptions; audit |
| Admin | Deny by default | Case-based elevation | Support action only | Support action only | Task-scoped audit |
| Super Admin | Controlled elevation | Logged exceptional access | Governance | Governance | Platform audit/policy |
| Provider / worker | Deny | Deny | Narrow callback/job only | Narrow callback/job only | Idempotent event/refresh only |

The enforcing layer for each allowed row must be database RLS/constraints or an authenticated access-layer operation; the UI alone is insufficient. Product/security review is open for TPO, guest, account-admin and exceptional administrator access. Test intents [TC-08](../test-case-graph.md) and [WF-03/WF-04](../nfr-workflows.md) cover same-company scope, blocked parties and audit.
