# Talentra Phase 4: Notifications, Community, Analytics & Reporting (Modules 10–11)

Phase 4 implements omni-channel notifications, delivery retries, user preference matrices, support ticketing, community discussions, and analytical reporting marts covering Milestones 14–16 of the [hackathon docket](../sources/Talentra-Database-Design-Hackathon-Docket.pdf).

## Module Scope

### Module 10 — Notifications, Preferences and Community
- **Notification Templates**: Multilingual template definitions (`notification_template`) categorised by system events (`APPLICATION_UPDATE`, `JOB_ALERT`, `GIG_UPDATE`, `BILLING`, `SECURITY`) and supported delivery channels (`IN_APP,EMAIL,SMS,PUSH`).
- **Notification Preferences**: Granular user toggles (`notification_preference`) per category, in-app/email/sms/push channel enablement, and digest frequencies (`INSTANT`, `DAILY`, `WEEKLY`, `NEVER`).
- **Notification Delivery Queue & History**: Reliable dispatch queue (`notification_delivery`) tracking channel delivery statuses (`QUEUED`, `SENT`, `DELIVERED`, `FAILED`, `READ`), retry counts, error payloads, and unique idempotency keys for deduplication.
- **Support & Ticketing**: Formal ticket system (`support_ticket`) with categorized issues (`ACCOUNT`, `BILLING`, `GIG_DISPUTE`, `KYC`), priorities (`LOW`, `NORMAL`, `HIGH`, `URGENT`), and threaded messages (`support_ticket_message`).
- **Knowledge Base & Community**: Categorized help center articles (`faq_article`), threaded community discussions (`community_discussion`), and nested discussion comments (`community_comment`) with moderation flags.

### Module 11 — Analytics, Reporting and Data Marts
- **Analytics Refresh Tracking**: Rollup execution logs (`analytics_refresh_log`) tracking reporting mart refresh intervals, processed row counts, durations in milliseconds, and status indicators.
- **Daily Application Funnel Mart**: Pre-aggregated funnel metrics (`analytics_application_funnel_daily`) by report date, organization, and job requirement, rolling up total views, applications, shortlists, interviews, offers, hires, and withdrawals.
- **Recruiter Velocity Mart**: Monthly recruiter performance metrics (`analytics_recruiter_velocity`) tracking active job loads, review turnaround times (`avg_hours_to_first_review`), time-to-hire (`avg_days_to_hire`), and offer acceptance rates.
- **Sourcing Channel Efficiency Mart**: Daily channel conversion metrics (`analytics_sourcing_efficiency`) calculating source-to-hire conversion rates across direct search, consultant submissions, referrals, and talent pools.
- **Wallet Financial Reconciliation Mart**: Daily balance integrity summaries (`analytics_wallet_reconciliation_summary`) reconciling credit purchases, plan allowances, debit consumption, refunds, active wallet balances, and identifying discrepancies.

---

## Deliverables & Evidence

| Module | Entity | Schema | Purpose & Constraint Evidence |
| --- | --- | --- | --- |
| 10 | `notification_template` | `public` | Multilingual notification templates with unique template codes |
| 10 | `notification_preference` | `public` | User channel and category delivery preferences |
| 10 | `notification_delivery` | `public` | Queue & log with unique idempotency keys and retry counts |
| 10 | `support_ticket` | `public` | Support tickets with unique ticket references |
| 10 | `support_ticket_message` | `public` | Threaded customer support messages and attachments |
| 10 | `faq_article` | `public` | Published help center articles with sort order |
| 10 | `community_discussion` | `public` | Moderated community discussion threads |
| 10 | `community_comment` | `public` | Nested discussion replies with upvote metrics |
| 11 | `analytics_refresh_log` | `public` | Data mart refresh audit and duration tracking |
| 11 | `analytics_application_funnel_daily` | `public` | Daily recruitment conversion funnel rollups |
| 11 | `analytics_recruiter_velocity` | `public` | Monthly recruiter velocity and offer acceptance rates |
| 11 | `analytics_sourcing_efficiency` | `public` | Channel conversion efficiency rollups |
| 11 | `analytics_wallet_reconciliation_summary`| `public` | Daily credit balance reconciliation |

---

## Migration & Test Execution

### Applied Migrations
1. `phase4/migrations/005_phase4.sql` (SHA-256 verified)

### Automated Test Suite
- `phase4/tests/phase4_constraints.sql`: 20 automated assertion checks validating:
  - Notification template creation and unique template code constraint
  - Notification preference storage and unique user category constraints
  - Notification delivery queueing and idempotency key uniqueness
  - Support ticket reference uniqueness and category defaults
  - Threaded ticket message association
  - FAQ article publication status
  - Community discussion and nested comment creation
  - Analytics refresh log recording
  - Daily application funnel aggregation and composite uniqueness
  - Monthly recruiter velocity metrics and unique composite constraint
  - Sourcing channel efficiency uniqueness
  - Daily financial wallet reconciliation uniqueness
  - Foreign key referential integrity on reporting marts
- **Outcome**: 20/20 checks passed with zero fixture leakage (100% rollback).
