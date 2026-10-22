# Actors, goals and feature discovery

Section 3 of the docket names nine human roles. The actor IDs below separate its three administrator roles and add gig, audit, support and system boundaries. Their permissions are proposed for review, not claims about current production grants.

| ID | Actor | Goal | Allowed data/action boundary | Frequency or trigger |
| --- | --- | --- | --- | --- |
| ACT-01 | Candidate | Build profile, apply, track progress, control visibility | Own profile/applications; block parties | Registration, search, application |
| ACT-02 | Employer / client | Post requirements, decide on applicants and gigs | Own organisation and jobs | Hiring demand |
| ACT-03 | Recruiter | Source/contact candidates for assigned jobs | Active assignments within own company; never candidate registration | Sourcing campaign |
| ACT-04 | Consultant | Source for an open requirement | Only consultant-open requirements after request approval | Consultant request |
| ACT-05 | Placement officer (TPO) | Support campus hiring | Scoped campus candidate/job relationships; exact grants to define | Campus campaign |
| ACT-06 | Gig worker | Offer services and apply to gigs | Own profile, availability, bids and assignments | Gig opportunity |
| ACT-07 | Guest | Discover permitted public information | Published public data only | Anonymous search |
| ACT-08 | Account Admin | Govern one customer account | Account-scoped seats, subscriptions and mappings; sensitive acts audited | Onboarding and account changes |
| ACT-09 | Security reviewer / auditor | Verify access, audit and recovery | Read evidence; access to personal data only under explicit control | Review or incident |
| ACT-10 | External provider | Return payment, verification, fulfilment or delivery result | Idempotent boundary events, no direct candidate access | Callback/reconciliation |
| ACT-11 | Scheduled worker | Refresh marts and reconcile status | Narrow service principal and job-specific permissions | Schedule |
| ACT-12 | Support staff | Resolve account, payment and delivery tickets | Case-scoped metadata; no default candidate contact or payment secrets | Ticket or incident |
| ACT-13 | Regulator / data-protection authority | Review lawful complaint or compliance response | Approved evidence export through privacy owner; no standing production login | Complaint or formal request |
| ACT-14 | Admin | Resolve platform support and operating incidents | Ticketed, time-limited action; no default broad candidate read | Incident or support escalation |
| ACT-15 | Super Admin | Govern global policy and exceptional access | Platform policy; logged elevation for sensitive data | Policy change or exceptional incident |
| ACT-16 | Database engineer / evidence runner | Build the model and produce reproducible proof | Development/test environment and approved migration path; no default production personal-data read | Migration, seed, test or restore exercise |

The TPO, guest and account-admin grants require explicit authorization design. There are no employer sub-roles in this docket version. No role should inherit unrestricted candidate contact access from a broad account grant.

## Outcome graph

| ID | Outcome | Evidence needed | Related requirements |
| --- | --- | --- | --- |
| GOAL-01 | Consistent candidate and job records | Duplicate/orphan checks, field quality, coverage | REQ-01, REQ-02, REQ-14 |
| GOAL-02 | One defensible hiring pipeline | Reconciled event/status counts and funnel definitions | REQ-02, REQ-12 |
| GOAL-03 | Better retention and placement decisions | Cohort retention and conversion KPI definitions plus baseline | REQ-01, REQ-12 |
| GOAL-04 | Safe multi-tenant operations | Role isolation, blocked-party, audit and recovery tests | REQ-03–05, REQ-14 |
| GOAL-05 | Sustainable revenue and gig operations | Ledger reconciliation, assignment integrity, external status matching | REQ-07, REQ-10, REQ-13 |

GOAL-03 has no source-defined numeric success threshold; observing a large seed is not evidence of improved retention.

## Feature inventory

`Must` means mandatory for the database assignment, `Expected` means Tier 2 or an explicit justification, `Stretch` means optional. The three-platform comparison below uses official public materials accessed 2026-10-17. It compares documented data coverage, not running product behavior or complete feature parity.

