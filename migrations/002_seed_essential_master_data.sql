-- =============================================================================
-- Migration: 002_seed_essential_master_data.sql
-- Module: Talentra Essential Master Data Seeding (Updated with Reference Code integrity)
-- Description:
--   Seeds base geographic countries (e.g. IN, US, GB, SG, AE, CA, DE, AU),
--   standard currencies (INR, USD, EUR, GBP, SGD, AED),
--   and integrates specialized Indian identity document types and extended
--   verification statuses into reference_code and their respective domain tables.
-- =============================================================================

BEGIN;

-- 1. Country seeding (ISO 3166-1 alpha-2)
INSERT INTO public.country (code, display_name, phone_calling_code)
VALUES
    ('IN', 'India', '+91'),
    ('US', 'United States', '+1'),
    ('GB', 'United Kingdom', '+44'),
    ('SG', 'Singapore', '+65'),
    ('AE', 'United Arab Emirates', '+971'),
    ('CA', 'Canada', '+1'),
    ('AU', 'Australia', '+61'),
    ('DE', 'Germany', '+49')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    phone_calling_code = EXCLUDED.phone_calling_code;

-- 2. Ensure Currencies (ISO 4217)
INSERT INTO public.currency (code, display_name, minor_unit)
VALUES
    ('INR', 'Indian Rupee', 2),
    ('USD', 'US Dollar', 2),
    ('EUR', 'Euro', 2),
    ('GBP', 'British Pound', 2),
    ('SGD', 'Singapore Dollar', 2),
    ('AED', 'UAE Dirham', 2)
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    minor_unit = EXCLUDED.minor_unit;

-- 3. Reference Codes for specialized document types
INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order)
VALUES
    ('document_type', 'pan_card', 'PAN Card', TRUE, 10),
    ('document_type', 'aadhaar_card', 'Aadhaar Card', TRUE, 20),
    ('document_type', 'passport', 'Passport', TRUE, 30),
    ('document_type', 'voter_id', 'Voter ID Card', TRUE, 40),
    ('document_type', 'driving_licence', 'Driving Licence', TRUE, 50)
ON CONFLICT (domain_code, code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    active = EXCLUDED.active,
    sort_order = EXCLUDED.sort_order;

-- 4. Document Types domain table
INSERT INTO public.document_type (code, display_name, active, sort_order, reference_code_id)
SELECT rc.code, rc.display_name, rc.active, rc.sort_order, rc.id
FROM public.reference_code rc
WHERE rc.domain_code = 'document_type'
  AND rc.code IN ('pan_card', 'aadhaar_card', 'passport', 'voter_id', 'driving_licence')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    active = EXCLUDED.active,
    sort_order = EXCLUDED.sort_order,
    reference_code_id = EXCLUDED.reference_code_id;

-- 5. Reference Codes for extended verification statuses
INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order)
VALUES
    ('verification_status', 'unverified', 'Unverified', TRUE, 1),
    ('verification_status', 'in_review', 'In Review', TRUE, 3),
    ('verification_status', 'expired', 'Expired', TRUE, 6),
    ('verification_status', 'revoked', 'Revoked', TRUE, 7)
ON CONFLICT (domain_code, code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    active = EXCLUDED.active,
    sort_order = EXCLUDED.sort_order;

-- 6. Verification Statuses domain table
INSERT INTO public.verification_status (code, display_name, active, sort_order, reference_code_id)
SELECT rc.code, rc.display_name, rc.active, rc.sort_order, rc.id
FROM public.reference_code rc
WHERE rc.domain_code = 'verification_status'
  AND rc.code IN ('unverified', 'in_review', 'expired', 'revoked')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    active = EXCLUDED.active,
    sort_order = EXCLUDED.sort_order,
    reference_code_id = EXCLUDED.reference_code_id;

COMMIT;
