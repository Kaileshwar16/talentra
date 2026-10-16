-- =============================================================================
-- Migration: 006_phase3_gap_closure.sql
-- Phase:     3 — Gap Closure (B36–B47)
-- Purpose:   Additive forward-only migration.  Adds the entities that cannot
--            be represented reliably by the 12 tables deployed in 004_phase3.sql
--            and closes integrity gaps identified during the B36–B47 audit.
-- Depends:   001_connected_er.sql, 002_phase2.sql, 003_restrict_security_functions.sql,
--            004_phase3.sql
-- Platform:  PostgreSQL 18 on Neon
-- =============================================================================

BEGIN;

SET LOCAL lock_timeout       = '10s';
SET LOCAL statement_timeout  = '120s';

-- =========================================================================
-- B36 / B37 — user_device
-- =========================================================================
-- Rationale: device_session is a per-session record (session token + expiry).
-- A user may have MANY sessions on the SAME physical device.  The licence
-- enforces a per-user DEVICE cap (account_licence.max_devices_per_user), not
-- a session cap.  Without a distinct device registry there is no reliable
-- entity to count against that limit.

CREATE TABLE IF NOT EXISTS public.user_device (
    id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id      BIGINT NOT NULL
                            REFERENCES public.user_account(id)
                            ON UPDATE RESTRICT ON DELETE RESTRICT,
    account_licence_id   BIGINT
                            REFERENCES public.account_licence(id)
                            ON UPDATE RESTRICT ON DELETE RESTRICT,
    device_fingerprint   VARCHAR(255) NOT NULL,
    device_name          VARCHAR(150),
    device_type          VARCHAR(40) NOT NULL DEFAULT 'BROWSER'
                            CONSTRAINT chk_ud_device_type
                            CHECK (device_type IN (
                                'BROWSER','MOBILE_ANDROID','MOBILE_IOS',
                                'DESKTOP_WIN','DESKTOP_MAC','DESKTOP_LINUX','OTHER'
                            )),
    os_name              VARCHAR(80),
    browser_name         VARCHAR(80),
    registered_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_trusted           BOOLEAN NOT NULL DEFAULT FALSE,
    revoked_at           TIMESTAMPTZ,
    revocation_reason    VARCHAR(150),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_user_device_fingerprint
        UNIQUE (user_account_id, device_fingerprint)
);

COMMENT ON TABLE  public.user_device IS
    'Registry of physical/virtual devices associated with a user account. '
    'Distinct from device_session (per-session record). Used to enforce the '
    'max_devices_per_user limit on account_licence (B36/B37).';
COMMENT ON COLUMN public.user_device.account_licence_id IS
    'Licence against whose device quota this device is counted.';
COMMENT ON COLUMN public.user_device.revoked_at IS
    'Non-null when the device has been de-registered; does not delete the row.';

CREATE INDEX IF NOT EXISTS idx_user_device_user
    ON public.user_device (user_account_id, revoked_at)
    WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_user_device_licence
    ON public.user_device (account_licence_id)
    WHERE account_licence_id IS NOT NULL;

-- B37: Device limit enforcement function -------
-- Called as a BEFORE INSERT trigger on user_device.
-- Aborts the insert when the active device count for this user/licence pair
-- would exceed account_licence.max_devices_per_user.
CREATE OR REPLACE FUNCTION public.check_user_device_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_devices INTEGER;
    v_current     INTEGER;
BEGIN
    -- Only enforce when a licence is specified on the device
    IF NEW.account_licence_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT max_devices_per_user
      INTO v_max_devices
      FROM public.account_licence
     WHERE id = NEW.account_licence_id
       AND is_active = TRUE;

    IF v_max_devices IS NULL THEN
        RAISE EXCEPTION
            'account_licence % not found or inactive', NEW.account_licence_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    SELECT COUNT(*)
      INTO v_current
      FROM public.user_device
     WHERE user_account_id    = NEW.user_account_id
       AND account_licence_id = NEW.account_licence_id
       AND revoked_at IS NULL;

    IF v_current >= v_max_devices THEN
        RAISE EXCEPTION
            'Device limit exceeded: licence % allows % devices per user, '
            'user % already has % active device(s).',
            NEW.account_licence_id, v_max_devices,
            NEW.user_account_id, v_current
            USING ERRCODE = '23514';   -- check_violation
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_device_limit ON public.user_device;
CREATE TRIGGER trg_check_device_limit
    BEFORE INSERT ON public.user_device
    FOR EACH ROW
    EXECUTE FUNCTION public.check_user_device_limit();

