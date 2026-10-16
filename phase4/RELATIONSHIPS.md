# Talentra Phase 4: Entity Relationships & ER Diagrams

This document details the relational architecture, foreign key constraints, and entity diagrams for Modules 10 and 11 (Phase 4).

---

## 1. Module 10: Notifications, Preferences & Community

```mermaid
erDiagram
    user_account ||--o{ notification_preference : configures
    notification_template ||--o{ notification_delivery : formats
    user_account ||--o{ notification_delivery : receives
    user_account ||--o{ support_ticket : opens
    user_account ||--o{ support_ticket : "assigned to"
    support_ticket ||--o{ support_ticket_message : contains
    user_account ||--o{ support_ticket_message : authors
    user_account ||--o{ community_discussion : creates
    community_discussion ||--o{ community_comment : contains
    user_account ||--o{ community_comment : posts
    community_comment ||--o{ community_comment : replies

    notification_template {
        bigint id PK
        varchar template_code UK
        varchar category
        varchar subject_template
        text body_template
        varchar supported_channels
        boolean is_active
    }

    notification_preference {
        bigint id PK
        bigint user_account_id FK
        varchar category
        boolean in_app_enabled
        boolean email_enabled
        boolean sms_enabled
        boolean push_enabled
        varchar digest_frequency
    }

    notification_delivery {
        bigint id PK
        bigint user_account_id FK
        bigint template_id FK
        varchar channel
        varchar delivery_status
        integer retry_count
        varchar idempotency_key UK
        timestamptz created_at
    }

    support_ticket {
        bigint id PK
        varchar ticket_reference UK
        bigint user_account_id FK
        varchar category
        varchar priority
        varchar ticket_status
        bigint assigned_admin_user_id FK
    }

    support_ticket_message {
        bigint id PK
        bigint support_ticket_id FK
        bigint author_user_account_id FK
        bigint sender_user_account_id FK
        boolean is_staff_reply
        text message_body
    }

    faq_article {
        bigint id PK
        varchar category
        varchar question
        text answer_markdown
        boolean is_published
        integer sort_order
    }

    community_discussion {
        bigint id PK
        bigint author_user_account_id FK
        varchar title
        text body
        varchar category
        boolean is_pinned
        boolean is_moderated
    }

    community_comment {
        bigint id PK
        bigint discussion_id FK
        bigint author_user_account_id FK
        bigint parent_comment_id FK
        text body
        integer upvotes
    }
```

---

## 2. Module 11: Analytics Layer & Reporting Data Marts

```mermaid
erDiagram
    organisation ||--o{ analytics_application_funnel_daily : aggregates
    job_requirement ||--o{ analytics_application_funnel_daily : evaluates
    organisation ||--o{ analytics_recruiter_velocity : tracks
    user_account ||--o{ analytics_recruiter_velocity : measures
    organisation ||--o{ analytics_sourcing_efficiency : computes

    analytics_refresh_log {
        bigint id PK
        varchar mart_name
        date period_start
        date period_end
        integer rows_processed
        varchar refresh_status
        integer duration_ms
        timestamptz refreshed_at
    }

    analytics_application_funnel_daily {
        bigint id PK
        date report_date
        bigint organisation_id FK
        bigint job_requirement_id FK
        integer total_views
        integer total_applications
        integer total_shortlisted
        integer total_interviewed
        integer total_offered
        integer total_joined
        integer total_withdrawn
    }

    analytics_recruiter_velocity {
        bigint id PK
        date report_month
        bigint recruiter_user_account_id FK
        bigint organisation_id FK
        integer total_jobs_managed
        integer total_applications_reviewed
        numeric avg_hours_to_first_review
        numeric avg_days_to_hire
        numeric offer_acceptance_rate_percent
    }

    analytics_sourcing_efficiency {
        bigint id PK
        date report_date
        bigint organisation_id FK
        varchar sourcing_channel
        integer candidates_sourced
        integer candidates_applied
        integer candidates_hired
        numeric channel_conversion_rate
    }

    analytics_wallet_reconciliation_summary {
        bigint id PK
        date reconciliation_date UK
        integer total_credits_purchased
        integer total_credits_granted
        integer total_credits_consumed
        integer total_credits_refunded
        integer net_active_wallet_balance
        integer total_resumes_downloaded
        integer discrepancy_count
    }
```

---

## 3. Cross-Module Reporting Integrity

1. **Analytical Rollup Boundaries**:
   Reporting marts summarize core transaction records without duplicating sensitive personally identifiable information (PII). All personal candidate data remains protected under Module 2 constraints.
2. **Composite Uniqueness**:
   Daily rollup tables enforce composite unique keys (e.g., `report_date + organisation_id + job_requirement_id`) to ensure that scheduled refresh jobs are strictly idempotent and prevent duplicate metrics.
3. **Audit Trail Synchronization**:
   Every analytical pipeline execution writes to `analytics_refresh_log`, capturing duration in milliseconds and row throughput to detect stale caches or data pipeline delays.
