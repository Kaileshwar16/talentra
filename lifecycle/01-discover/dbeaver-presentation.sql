-- Talentra local presentation: select one statement at a time in DBeaver.
-- Target: 127.0.0.1:15432 / talentra_local / read-only talentra_viewer.

-- 1. Confirm the database being shown.
SELECT current_database() AS database_name, current_user AS login_name;

-- 2. Show the physical schema hierarchy.
SELECT n.nspname AS schema_name,
       count(*) FILTER (WHERE c.relkind IN ('r', 'p')) AS physical_tables,
       count(*) FILTER (WHERE c.relkind = 'v') AS views
FROM pg_namespace AS n
LEFT JOIN pg_class AS c ON c.relnamespace = n.oid
WHERE n.nspname IN ('public', 'identity', 'organisation', 'gig', 'neon_auth')
GROUP BY n.nspname
ORDER BY n.nspname;

-- 3. Show the local core scale. Run only if time allows; these are exact counts.
SELECT 'candidate_profile' AS entity, count(*) AS rows FROM public.candidate_profile
UNION ALL
SELECT 'job_requirement', count(*) FROM public.job_requirement
UNION ALL
SELECT 'application', count(*) FROM public.application;

-- 4. Trace one synthetic candidate through real foreign keys and status labels.
SELECT c.id AS candidate_id,
       u.full_name,
       a.id AS application_id,
       j.title AS job_title,
       s.display_name AS application_status,
       a.applied_at
FROM public.user_account AS u
JOIN public.candidate_profile AS c ON c.user_account_id = u.id
JOIN public.application AS a ON a.candidate_profile_id = c.id
JOIN public.job_requirement AS j ON j.id = a.job_requirement_id
JOIN public.application_status AS s ON s.id = a.application_status_id
WHERE u.email = 'seed5-00000001@talentra.example'
ORDER BY a.id
LIMIT 10;

-- 5. Show a small populated public gig sample. Physical gig.* tables are empty here.
SELECT r.id AS gig_request_id,
       r.title,
       a.id AS gig_application_id,
       x.id AS assignment_id,
       x.assignment_status
FROM public.gig_request AS r
LEFT JOIN public.gig_application AS a ON a.gig_request_id = r.id
LEFT JOIN public.gig_assignment AS x ON x.gig_application_id = a.id
ORDER BY r.id, a.id
LIMIT 10;

-- 6. Show small operational examples without opening large or sensitive tables.
SELECT 'wallet_ledger' AS example, count(*) AS rows FROM public.wallet_transaction_ledger
UNION ALL
SELECT 'notification_delivery', count(*) FROM public.notification_delivery
UNION ALL
SELECT 'analytics_funnel_daily', count(*) FROM public.analytics_application_funnel_daily;
