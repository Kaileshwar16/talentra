-- Synthetic Phase 5 licensing, sourcing, subscription, and payment examples.
INSERT INTO public.subscription_plan(code,name,price,currency_id,billing_interval)
VALUES ('P5-BASIC','Phase 5 Basic',1999,1,'MONTHLY')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.account_licence(account_profile_id,licence_key,max_seats,max_devices_per_user,subscription_plan_id)
SELECT a.id,'P5-LIC-'||a.account_code,5,3,p.id
FROM public.account_profile a CROSS JOIN public.subscription_plan p
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010' AND p.code='P5-BASIC'
ON CONFLICT (licence_key) DO NOTHING;

INSERT INTO public.account_subscription(account_profile_id,subscription_plan_id,subscription_status,
 current_period_starts_at,current_period_ends_at)
SELECT a.id,p.id,'ACTIVE',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP+interval '1 month'
FROM public.account_profile a CROSS JOIN public.subscription_plan p
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010' AND p.code='P5-BASIC'
AND NOT EXISTS (SELECT 1 FROM public.account_subscription s WHERE s.account_profile_id=a.id);

INSERT INTO public.wallet_account(account_profile_id,credit_balance,currency_id)
SELECT a.id,100,1 FROM public.account_profile a
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010'
ON CONFLICT (account_profile_id) DO NOTHING;

INSERT INTO public.payment_transaction(account_profile_id,amount,currency_id,payment_status,
 gateway_transaction_id,idempotency_key)
SELECT a.id,1999,1,'SUCCEEDED','P5-PAY-'||a.account_code,'P5-PAY-'||a.account_code
FROM public.account_profile a WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010'
ON CONFLICT (idempotency_key) DO NOTHING;

INSERT INTO public.wallet_transaction_ledger(wallet_account_id,transaction_type,credits_delta,
 balance_after,idempotency_key)
SELECT w.id,'PURCHASE',100,100,'P5-WALLET-'||a.account_code
FROM public.wallet_account w JOIN public.account_profile a ON a.id=w.account_profile_id
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010'
AND NOT EXISTS (SELECT 1 FROM public.wallet_transaction_ledger l
 WHERE l.idempotency_key='P5-WALLET-'||a.account_code);

INSERT INTO public.invoice(account_profile_id,payment_transaction_id,invoice_number,
 invoice_status,subtotal_amount,tax_amount,total_amount,currency_id)
SELECT a.id,t.id,'P5-INV-'||a.account_code,'PAID',1999,0,1999,1
FROM public.payment_transaction t JOIN public.account_profile a ON a.id=t.account_profile_id
WHERE t.idempotency_key LIKE 'P5-PAY-%'
ON CONFLICT (invoice_number) DO NOTHING;

INSERT INTO public.payment_refund(payment_transaction_id,account_profile_id,refund_amount,
 currency_id,refund_status,refund_type,idempotency_key)
SELECT t.id,t.account_profile_id,199,1,'SUCCEEDED','PARTIAL',
 'P5-REF-'||a.account_code
FROM public.payment_transaction t JOIN public.account_profile a ON a.id=t.account_profile_id
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000005'
ON CONFLICT (idempotency_key) DO NOTHING;

INSERT INTO public.sourcing_pool(organisation_id,name)
SELECT o.id,'Phase 5 Pool '||a.account_code
FROM public.organisation o JOIN public.account_profile a ON a.id=o.account_profile_id
WHERE a.account_code BETWEEN 'P5-000001' AND 'P5-000010'
AND NOT EXISTS (SELECT 1 FROM public.sourcing_pool p
 WHERE p.organisation_id=o.id AND p.name='Phase 5 Pool '||a.account_code);

WITH pools AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.sourcing_pool WHERE name LIKE 'Phase 5 Pool %'),
candidates AS (SELECT c.id,row_number() OVER (ORDER BY c.id) rn
 FROM public.candidate_profile c JOIN public.user_account u ON u.id=c.user_account_id
 WHERE u.email LIKE 'seed5-%@talentra.example' LIMIT 10),
employers AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'employer5-%@talentra.example')
INSERT INTO public.sourcing_pool_candidate(sourcing_pool_id,candidate_profile_id,added_by_user_id)
SELECT p.id,c.id,e.id FROM pools p JOIN candidates c ON c.rn=p.rn
JOIN employers e ON e.rn=p.rn
ON CONFLICT (sourcing_pool_id,candidate_profile_id) DO NOTHING;

WITH employers AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'employer5-%@talentra.example'),
pools AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.sourcing_pool WHERE name LIKE 'Phase 5 Pool %')
INSERT INTO public.sourcing_outreach_batch(sourcing_pool_id,created_by_user_id,batch_name,
 outreach_channel,batch_status,total_recipients)
SELECT p.id,e.id,'Phase 5 Batch '||p.id,'EMAIL','COMPLETED',1
FROM pools p JOIN employers e ON e.rn=p.rn
WHERE NOT EXISTS (SELECT 1 FROM public.sourcing_outreach_batch b WHERE b.sourcing_pool_id=p.id);

INSERT INTO public.sourcing_outreach_recipient(outreach_batch_id,candidate_profile_id,
 delivery_status,delivered_at)
SELECT b.id,pc.candidate_profile_id,'DELIVERED',CURRENT_TIMESTAMP
FROM public.sourcing_outreach_batch b
JOIN public.sourcing_pool_candidate pc ON pc.sourcing_pool_id=b.sourcing_pool_id
WHERE b.batch_name LIKE 'Phase 5 Batch %'
ON CONFLICT (outreach_batch_id,candidate_profile_id) DO NOTHING;

WITH recruiters AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.user_account WHERE email LIKE 'recruiter5-%@talentra.example'),
orgs AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.organisation WHERE name LIKE 'Phase 5 Org %'),
candidates AS (SELECT c.id,row_number() OVER (ORDER BY c.id) rn
 FROM public.candidate_profile c JOIN public.user_account u ON u.id=c.user_account_id
 WHERE u.email LIKE 'seed5-%@talentra.example' LIMIT 10)
INSERT INTO public.profile_download_event(candidate_profile_id,downloader_user_account_id,
 organisation_id,credits_deducted)
SELECT c.id,r.id,o.id,1 FROM candidates c JOIN recruiters r ON r.rn=c.rn JOIN orgs o ON o.rn=c.rn
WHERE NOT EXISTS (SELECT 1 FROM public.profile_download_event d
 WHERE d.candidate_profile_id=c.id AND d.downloader_user_account_id=r.id);

INSERT INTO public.device_session(user_account_id,session_token_hash,expires_at)
SELECT u.id,md5(u.email)||md5(u.email),CURRENT_TIMESTAMP+interval '1 day'
FROM public.user_account u WHERE u.email LIKE 'recruiter5-%@talentra.example'
ON CONFLICT (session_token_hash) DO NOTHING;

UPDATE public.job_requirement SET open_to_consultants=true
WHERE title='Phase 5 Job 000001' AND open_to_consultants=false;

INSERT INTO public.consultant_request(job_requirement_id,consultant_organisation_id,commission_rate_percent)
SELECT j.id,o.id,10 FROM public.job_requirement j CROSS JOIN public.organisation o
JOIN public.account_profile a ON a.id=o.account_profile_id
WHERE j.title='Phase 5 Job 000001' AND a.account_code='P5-000001'
AND NOT EXISTS (SELECT 1 FROM public.consultant_request r
 WHERE r.job_requirement_id=j.id AND r.consultant_organisation_id=o.id);
