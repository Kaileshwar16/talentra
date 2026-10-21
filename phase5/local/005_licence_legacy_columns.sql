-- 006_phase3_gap_closure.sql and the Phase 3 tests use these two licence
-- fields, but 004_phase3.sql omits them on a clean physical-schema database.
ALTER TABLE public.account_licence
    ADD COLUMN max_devices_per_user INTEGER NOT NULL DEFAULT 3
        CHECK (max_devices_per_user > 0),
    ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;
