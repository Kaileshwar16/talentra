-- =============================================================================
-- Test Suite: phase3_constraints.sql
-- Module Coverage: Phase 3 (Modules 7, 8, 9) and Gap Closure (B36–B47)
-- Dependencies: Phases 1 and 2 deployed, 004_phase3.sql and 006_phase3_gap_closure.sql applied
-- Platform: PostgreSQL 18 on Neon
-- Isolation: Complete rollback via savepoint/exception to leave no test pollution
-- =============================================================================

DO $tests$
DECLARE
  passed INTEGER := 0;
  total_tests INTEGER := 37;
  v_user_a BIGINT;
  v_user_b BIGINT;
  v_user_c BIGINT;
  v_candidate_a BIGINT;
  v_account_org BIGINT;
  v_account_billing BIGINT;
  v_org_a BIGINT;
  v_job_a BIGINT;
  v_job_closed BIGINT;
  v_currency_inr BIGINT;
  v_plan_id BIGINT;
  v_sub_id BIGINT;
  v_licence_id BIGINT;
  v_seat_id BIGINT;
  v_device_id BIGINT;
  v_ud_1 BIGINT;
  v_ud_2 BIGINT;
  v_ud_3 BIGINT;
  v_pool_id BIGINT;
  v_pool_cand_id BIGINT;
  v_batch_id BIGINT;
  v_recipient_id BIGINT;
  v_consultant_req_id BIGINT;
  v_decision_id BIGINT;
  v_wallet_id BIGINT;
  v_ledger_id BIGINT;
  v_payment_id BIGINT;
  v_invoice_id BIGINT;
  v_refund_id BIGINT;
  v_download_id BIGINT;
