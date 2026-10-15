# Phase 2 relationship models

These diagrams show the main links for B27–B29. [relationships.csv](docs/relationships.csv) contains every installed foreign key, including the composite ownership keys.

## Administration (B27)

```mermaid
erDiagram
    USER_ACCOUNT ||--o{ USER_ROLE : receives
    APP_ROLE ||--o{ USER_ROLE : assigned_as
    APP_ROLE ||--o{ ROLE_PERMISSION : allows
    PERMISSION ||--o{ ROLE_PERMISSION : granted_by
    USER_ACCOUNT ||--o| DB_PRINCIPAL : authenticates_as
    USER_ACCOUNT ||--o{ CREDENTIAL : owns
    USER_ACCOUNT ||--o{ SESSION_RECORD : starts
    USER_ACCOUNT ||--o{ USER_CONSENT : records
    USER_ACCOUNT ||--o{ AUDIT_EVENT : acts_in
    CANDIDATE_PROFILE ||--o{ USER_BLOCK : creates
    USER_BLOCK }o--o| USER_ACCOUNT : blocks_user
    USER_BLOCK }o--o| ORGANISATION : blocks_company
```

`DB_PRINCIPAL` maps one database login role to one account. The role/permission and user/role joins decide access at query time. A user block has exactly one target: another account or an organisation.

## Organisation and account (B28)

```mermaid
erDiagram
    ACCOUNT_PROFILE ||--o{ ORGANISATION : contains
    ORGANISATION ||--o{ ORGANISATION : parent_of
    ORGANISATION ||--o{ ORGANISATION_LOCATION : has
    ORGANISATION ||--o{ ORGANISATION_IDENTIFIER : has
    ORGANISATION ||--o{ VERIFICATION_RECORD : verified_by
    ACCOUNT_PROFILE ||--o{ ACCOUNT_ADMINISTRATOR : managed_by
    USER_ACCOUNT ||--o{ ACCOUNT_ADMINISTRATOR : administers
    ORGANISATION ||--o{ ORGANISATION_MEMBER : includes
    ORGANISATION ||--o{ ORGANISATION_RECRUITER : maps
    USER_ACCOUNT ||--o{ ORGANISATION_RECRUITER : recruited_as
    ORGANISATION_RECRUITER ||--o{ JOB_RECRUITER_ASSIGNMENT : authorizes
    JOB_REQUIREMENT ||--o{ JOB_RECRUITER_ASSIGNMENT : assigned_to
```

Parent and child organisations share an account. A job assignment points to both its job's organisation and the same recruiter's active company mapping. Effective-dated intervals are half-open and cannot overlap for the same subject.

## Gig marketplace (B29)

```mermaid
erDiagram
    USER_ACCOUNT ||--o| GIG_WORKER_PROFILE : works_as
    GIG_WORKER_PROFILE ||--o{ GIG_SERVICE : offers
    GIG_WORKER_PROFILE ||--o{ GIG_AVAILABILITY : declares
    ORGANISATION ||--o{ GIG_REQUEST : requests
    GIG_REQUEST ||--o{ GIG_APPLICATION : receives
    GIG_WORKER_PROFILE ||--o{ GIG_APPLICATION : submits
    GIG_APPLICATION ||--o| GIG_ASSIGNMENT : accepted_as
    GIG_ASSIGNMENT ||--o| GIG_RATING : rated_after
    GIG_ASSIGNMENT ||--o{ FULFILMENT_EVENT : reconciled_from
    ORGANISATION ||--o{ GIG_WORKER_LIST_ENTRY : keeps
    GIG_WORKER_PROFILE ||--o{ GIG_WORKER_LIST_ENTRY : listed_in
    GIG_WORKER_PROFILE ||--o{ WORKER_PROJECT : reports
```

Workers submit applications to requester-created gigs. A single accepted application may become one assignment. The assignment stores the same worker, request and exact time window as its parents, and worker assignment windows cannot overlap.
