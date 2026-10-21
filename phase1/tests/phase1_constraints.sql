-- Run with psql -v ON_ERROR_STOP=1. Test data is always rolled back.
DO $tests$
DECLARE
  passed INTEGER := 0;
  user_a BIGINT;
  user_b BIGINT;
  candidate_a BIGINT;
  candidate_b BIGINT;
  org_a BIGINT;
  draft_status BIGINT;
  onsite BIGINT;
  permanent BIGINT;
  applied BIGINT;
  inr BIGINT;
  yearly BIGINT;
  job_a BIGINT;
  job_b BIGINT;
  resume_a BIGINT;
  questionnaire_a BIGINT;
  questionnaire_b BIGINT;
  application_a BIGINT;
  application_b BIGINT;
  question_a BIGINT;
  question_b BIGINT;
  option_a BIGINT;
  option_a2 BIGINT;
  option_b BIGINT;
  document_b BIGINT;
  offer_b BIGINT;
  stage_b BIGINT;
BEGIN
  BEGIN

INSERT INTO public.user_account (full_name, email) VALUES ('Phase One Test A', 'phase1-a@example.invalid') RETURNING id INTO user_a;
INSERT INTO public.user_account (full_name, email) VALUES ('Phase One Test B', 'phase1-b@example.invalid') RETURNING id INTO user_b;
INSERT INTO public.candidate_profile (user_account_id) VALUES (user_a) RETURNING id INTO candidate_a;
INSERT INTO public.candidate_profile (user_account_id) VALUES (user_b) RETURNING id INTO candidate_b;
INSERT INTO public.organisation (name) VALUES ('Phase One Test Organisation') RETURNING id INTO org_a;
SELECT id INTO draft_status FROM public.job_status WHERE code = 'draft';
SELECT id INTO onsite FROM public.work_type WHERE code = 'onsite';
SELECT id INTO permanent FROM public.employment_type WHERE code = 'permanent';
SELECT id INTO applied FROM public.application_status WHERE code = 'applied';
SELECT id INTO inr FROM public.currency WHERE code = 'INR';
SELECT id INTO yearly FROM public.salary_period WHERE code = 'year';
INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id)
 VALUES ('Phase One Test Job A', org_a, draft_status, onsite, permanent) RETURNING id INTO job_a;
INSERT INTO public.job_requirement (title, organisation_id, job_status_id, work_type_id, employment_type_id)
 VALUES ('Phase One Test Job B', org_a, draft_status, onsite, permanent) RETURNING id INTO job_b;
INSERT INTO public.resume_version (candidate_profile_id, version_number, private_storage_reference)
 VALUES (candidate_a, 1, 'private://phase1-test/resume') RETURNING id INTO resume_a;
INSERT INTO public.questionnaire (title, version_number, job_requirement_id) VALUES ('Phase One Questions A', 1, job_a) RETURNING id INTO questionnaire_a;
INSERT INTO public.questionnaire (title, version_number, job_requirement_id) VALUES ('Phase One Questions B', 1, job_b) RETURNING id INTO questionnaire_b;
INSERT INTO public.application (candidate_profile_id, job_requirement_id, application_status_id, resume_version_id, questionnaire_id)
 VALUES (candidate_a, job_a, applied, resume_a, questionnaire_a) RETURNING id INTO application_a;
INSERT INTO public.application (candidate_profile_id, job_requirement_id, application_status_id, questionnaire_id)
 VALUES (candidate_b, job_b, applied, questionnaire_b) RETURNING id INTO application_b;
INSERT INTO public.question (questionnaire_id, question_type_id, question_text)
 SELECT questionnaire_a, id, 'Pick one' FROM public.question_type WHERE code = 'single_choice' RETURNING id INTO question_a;
INSERT INTO public.question (questionnaire_id, question_type_id, question_text)
 SELECT questionnaire_b, id, 'Other job question' FROM public.question_type WHERE code = 'single_choice' RETURNING id INTO question_b;
INSERT INTO public.question_option (question_id, option_text) VALUES (question_a, 'A') RETURNING id INTO option_a;
INSERT INTO public.question_option (question_id, option_text) VALUES (question_a, 'B') RETURNING id INTO option_a2;
INSERT INTO public.question_option (question_id, option_text) VALUES (question_b, 'B') RETURNING id INTO option_b;
INSERT INTO public.application_answer (application_id, questionnaire_id, question_id, question_option_id)
 VALUES (application_a, questionnaire_a, question_a, option_a);
INSERT INTO public.candidate_document (candidate_profile_id, document_type_id, name, private_storage_reference)
 SELECT candidate_b, id, 'Other candidate document', 'private://phase1-test/document' FROM public.document_type WHERE code = 'certificate' RETURNING id INTO document_b;
INSERT INTO public.offer (application_id, offer_status_id, version_number, amount, currency_id, salary_period_id)
 SELECT application_b, id, 1, 100000, inr, yearly FROM public.offer_status WHERE code = 'draft' RETURNING id INTO offer_b;
INSERT INTO public.job_hiring_stage (name, job_requirement_id, hiring_stage_type_id, sequence)
 SELECT 'Interview', job_b, id, 1 FROM public.hiring_stage_type WHERE code = 'interview' RETURNING id INTO stage_b;
INSERT INTO public.application_profile_snapshot (application_id, profile_version, profile_data)
 VALUES (application_a, 1, '{"headline":"Test"}');

BEGIN
  INSERT INTO public.user_account (full_name, email) VALUES ('Duplicate', 'phase1-a@example.invalid');
  RAISE EXCEPTION 'Test failed: duplicate email was accepted';
