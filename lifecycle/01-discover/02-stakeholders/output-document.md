# 02 Output document — Stakeholders, Personas and Roles

The database serves people who look for work, people who hire, staff who operate the platform, and systems that send or receive events. This document says **who each actor is, what they need, how often they act, and where access stops**. The [actor register](../actors-goals-features.md) carries the stable ACT IDs. Permissions below are proposed policy for review; they are not proof of current production grants.

## Actor roster: goals, access and frequency

Frequency describes a normal trigger, not a measured usage statistic. A person may hold more than one role, but permissions must be checked for the active role and account context on each action.

| ID / actor | Goal | Proposed permission boundary | Typical frequency or trigger |
| --- | --- | --- | --- |
| ACT-01 Candidate | Find work and control their profile | Own profile, applications, preferences and blocks | At registration, then each search/application/status check |
| ACT-02 Employer/client | Fill jobs and approve gig work | Own verified organisation, its postings and scoped applicants | Each hiring campaign |
| ACT-03 Recruiter | Source and contact candidates | Only active assigned jobs of the recruiter’s own company; no candidate registration | Each assigned sourcing campaign |
| ACT-04 Consultant | Source for an approved request | Only consultant-open jobs after employer approval | Per request or shortlist |
| ACT-05 Placement officer/TPO | Coordinate campus candidates | Campus-linked data only after ownership and consent rules are approved | Campus drives and placement periods |
| ACT-06 Gig worker | Offer services, bid and track work | Own gig profile, availability, bids and earnings reference | Per opportunity or assignment |
| ACT-07 Guest | Discover public jobs | Published public listings only | Anonymous visit |
| ACT-08 Account Admin | Operate one customer account | Seats, subscriptions, mappings and account-scoped records | Onboarding and account changes |
| ACT-14 Admin | Resolve incidents and support escalations | Ticketed, time-limited action | Incident or support escalation |
| ACT-15 Super Admin | Govern platform policy | Logged exceptional elevation and platform policy | Policy change or exceptional incident |
| ACT-16 Database engineer | Build and prove the database design | Development/test access; production changes through an approved path | Migration, seed, test or restore run |
| ACT-09 Auditor/security reviewer | Verify controls and evidence | Read audit/test evidence; no standing personal-data access | Audit cycle or incident |
| ACT-10 External provider | Return payment, verification, fulfilment or delivery result | Authenticated callback/reference only; no direct candidate table access | Provider callback or reconciliation |
| ACT-11 Scheduled worker | Refresh marts and reconcile states | Narrow service principal for one scheduled task | Daily or configured schedule |
| ACT-12 Support staff | Resolve a user ticket | Ticket-scoped metadata; personal data requires approved elevation | Per support case |
| ACT-13 Regulator/data-protection authority | Review a formal request | Approved evidence export through privacy owner; no standing database login | Complaint or lawful request |

The source docket explicitly names nine platform roles. Gig worker, auditor, provider, scheduled worker, support, regulator and database engineer are additional actors needed to explain the work and its boundaries; listing them does not grant access.

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
| Admin (ACT-14) | Resolve support and operating issues | Excessive access to identity/payment data | Ticket-scoped action and sensitive-action log |
| Super Admin (ACT-15) | Govern platform-wide policy | Privilege misuse | Controlled elevation and independent audit |
| Database engineer (ACT-16) | Run migration, seed, tests and restore | Test credentials accidentally used for live data | Reproducible evidence from the named environment |
| Gig worker (ACT-06) | Publish availability, bid, complete gig | Overlap, duplicate bid, external handoff failure | One valid assignment and reconciled status |
| Security reviewer (ACT-09) | Review access, recovery and audit evidence | Owner-level access masks policy defects | Separate-role test evidence |
| External provider (ACT-10) | Return payment/fulfilment/delivery result | Duplicate or out-of-order callback | Idempotent accepted event or recorded rejection |
| Scheduled worker (ACT-11) | Refresh marts and reconcile | Stale totals or overbroad service role | Scoped job, timestamped refresh, source reconciliation |
| Support staff (ACT-12) | Resolve a ticket or failed transaction | Excessive access while troubleshooting | Case-scoped resolution and recorded access |
| Regulator / data-protection authority (ACT-13) | Review a formal complaint or evidence request | Incomplete or overbroad disclosure | Approved, dated and auditable evidence export |

## Actor-to-requirement trace

