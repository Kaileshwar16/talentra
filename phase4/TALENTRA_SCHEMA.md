# Talentra Phase 4: Notifications, Community, Support & Analytics (Modules 10–11)

This document provides the complete data dictionary, architectural design specifications, constraint rules, and reporting data mart specifications for Phase 4, implementing Milestones 14–16 of the Talentra Platform.

---

## 1. Module Overview & Schema Organization

Phase 4 introduces 13 production-grade enterprise entities deployed under the `public` schema:

| Module | Entities | Functional Scope |
| --- | --- | --- |
| **Module 10 — Notifications, Preferences and Community** | `notification_template`, `notification_preference`, `notification_delivery`, `support_ticket`, `support_ticket_message`, `faq_article`, `community_discussion`, `community_comment` | Multi-channel templated notifications (Email, SMS, Push, In-App), granular opt-in/opt-out preferences, unforgeable delivery event logging, helpdesk support ticketing with threaded messaging, self-service knowledge base FAQs, and moderated community forum discussions with nested comments. |
| **Module 11 — Analytics Layer and Reporting Marts** | `analytics_refresh_log`, `analytics_application_funnel_daily`, `analytics_recruiter_velocity`, `analytics_sourcing_efficiency`, `analytics_wallet_reconciliation_summary` | Fast-read analytical data marts providing daily aggregated recruitment funnels, recruiter time-to-hire velocity KPIs, multi-channel sourcing conversion rates, and double-entry financial wallet reconciliation summaries with ETL refresh audit tracking. |

---

## 2. Module 10: Notifications, Preferences, Support & Community

### Entities & Data Dictionary

1. **`public.notification_template`**: Parameterized message templates for system events.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `code VARCHAR(100) NOT NULL UNIQUE`: Event trigger code (`JOB_APPLICATION_SUBMITTED`, `INTERVIEW_SCHEDULED`, `OFFER_EXTENDED`, `PASSWORD_RESET`).
   - `channel VARCHAR(30) NOT NULL CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP', 'WHATSAPP'))`.
   - `subject_template TEXT`: Subject line with mustache variable placeholders.
   - `body_template TEXT NOT NULL`: Message template with dynamic interpolation parameters.
   - `is_active BOOLEAN NOT NULL DEFAULT true`.

2. **`public.notification_preference`**: Granular user communication preference settings.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `notification_category VARCHAR(50) NOT NULL CHECK (notification_category IN ('APPLICATION_UPDATES', 'INTERVIEW_REMINDERS', 'MARKETING', 'BILLING_ALERTS', 'SECURITY_NOTICES'))`.
   - `channel VARCHAR(30) NOT NULL CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP', 'WHATSAPP'))`.
   - `is_enabled BOOLEAN NOT NULL DEFAULT true`.
   - `CONSTRAINT uq_user_pref UNIQUE (user_account_id, notification_category, channel)`.

3. **`public.notification_delivery`**: Delivery state machine log.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `notification_template_id BIGINT REFERENCES public.notification_template(id) ON DELETE RESTRICT`.
   - `channel VARCHAR(30) NOT NULL CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP', 'WHATSAPP'))`.
   - `recipient_address VARCHAR(255) NOT NULL`: Destination email, phone, or push device token.
   - `payload JSONB NOT NULL DEFAULT '{}'::jsonb`: Interpolated parameters.
   - `delivery_status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (delivery_status IN ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED'))`.
   - `sent_at TIMESTAMPTZ`, `delivered_at TIMESTAMPTZ`.
   - `external_reference VARCHAR(100)`: Dispatch provider message ID (SendGrid, Twilio, Firebase).

4. **`public.support_ticket`**: Helpdesk customer support tickets.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `ticket_number VARCHAR(50) NOT NULL UNIQUE`: Formatted human-readable ticket code (`TKT-202610-0001`).
   - `user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `organisation_id BIGINT REFERENCES public.organisation(id) ON DELETE RESTRICT`.
   - `assigned_agent_user_id BIGINT REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `subject VARCHAR(200) NOT NULL`, `category VARCHAR(50) NOT NULL`, `priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT'))`.
   - `status VARCHAR(50) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'WAITING_ON_USER', 'RESOLVED', 'CLOSED'))`.
   - `created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `resolved_at TIMESTAMPTZ`.

5. **`public.support_ticket_message`**: Chronological support ticket conversation messages.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `support_ticket_id BIGINT NOT NULL REFERENCES public.support_ticket(id) ON DELETE RESTRICT`.
   - `sender_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `message_body TEXT NOT NULL`.
   - `is_internal_note BOOLEAN NOT NULL DEFAULT false`: Private agent notes hidden from customers.
   - `sent_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.

6. **`public.faq_article`**: Self-service platform documentation.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `category VARCHAR(50) NOT NULL`, `slug VARCHAR(150) NOT NULL UNIQUE`.
   - `question VARCHAR(300) NOT NULL`, `answer_markdown TEXT NOT NULL`.
   - `sort_order INTEGER NOT NULL DEFAULT 0`, `is_published BOOLEAN NOT NULL DEFAULT true`.
   - `view_count INTEGER NOT NULL DEFAULT 0`, `helpful_count INTEGER NOT NULL DEFAULT 0`.

7. **`public.community_discussion`**: User forum discussion threads.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `author_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `category VARCHAR(50) NOT NULL`, `title VARCHAR(250) NOT NULL`.
   - `content TEXT NOT NULL`, `view_count INTEGER NOT NULL DEFAULT 0`, `upvote_count INTEGER NOT NULL DEFAULT 0`.
   - `is_pinned BOOLEAN NOT NULL DEFAULT false`, `is_locked BOOLEAN NOT NULL DEFAULT false`.

