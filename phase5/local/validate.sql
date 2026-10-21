-- Read-only checks for the synthetic local core seed.
SELECT 'candidate_profile' AS entity, count(*) AS rows FROM public.candidate_profile
UNION ALL SELECT 'job_requirement', count(*) FROM public.job_requirement
UNION ALL SELECT 'application', count(*) FROM public.application
UNION ALL SELECT 'account_profile', count(*) FROM public.account_profile
UNION ALL SELECT 'organisation', count(*) FROM public.organisation;

SELECT application_status_id, count(*) AS rows
FROM public.application GROUP BY application_status_id ORDER BY application_status_id;

SELECT count(*) FILTER (WHERE full_name ~ '[^ -~]') AS multilingual_names,
       count(*) FILTER (WHERE email LIKE 'seed5-%@talentra.example') AS synthetic_users
FROM public.user_account;

SELECT count(*) AS orphan_applications
FROM public.application AS a
LEFT JOIN public.candidate_profile AS c ON c.id = a.candidate_profile_id
LEFT JOIN public.job_requirement AS j ON j.id = a.job_requirement_id
WHERE c.id IS NULL OR j.id IS NULL;

SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size;

SELECT 'employer_users' AS entity, count(*) AS rows FROM public.user_account WHERE email LIKE 'employer5-%@talentra.example'
UNION ALL SELECT 'recruiter_users', count(*) FROM public.user_account WHERE email LIKE 'recruiter5-%@talentra.example'
UNION ALL SELECT 'gig_workers', count(*) FROM public.gig_worker_profile
UNION ALL SELECT 'gig_requests', count(*) FROM public.gig_request
UNION ALL SELECT 'gig_assignments', count(*) FROM public.gig_assignment
UNION ALL SELECT 'account_subscriptions', count(*) FROM public.account_subscription
UNION ALL SELECT 'licences', count(*) FROM public.account_licence
UNION ALL SELECT 'payments', count(*) FROM public.payment_transaction
UNION ALL SELECT 'refunds', count(*) FROM public.payment_refund
UNION ALL SELECT 'outreach_recipients', count(*) FROM public.sourcing_outreach_recipient
UNION ALL SELECT 'notification_deliveries', count(*) FROM public.notification_delivery
UNION ALL SELECT 'community_discussions', count(*) FROM public.community_discussion
UNION ALL SELECT 'audit_events', count(*) FROM public.audit_event
UNION ALL SELECT 'funnel_rows', count(*) FROM public.analytics_application_funnel_daily;