-- =========================================================================
-- B36 / B37 — licence_seat_assignment: active index & seat limit enforcement
-- =========================================================================
-- Replace the static (licence, user) uniqueness constraint with a partial
-- unique index on active assignments, enabling historical re-assignment
-- after an assignment has ended (B37 audit).
ALTER TABLE public.licence_seat_assignment DROP CONSTRAINT IF EXISTS uq_licence_seat;

CREATE UNIQUE INDEX IF NOT EXISTS uq_licence_seat_active
    ON public.licence_seat_assignment (account_licence_id, user_account_id)
    WHERE is_active = TRUE;

CREATE OR REPLACE FUNCTION public.check_licence_seat_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_allocated INTEGER;
    v_active    INTEGER;
BEGIN
    IF NEW.is_active IS NOT TRUE THEN
        RETURN NEW;
    END IF;

    SELECT allocated_seats
      INTO v_allocated
      FROM public.account_licence
     WHERE id = NEW.account_licence_id
       AND is_active = TRUE;

    IF v_allocated IS NULL THEN
        RAISE EXCEPTION 'account_licence % not found or inactive', NEW.account_licence_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    SELECT COUNT(*)
      INTO v_active
      FROM public.licence_seat_assignment
     WHERE account_licence_id = NEW.account_licence_id
       AND is_active = TRUE
       AND id <> COALESCE(NEW.id, -1);

    IF v_active >= v_allocated THEN
        RAISE EXCEPTION
            'Licence seat limit exceeded: licence % allows % seats, % active seats already assigned.',
            NEW.account_licence_id, v_allocated, v_active
            USING ERRCODE = '23514';  -- check_violation
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_licence_seat_limit ON public.licence_seat_assignment;
CREATE TRIGGER trg_check_licence_seat_limit
    BEFORE INSERT OR UPDATE OF account_licence_id, is_active
    ON public.licence_seat_assignment
    FOR EACH ROW
    EXECUTE FUNCTION public.check_licence_seat_limit();

-- =========================================================================
-- B38 — sourcing_outreach_batch
-- =========================================================================
-- Rationale: sourcing_pool tracks a pool of candidates.  Recruiters send
-- outreach campaigns to subsets of the pool.  Without this entity there is
-- no way to record campaign metadata (channel, subject, scheduled time) or
-- track delivery status across recipients as a unit.

CREATE TABLE IF NOT EXISTS public.sourcing_outreach_batch (
    id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sourcing_pool_id     BIGINT NOT NULL
                            REFERENCES public.sourcing_pool(id)
                            ON UPDATE RESTRICT ON DELETE RESTRICT,
    created_by_user_id   BIGINT NOT NULL
                            REFERENCES public.user_account(id)
                            ON UPDATE RESTRICT ON DELETE RESTRICT,
    batch_name           VARCHAR(200) NOT NULL,
    outreach_channel     VARCHAR(40) NOT NULL DEFAULT 'EMAIL'
                            CONSTRAINT chk_sob_channel
                            CHECK (outreach_channel IN (
                                'EMAIL','SMS','IN_APP','LINKEDIN','WHATSAPP'
                            )),
    subject_template     TEXT,
    body_template        TEXT,
    batch_status         VARCHAR(30) NOT NULL DEFAULT 'DRAFT'
                            CONSTRAINT chk_sob_status
                            CHECK (batch_status IN (
                                'DRAFT','SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED'
                            )),
    scheduled_at         TIMESTAMPTZ,
    sent_at              TIMESTAMPTZ,
    total_recipients     INTEGER NOT NULL DEFAULT 0
                            CONSTRAINT chk_sob_total_recipients
                            CHECK (total_recipients >= 0),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at           TIMESTAMPTZ
);

COMMENT ON TABLE public.sourcing_outreach_batch IS
    'A recruiter-initiated outreach campaign directed at a subset of a '
    'sourcing pool.  Tracks channel, template, timing and aggregate counts (B38).';

CREATE INDEX IF NOT EXISTS idx_sob_pool_status
    ON public.sourcing_outreach_batch (sourcing_pool_id, batch_status)
    WHERE deleted_at IS NULL;

-- =========================================================================
-- B39 — sourcing_outreach_recipient
-- =========================================================================
-- Rationale: One row per (batch, candidate) captures per-candidate delivery
-- state and response.  Without it, delivery failures and opt-outs are lost.

