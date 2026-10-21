-- Read-only snapshot for the discovery pack. Explicitly select project
-- jolly-pond-45332483, branch br-jolly-dawn-azv4gh54, database neondb.
SELECT current_database() AS database,
       now() AS observed_at,
       (SELECT count(*) FROM public.candidate_profile) AS candidates,
       (SELECT count(*) FROM public.job_requirement) AS jobs,
       (SELECT count(*) FROM public.application) AS applications,
       pg_database_size(current_database()) AS db_bytes,
       (SELECT count(*) FROM information_schema.tables
        WHERE table_schema = 'identity' AND table_type = 'BASE TABLE') AS identity_base_tables,
       (SELECT count(*) FROM information_schema.views
        WHERE table_schema = 'identity') AS identity_views;

SELECT (SELECT count(*) FROM public.analytics_application_funnel_daily) AS funnel_rows,
       (SELECT max(report_date) FROM public.analytics_application_funnel_daily) AS latest_funnel_date,
       (SELECT count(*) FROM public.notification_delivery) AS deliveries,
       (SELECT count(*) FROM public.application WHERE candidate_profile_id IS NULL) AS null_candidate,
       (SELECT count(*) FROM public.application WHERE job_requirement_id IS NULL) AS null_job;
