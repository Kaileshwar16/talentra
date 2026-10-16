"""Emit idempotent SQL for a bounded Phase 5 synthetic core-data batch.

Run stages in order: accounts, users, candidates, jobs, applications.
Emails use the reserved .example domain; no real identities are generated.
"""

import argparse


def sql(stage: str, start: int, end: int, accounts: int, jobs: int, apps: int) -> str:
    if stage == "accounts":
        return f"""INSERT INTO public.account_profile(account_code,account_name,account_type)
SELECT 'P5-'||lpad(g::text,6,'0'),'Phase 5 Account '||g,'ENTERPRISE'
FROM generate_series(1,{accounts}) g ON CONFLICT (account_code) DO NOTHING;
INSERT INTO public.organisation(name,account_profile_id,organisation_type_id,verification_status_id,is_active)
SELECT 'Phase 5 Org '||a.account_code,a.id,1,2,true FROM public.account_profile a
WHERE a.account_code LIKE 'P5-%' AND NOT EXISTS
 (SELECT 1 FROM public.organisation o WHERE o.account_profile_id=a.id);"""
    if stage == "users":
        return f"""INSERT INTO public.user_account(full_name,email,language_id)
SELECT CASE WHEN g%10=0 THEN 'आर्या शर्मा' WHEN g%10=1 THEN 'ليلى أحمد'
 WHEN g%10=2 THEN '王美玲' WHEN g%10=3 THEN 'Алексей Иванов'
 ELSE 'Asha Kumar '||(g%500) END,
 'seed5-'||lpad(g::text,8,'0')||'@talentra.example',1
FROM generate_series({start},{end}) g ON CONFLICT (email) DO NOTHING;"""
    if stage == "candidates":
        return f"""INSERT INTO public.candidate_profile(user_account_id,headline,summary,available_from)
SELECT u.id,'Synthetic candidate '||split_part(split_part(u.email,'@',1),'-',2),
 'Phase 5 synthetic profile',CURRENT_DATE+(split_part(split_part(u.email,'@',1),'-',2)::int%30)
FROM public.user_account u WHERE u.email LIKE 'seed5-%@talentra.example'
AND split_part(split_part(u.email,'@',1),'-',2)::int BETWEEN {start} AND {end}
AND NOT EXISTS (SELECT 1 FROM public.candidate_profile c WHERE c.user_account_id=u.id);"""
    if stage == "jobs":
        return f"""WITH orgs AS (SELECT id,row_number() OVER (ORDER BY id) rn
 FROM public.organisation WHERE name LIKE 'Phase 5 Org %')
INSERT INTO public.job_requirement(title,description,organisation_id,job_status_id,work_type_id,
 employment_type_id,salary_min,salary_max,currency_id,salary_period_id,language_id,published_at,deadline,positions)
SELECT 'Phase 5 Job '||lpad(g::text,6,'0'),'Synthetic job requirement',o.id,2,
 ((g-1)%3)+1,((g-1)%6)+1,
 CASE WHEN g%4=0 THEN NULL ELSE 30000+(g%12)*5000 END,
 CASE WHEN g%4=0 THEN NULL ELSE 60000+(g%12)*5000 END,
 CASE WHEN g%4=0 THEN NULL ELSE 1 END,CASE WHEN g%4=0 THEN NULL ELSE 3 END,
 1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP+interval '30 days',1
FROM generate_series({start},{end}) g JOIN orgs o ON o.rn=((g-1)%{accounts})+1
WHERE NOT EXISTS (SELECT 1 FROM public.job_requirement j
 WHERE j.title='Phase 5 Job '||lpad(g::text,6,'0'));"""
    if stage == "applications":
        return f"""WITH candidates AS (
 SELECT c.id,split_part(split_part(u.email,'@',1),'-',2)::int AS n
 FROM public.candidate_profile c JOIN public.user_account u ON u.id=c.user_account_id
 WHERE u.email LIKE 'seed5-%@talentra.example'
 AND split_part(split_part(u.email,'@',1),'-',2)::int BETWEEN {start} AND {end}),
jobs AS (SELECT id,right(title,6)::int AS n FROM public.job_requirement
 WHERE title LIKE 'Phase 5 Job %')
INSERT INTO public.application(candidate_profile_id,job_requirement_id,application_status_id,applied_at)
SELECT c.id,j.id,((c.n+s)%7)+1,CURRENT_TIMESTAMP-((c.n+s)%90)*interval '1 day'
FROM candidates c CROSS JOIN generate_series(1,{apps}) s
JOIN jobs j ON j.n=((c.n*7+s*199)%{jobs})+1
ON CONFLICT (candidate_profile_id,job_requirement_id) DO NOTHING;"""
    raise ValueError(stage)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("stage", choices=["accounts", "users", "candidates", "jobs", "applications"])
    parser.add_argument("--start", type=int, default=1)
    parser.add_argument("--end", type=int, default=10000)
    parser.add_argument("--accounts", type=int, default=100)
    parser.add_argument("--jobs", type=int, default=1000)
    parser.add_argument("--applications-per-candidate", type=int, default=5)
    args = parser.parse_args()
    if args.start < 1 or args.end < args.start or args.accounts < 1 or args.jobs < 1 or args.applications_per_candidate < 1:
        parser.error("counts must be positive and end must be at least start")
    print(sql(args.stage, args.start, args.end, args.accounts, args.jobs, args.applications_per_candidate))
