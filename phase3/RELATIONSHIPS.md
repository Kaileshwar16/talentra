# Talentra Phase 3: Entity Relationships & ER Diagrams

This document details the relational architecture, foreign key constraints, and entity diagrams for Modules 7, 8, and 9 (Phase 3) incorporating the 6 gap closure entities deployed under **B36–B47**.

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
    user_account ||--o{ user_device : registers
    account_licence ||--o{ user_device : "counts against quota"
    user_account ||--o{ device_session : "authenticates"
    user_device ||--o{ device_session : "identified as"

    subscription_plan {
        bigint id PK
        varchar code UK
        varchar name
        integer tier_level
        varchar billing_period
        numeric price_amount
        integer max_seats
        integer max_devices_per_seat
        integer candidate_download_credits
    }

    account_subscription {
        bigint id PK
        bigint account_profile_id FK
        bigint subscription_plan_id FK
        varchar subscription_status
        timestamptz starts_at
        timestamptz ends_at
        timestamptz current_period_starts_at
        timestamptz current_period_ends_at
    }

    account_licence {
        bigint id PK
        bigint account_profile_id FK
        bigint subscription_plan_id FK
        varchar licence_key UK
        integer allocated_seats
        integer max_devices_per_user
        varchar licence_status
        boolean is_active
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

    user_device {
        bigint id PK
        bigint user_account_id FK
        bigint account_licence_id FK
        varchar device_fingerprint
        varchar device_name
        varchar device_type
        timestamptz registered_at
        timestamptz revoked_at
    }

    device_session {
        bigint id PK
        bigint user_account_id FK
        bigint user_device_id FK
        varchar device_fingerprint
        varchar session_token_hash UK
        boolean is_active
        timestamptz expires_at
    }
```

---

## 2. Module 8: Sourcing, Outreach Campaigns & Consultant Mandates

```mermaid
erDiagram
    organisation ||--o{ sourcing_pool : owns
    sourcing_pool ||--o{ sourcing_pool_candidate : includes
    candidate_profile ||--o{ sourcing_pool_candidate : contains
    user_account ||--o{ sourcing_pool_candidate : "added by"
    sourcing_pool ||--o{ sourcing_outreach_batch : "targets"
    user_account ||--o{ sourcing_outreach_batch : "created by"
    sourcing_outreach_batch ||--o{ sourcing_outreach_recipient : "dispatches"
    candidate_profile ||--o{ sourcing_outreach_recipient : "received by"
    job_requirement ||--o{ consultant_request : "commissioned for"
    user_account ||--o{ consultant_request : "consultant agent"
    organisation ||--o{ consultant_request : "consultant agency"
    consultant_request ||--o{ consultant_request_decision : "audited by"
    user_account ||--o{ consultant_request_decision : "decided by"

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

    sourcing_outreach_batch {
        bigint id PK
        bigint sourcing_pool_id FK
        bigint created_by_user_id FK
        varchar batch_name
        varchar outreach_channel
        varchar batch_status
        integer total_recipients
    }

    sourcing_outreach_recipient {
        bigint id PK
        bigint outreach_batch_id FK
        bigint candidate_profile_id FK
        varchar delivery_status
        varchar candidate_response
        varchar external_message_id
    }

    consultant_request {
        bigint id PK
        bigint job_requirement_id FK
        bigint consultant_user_account_id FK
        bigint consultant_organisation_id FK
        numeric commission_rate_percent
        varchar request_status
    }

    consultant_request_decision {
        bigint id PK
        bigint consultant_request_id FK
        bigint decided_by_user_id FK
        varchar decision
        text decision_reason
        timestamptz effective_at
    }
```

---

## 3. Module 9: Billing, Invoices, Refunds & Financial Ledger

```mermaid
erDiagram
    account_profile ||--o{ wallet_account : owns
    wallet_account ||--o{ wallet_transaction_ledger : records
    account_profile ||--o{ payment_transaction : pays
    wallet_account ||--o{ payment_transaction : credits
    subscription_plan ||--o{ payment_transaction : purchases
    account_profile ||--o{ invoice : billed_to
    account_subscription ||--o{ invoice : covers
    payment_transaction ||--o{ invoice : settles
    payment_transaction ||--o{ payment_refund : refunded_by
    account_profile ||--o{ payment_refund : credited_to
    candidate_profile ||--o{ profile_download_event : subject
    user_account ||--o{ profile_download_event : downloaded_by
    wallet_transaction_ledger ||--o{ profile_download_event : charged_by

    wallet_account {
        bigint id PK
        bigint account_profile_id FK
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
    }

    payment_transaction {
        bigint id PK
        bigint account_profile_id FK
        bigint wallet_account_id FK
        numeric amount
        bigint currency_id FK
        varchar payment_status
        varchar gateway_transaction_id
        varchar idempotency_key UK
    }

    invoice {
        bigint id PK
        bigint account_profile_id FK
        bigint account_subscription_id FK
        bigint payment_transaction_id FK
        varchar invoice_number UK
        varchar invoice_status
        numeric subtotal_amount
        numeric tax_amount
        numeric total_amount
    }

    payment_refund {
        bigint id PK
        bigint payment_transaction_id FK
        bigint account_profile_id FK
        numeric refund_amount
        varchar refund_status
        varchar refund_type
        varchar gateway_refund_id UK
        varchar idempotency_key UK
    }

    profile_download_event {
        bigint id PK
        bigint candidate_profile_id FK
        bigint downloader_user_account_id FK
        bigint wallet_transaction_id FK
        varchar download_format
        inet ip_address
    }
```
