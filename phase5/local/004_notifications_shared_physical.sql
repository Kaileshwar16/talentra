-- Local physical-schema version of phase5/seeds/004_notifications_shared.sql.
INSERT INTO public.notification_template(template_code,subject_template,body_template,supported_channels)
VALUES ('P5-JOB-ALERT','New jobs for you','A matching job is available.','IN_APP,EMAIL')
ON CONFLICT (template_code) DO NOTHING;

INSERT INTO public.notification_preference(user_account_id,category,in_app_enabled)
SELECT u.id,'JOB_ALERT',true FROM public.user_account u
WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=100
AND NOT EXISTS (SELECT 1 FROM public.notification_preference p
 WHERE p.user_account_id=u.id AND p.category='JOB_ALERT');

INSERT INTO public.notification_delivery(user_account_id,channel,
 delivery_status,title,template_id,idempotency_key)
SELECT u.id,'IN_APP',CASE WHEN split_part(split_part(u.email,'@',1),'-',2)::int%10=0
 THEN 'FAILED' ELSE 'DELIVERED' END,'Synthetic job alert',t.id,'P5-ALERT-'||u.id
FROM public.user_account u CROSS JOIN public.notification_template t
WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=1000
AND t.template_code='P5-JOB-ALERT'
AND NOT EXISTS (SELECT 1 FROM public.notification_delivery d
 WHERE d.idempotency_key='P5-ALERT-'||u.id);

INSERT INTO public.community_discussion(author_user_account_id,title,body,category)
SELECT u.id,'Phase 5 Discussion '||u.id,'Synthetic community discussion','CAREER'
FROM public.user_account u WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=10
AND NOT EXISTS (SELECT 1 FROM public.community_discussion d
 WHERE d.title='Phase 5 Discussion '||u.id);

INSERT INTO public.community_comment(discussion_id,author_user_account_id,body)
SELECT d.id,d.author_user_account_id,'Synthetic comment on career opportunities'
FROM public.community_discussion d WHERE d.title LIKE 'Phase 5 Discussion %'
AND NOT EXISTS (SELECT 1 FROM public.community_comment c WHERE c.discussion_id=d.id);

INSERT INTO public.consent_record(user_account_id,consent_type,consent_version,is_granted,metadata)
SELECT u.id,'TERMS','2026-10',true,'{"synthetic":true,"seed":"phase5"}'::jsonb
FROM public.user_account u WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=100
AND NOT EXISTS (SELECT 1 FROM public.consent_record c
 WHERE c.user_account_id=u.id AND c.consent_type='TERMS' AND c.consent_version='2026-10');

INSERT INTO public.user_credential(user_account_id,credential_type,credential_identifier,
 secret_hash,is_primary)
SELECT u.id,'OAUTH_TOKEN','P5-EXTERNAL-'||u.id,NULL,false
FROM public.user_account u WHERE u.email LIKE 'employer5-%@talentra.example'
ON CONFLICT (credential_type,credential_identifier) DO NOTHING;

WITH users AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'seed5-%@talentra.example'
 AND split_part(split_part(email,'@',1),'-',2)::int<=20)
INSERT INTO public.user_block(blocker_user_account_id,blocked_user_account_id)
SELECT a.id,b.id FROM users a JOIN users b ON b.rn=a.rn+1 WHERE a.rn<=10
AND NOT EXISTS (SELECT 1 FROM public.user_block x
 WHERE x.blocker_user_account_id=a.id AND x.blocked_user_account_id=b.id);

INSERT INTO public.audit_event(action_code,entity_type,outcome,metadata)
SELECT 'PHASE5_SEED','synthetic_seed','SUCCESS',
 '{"run_id":"phase5-2026-10-16","synthetic":true}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM public.audit_event a
 WHERE a.metadata->>'run_id'='phase5-2026-10-16');

INSERT INTO public.analytics_application_funnel_daily(report_date,job_requirement_id,organisation_id,
 total_applications,total_shortlisted,total_interviewed,total_offered,total_joined,total_withdrawn)
SELECT CURRENT_DATE,j.id,j.organisation_id,
 count(*),
 count(*) FILTER (WHERE a.application_status_id=2),
 count(*) FILTER (WHERE a.application_status_id=3),
 count(*) FILTER (WHERE a.application_status_id=4),
 count(*) FILTER (WHERE a.application_status_id=5),
 count(*) FILTER (WHERE a.application_status_id=7)
FROM public.job_requirement j JOIN public.application a ON a.job_requirement_id=j.id
WHERE j.title BETWEEN 'Phase 5 Job 000001' AND 'Phase 5 Job 000010'
AND NOT EXISTS (SELECT 1 FROM public.analytics_application_funnel_daily f
 WHERE f.job_requirement_id=j.id AND f.report_date=CURRENT_DATE)
GROUP BY j.id,j.organisation_id;

INSERT INTO public.analytics_recruiter_velocity(report_month,recruiter_user_account_id,organisation_id,
 total_jobs_managed,total_applications_reviewed)
SELECT date_trunc('month',CURRENT_DATE)::date,r.recruiter_user_account_id,r.organisation_id,10,50
FROM public.organisation_recruiter r JOIN public.user_account u ON u.id=r.recruiter_user_account_id
WHERE u.email LIKE 'recruiter5-%@talentra.example'
AND NOT EXISTS (SELECT 1 FROM public.analytics_recruiter_velocity v
 WHERE v.recruiter_user_account_id=r.recruiter_user_account_id
 AND v.report_month=date_trunc('month',CURRENT_DATE)::date);

INSERT INTO public.analytics_sourcing_efficiency(report_date,organisation_id,sourcing_channel,
 candidates_sourced,candidates_applied,candidates_hired)
SELECT CURRENT_DATE,p.organisation_id,'EMAIL',10,5,1 FROM public.sourcing_pool p
WHERE p.pool_name LIKE 'Phase 5 Pool %'
AND NOT EXISTS (SELECT 1 FROM public.analytics_sourcing_efficiency s
 WHERE s.organisation_id=p.organisation_id AND s.report_date=CURRENT_DATE
 AND s.sourcing_channel='EMAIL');

INSERT INTO public.analytics_wallet_reconciliation_summary(reconciliation_date,
 total_credits_purchased,net_active_wallet_balance,total_resumes_downloaded)
SELECT CURRENT_DATE,1000,
 (SELECT COALESCE(sum(balance_credits),0) FROM public.wallet_account),
 (SELECT count(*) FROM public.profile_download_event)
WHERE NOT EXISTS (SELECT 1 FROM public.analytics_wallet_reconciliation_summary s
 WHERE s.reconciliation_date=CURRENT_DATE);