8. **`public.community_comment`**: Threaded replies on community discussions.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `community_discussion_id BIGINT NOT NULL REFERENCES public.community_discussion(id) ON DELETE RESTRICT`.
   - `author_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `parent_comment_id BIGINT REFERENCES public.community_comment(id) ON DELETE RESTRICT`: Nested hierarchical replies.
   - `content TEXT NOT NULL`, `upvote_count INTEGER NOT NULL DEFAULT 0`.

---

## 3. Module 11: Analytics Layer & Reporting Marts

### Entities & Data Dictionary

1. **`public.analytics_refresh_log`**: Audit tracking of ETL aggregate pipeline refreshes.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `mart_name VARCHAR(100) NOT NULL`: Name of refreshed reporting mart.
   - `refresh_started_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()`.
   - `refresh_completed_at TIMESTAMPTZ`.
   - `rows_processed INTEGER NOT NULL DEFAULT 0`.
   - `status VARCHAR(50) NOT NULL DEFAULT 'RUNNING' CHECK (status IN ('RUNNING', 'COMPLETED', 'FAILED'))`.
   - `error_message TEXT`.

2. **`public.analytics_application_funnel_daily`**: Daily recruitment pipeline conversion metrics.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `report_date DATE NOT NULL`.
   - `job_requirement_id BIGINT NOT NULL REFERENCES public.job_requirement(id) ON DELETE RESTRICT`.
   - `total_applications INTEGER NOT NULL DEFAULT 0`.
   - `shortlisted_count INTEGER NOT NULL DEFAULT 0`.
   - `interviewed_count INTEGER NOT NULL DEFAULT 0`.
   - `offered_count INTEGER NOT NULL DEFAULT 0`.
   - `joined_count INTEGER NOT NULL DEFAULT 0`.
   - `rejected_count INTEGER NOT NULL DEFAULT 0`.
   - `CONSTRAINT uq_funnel_daily UNIQUE (report_date, job_requirement_id)`.

3. **`public.analytics_recruiter_velocity`**: Monthly recruiter productivity metrics.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `report_month DATE NOT NULL`: First day of reporting month.
   - `recruiter_user_account_id BIGINT NOT NULL REFERENCES public.user_account(id) ON DELETE RESTRICT`.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`.
   - `jobs_managed INTEGER NOT NULL DEFAULT 0`.
   - `interviews_conducted INTEGER NOT NULL DEFAULT 0`.
   - `offers_extended INTEGER NOT NULL DEFAULT 0`.
   - `successful_hires INTEGER NOT NULL DEFAULT 0`.
   - `average_days_to_hire NUMERIC(5,2) DEFAULT 0.00`.
   - `CONSTRAINT uq_recruiter_velocity UNIQUE (report_month, recruiter_user_account_id, organisation_id)`.

4. **`public.analytics_sourcing_efficiency`**: Sourcing channel ROI and conversion tracking.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `report_date DATE NOT NULL`.
   - `organisation_id BIGINT NOT NULL REFERENCES public.organisation(id) ON DELETE RESTRICT`.
   - `sourcing_channel VARCHAR(50) NOT NULL`: Pipeline channel (`PORTAL`, `LINKEDIN`, `REFERRAL`, `AGENCY`, `CAMPUS`).
   - `candidates_identified INTEGER NOT NULL DEFAULT 0`.
   - `candidates_contacted INTEGER NOT NULL DEFAULT 0`.
   - `candidates_engaged INTEGER NOT NULL DEFAULT 0`.
   - `candidates_hired INTEGER NOT NULL DEFAULT 0`.
   - `conversion_rate NUMERIC(5,2) DEFAULT 0.00 CHECK (conversion_rate >= 0.00 AND conversion_rate <= 100.00)`.
   - `CONSTRAINT uq_sourcing_eff UNIQUE (report_date, organisation_id, sourcing_channel)`.

5. **`public.analytics_wallet_reconciliation_summary`**: Daily commercial financial summary.
   - `id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`
   - `reconciliation_date DATE NOT NULL`.
   - `wallet_account_id BIGINT NOT NULL REFERENCES public.wallet_account(id) ON DELETE RESTRICT`.
   - `opening_balance NUMERIC(14,2) NOT NULL`.
   - `total_deposits NUMERIC(14,2) NOT NULL DEFAULT 0.00`.
   - `total_deductions NUMERIC(14,2) NOT NULL DEFAULT 0.00`.
   - `closing_balance NUMERIC(14,2) NOT NULL`.
   - `discrepancy_amount NUMERIC(14,2) NOT NULL DEFAULT 0.00`: Difference indicator (`opening + deposits - deductions - closing`).
   - `is_reconciled BOOLEAN NOT NULL DEFAULT true`.
   - `CONSTRAINT uq_wallet_recon_daily UNIQUE (reconciliation_date, wallet_account_id)`.

---

## 4. Architectural & Performance Design

1. **Pre-aggregated Reporting Marts**: The analytics layer avoids costly multi-table joins across large operational tables by pre-aggregating metrics at the appropriate grain (daily/monthly).
2. **Deterministic Refresh Tracking**: `analytics_refresh_log` records timestamps, processed row counts, and status for every batch aggregation run.
3. **Optimized Indexing**: Composite indexes on `(report_date, organisation_id)` support dashboard filtering with sub-millisecond query execution.
