-- =============================================================================
-- Test Suite: phase3_constraints.sql
-- Module Coverage: Phase 3 (Modules 7, 8, 9)
-- Dependencies: Phases 1 and 2 deployed
-- Run with psql -v ON_ERROR_STOP=1. Test data is always rolled back.
-- =============================================================================

DO $tests$
DECLARE
  passed INTEGER := 0;
  test_count INTEGER := 0;
  v_user_a BIGINT;
  v_user_b BIGINT;
  v_candidate_a BIGINT;
  v_account_org BIGINT;
  v_account_billing BIGINT;
  v_org_a BIGINT;
  v_job_a BIGINT;
  v_currency_inr BIGINT;
  v_plan_id BIGINT;
  v_sub_id BIGINT;
  v_licence_id BIGINT;
  v_seat_id BIGINT;
  v_device_id BIGINT;
  v_pool_id BIGINT;
  v_pool_cand_id BIGINT;
  v_consultant_req_id BIGINT;
  v_wallet_id BIGINT;
  v_ledger_id BIGINT;
  v_payment_id BIGINT;
  v_download_id BIGINT;
BEGIN
  -- Begin isolated test block; everything is rolled back at the end
  BEGIN

    -- 1. Setup base test fixtures
    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Three User A', 'phase3-a@example.invalid')
    RETURNING id INTO v_user_a;

    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Three User B', 'phase3-b@example.invalid')
    RETURNING id INTO v_user_b;

    INSERT INTO public.candidate_profile (user_account_id)
    VALUES (v_user_a)
    RETURNING id INTO v_candidate_a;

    SELECT id INTO v_currency_inr FROM public.currency WHERE code = 'INR' LIMIT 1;
    IF v_currency_inr IS NULL THEN
      SELECT id INTO v_currency_inr FROM public.currency LIMIT 1;
    END IF;

    INSERT INTO organisation.account_profile (account_name, account_status_id)
    SELECT 'Phase Three Org Account', id FROM organisation.account_status WHERE code = 'active'
    RETURNING id INTO v_account_org;

    INSERT INTO public.account_profile (account_name, account_status_id)
    SELECT 'Phase Three Billing Account', id FROM organisation.account_status WHERE code = 'active'
    RETURNING id INTO v_account_billing;

    INSERT INTO public.organisation (name, account_profile_id, organisation_type_id, verification_status_id)
    SELECT 'Phase Three Organisation', v_account_org, t.id, s.id
    FROM organisation.organisation_type t CROSS JOIN public.verification_status s
    WHERE t.code = 'employer' AND s.code = 'pending'
    RETURNING id INTO v_org_a;

    INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id)
    SELECT 'Phase 3 Engineer', v_org_a, s.id, w.id, e.id
    FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
    WHERE s.code = 'draft' AND w.code = 'onsite' AND e.code = 'permanent'
    RETURNING id INTO v_job_a;

    -- =========================================================================
    -- MODULE 7: PLANS, LICENCES, SEATS, DEVICES AND SESSIONS
    -- =========================================================================

    -- Test 1: Create subscription_plan
    INSERT INTO public.subscription_plan (
      code, name, description, tier_level, billing_period, price_amount, currency_id,
      candidate_download_credits, job_posting_limit, max_seats, max_devices_per_seat, is_active
    ) VALUES (
      'P3_GROWTH', 'Phase 3 Growth Plan', 'Test plan for commercial testing', 2, 'MONTHLY',
      4999.00, v_currency_inr, 200, 15, 5, 3, TRUE
    ) RETURNING id INTO v_plan_id;
    passed := passed + 1;

    -- Test 2: Reject duplicate subscription_plan code
    BEGIN
      INSERT INTO public.subscription_plan (code, name, currency_id)
      VALUES ('P3_GROWTH', 'Duplicate Plan', v_currency_inr);
      RAISE EXCEPTION 'Test failed: duplicate plan code was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 3: Create account_subscription
    INSERT INTO public.account_subscription (
      account_profile_id, subscription_plan_id, subscription_status,
      started_at, current_period_starts_at, current_period_ends_at
    ) VALUES (
      v_account_billing, v_plan_id, 'ACTIVE',
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days'
    ) RETURNING id INTO v_sub_id;
    passed := passed + 1;

    -- Test 4: Create account_licence
    INSERT INTO public.account_licence (
      account_profile_id, subscription_plan_id, licence_key, allocated_seats,
      licence_status, valid_from, valid_to
    ) VALUES (
      v_account_billing, v_plan_id, 'LIC-P3-TEST-KEY-001', 5,
      'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '365 days'
    ) RETURNING id INTO v_licence_id;
    passed := passed + 1;

    -- Test 5: Reject duplicate licence_key
    BEGIN
      INSERT INTO public.account_licence (
        account_profile_id, licence_key, valid_from, valid_to
      ) VALUES (
        v_account_billing, 'LIC-P3-TEST-KEY-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days'
      );
      RAISE EXCEPTION 'Test failed: duplicate licence_key was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 6: Assign seat to user
    INSERT INTO public.licence_seat_assignment (
      account_licence_id, user_account_id, seat_role, valid_from, valid_to, is_active
    ) VALUES (
      v_licence_id, v_user_b, 'RECRUITER', CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL, TRUE
    ) RETURNING id INTO v_seat_id;
    passed := passed + 1;

    -- Test 7: Create device_session
    INSERT INTO public.device_session (
      user_account_id, device_fingerprint, device_type, session_token_hash,
      is_active, expires_at
    ) VALUES (
      v_user_b, 'dfp-test-browser-xyz', 'BROWSER', 'sha256-test-session-token-hash-12345',
      TRUE, CURRENT_TIMESTAMP + INTERVAL '12 hours'
    ) RETURNING id INTO v_device_id;
    passed := passed + 1;

    -- Test 8: Reject duplicate session_token_hash
    BEGIN
      INSERT INTO public.device_session (
        user_account_id, device_fingerprint, session_token_hash, expires_at
      ) VALUES (
        v_user_b, 'dfp-test-browser-abc', 'sha256-test-session-token-hash-12345', CURRENT_TIMESTAMP + INTERVAL '12 hours'
      );
      RAISE EXCEPTION 'Test failed: duplicate session_token_hash was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- =========================================================================
    -- MODULE 8: SOURCING, CONSULTANT REQUESTS AND RECRUITER WORKFLOWS
    -- =========================================================================

    -- Test 9: Create sourcing_pool
    INSERT INTO public.sourcing_pool (
      organisation_id, name, pool_name, pool_description, target_role, is_private
    ) VALUES (
      v_org_a, 'Senior Backend Engineers', 'Senior Backend Engineers', 'Private sourcing pool for backend talent', 'Backend Engineer', TRUE
    ) RETURNING id INTO v_pool_id;
    passed := passed + 1;

    -- Test 10: Add candidate to sourcing_pool
    INSERT INTO public.sourcing_pool_candidate (
      sourcing_pool_id, candidate_profile_id, added_by_user_id, added_by_recruiter_id, sourcing_channel, candidate_match_score
    ) VALUES (
      v_pool_id, v_candidate_a, v_user_b, v_user_b, 'DIRECT_SEARCH', 94.50
    ) RETURNING id INTO v_pool_cand_id;
    passed := passed + 1;

    -- Test 11: Create consultant_request
    INSERT INTO public.consultant_request (
      job_requirement_id, consultant_user_account_id, consultant_organisation_id,
      commission_rate_percent, request_status, notes
    ) VALUES (
      v_job_a, v_user_b, v_org_a, 15.00, 'REQUESTED', 'Staffing request for niche backend skill'
    ) RETURNING id INTO v_consultant_req_id;
    passed := passed + 1;

    -- =========================================================================
    -- MODULE 9: SUBSCRIPTIONS, WALLETS, PAYMENTS, FINANCE AND DOWNLOAD HISTORY
    -- =========================================================================

    -- Test 12: Create wallet_account
    INSERT INTO public.wallet_account (
      account_profile_id, balance_credits, currency_id, wallet_status
    ) VALUES (
      v_account_billing, 100, v_currency_inr, 'ACTIVE'
    ) RETURNING id INTO v_wallet_id;
    passed := passed + 1;

    -- Test 13: Reject duplicate wallet for same account_profile
    BEGIN
      INSERT INTO public.wallet_account (account_profile_id, balance_credits, currency_id)
      VALUES (v_account_billing, 50, v_currency_inr);
      RAISE EXCEPTION 'Test failed: duplicate wallet_account was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 14: Append entry to wallet_transaction_ledger
    INSERT INTO public.wallet_transaction_ledger (
      wallet_account_id, transaction_type, credit_amount, credits_delta, balance_after,
      description, idempotency_key, reference_order_id
    ) VALUES (
      v_wallet_id, 'PLAN_GRANT', 100, 100, 100,
      'Initial monthly plan credit grant', 'tx-idemp-key-phase3-001', 'ORD-2026-P3-001'
    ) RETURNING id INTO v_ledger_id;
    passed := passed + 1;

    -- Test 15: Reject duplicate idempotency_key on ledger
    BEGIN
      INSERT INTO public.wallet_transaction_ledger (
        wallet_account_id, transaction_type, credit_amount, credits_delta, balance_after,
        idempotency_key
      ) VALUES (
        v_wallet_id, 'PURCHASE', 50, 50, 150, 'tx-idemp-key-phase3-001'
      );
      RAISE EXCEPTION 'Test failed: duplicate idempotency_key on wallet ledger was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 16: Verify append-only immutability of wallet_transaction_ledger
    BEGIN
      UPDATE public.wallet_transaction_ledger
      SET balance_after = 999
      WHERE id = v_ledger_id;
      RAISE EXCEPTION 'Test failed: wallet_transaction_ledger was mutated';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- Test 17: Create payment_transaction
    INSERT INTO public.payment_transaction (
      account_profile_id, wallet_account_id, subscription_plan_id, amount,
      currency_id, payment_status, payment_gateway, gateway_transaction_id, idempotency_key
    ) VALUES (
      v_account_billing, v_wallet_id, v_plan_id, 4999.00,
      v_currency_inr, 'SUCCEEDED', 'STRIPE', 'ch_stripe_p3_test_001', 'idem_pay_p3_001'
    ) RETURNING id INTO v_payment_id;
    passed := passed + 1;

    -- Test 18: Reject duplicate payment idempotency_key
    BEGIN
      INSERT INTO public.payment_transaction (
        account_profile_id, amount, currency_id, gateway_transaction_id, idempotency_key
      ) VALUES (
        v_account_billing, 4999.00, v_currency_inr, 'ch_stripe_p3_test_002', 'idem_pay_p3_001'
      );
      RAISE EXCEPTION 'Test failed: duplicate payment idempotency_key was accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 19: Record profile_download_event
    INSERT INTO public.profile_download_event (
      candidate_profile_id, downloader_user_account_id, recruiter_user_account_id, wallet_transaction_id,
      download_format, ip_address, user_agent
    ) VALUES (
      v_candidate_a, v_user_b, v_user_b, v_ledger_id,
      'PDF', '192.168.1.10'::inet, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
    ) RETURNING id INTO v_download_id;
    passed := passed + 1;

    -- Test 20: Verify append-only immutability of profile_download_event
    BEGIN
      UPDATE public.profile_download_event
      SET download_format = 'DOCX'
      WHERE id = v_download_id;
      RAISE EXCEPTION 'Test failed: profile_download_event was mutated';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- Clean rollback of test fixtures
    RAISE EXCEPTION 'Phase3 rollback marker';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM = 'Phase3 rollback marker' THEN
        RAISE NOTICE '% Phase 3 checks passed; all test fixtures rolled back safely', passed;
      ELSE
        RAISE;
      END IF;
  END;
END $tests$;