BEGIN
  -- Isolated execution block — rolled back entirely at end
  BEGIN

    -- =========================================================================
    -- FIXTURE SETUP
    -- =========================================================================
    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Three User A', 'p3-suite-a@example.invalid')
    RETURNING id INTO v_user_a;

    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Three User B', 'p3-suite-b@example.invalid')
    RETURNING id INTO v_user_b;

    INSERT INTO public.user_account (full_name, email)
    VALUES ('Phase Three User C', 'p3-suite-c@example.invalid')
    RETURNING id INTO v_user_c;

    INSERT INTO public.candidate_profile (user_account_id)
    VALUES (v_user_a)
    RETURNING id INTO v_candidate_a;

    SELECT id INTO v_currency_inr FROM public.currency WHERE code = 'INR' LIMIT 1;
    IF v_currency_inr IS NULL THEN
      SELECT id INTO v_currency_inr FROM public.currency LIMIT 1;
    END IF;

    INSERT INTO organisation.account_profile (account_name, account_status_id)
    SELECT 'Phase Three Suite Org Account', id FROM organisation.account_status WHERE code = 'active'
    RETURNING id INTO v_account_org;

    INSERT INTO public.account_profile (account_code, account_name, account_status)
    VALUES ('P3-SUITE-BILLING', 'Phase Three Suite Billing Account', 'ACTIVE')
    RETURNING id INTO v_account_billing;

    INSERT INTO public.organisation (name, account_profile_id, organisation_type_id, verification_status_id)
    SELECT 'Phase Three Suite Organisation', v_account_org, t.id, s.id
    FROM organisation.organisation_type t CROSS JOIN public.verification_status s
    WHERE t.code = 'employer' AND s.code = 'pending'
    RETURNING id INTO v_org_a;

    -- Job A: open to external consultants
    INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id, open_to_consultants)
    SELECT 'Staff Systems Architect', v_org_a, s.id, w.id, e.id, TRUE
    FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
    WHERE s.code = 'draft' AND w.code = 'onsite' AND e.code = 'permanent'
    RETURNING id INTO v_job_a;

    -- Job Closed: explicitly closed to consultants
    INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id, open_to_consultants)
    SELECT 'Internal Confidential Lead', v_org_a, s.id, w.id, e.id, FALSE
    FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
    WHERE s.code = 'draft' AND w.code = 'onsite' AND e.code = 'permanent'
    RETURNING id INTO v_job_closed;

    -- =========================================================================
    -- TEST GROUP 1: MODULE 7 — PLANS, LICENCES, SEATS, DEVICES (B36, B37)
    -- =========================================================================

    -- Test 1: Create subscription_plan
    INSERT INTO public.subscription_plan (
      code, name, tier_level, billing_period, price_amount, currency_id,
      candidate_download_credits, job_posting_limit, max_seats, max_devices_per_seat, is_active
    ) VALUES (
      'P3_SUITE_ENT', 'Enterprise Suite Plan', 3, 'ANNUAL',
      99999.00, v_currency_inr, 1000, 50, 10, 2, TRUE
    ) RETURNING id INTO v_plan_id;
    passed := passed + 1;

    -- Test 2: Reject duplicate subscription_plan code
    BEGIN
      INSERT INTO public.subscription_plan (code, name, currency_id)
      VALUES ('P3_SUITE_ENT', 'Duplicate Plan', v_currency_inr);
      RAISE EXCEPTION 'Test 2 failed: duplicate plan code accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 3: Create account_subscription with valid temporal period
    INSERT INTO public.account_subscription (
      account_profile_id, subscription_plan_id, subscription_status,
      starts_at, current_period_starts_at, current_period_ends_at
    ) VALUES (
      v_account_billing, v_plan_id, 'ACTIVE',
      CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '365 days'
    ) RETURNING id INTO v_sub_id;
    passed := passed + 1;

    -- Test 4: Reject subscription with invalid period (ends_at < starts_at)
    BEGIN
      INSERT INTO public.account_subscription (
        account_profile_id, subscription_plan_id, subscription_status,
        starts_at, current_period_starts_at, current_period_ends_at
      ) VALUES (
        v_account_billing, v_plan_id, 'ACTIVE',
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP - INTERVAL '1 day'
      );
      RAISE EXCEPTION 'Test 4 failed: inverted subscription period accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 5: Reject overlapping active subscription on the same account (B47)
    BEGIN
      INSERT INTO public.account_subscription (
        account_profile_id, subscription_plan_id, subscription_status,
        starts_at, current_period_starts_at, current_period_ends_at
      ) VALUES (
        v_account_billing, v_plan_id, 'ACTIVE',
        CURRENT_TIMESTAMP + INTERVAL '10 days',
        CURRENT_TIMESTAMP + INTERVAL '10 days',
        CURRENT_TIMESTAMP + INTERVAL '40 days'
      );
      RAISE EXCEPTION 'Test 5 failed: overlapping active subscription accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 6: Create account_licence with max_devices_per_user = 2
    INSERT INTO public.account_licence (
      account_profile_id, subscription_plan_id, licence_key, allocated_seats,
      max_devices_per_user, licence_status, valid_from, valid_to, is_active
    ) VALUES (
      v_account_billing, v_plan_id, 'LIC-P3-DEV-CAP-001', 5,
      2, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '365 days', TRUE
    ) RETURNING id INTO v_licence_id;
    passed := passed + 1;

    -- Test 7: Assign seat to user_b
    INSERT INTO public.licence_seat_assignment (
      account_licence_id, user_account_id, seat_role, valid_from, valid_to, is_active
    ) VALUES (
      v_licence_id, v_user_b, 'RECRUITER', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL, TRUE
    ) RETURNING id INTO v_seat_id;
    passed := passed + 1;

    -- Test 8: Historical seat re-assignment (end first assignment, assign again)
    UPDATE public.licence_seat_assignment
    SET is_active = FALSE, valid_to = CURRENT_TIMESTAMP
    WHERE id = v_seat_id;

    INSERT INTO public.licence_seat_assignment (
      account_licence_id, user_account_id, seat_role, valid_from, valid_to, is_active
    ) VALUES (
      v_licence_id, v_user_b, 'HIRING_MANAGER', CURRENT_TIMESTAMP, NULL, TRUE
    );
    passed := passed + 1;

    -- Test 9: Register device 1 for user_b under licence (allowed, count = 1 <= 2)
    INSERT INTO public.user_device (
      user_account_id, account_licence_id, device_fingerprint, device_name, device_type
    ) VALUES (
      v_user_b, v_licence_id, 'fp-work-macbook-pro-m2', 'Work Laptop', 'DESKTOP_MAC'
    ) RETURNING id INTO v_ud_1;
    passed := passed + 1;

    -- Test 10: Register device 2 for user_b under licence (allowed, count = 2 <= 2)
    INSERT INTO public.user_device (
      user_account_id, account_licence_id, device_fingerprint, device_name, device_type
    ) VALUES (
      v_user_b, v_licence_id, 'fp-iphone-15-pro', 'Personal Phone', 'MOBILE_IOS'
    ) RETURNING id INTO v_ud_2;
    passed := passed + 1;

    -- Test 11: Register device 3 for user_b under licence (REJECTED: cap of 2 exceeded)
    BEGIN
      INSERT INTO public.user_device (
        user_account_id, account_licence_id, device_fingerprint, device_name, device_type
      ) VALUES (
        v_user_b, v_licence_id, 'fp-home-pc-windows', 'Home PC', 'DESKTOP_WIN'
      );
      RAISE EXCEPTION 'Test 11 failed: active device cap was not enforced';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 12: Revoke device 1, then register device 3 (allowed because active count drops to 1)
    UPDATE public.user_device
    SET revoked_at = CURRENT_TIMESTAMP, revocation_reason = 'Upgraded hardware'
    WHERE id = v_ud_1;

    INSERT INTO public.user_device (
      user_account_id, account_licence_id, device_fingerprint, device_name, device_type
    ) VALUES (
      v_user_b, v_licence_id, 'fp-home-pc-windows', 'Home PC', 'DESKTOP_WIN'
    ) RETURNING id INTO v_ud_3;
    passed := passed + 1;

    -- Test 13: Reject invalid device_type enum
    BEGIN
      INSERT INTO public.user_device (
        user_account_id, account_licence_id, device_fingerprint, device_type
      ) VALUES (
        v_user_c, v_licence_id, 'fp-smart-fridge', 'SMART_TOASTER'
      );
      RAISE EXCEPTION 'Test 13 failed: invalid device_type accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 14: Create device_session linked to user_device
    INSERT INTO public.device_session (
      user_account_id, user_device_id, device_fingerprint, device_type, session_token_hash,
      is_active, expires_at
    ) VALUES (
      v_user_b, v_ud_3, 'fp-home-pc-windows', 'DESKTOP_WIN', 'sha256-hash-session-test-p3-001',
      TRUE, CURRENT_TIMESTAMP + INTERVAL '24 hours'
    ) RETURNING id INTO v_device_id;
    passed := passed + 1;

    -- Test 15: Reject duplicate device_session token hash
    BEGIN
      INSERT INTO public.device_session (
        user_account_id, device_fingerprint, session_token_hash, expires_at
      ) VALUES (
        v_user_c, 'fp-other-machine', 'sha256-hash-session-test-p3-001', CURRENT_TIMESTAMP + INTERVAL '1 hour'
      );
      RAISE EXCEPTION 'Test 15 failed: duplicate session_token_hash accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- =========================================================================
    -- TEST GROUP 2: MODULE 8 — SOURCING & CONSULTANT WORKFLOWS (B38, B39, B40, B46)
    -- =========================================================================

    -- Test 16: Create sourcing_pool and candidate member
    INSERT INTO public.sourcing_pool (
      organisation_id, pool_name, pool_description, target_role, is_private
    ) VALUES (
      v_org_a, 'P3 Cloud SRE Pool', 'Cloud Reliability Engineers', 'SRE', TRUE
    ) RETURNING id INTO v_pool_id;

    INSERT INTO public.sourcing_pool_candidate (
      sourcing_pool_id, candidate_profile_id, added_by_recruiter_id, sourcing_channel
    ) VALUES (
      v_pool_id, v_candidate_a, v_user_b, 'DIRECT_SEARCH'
    ) RETURNING id INTO v_pool_cand_id;
    passed := passed + 1;

    -- Test 17: Create sourcing_outreach_batch
    INSERT INTO public.sourcing_outreach_batch (
      sourcing_pool_id, created_by_user_id, batch_name, outreach_channel,
      subject_template, body_template, batch_status, total_recipients
    ) VALUES (
      v_pool_id, v_user_b, 'Q4 SRE Outreach Campaign', 'EMAIL',
      'Exciting Cloud Architect role at {{company}}', 'Hi {{name}}, we loved your profile...',
      'IN_PROGRESS', 1
    ) RETURNING id INTO v_batch_id;
    passed := passed + 1;

    -- Test 18: Create sourcing_outreach_recipient
    INSERT INTO public.sourcing_outreach_recipient (
      outreach_batch_id, candidate_profile_id, delivery_status, external_message_id
    ) VALUES (
      v_batch_id, v_candidate_a, 'DELIVERED', 'msg-sendgrid-test-001'
    ) RETURNING id INTO v_recipient_id;
    passed := passed + 1;

    -- Test 19: Reject duplicate candidate in same outreach_batch
    BEGIN
      INSERT INTO public.sourcing_outreach_recipient (
        outreach_batch_id, candidate_profile_id, delivery_status
      ) VALUES (
        v_batch_id, v_candidate_a, 'PENDING'
      );
      RAISE EXCEPTION 'Test 19 failed: duplicate batch recipient accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 20: Reject consultant request for job that is NOT open to consultants (B46)
    BEGIN
      INSERT INTO public.consultant_request (
        job_requirement_id, consultant_user_account_id, consultant_organisation_id,
        commission_rate_percent, request_status
      ) VALUES (
        v_job_closed, v_user_b, v_org_a, 10.00, 'REQUESTED'
      );
      RAISE EXCEPTION 'Test 20 failed: consultant request accepted on closed job';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 21: Create consultant_request for job that IS open to consultants (B46)
    INSERT INTO public.consultant_request (
      job_requirement_id, consultant_user_account_id, consultant_organisation_id,
      commission_rate_percent, request_status, notes
    ) VALUES (
      v_job_a, v_user_b, v_org_a, 12.50, 'REQUESTED', 'Specialist SRE recruitment mandate'
    ) RETURNING id INTO v_consultant_req_id;
    passed := passed + 1;

    -- Test 22: Reject invalid commission_rate_percent (> 100) (B46)
    BEGIN
      INSERT INTO public.consultant_request (
        job_requirement_id, consultant_user_account_id, consultant_organisation_id,
        commission_rate_percent
      ) VALUES (
        v_job_a, v_user_c, v_org_a, 150.00
      );
      RAISE EXCEPTION 'Test 22 failed: commission rate > 100%% accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 23: Record immutable consultant_request_decision (B40)
    INSERT INTO public.consultant_request_decision (
      consultant_request_id, decided_by_user_id, decision, decision_reason
    ) VALUES (
      v_consultant_req_id, v_user_a, 'ACCEPTED', 'Approved at negotiated 12.5% rate'
    ) RETURNING id INTO v_decision_id;
    passed := passed + 1;

    -- Test 24: Reject mutation on consultant_request_decision (append-only audit log)
    BEGIN
      UPDATE public.consultant_request_decision
      SET decision = 'REVOKED'
      WHERE id = v_decision_id;
      RAISE EXCEPTION 'Test 24 failed: consultant_request_decision UPDATE allowed';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- Test 25: Reject DELETE on consultant_request_decision
    BEGIN
      DELETE FROM public.consultant_request_decision
      WHERE id = v_decision_id;
      RAISE EXCEPTION 'Test 25 failed: consultant_request_decision DELETE allowed';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- =========================================================================
    -- TEST GROUP 3: MODULE 9 — BILLING, INVOICES, REFUNDS & WALLET (B41-B47)
    -- =========================================================================

    -- Test 26: Create wallet_account
    INSERT INTO public.wallet_account (
      account_profile_id, balance_credits, currency_id, wallet_status
    ) VALUES (
      v_account_billing, 500, v_currency_inr, 'ACTIVE'
    ) RETURNING id INTO v_wallet_id;
    passed := passed + 1;

    -- Test 27: Append-only wallet_transaction_ledger
    INSERT INTO public.wallet_transaction_ledger (
      wallet_account_id, transaction_type, credit_amount, balance_after,
      description, idempotency_key
    ) VALUES (
      v_wallet_id, 'PLAN_GRANT', 500, 500,
      'Annual enterprise credit allocation', 'tx-idemp-p3-suite-001'
    ) RETURNING id INTO v_ledger_id;
    passed := passed + 1;

    -- Test 28: Reject duplicate ledger idempotency_key
    BEGIN
      INSERT INTO public.wallet_transaction_ledger (
        wallet_account_id, transaction_type, credit_amount, balance_after,
        idempotency_key
      ) VALUES (
        v_wallet_id, 'PURCHASE', 100, 600, 'tx-idemp-p3-suite-001'
      );
      RAISE EXCEPTION 'Test 28 failed: duplicate ledger idempotency_key accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 29: Reject UPDATE on wallet_transaction_ledger
    BEGIN
      UPDATE public.wallet_transaction_ledger
      SET balance_after = 9999
      WHERE id = v_ledger_id;
      RAISE EXCEPTION 'Test 29 failed: wallet_transaction_ledger UPDATE allowed';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- Test 30: Create payment_transaction (positive amount enforced)
    INSERT INTO public.payment_transaction (
      account_profile_id, wallet_account_id, subscription_plan_id, amount,
      currency_id, payment_status, payment_gateway, gateway_transaction_id, idempotency_key
    ) VALUES (
      v_account_billing, v_wallet_id, v_plan_id, 99999.00,
      v_currency_inr, 'SUCCEEDED', 'STRIPE', 'ch_stripe_suite_001', 'pay-idemp-suite-001'
    ) RETURNING id INTO v_payment_id;
    passed := passed + 1;

    -- Test 31: Reject payment_transaction with amount <= 0
    BEGIN
      INSERT INTO public.payment_transaction (
        account_profile_id, amount, currency_id, gateway_transaction_id, idempotency_key
      ) VALUES (
        v_account_billing, -50.00, v_currency_inr, 'gw-tx-neg-amount-test', 'pay-idemp-neg-amount'
      );
      RAISE EXCEPTION 'Test 31 failed: negative payment amount accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 32: Create customer-facing invoice (sum total check: total = subtotal + tax)
    INSERT INTO public.invoice (
      account_profile_id, account_subscription_id, payment_transaction_id,
      invoice_number, invoice_status, subtotal_amount, tax_amount, total_amount, currency_id
    ) VALUES (
      v_account_billing, v_sub_id, v_payment_id,
      'INV-2026-P3-0001', 'PAID', 84744.92, 15254.08, 99999.00, v_currency_inr
    ) RETURNING id INTO v_invoice_id;
    passed := passed + 1;

    -- Test 33: Reject invoice with arithmetic mismatch (total != subtotal + tax)
    BEGIN
      INSERT INTO public.invoice (
        account_profile_id, invoice_number, subtotal_amount, tax_amount, total_amount, currency_id
      ) VALUES (
        v_account_billing, 'INV-2026-BAD-MATH', 1000.00, 100.00, 1500.00, v_currency_inr
      );
      RAISE EXCEPTION 'Test 33 failed: invoice with total != subtotal + tax accepted';
    EXCEPTION WHEN check_violation THEN
      passed := passed + 1;
    END;

    -- Test 34: Reject duplicate invoice_number
    BEGIN
      INSERT INTO public.invoice (
        account_profile_id, invoice_number, subtotal_amount, tax_amount, total_amount, currency_id
      ) VALUES (
        v_account_billing, 'INV-2026-P3-0001', 500.00, 0.00, 500.00, v_currency_inr
      );
      RAISE EXCEPTION 'Test 34 failed: duplicate invoice_number accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 35: Create payment_refund
    INSERT INTO public.payment_refund (
      payment_transaction_id, account_profile_id, refund_amount, currency_id,
      refund_status, refund_type, gateway_refund_id, idempotency_key
    ) VALUES (
      v_payment_id, v_account_billing, 5000.00, v_currency_inr,
      'SUCCEEDED', 'PARTIAL', 're_stripe_suite_001', 'ref-idemp-suite-001'
    ) RETURNING id INTO v_refund_id;
    passed := passed + 1;

    -- Test 36: Reject duplicate refund idempotency_key
    BEGIN
      INSERT INTO public.payment_refund (
        payment_transaction_id, account_profile_id, refund_amount, currency_id,
        gateway_refund_id, idempotency_key
      ) VALUES (
        v_payment_id, v_account_billing, 2000.00, v_currency_inr,
        're_stripe_suite_002', 'ref-idemp-suite-001'
      );
      RAISE EXCEPTION 'Test 36 failed: duplicate refund idempotency_key accepted';
    EXCEPTION WHEN unique_violation THEN
      passed := passed + 1;
    END;

    -- Test 37: Record profile_download_event & verify immutability
    INSERT INTO public.profile_download_event (
      candidate_profile_id, recruiter_user_account_id, wallet_transaction_id,
      download_format, ip_address
    ) VALUES (
      v_candidate_a, v_user_b, v_ledger_id,
      'PDF', '10.0.0.42'::inet
    ) RETURNING id INTO v_download_id;

    BEGIN
      UPDATE public.profile_download_event
      SET download_format = 'DOCX'
      WHERE id = v_download_id;
      RAISE EXCEPTION 'Test 37 failed: profile_download_event UPDATE allowed';
    EXCEPTION WHEN SQLSTATE '55000' THEN
      passed := passed + 1;
    END;

    -- Clean rollback: roll back all created test records so database is pristine
    RAISE EXCEPTION 'P3_ROLLBACK_SAFE_COMPLETE';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM = 'P3_ROLLBACK_SAFE_COMPLETE' THEN
        RAISE NOTICE 'SUCCESS: % of % Phase 3 constraint & integrity tests PASSED. All test fixtures rolled back cleanly.', passed, total_tests;
      ELSE
        RAISE;
      END IF;
  END;
END $tests$;
