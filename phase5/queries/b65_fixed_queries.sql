-- Phase 5 B65 fixed read-only query set. Run against Neon production neondb.
-- Sample IDs were selected from the live 2026-10-17 seed: candidate 46, job 29, recruiter 10092.
-- Q01-Q10 are the top ten for plan capture. No ANALYZE is used.

-- Q01: Candidate profile lookup [lookup]
SELECT id, user_account_id, headline, city_id FROM public.candidate_profile WHERE id = 46 AND deleted_at IS NULL;

-- Q02: Recent published jobs [lookup]
SELECT id, organisation_id, title, published_at FROM public.job_requirement WHERE published_at IS NOT NULL AND deleted_at IS NULL ORDER BY published_at DESC, id DESC LIMIT 20;

-- Q03: Candidate application history [functional]
SELECT a.id, a.job_requirement_id, s.code AS status, a.applied_at FROM public.application a JOIN public.application_status s ON s.id = a.application_status_id WHERE a.candidate_profile_id = 46 AND a.deleted_at IS NULL ORDER BY a.applied_at DESC, a.id DESC LIMIT 20;

-- Q04: Job pipeline counts [analytics]
SELECT s.code AS status, count(*) AS applications FROM public.application a JOIN public.application_status s ON s.id = a.application_status_id WHERE a.job_requirement_id = 29 AND a.deleted_at IS NULL GROUP BY s.code ORDER BY s.code;

-- Q05: Recruiter assignments [security/lookup]
SELECT o.id AS mapping_id, o.organisation_id, o.recruiter_user_account_id, count(jra.id) AS assigned_jobs FROM public.organisation_recruiter o LEFT JOIN public.job_recruiter_assignment jra ON jra.organisation_recruiter_id = o.id WHERE o.recruiter_user_account_id = 10092 GROUP BY o.id, o.organisation_id, o.recruiter_user_account_id;

-- Q06: Gig assignment status [functional]
SELECT r.id AS request_id, r.status AS request_status, ga.assignment_status, ga.scheduled_start_at FROM public.gig_request r LEFT JOIN public.gig_assignment ga ON ga.gig_request_id = r.id WHERE r.id BETWEEN 1 AND 20 ORDER BY r.id, ga.id;

-- Q07: Consultant requests and eligible jobs [business rule]
SELECT cr.id, cr.request_status, j.id AS job_id, j.open_to_consultants FROM public.consultant_request cr JOIN public.job_requirement j ON j.id = cr.job_requirement_id WHERE cr.id <= 20 ORDER BY cr.id;

-- Q08: Wallet and ledger [transactional]
SELECT w.id, w.balance_credits, count(l.id) AS ledger_entries, coalesce(sum(l.credit_amount),0) AS ledger_credits FROM public.wallet_account w LEFT JOIN public.wallet_transaction_ledger l ON l.wallet_account_id = w.id WHERE w.id = 1 GROUP BY w.id, w.balance_credits;

-- Q09: Outreach delivery counts [functional]
SELECT b.id, b.batch_status, count(r.id) AS recipients, count(*) FILTER (WHERE r.delivery_status = 'DELIVERED') AS delivered FROM public.sourcing_outreach_batch b LEFT JOIN public.sourcing_outreach_recipient r ON r.outreach_batch_id = b.id WHERE b.id <= 20 GROUP BY b.id, b.batch_status ORDER BY b.id;

-- Q10: Notification delivery summary [analytics]
SELECT delivery_status, count(*) AS deliveries FROM public.notification_delivery GROUP BY delivery_status ORDER BY delivery_status;

-- Q11: Funnel mart freshness [analytics]
SELECT count(*) AS mart_rows, max(report_date) AS latest_report_date, sum(coalesce(applied_count,0)) AS mart_applied FROM public.analytics_application_funnel_daily;

-- Q12: Application integrity sample and total [quality]
SELECT count(*) AS applications, count(*) FILTER (WHERE candidate_profile_id IS NULL) AS missing_candidate, count(*) FILTER (WHERE job_requirement_id IS NULL) AS missing_job FROM public.application;
