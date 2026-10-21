-- B66 read-only seed quality checks; run on production neondb.
-- Zero means no violations observed for that check, not a complete data-standard audit.

-- DQ01: Seed volume and detail coverage
SELECT (SELECT count(*) FROM public.candidate_profile) AS candidates, (SELECT count(*) FROM public.job_requirement) AS jobs, (SELECT count(*) FROM public.application) AS applications, (SELECT count(*) FROM public.candidate_education) AS education_rows, (SELECT count(*) FROM public.candidate_experience) AS experience_rows, (SELECT count(*) FROM public.candidate_skill) AS skill_rows, (SELECT count(*) FROM public.candidate_language) AS language_rows, (SELECT count(*) FROM public.resume_version) AS resume_rows, (SELECT count(*) FROM public.job_recruiter_assignment) AS recruiter_job_assignments;

-- DQ02: Account and contact format
SELECT (SELECT count(*) FROM public.user_account WHERE email IS NOT NULL AND email <> lower(email)) AS mixed_case_emails, (SELECT count(*) FROM public.user_account WHERE email IS NOT NULL AND email !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$') AS malformed_emails, (SELECT count(*) FROM (SELECT lower(email) FROM public.user_account WHERE email IS NOT NULL GROUP BY lower(email) HAVING count(*) > 1) d) AS duplicate_normalized_emails, (SELECT count(*) FROM public.candidate_contact WHERE phone_e164 IS NOT NULL AND phone_e164 !~ '^\+[1-9][0-9]{1,14}$') AS invalid_e164_phones;

-- DQ03: Range, salary and money checks
SELECT (SELECT count(*) FROM public.candidate_education WHERE end_date < start_date) AS reversed_education_dates, (SELECT count(*) FROM public.candidate_experience WHERE end_date < start_date) AS reversed_experience_dates, (SELECT count(*) FROM public.job_requirement WHERE salary_min IS NOT NULL AND salary_max IS NOT NULL AND salary_min > salary_max) AS reversed_salary_bounds, (SELECT count(*) FROM public.job_requirement WHERE (salary_min IS NOT NULL OR salary_max IS NOT NULL) AND currency_id IS NULL) AS salary_without_currency, (SELECT count(*) FROM public.payment_transaction WHERE amount < 0) AS negative_payments, (SELECT count(*) FROM public.wallet_account WHERE balance_credits < 0) AS negative_wallet_balances;

-- DQ04: Application relationship integrity
SELECT count(*) FILTER (WHERE c.id IS NULL) AS missing_candidate_fk, count(*) FILTER (WHERE j.id IS NULL) AS missing_job_fk, count(*) FILTER (WHERE s.id IS NULL) AS missing_status_fk, count(*) AS applications_checked FROM public.application a LEFT JOIN public.candidate_profile c ON c.id=a.candidate_profile_id LEFT JOIN public.job_requirement j ON j.id=a.job_requirement_id LEFT JOIN public.application_status s ON s.id=a.application_status_id;

-- DQ05: Constraint validation
SELECT count(*) FILTER (WHERE NOT convalidated) AS unvalidated_constraints, count(*) AS all_constraints FROM pg_constraint WHERE connamespace IN (SELECT oid FROM pg_namespace WHERE nspname IN ('public','identity','organisation','gig'));

-- DQ06: Gig assignment overlap
SELECT count(*) AS overlapping_pairs FROM public.gig_assignment a JOIN public.gig_assignment b ON a.id < b.id AND a.gig_worker_profile_id=b.gig_worker_profile_id AND a.scheduled_start_at < b.scheduled_end_at AND b.scheduled_start_at < a.scheduled_end_at WHERE a.assignment_status NOT IN ('CANCELLED','REJECTED') AND b.assignment_status NOT IN ('CANCELLED','REJECTED');

-- DQ07: Mart source comparison
SELECT (SELECT count(*) FROM public.application) AS source_applications, (SELECT coalesce(sum(applied_count),0) FROM public.analytics_application_funnel_daily) AS mart_applied_count, (SELECT max(report_date) FROM public.analytics_application_funnel_daily) AS latest_report_date, (SELECT count(*) FROM public.analytics_application_funnel_daily) AS mart_rows;

-- DQ08: Non-null coverage denominators
SELECT (SELECT count(*) FROM public.user_account WHERE email IS NOT NULL) AS emails_present, (SELECT count(*) FROM public.candidate_contact WHERE phone_e164 IS NOT NULL) AS phones_present, (SELECT count(*) FROM public.job_requirement WHERE salary_min IS NOT NULL OR salary_max IS NOT NULL) AS jobs_with_salary, (SELECT count(*) FROM public.job_requirement WHERE salary_min IS NULL AND salary_max IS NULL) AS jobs_without_salary, (SELECT count(*) FROM public.payment_transaction) AS payments, (SELECT count(*) FROM public.wallet_account) AS wallets;

-- DQ09: Duplicate candidate-job pairs
SELECT count(*) AS duplicate_candidate_job_pairs FROM (SELECT candidate_profile_id, job_requirement_id FROM public.application GROUP BY candidate_profile_id, job_requirement_id HAVING count(*) > 1) d;
