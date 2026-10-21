-- Phase 3 gap closure and its tests refer to the older subscription window
-- columns, although 004_phase3.sql does not create them on a clean database.
ALTER TABLE public.account_subscription
    ADD COLUMN starts_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN ends_at TIMESTAMPTZ;