| Actor IDs | Requirement IDs | Principal workflow |
| --- | --- | --- |
| ACT-01 Candidate | REQ-01–02, REQ-04–05, REQ-11, REQ-15–16 | WF-01–03, WF-09 |
| ACT-02 Employer/client | REQ-02, REQ-06–08, REQ-10–12, REQ-15–16 | WF-02, WF-04–06, WF-08–10 |
| ACT-03 Recruiter | REQ-02–06, REQ-08 | WF-02–04, WF-06 |
| ACT-04 Consultant | REQ-04, REQ-08 | WF-03, WF-06 |
| ACT-05 TPO | REQ-01–02 | WF-01–02, pending campus permission decision |
| ACT-06 Gig worker | REQ-07 | WF-05 |
| ACT-07 Guest | REQ-02–03 | WF-02–03, public view only |
| ACT-08 Account Admin | REQ-06, REQ-09–10 | WF-04, WF-07–08 |
| ACT-14 Admin | REQ-03, REQ-05, REQ-11–14, REQ-17–18 | WF-03, WF-09–12 |
| ACT-15 Super Admin | REQ-03, REQ-05, REQ-14, REQ-17–18 | WF-03, WF-12 |
| ACT-16 Database engineer | REQ-14, REQ-17–18 | WF-12 |
| ACT-09 Auditor/security reviewer | REQ-09, REQ-14, REQ-17–18 | WF-12 |
| ACT-10 Provider | REQ-10–11, REQ-13 | WF-08–09, WF-11 |
| ACT-11 Scheduled worker | REQ-12–13 | WF-10–11 |
| ACT-12 Support staff | REQ-11 | WF-09 |
| ACT-13 Regulator | REQ-14 | WF-12, evidence export only |

The table identifies affected actors beyond the minimum actor named on each requirement. Scope and permissions are proposed until access tests and owner review complete.

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
| TPO | Deny candidate edits | Deny until campus link and candidate consent are verified; then campus scope only | Campus-approved job read | Deny | Deny |
| Account Admin | Deny | No candidate contact by default; own-account applicant access only under approved policy | Own account governance | Own account governance | Own seats/subscriptions; audit |
| Admin | Deny by default | Ticketed, time-limited case elevation | Ticketed support action | Ticketed support action | Task-scoped audit |
| Super Admin | Logged exceptional elevation | Logged, time-limited exceptional access | Platform governance | Platform governance | Platform audit/policy |
| Provider / worker | Deny | Deny | Narrow callback/job only | Narrow callback/job only | Idempotent event/refresh only |
| Support staff | Deny | Case-scoped metadata only; personal data requires elevation | Ticket-linked correction only | Ticket-linked correction only | Case-scoped support and audit read |
| Regulator | Deny | No standing access; approved export only | No standing access | No standing access | Approved evidence export only |
| Database engineer | Development/test only | No default production read | Migration under approved path | Migration under approved path | Seed, plan, constraint and restore evidence |

The enforcing layer for each allowed row must be database RLS/constraints or an authenticated access-layer operation; the UI alone is insufficient. Product/security review is open for TPO, guest, account-admin and exceptional administrator access. Test intents [TC-08](../test-case-graph.md) and [WF-03/WF-04](../nfr-workflows.md) cover same-company scope, blocked parties and audit.

## What the matrix means in a real decision

Suppose Recruiter R works for Company A and opens Job J owned by Company B. The access layer resolves R’s active company and assignment before loading J; the result must be **denied and audited**, even if R knows J’s ID. If Company A owns J but the assignment expired yesterday, the same denial applies. If Candidate C has blocked R or Company A, C must not appear in R’s candidate search or contact action. A user-interface filter alone would leave the data exposed to direct queries, so the database policy or authenticated service operation must enforce the predicate.

An auditor can inspect the denial record and policy test result without receiving Candidate C’s contact details. Support can see the related ticket and a masked identifier; a temporary personal-data view requires an approved case and its own audit event. This is the intended boundary to test, not an assertion that every production role already behaves this way.

## Handoffs that need owners

| Handoff | Sender → receiver | Record produced | Failure owner / proposed response |
| --- | --- | --- | --- |
| Candidate application | Candidate → employer/recruiter | Application and stage event | Product owner defines retry, duplicate and withdrawal rules |
| Consultant sourcing request | Consultant → employer | Request decision and shortlist | Employer decides; rejected/expired request blocks further sourcing |
| Gig assignment | Requester → fulfilment provider | Handoff reference and status | Operations reconciles timeout with a stable idempotency key |
| Payment confirmation | Gateway → account/ledger worker | One payment event and ledger entry | Finance/operations reconciles duplicate or missing callbacks |
| Complaint/evidence request | Support/privacy owner → regulator | Approved export and disclosure log | Privacy owner checks lawful scope and redaction |

**Decision still needed:** the domain and security owners must sign off the TPO, guest, support and exceptional-admin predicates, then run two-account tests using separate principals. The presence of an ACT ID or a table is not a deployed permission test.
