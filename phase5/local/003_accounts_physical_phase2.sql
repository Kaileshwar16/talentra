-- Create matching account rows for the physical Phase 2 schema and the
-- legacy public table used by Phase 3 and the Phase 5 seed. Fresh local DB only.
INSERT INTO public.account_profile(account_code, account_name, account_type)
SELECT 'P5-' || lpad(g::text, 6, '0'), 'Phase 5 Account ' || g, 'ENTERPRISE'
FROM generate_series(1, 100) AS g
ON CONFLICT (account_code) DO NOTHING;

INSERT INTO organisation.account_profile(id, account_name, account_status_id)
    OVERRIDING SYSTEM VALUE
SELECT a.id, a.account_name, s.id
FROM public.account_profile AS a
CROSS JOIN organisation.account_status AS s
WHERE a.account_code LIKE 'P5-%' AND s.code = 'active'
  AND NOT EXISTS (SELECT 1 FROM organisation.account_profile AS p WHERE p.id = a.id);

SELECT setval(pg_get_serial_sequence('organisation.account_profile', 'id'),
              (SELECT max(id) FROM organisation.account_profile));

INSERT INTO public.organisation(name, account_profile_id, organisation_type_id,
                                verification_status_id, is_active)
SELECT 'Phase 5 Org ' || a.account_code, a.id, 1, 2, true
FROM public.account_profile AS a
WHERE a.account_code LIKE 'P5-%'
  AND NOT EXISTS (SELECT 1 FROM public.organisation AS o
                  WHERE o.account_profile_id = a.id);