| ID | Capability | Priority | Requirement / goal | Workflow |
| --- | --- | --- | --- | --- |
| FEAT-01 | Candidate profile, resumes and related history | Must + Expected details | REQ-01, REQ-15 / GOAL-01 | WF-01 |
| FEAT-02 | Jobs, questionnaires and application pipeline | Must | REQ-02 / GOAL-02 | WF-02 |
| FEAT-03 | Access, blocking, consent and audit | Must | REQ-03–05 / GOAL-04 | WF-03 |
| FEAT-04 | Organisation and recruiter mapping | Must | REQ-06 / GOAL-04 | WF-04 |
| FEAT-05 | Separate gig marketplace and fulfilment reference | Must | REQ-07 / GOAL-05 | WF-05 |
| FEAT-06 | Sourcing, consultant request and outreach | Must | REQ-08 / GOAL-02 | WF-06 |
| FEAT-07 | Seats, devices, sessions and revocation | Must | REQ-09 / GOAL-04 | WF-07 |
| FEAT-08 | Subscriptions, wallet, refunds and downloads | Must | REQ-10 / GOAL-05 | WF-08 |
| FEAT-09 | Preferences, notifications, support/community | Must | REQ-11 / GOAL-03 | WF-09 |
| FEAT-10 | Analytics and optional reference insights | Must + Stretch domains | REQ-12, REQ-16 / GOAL-02–03 | WF-10 |
| FEAT-11 | External integration reference contracts | Must | REQ-13 / GOAL-05 | WF-11 |
| FEAT-12 | Seed, validation, performance and recovery evidence | Must | REQ-14 / GOAL-01–05 | WF-12 |

### Required competitor study: evidence register

| Platform | Candidate data fields evidenced | Employer data fields evidenced | Talentra design comparison | Evidence limit |
| --- | --- | --- | --- | --- |
| Naukri | [Profile guide](https://static.naukimg.com/rstatic/docs/Naukri_Confidential_Guide_%28for_candidates%29.pdf) documents skills, employment/designation and resume; [Resdex](https://recruit.naukri.com/recruit/resume-database-access-resdex) exposes location, industry and skill filters. | [Job posting](https://recruit.naukri.com/recruit/job-posting) supports postings, applicants and CV recommendations. | Talentra schema matches profile, skills, job and application domains; separate gig/ledger domains may add coverage, but comparative product depth is unproven. | Public documentation does not establish Naukri's entire internal data model. |
| Monster | [Applicant management](https://hiring.monster.com/help-center/job-postings/managing-your-jobs-and-applicants/applicant-management-with-monster/) documents work experience, skills, education and resumes; [resume upload](https://www.monster.com/resume/upload) describes visibility controls. | [Applicant management](https://hiring.monster.com/help-center/job-postings/managing-your-jobs-and-applicants/applicant-management-with-monster/) shows pipeline and applicant details; [FAQ](https://hiring.monster.com/help-center/faqs-and-resources/monster-faqs/) describes employer/company profile. | Talentra schema matches core profile, resume, posting and pipeline concepts; blocked-party enforcement and gig handoff require separate behavioral comparison. | Product tier and region may change available fields. |
| LinkedIn | [Profile guidance](https://socialimpact.linkedin.com/content/dam/me/socialimpact-linkedin-com/lifg-resources/linkedin-training-content/linkedin-profile-tip-sheet.pdf) documents experience, education, skills and optional sections. | [Company Pages](https://www.business.linkedin.com/advertise/linkedin-pages) document company name, industry, site and description; [Career Pages](https://business.linkedin.com/in/en/hire/company-career-pages/features) document jobs and insights. | Talentra schema matches profile/organisation/job basics and adds an explicit gig and financial ledger model; LinkedIn's network/endorsement depth is outside the current core design. | A public page cannot prove all stored fields or data quality. |

The docket asks Talentra to exceed competitors in the domains that matter. These sources support a **coverage hypothesis**, not that success claim. A field-level audit of Talentra's data dictionary and product-specific access to competing flows are needed before claiming that it exceeds any of them.