EXCEPTION WHEN SQLSTATE '23505' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.user_account (full_name, email) VALUES ('Uppercase', 'UPPER@example.invalid');
  RAISE EXCEPTION 'Test failed: non-normalized email was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.candidate_profile (user_account_id) VALUES (user_a);
  RAISE EXCEPTION 'Test failed: one profile per user was accepted';
EXCEPTION WHEN SQLSTATE '23505' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.candidate_profile (user_account_id) VALUES (-12345);
  RAISE EXCEPTION 'Test failed: orphan candidate was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.job_requirement SET salary_min = 200, salary_max = 100, currency_id = inr, salary_period_id = yearly WHERE id = job_a;
  RAISE EXCEPTION 'Test failed: inverted salary bounds was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.job_requirement SET salary_min = 100 WHERE id = job_a;
  RAISE EXCEPTION 'Test failed: salary requires currency was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application (candidate_profile_id, job_requirement_id, application_status_id) VALUES (candidate_a, job_a, applied);
  RAISE EXCEPTION 'Test failed: duplicate application was accepted';
EXCEPTION WHEN SQLSTATE '23505' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application (candidate_profile_id, job_requirement_id, application_status_id, resume_version_id) VALUES (candidate_b, job_a, applied, resume_a);
  RAISE EXCEPTION 'Test failed: resume ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application (candidate_profile_id, job_requirement_id, application_status_id, questionnaire_id) VALUES (candidate_b, job_a, applied, questionnaire_b);
  RAISE EXCEPTION 'Test failed: questionnaire job ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.application_answer SET question_option_id = option_b WHERE application_id = application_a;
  RAISE EXCEPTION 'Test failed: question option ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application_answer (application_id, questionnaire_id, question_id, question_option_id) VALUES (application_a, questionnaire_a, question_a, option_a2);
  RAISE EXCEPTION 'Test failed: single-choice cardinality was accepted';
EXCEPTION WHEN SQLSTATE '23505' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.application_answer SET question_option_id = NULL, answer_text = 'invalid representation' WHERE application_id = application_a;
  RAISE EXCEPTION 'Test failed: answer type was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application_answer (application_id, questionnaire_id, question_id, question_option_id) VALUES (application_a, questionnaire_b, question_b, option_b);
  RAISE EXCEPTION 'Test failed: questionnaire answer ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application_document (application_id, candidate_profile_id, candidate_document_id) VALUES (application_a, candidate_a, document_b);
  RAISE EXCEPTION 'Test failed: document ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.joining_record (application_id, offer_id, joined_on) VALUES (application_a, offer_b, CURRENT_DATE);
  RAISE EXCEPTION 'Test failed: offer application ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.application_stage_result (application_id, job_requirement_id, job_hiring_stage_id, stage_decision_id) SELECT application_a, job_a, stage_b, id FROM public.stage_decision WHERE code = 'pending';
  RAISE EXCEPTION 'Test failed: stage job ownership was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.application_profile_snapshot SET profile_data = '{}' WHERE application_id = application_a;
  RAISE EXCEPTION 'Test failed: snapshot immutability was accepted';
EXCEPTION WHEN SQLSTATE '55000' THEN
  passed := passed + 1;
END;

BEGIN
  UPDATE public.resume_version SET private_storage_reference = 'changed' WHERE id = resume_a;
  RAISE EXCEPTION 'Test failed: resume immutability was accepted';
EXCEPTION WHEN SQLSTATE '55000' THEN
  passed := passed + 1;
END;

BEGIN
  DELETE FROM public.application_status_history WHERE application_id = application_a;
  RAISE EXCEPTION 'Test failed: status history append-only was accepted';
EXCEPTION WHEN SQLSTATE '55000' THEN
  passed := passed + 1;
END;

BEGIN
  TRUNCATE public.application_status_history;
  RAISE EXCEPTION 'Test failed: history truncate rejected was accepted';
EXCEPTION WHEN SQLSTATE '55000' THEN
  passed := passed + 1;
END;

BEGIN
  DELETE FROM public.user_account WHERE id = user_a;
  RAISE EXCEPTION 'Test failed: source user deletion restricted was accepted';
EXCEPTION WHEN SQLSTATE '23503' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.profile_completion_score (candidate_profile_id, score_percent, rules_version) VALUES (candidate_a, 101, 1);
  RAISE EXCEPTION 'Test failed: profile score range was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

BEGIN
  INSERT INTO public.candidate_project (candidate_profile_id, title, project_role, start_date, end_date) VALUES (candidate_a, 'Test', 'Developer', '2026-10-15', '2026-10-14');
  RAISE EXCEPTION 'Test failed: date ordering was accepted';
EXCEPTION WHEN SQLSTATE '23514' THEN
  passed := passed + 1;
END;

IF (SELECT count(*) FROM public.application_status_history WHERE application_id = application_a) <> 1 THEN
 RAISE EXCEPTION 'Initial application status history missing';
END IF;
passed := passed + 1;
UPDATE public.application SET application_status_id = (SELECT id FROM public.application_status WHERE code = 'shortlisted') WHERE id = application_a;
IF (SELECT count(*) FROM public.application_status_history WHERE application_id = application_a) <> 2 THEN
 RAISE EXCEPTION 'Application status transition history missing';
END IF;
passed := passed + 1;
IF (SELECT count(*) FROM public.job_status_history WHERE job_requirement_id = job_a) <> 1 THEN
 RAISE EXCEPTION 'Initial job status history missing';
END IF;
passed := passed + 1;

IF passed <> 26 THEN RAISE EXCEPTION 'Unexpected test count: %', passed; END IF;
RAISE EXCEPTION 'Validation passed' USING ERRCODE = 'Z0002';
EXCEPTION WHEN SQLSTATE 'Z0002' THEN RAISE NOTICE '26 Phase 1 checks passed; test data rolled back';
END;
END $tests$;