CREATE TABLE IF NOT EXISTS public.sourcing_outreach_recipient (
    id                       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outreach_batch_id        BIGINT NOT NULL
                                REFERENCES public.sourcing_outreach_batch(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    candidate_profile_id     BIGINT NOT NULL
                                REFERENCES public.candidate_profile(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    delivery_status          VARCHAR(30) NOT NULL DEFAULT 'PENDING'
                                CONSTRAINT chk_sor_delivery_status
                                CHECK (delivery_status IN (
                                    'PENDING','SENT','DELIVERED','BOUNCED',
                                    'OPENED','CLICKED','REPLIED','OPT_OUT','FAILED'
                                )),
    delivered_at             TIMESTAMPTZ,
    opened_at                TIMESTAMPTZ,
    responded_at             TIMESTAMPTZ,
    candidate_response       VARCHAR(30)
                                CONSTRAINT chk_sor_response
                                CHECK (candidate_response IS NULL OR candidate_response IN (
                                    'INTERESTED','NOT_INTERESTED','MAYBE','NO_RESPONSE'
                                )),
    failure_reason           TEXT,
    external_message_id      VARCHAR(255),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_sor_batch_candidate
        UNIQUE (outreach_batch_id, candidate_profile_id)
);

COMMENT ON TABLE public.sourcing_outreach_recipient IS
    'Per-candidate delivery and engagement record for a sourcing outreach '
    'batch (B39).  Append-friendly; delivery_status advances through the '
    'delivery pipeline.';

CREATE INDEX IF NOT EXISTS idx_sor_batch
    ON public.sourcing_outreach_recipient (outreach_batch_id, delivery_status);

CREATE INDEX IF NOT EXISTS idx_sor_candidate
    ON public.sourcing_outreach_recipient (candidate_profile_id);

-- =========================================================================
-- B40 — consultant_request_decision
-- =========================================================================
-- Rationale: consultant_request.approved_by_user_id / decided_at are
-- mutable columns on the parent row.  Any subsequent status change
-- overwrites the previous decision, making audit impossible.  A separate
-- append-only decision log is required to satisfy the complete decision
-- trail requirement.

CREATE TABLE IF NOT EXISTS public.consultant_request_decision (
    id                       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    consultant_request_id    BIGINT NOT NULL
                                REFERENCES public.consultant_request(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    decided_by_user_id       BIGINT NOT NULL
                                REFERENCES public.user_account(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    decision                 VARCHAR(30) NOT NULL
                                CONSTRAINT chk_crd_decision
                                CHECK (decision IN (
                                    'ACCEPTED','DECLINED','REVOKED','REINSTATED'
                                )),
    decision_reason          TEXT,
    effective_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.consultant_request_decision IS
    'Immutable audit log of every accept/decline/revoke decision on a '
    'consultant_request.  One row per decision event (B40).';

-- Protect this table from mutation — it is an audit log.
DROP TRIGGER IF EXISTS reject_mutation ON public.consultant_request_decision;
CREATE TRIGGER reject_mutation
    BEFORE UPDATE OR DELETE ON public.consultant_request_decision
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

DROP TRIGGER IF EXISTS reject_truncate ON public.consultant_request_decision;
CREATE TRIGGER reject_truncate
    BEFORE TRUNCATE ON public.consultant_request_decision
    FOR EACH STATEMENT
    EXECUTE FUNCTION public.talentra_reject_mutation();

CREATE INDEX IF NOT EXISTS idx_crd_request
    ON public.consultant_request_decision (consultant_request_id, effective_at);

-- =========================================================================
-- B41 — invoice
-- =========================================================================
-- Rationale: payment_transaction records gateway-level financial events.
-- An invoice is the formal customer-facing billing document (with line
-- items, tax, due date) that may cover one or more transactions.  The
-- two entities serve different purposes and cannot be merged without
-- violating 3NF.

CREATE TABLE IF NOT EXISTS public.invoice (
    id                       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_profile_id       BIGINT NOT NULL
                                REFERENCES public.account_profile(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    account_subscription_id  BIGINT
                                REFERENCES public.account_subscription(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    payment_transaction_id   BIGINT
                                REFERENCES public.payment_transaction(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    invoice_number           VARCHAR(60) NOT NULL,
    invoice_status           VARCHAR(30) NOT NULL DEFAULT 'DRAFT'
                                CONSTRAINT chk_inv_status
                                CHECK (invoice_status IN (
                                    'DRAFT','ISSUED','PAID','VOID','OVERDUE'
                                )),
    subtotal_amount          NUMERIC(14, 2) NOT NULL
                                CONSTRAINT chk_inv_subtotal
                                CHECK (subtotal_amount >= 0),
    tax_amount               NUMERIC(14, 2) NOT NULL DEFAULT 0.00
                                CONSTRAINT chk_inv_tax
                                CHECK (tax_amount >= 0),
    total_amount             NUMERIC(14, 2) NOT NULL
                                CONSTRAINT chk_inv_total
                                CHECK (total_amount >= 0),
    currency_id              BIGINT NOT NULL
                                REFERENCES public.currency(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    issued_at                TIMESTAMPTZ,
    due_at                   TIMESTAMPTZ,
    paid_at                  TIMESTAMPTZ,
    notes                    TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_invoice_number UNIQUE (invoice_number),
    -- total must equal subtotal + tax
    CONSTRAINT chk_inv_total_eq_sum
        CHECK (total_amount = subtotal_amount + tax_amount)
);

COMMENT ON TABLE public.invoice IS
    'Customer-facing invoice document linked to a subscription and/or '
    'payment_transaction (B41).  Distinct from payment_transaction: '
    'an invoice represents the billing obligation, a payment_transaction '
    'represents its settlement.';

CREATE INDEX IF NOT EXISTS idx_invoice_account
    ON public.invoice (account_profile_id, invoice_status);

CREATE INDEX IF NOT EXISTS idx_invoice_payment_tx
    ON public.invoice (payment_transaction_id)
    WHERE payment_transaction_id IS NOT NULL;

-- =========================================================================
-- B42 — payment_refund
-- =========================================================================
-- Rationale: Refunds reverse a payment_transaction either fully or partially.
-- They cannot be modelled as negative payment_transactions without breaking
-- the amount > 0 check or the unique idempotency_key semantics.  A separate
-- entity is required so each refund has its own gateway reference and
-- idempotency guard.

CREATE TABLE IF NOT EXISTS public.payment_refund (
    id                       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_transaction_id   BIGINT NOT NULL
                                REFERENCES public.payment_transaction(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    account_profile_id       BIGINT NOT NULL
                                REFERENCES public.account_profile(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    refund_amount            NUMERIC(12, 2) NOT NULL
                                CONSTRAINT chk_pr_amount
                                CHECK (refund_amount > 0),
    currency_id              BIGINT NOT NULL
                                REFERENCES public.currency(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    refund_status            VARCHAR(30) NOT NULL DEFAULT 'PENDING'
                                CONSTRAINT chk_pr_status
                                CHECK (refund_status IN (
                                    'PENDING','SUCCEEDED','FAILED','CANCELLED'
                                )),
    refund_reason            VARCHAR(100),
    refund_type              VARCHAR(20) NOT NULL DEFAULT 'PARTIAL'
                                CONSTRAINT chk_pr_type
                                CHECK (refund_type IN ('FULL','PARTIAL')),
    gateway_refund_id        VARCHAR(150),
    idempotency_key          VARCHAR(150) NOT NULL,
    initiated_by_user_id     BIGINT
                                REFERENCES public.user_account(id)
                                ON UPDATE RESTRICT ON DELETE RESTRICT,
    processed_at             TIMESTAMPTZ,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_payment_refund_idempotency UNIQUE (idempotency_key),
    CONSTRAINT uq_payment_refund_gateway     UNIQUE (gateway_refund_id)
);

COMMENT ON TABLE public.payment_refund IS
    'Records full or partial refunds against a payment_transaction (B42). '
    'Each refund has its own idempotency_key and gateway reference so it '
    'cannot be confused with the original charge.';

CREATE INDEX IF NOT EXISTS idx_payment_refund_tx
    ON public.payment_refund (payment_transaction_id, refund_status);

CREATE INDEX IF NOT EXISTS idx_payment_refund_account
    ON public.payment_refund (account_profile_id);

-- =========================================================================
-- B43 — wallet_transaction_ledger: UNIQUE idempotency_key
-- =========================================================================
-- The column exists but the UNIQUE constraint was missing.

DO $$
BEGIN
    -- Check if either a constraint or unique index with this name already exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_class
        WHERE relname = 'uq_wallet_ledger_idempotency'
    ) THEN
        CREATE UNIQUE INDEX uq_wallet_ledger_idempotency
            ON public.wallet_transaction_ledger (idempotency_key)
            WHERE idempotency_key IS NOT NULL;
    END IF;
END;
$$;

-- =========================================================================
-- B36/B37 addendum — FK from device_session to user_device
-- =========================================================================
-- Allow sessions to reference the canonical device record if desired.
-- This is an optional nullable FK; existing rows are unaffected.

ALTER TABLE public.device_session
    ADD COLUMN IF NOT EXISTS user_device_id BIGINT
        REFERENCES public.user_device(id)
        ON UPDATE RESTRICT ON DELETE RESTRICT;

COMMENT ON COLUMN public.device_session.user_device_id IS
    'Optional reference to the registered user_device record this session '
    'belongs to (B36/B37 link).';

CREATE INDEX IF NOT EXISTS idx_device_session_user_device
    ON public.device_session (user_device_id)
    WHERE user_device_id IS NOT NULL;

-- =========================================================================
-- B46 — Consultant eligibility and commission constraints
-- =========================================================================
ALTER TABLE public.consultant_request
    DROP CONSTRAINT IF EXISTS chk_cr_commission_rate;
ALTER TABLE public.consultant_request
    ADD CONSTRAINT chk_cr_commission_rate
    CHECK (commission_rate_percent IS NULL OR (commission_rate_percent >= 0 AND commission_rate_percent <= 100));

COMMENT ON CONSTRAINT chk_cr_commission_rate ON public.consultant_request IS
    'Ensures consultant commission percentage is within [0, 100] (B46).';

CREATE OR REPLACE FUNCTION public.check_consultant_job_eligibility()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_open BOOLEAN;
BEGIN
    SELECT open_to_consultants
      INTO v_open
      FROM public.job_requirement
     WHERE id = NEW.job_requirement_id;

    IF v_open IS NOT TRUE THEN
        RAISE EXCEPTION
            'Job requirement % is not open to consultants.', NEW.job_requirement_id
            USING ERRCODE = '23514';  -- check_violation
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_consultant_job_eligibility ON public.consultant_request;
CREATE TRIGGER trg_check_consultant_job_eligibility
    BEFORE INSERT OR UPDATE OF job_requirement_id ON public.consultant_request
    FOR EACH ROW
    EXECUTE FUNCTION public.check_consultant_job_eligibility();

-- =========================================================================
-- B47 — Subscription temporal integrity and overlap prevention
-- =========================================================================
ALTER TABLE public.account_subscription
    DROP CONSTRAINT IF EXISTS chk_sub_current_period_timing;
ALTER TABLE public.account_subscription
    ADD CONSTRAINT chk_sub_current_period_timing
    CHECK (
        (current_period_ends_at IS NULL OR current_period_starts_at IS NULL)
        OR (current_period_ends_at >= current_period_starts_at)
    );

CREATE OR REPLACE FUNCTION public.check_subscription_no_overlap()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_overlap INTEGER;
    v_start   TIMESTAMPTZ;
    v_end     TIMESTAMPTZ;
BEGIN
    IF NEW.subscription_status NOT IN ('ACTIVE', 'TRIAL') THEN
        RETURN NEW;
    END IF;

    v_start := COALESCE(NEW.current_period_starts_at, NEW.starts_at);
    v_end   := COALESCE(NEW.current_period_ends_at, NEW.ends_at, 'infinity'::TIMESTAMPTZ);

    -- If range is inverted, let check constraints handle it
    IF v_start IS NOT NULL AND v_end IS NOT NULL AND v_end < v_start THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*)
      INTO v_overlap
      FROM public.account_subscription
     WHERE account_profile_id = NEW.account_profile_id
       AND id <> COALESCE(NEW.id, -1)
       AND subscription_status IN ('ACTIVE', 'TRIAL')
       AND deleted_at IS NULL
       AND tstzrange(COALESCE(current_period_starts_at, starts_at), COALESCE(current_period_ends_at, ends_at, 'infinity'::TIMESTAMPTZ), '[]')
           && tstzrange(v_start, v_end, '[]');

    IF v_overlap > 0 THEN
        RAISE EXCEPTION
            'Active or trial subscription already exists for account % in overlapping period.',
            NEW.account_profile_id
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_sub_no_overlap ON public.account_subscription;
CREATE TRIGGER trg_check_sub_no_overlap
    BEFORE INSERT OR UPDATE OF subscription_status, current_period_starts_at, current_period_ends_at, starts_at, ends_at
    ON public.account_subscription
    FOR EACH ROW
    EXECUTE FUNCTION public.check_subscription_no_overlap();

-- =========================================================================
-- Catalogue: update schema comment with migration record
-- =========================================================================
COMMENT ON SCHEMA public IS
    'Talentra application schema — Phase 3 gap closure applied '
    '(006_phase3_gap_closure.sql, B36-B47). '
    'New tables: user_device, sourcing_outreach_batch, sourcing_outreach_recipient, '
    'consultant_request_decision, invoice, payment_refund. '
    'New constraints & triggers: uq_wallet_ledger_idempotency, chk_cr_commission_rate, '
    'trg_check_consultant_job_eligibility, trg_check_sub_no_overlap.';

COMMIT;
