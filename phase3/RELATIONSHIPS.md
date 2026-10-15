# Talentra Phase 3: Entity Relationships & ER Diagrams

This document details the relational architecture, foreign key constraints, and entity diagrams for Modules 7, 8, and 9 (Phase 3).

---

## 1. Module 7: Plans, Licences, Seats, Devices & Sessions

```mermaid
erDiagram
    account_profile ||--o{ account_subscription : subscribes
    subscription_plan ||--o{ account_subscription : defines
    account_profile ||--o{ account_licence : allocates
    subscription_plan ||--o{ account_licence : defines
    account_licence ||--o{ licence_seat_assignment : assigns
    user_account ||--o{ licence_seat_assignment : occupies
    user_account ||--o{ device_session : registers

    subscription_plan {
        bigint id PK
        varchar code UK
        varchar name
        integer tier_level
        varchar billing_period
        numeric price_amount
        integer max_seats
        integer candidate_download_credits
    }

    account_subscription {
        bigint id PK
        bigint account_profile_id FK
        bigint subscription_plan_id FK
        varchar subscription_status
        timestamptz current_period_starts_at
        timestamptz current_period_ends_at
    }

    account_licence {
        bigint id PK
        bigint account_profile_id FK
        bigint subscription_plan_id FK
        varchar licence_key UK
        integer allocated_seats
        varchar licence_status
    }

    licence_seat_assignment {
        bigint id PK
        bigint account_licence_id FK
        bigint user_account_id FK
        varchar seat_role
        timestamptz valid_from
        timestamptz valid_to
        boolean is_active
    }

    device_session {
        bigint id PK
        bigint user_account_id FK
        varchar device_fingerprint
        varchar device_type
        varchar session_token_hash UK
        boolean is_active
        timestamptz expires_at
    }
```

---

## 2. Module 8: Sourcing, Consultant Requests & Recruiter Workflows

```mermaid
erDiagram
    organisation ||--o{ sourcing_pool : owns
    sourcing_pool ||--o{ sourcing_pool_candidate : includes
    candidate_profile ||--o{ sourcing_pool_candidate : contains
    user_account ||--o{ sourcing_pool_candidate : "added by"
    job_requirement ||--o{ consultant_request : "commissioned for"
    user_account ||--o{ consultant_request : "consultant agent"
    organisation ||--o{ consultant_request : "consultant agency"

    sourcing_pool {
        bigint id PK
        bigint organisation_id FK
        varchar pool_name
        varchar target_role
        boolean is_private
    }

    sourcing_pool_candidate {
        bigint id PK
        bigint sourcing_pool_id FK
        bigint candidate_profile_id FK
        bigint added_by_user_id FK
        varchar sourcing_channel
        numeric candidate_match_score
    }

    consultant_request {
        bigint id PK
        bigint job_requirement_id FK
        bigint consultant_user_account_id FK
        bigint consultant_organisation_id FK
        numeric commission_rate_percent
        varchar request_status
    }
```

---

## 3. Module 9: Subscriptions, Wallets, Payments & Ledger

```mermaid
erDiagram
    account_profile ||--|| wallet_account : "maintains balance"
    currency ||--o{ wallet_account : denominates
    wallet_account ||--o{ wallet_transaction_ledger : records
    account_profile ||--o{ payment_transaction : executes
    wallet_account ||--o{ payment_transaction : credits
    subscription_plan ||--o{ payment_transaction : purchases
    candidate_profile ||--o{ profile_download_event : "resume viewed"
    user_account ||--o{ profile_download_event : "downloaded by"
    wallet_transaction_ledger ||--o{ profile_download_event : "debited by"

    wallet_account {
        bigint id PK
        bigint account_profile_id FK, UK
        integer balance_credits
        bigint currency_id FK
        varchar wallet_status
    }

    wallet_transaction_ledger {
        bigint id PK
        bigint wallet_account_id FK
        varchar transaction_type
        integer credit_amount
        integer credits_delta
        integer balance_after
        varchar idempotency_key UK
        varchar reference_order_id
        timestamptz recorded_at
    }

    payment_transaction {
        bigint id PK
        bigint account_profile_id FK
        bigint wallet_account_id FK
        bigint subscription_plan_id FK
        numeric amount
        bigint currency_id FK
        varchar payment_status
        varchar payment_gateway
        varchar gateway_transaction_id UK
        varchar idempotency_key UK
    }

    profile_download_event {
        bigint id PK
        bigint candidate_profile_id FK
        bigint downloader_user_account_id FK
        bigint recruiter_user_account_id FK
        bigint wallet_transaction_id FK
        varchar download_format
        inet ip_address
        timestamptz occurred_at
    }
```

---

## 4. Integrity and Immutability Controls

1. **Non-Overlapping Active Seats**:
   Seat allocations prevent concurrent active assignments for the same licence and user.
2. **Append-Only Financial Ledger**:
   `public.wallet_transaction_ledger` enforces append-only semantics via the `talentra_reject_mutation()` trigger, preventing unauthorized updates or deletions.
3. **Download Traceability**:
   `public.profile_download_event` links every resume export event to the candidate profile, downloading recruiter, client IP address, and ledger debit transaction.
4. **Transaction Idempotency**:
   Unique indexes on `idempotency_key` prevent duplicate payment processing or duplicate credit allocations from webhook retries.
