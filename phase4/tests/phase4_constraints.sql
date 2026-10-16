-- =============================================================================
-- Test Suite: phase4_constraints.sql
-- Module Coverage: Phase 4 (Modules 10, 11)
-- Dependencies: Phases 1, 2, 3 deployed
-- Run with psql -v ON_ERROR_STOP=1. Test data is always rolled back.
-- =============================================================================

DO $tests$
DECLARE
  passed INTEGER := 0;
  v_user_a BIGINT;
  v_user_b BIGINT;
  v_org_a BIGINT;
  v_job_a BIGINT;
  v_account_org BIGINT;
  v_notif_tmpl_id BIGINT;
  v_notif_pref_id BIGINT;
  v_delivery_id BIGINT;
  v_ticket_id BIGINT;
  v_msg_id BIGINT;
  v_faq_id BIGINT;
  v_disc_id BIGINT;
  v_comm_id BIGINT;
  v_refresh_id BIGINT;
  v_funnel_id BIGINT;
  v_velocity_id BIGINT;
  v_efficiency_id BIGINT;
  v_recon_id BIGINT;
BEGIN
  -- Begin isolated test block; everything is rolled back at the end
  BEGIN

    -- 1. Setup base test fixtures
    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Four User A', 'phase4-a@example.invalid')
    RETURNING id INTO v_user_a;

    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Four User B', 'phase4-b@example.invalid')
    RETURNING id INTO v_user_b;

    INSERT INTO organisation.account_profile (account_name, account_status_id)
    SELECT 'Phase Four Org Account', id FROM organisation.account_status WHERE code = 'active'
    RETURNING id INTO v_account_org;

    INSERT INTO public.organisation (name, account_profile_id, organisation_type_id, verification_status_id)
    SELECT 'Phase Four Organisation', v_account_org, t.id, s.id
    FROM organisation.organisation_type t CROSS JOIN public.verification_status s
    WHERE t.code = 'employer' AND s.code = 'pending'
    RETURNING id INTO v_org_a;

    INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id)
    SELECT 'Phase 4 Analytics Lead', v_org_a, s.id, w.id, e.id
    FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
    WHERE s.code = 'draft' AND w.code = 'onsite' AND e.code = 'permanent'
    RETURNING id INTO v_job_a;

    -- =========================================================================
    -- MODULE 10: NOTIFICATIONS, PREFERENCES AND COMMUNITY
    -- =========================================================================

    -- Test 1: Create notification_template
    INSERT INTO public.notification_template (
      template_code, category, subject_template, body_template, supported_channels, is_active
    ) VALUES (
      'JOB_APPLICATION_SUBMITTED', 'APPLICATION_UPDATE',
      'Your application for {{job_title}} was received',
      'Hello {{candidate_name}}, your application for {{job_title}} at {{org_name}} has been received.',
      'IN_APP,EMAIL', TRUE
    ) RETURNING id INTO v_notif_tmpl_id;
    passed := passed + 1;

    -- Test 2: Reject duplicate notification_template code
    BEGIN
      INSERT INTO public.notification_template (
        template_code, category, subject_template, body_template
      ) VALUES (
        'JOB_APPLICATION_SUBMITTED', 'JOB_ALERT', 'Duplicate', 'Duplicate body'
      );
      RAISE EXCEPTION 'Test failed: duplicate notification_template was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 3: Set notification_preference
    INSERT INTO public.notification_preference (
      user_account_id, category, in_app_enabled, email_enabled, sms_enabled, push_enabled, digest_frequency
    ) VALUES (
      v_user_a, 'APPLICATION_UPDATE', TRUE, TRUE, FALSE, TRUE, 'INSTANT'
    ) RETURNING id INTO v_notif_pref_id;
    passed := passed + 1;

    -- Test 4: Queue notification_delivery
    INSERT INTO public.notification_delivery (
      user_account_id, template_id, channel, title, body_content, delivery_status, idempotency_key
    ) VALUES (
      v_user_a, v_notif_tmpl_id, 'IN_APP', 'Application Submitted', 'Your application is in review.', 'QUEUED', 'notif-idemp-p4-001'
    ) RETURNING id INTO v_delivery_id;
    passed := passed + 1;

    -- Test 5: Reject duplicate delivery idempotency_key
    BEGIN
      INSERT INTO public.notification_delivery (
        user_account_id, template_id, channel, title, body_content, idempotency_key
      ) VALUES (
        v_user_a, v_notif_tmpl_id, 'EMAIL', 'Application Submitted', 'Duplicate send attempt', 'notif-idemp-p4-001'
      );
      RAISE EXCEPTION 'Test failed: duplicate notification_delivery idempotency_key was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 6: Create support_ticket
    INSERT INTO public.support_ticket (
      ticket_reference, user_account_id, subject, category, priority, ticket_status
    ) VALUES (
      'TICK-2026-P4-001', v_user_a, 'Need help with gig payout verification', 'BILLING', 'HIGH', 'OPEN'
    ) RETURNING id INTO v_ticket_id;
    passed := passed + 1;

    -- Test 7: Reject duplicate support ticket reference
    BEGIN
      INSERT INTO public.support_ticket (ticket_reference, user_account_id, subject, category)
      VALUES ('TICK-2026-P4-001', v_user_b, 'Another ticket', 'GENERAL');
      RAISE EXCEPTION 'Test failed: duplicate ticket_reference was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 8: Create support_ticket_message
    INSERT INTO public.support_ticket_message (
      support_ticket_id, author_user_account_id, sender_user_account_id, is_staff_reply, message_body
    ) VALUES (
      v_ticket_id, v_user_a, v_user_a, FALSE, 'Here are my payment gateway transaction IDs for reconciliation.'
    ) RETURNING id INTO v_msg_id;
    passed := passed + 1;

    -- Test 9: Create FAQ article
    INSERT INTO public.faq_article (
      category, question, answer, answer_markdown, is_published, sort_order
    ) VALUES (
      'BILLING', 'How are candidate profile download credits deducted?',
      'Credits are deducted automatically upon successful PDF resume export.',
      'Credits are deducted automatically upon successful PDF resume export.', TRUE, 1
    ) RETURNING id INTO v_faq_id;
    passed := passed + 1;

    -- Test 10: Create community_discussion
    INSERT INTO public.community_discussion (
      author_user_account_id, title, body, category, is_pinned
    ) VALUES (
      v_user_a, 'Best practices for PostgreSQL 18 partitioning',
      'What are your experiences with declarative partitioning in PG 18 on Neon?', 'TECH_TALK', FALSE
    ) RETURNING id INTO v_disc_id;
    passed := passed + 1;

    -- Test 11: Create community_comment
    INSERT INTO public.community_comment (
      discussion_id, author_user_account_id, body, upvotes
    ) VALUES (
      v_disc_id, v_user_b, 'Range partitioning on timestamp with btree_gist works wonderfully.', 3
    ) RETURNING id INTO v_comm_id;
    passed := passed + 1;

    -- =========================================================================
    -- MODULE 11: ANALYTICS LAYER, REPORTING AND DATA MARTS
    -- =========================================================================

    -- Test 12: Record analytics_refresh_log
    INSERT INTO public.analytics_refresh_log (
      mart_name, period_start, period_end, rows_processed, refresh_status, duration_ms
    ) VALUES (
      'application_funnel_daily', CURRENT_DATE - 1, CURRENT_DATE, 1420, 'SUCCESS', 125
    ) RETURNING id INTO v_refresh_id;
    passed := passed + 1;

    -- Test 13: Insert analytics_application_funnel_daily
    INSERT INTO public.analytics_application_funnel_daily (
      report_date, organisation_id, job_requirement_id,
      total_views, total_applications, total_shortlisted, total_interviewed, total_offered, total_joined, total_withdrawn
    ) VALUES (
      CURRENT_DATE, v_org_a, v_job_a,
      250, 45, 12, 6, 2, 2, 1
    ) RETURNING id INTO v_funnel_id;
    passed := passed + 1;

    -- Test 14: Insert analytics_recruiter_velocity
    INSERT INTO public.analytics_recruiter_velocity (
      report_month, recruiter_user_account_id, organisation_id,
      total_jobs_managed, total_applications_reviewed, avg_hours_to_first_review, avg_days_to_hire,
      total_offers_extended, total_offers_accepted, offer_acceptance_rate_percent
    ) VALUES (
      DATE_TRUNC('month', CURRENT_DATE)::DATE, v_user_b, v_org_a,
      8, 120, 14.50, 21.00, 5, 4, 80.00
    ) RETURNING id INTO v_velocity_id;
    passed := passed + 1;

    -- Test 15: Reject duplicate recruiter velocity rollup for same month, recruiter, and org
    BEGIN
      INSERT INTO public.analytics_recruiter_velocity (
        report_month, recruiter_user_account_id, organisation_id, total_jobs_managed
      ) VALUES (
        DATE_TRUNC('month', CURRENT_DATE)::DATE, v_user_b, v_org_a, 10
      );
      RAISE EXCEPTION 'Test failed: duplicate recruiter velocity record was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 16: Insert analytics_sourcing_efficiency
    INSERT INTO public.analytics_sourcing_efficiency (
      report_date, organisation_id, sourcing_channel,
      candidates_sourced, candidates_applied, candidates_hired, channel_conversion_rate
    ) VALUES (
      CURRENT_DATE, v_org_a, 'TALENT_POOL',
      60, 25, 4, 16.00
    ) RETURNING id INTO v_efficiency_id;
    passed := passed + 1;

    -- Test 17: Reject duplicate sourcing efficiency rollup for same date, org, and channel
    BEGIN
      INSERT INTO public.analytics_sourcing_efficiency (
        report_date, organisation_id, sourcing_channel
      ) VALUES (
        CURRENT_DATE, v_org_a, 'TALENT_POOL'
      );
      RAISE EXCEPTION 'Test failed: duplicate sourcing efficiency record was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 18: Insert analytics_wallet_reconciliation_summary
    INSERT INTO public.analytics_wallet_reconciliation_summary (
      reconciliation_date, total_credits_purchased, total_credits_granted,
      total_credits_consumed, total_credits_refunded, net_active_wallet_balance,
      total_resumes_downloaded, discrepancy_count
    ) VALUES (
      CURRENT_DATE, 5000, 1200, 3100, 50, 3050, 62, 0
    ) RETURNING id INTO v_recon_id;
    passed := passed + 1;

    -- Test 19: Reject duplicate wallet reconciliation for same date
    BEGIN
      INSERT INTO public.analytics_wallet_reconciliation_summary (reconciliation_date)
      VALUES (CURRENT_DATE);
      RAISE EXCEPTION 'Test failed: duplicate reconciliation_date was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 20: Validate data mart referential integrity to organisation
    BEGIN
      INSERT INTO public.analytics_application_funnel_daily (
        report_date, organisation_id, job_requirement_id
      ) VALUES (
        CURRENT_DATE + 1, 999999999, v_job_a
      );
      RAISE EXCEPTION 'Test failed: invalid organisation_id was accepted in funnel mart';
    EXCEPTION WHEN foreign_key_violation THEN
      passed := passed + 1;
    END;

    -- Clean rollback of test fixtures
    RAISE EXCEPTION 'Phase4 rollback marker';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM = 'Phase4 rollback marker' THEN
        RAISE NOTICE '% Phase 4 checks passed; all test fixtures rolled back safely', passed;
      ELSE
        RAISE;
      END IF;
  END;
END $tests$;
