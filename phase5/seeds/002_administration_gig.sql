-- Synthetic Phase 5 administration, organisation, and gig examples.
-- Run after generate_core.py. Re-running does not duplicate marked records.
INSERT INTO public.user_account(full_name,email,language_id)
SELECT 'Phase 5 Employer '||g,'employer5-'||lpad(g::text,4,'0')||'@talentra.example',1
FROM generate_series(1,20) g ON CONFLICT (email) DO NOTHING;

INSERT INTO public.user_account(full_name,email,language_id)
SELECT 'Phase 5 Recruiter '||g,'recruiter5-'||lpad(g::text,4,'0')||'@talentra.example',1
FROM generate_series(1,20) g ON CONFLICT (email) DO NOTHING;

INSERT INTO identity.user_role(user_account_id,app_role_id)
SELECT u.id,CASE WHEN u.email LIKE 'employer5-%' THEN 2
 WHEN u.email LIKE 'recruiter5-%' THEN 3 ELSE 4 END
FROM public.user_account u
WHERE (u.email LIKE 'employer5-%@talentra.example'
   OR u.email LIKE 'recruiter5-%@talentra.example'
   OR (u.email LIKE 'seed5-%@talentra.example'
       AND split_part(split_part(u.email,'@',1),'-',2)::int<=100))
AND NOT EXISTS (SELECT 1 FROM identity.user_role r WHERE r.user_account_id=u.id);

WITH orgs AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.organisation WHERE name LIKE 'Phase 5 Org %'),
recruiters AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'recruiter5-%@talentra.example')
INSERT INTO public.organisation_recruiter(organisation_id,recruiter_user_account_id)
SELECT o.id,r.id FROM orgs o JOIN recruiters r ON r.rn=o.rn
WHERE NOT EXISTS (SELECT 1 FROM public.organisation_recruiter m
 WHERE m.organisation_id=o.id AND m.recruiter_user_account_id=r.id);

INSERT INTO public.gig_worker_profile(user_account_id,headline,hourly_rate,currency_id)
SELECT u.id,'Phase 5 Gig Worker '||split_part(split_part(u.email,'@',1),'-',2),500,1
FROM public.user_account u WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=100
AND NOT EXISTS (SELECT 1 FROM public.gig_worker_profile w WHERE w.user_account_id=u.id);

INSERT INTO public.gig_worker_availability(gig_worker_profile_id,available_from,available_until,timezone_name)
SELECT w.id,CURRENT_TIMESTAMP+interval '7 days',CURRENT_TIMESTAMP+interval '9 days','Asia/Kolkata'
FROM public.gig_worker_profile w JOIN public.user_account u ON u.id=w.user_account_id
WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int<=100
AND NOT EXISTS (SELECT 1 FROM public.gig_worker_availability a WHERE a.gig_worker_profile_id=w.id);

WITH orgs AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.organisation WHERE name LIKE 'Phase 5 Org %'),
employers AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'employer5-%@talentra.example')
INSERT INTO public.gig_request(organisation_id,created_by_user_id,title,description,
 budget_amount,currency_id,pricing_model,status,starts_at,deadline)
SELECT o.id,e.id,'Phase 5 Gig '||lpad(g::text,4,'0'),'Synthetic gig request',
 5000,1,'FIXED','OPEN',CURRENT_TIMESTAMP+interval '7 days',CURRENT_TIMESTAMP+interval '8 days'
FROM generate_series(1,100) g JOIN orgs o ON o.rn=((g-1)%100)+1
JOIN employers e ON e.rn=((g-1)%20)+1
WHERE NOT EXISTS (SELECT 1 FROM public.gig_request r
 WHERE r.title='Phase 5 Gig '||lpad(g::text,4,'0'));

WITH workers AS (SELECT w.id,row_number() OVER (ORDER BY w.id) rn FROM public.gig_worker_profile w
 JOIN public.user_account u ON u.id=w.user_account_id
 WHERE u.email LIKE 'seed5-%@talentra.example'
 AND split_part(split_part(u.email,'@',1),'-',2)::int<=100),
requests AS (SELECT id,row_number() OVER (ORDER BY id) rn FROM public.gig_request
 WHERE title LIKE 'Phase 5 Gig %')
INSERT INTO public.gig_application(gig_request_id,gig_worker_profile_id,application_status,
 proposed_price,currency_id,decided_at)
SELECT r.id,w.id,'ACCEPTED',5000,1,CURRENT_TIMESTAMP
FROM requests r JOIN workers w ON w.rn=r.rn
ON CONFLICT (gig_request_id,gig_worker_profile_id) DO NOTHING;

INSERT INTO public.gig_assignment(gig_application_id,gig_request_id,gig_worker_profile_id,
 assignment_status,scheduled_start_at,scheduled_end_at,agreed_amount,currency_id)
SELECT a.id,a.gig_request_id,a.gig_worker_profile_id,'ACCEPTED',
 CURRENT_TIMESTAMP+interval '7 days',CURRENT_TIMESTAMP+interval '8 days',5000,1
FROM public.gig_application a JOIN public.gig_request r ON r.id=a.gig_request_id
WHERE r.title LIKE 'Phase 5 Gig %'
AND NOT EXISTS (SELECT 1 FROM public.gig_assignment x WHERE x.gig_application_id=a.id);
