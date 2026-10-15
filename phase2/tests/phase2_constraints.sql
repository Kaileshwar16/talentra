-- Run on a Phase 2 database as its owner. Test data and roles roll back.
DO $phase2_tests$
DECLARE
  account_a BIGINT; account_b BIGINT; org_a BIGINT; org_b BIGINT; org_child BIGINT;
  candidate_id BIGINT; employer_id BIGINT; recruiter_id BIGINT; outsider_id BIGINT;
  candidate_profile_id BIGINT; mapping_id BIGINT; job_a BIGINT; job_b BIGINT;
  worker_id BIGINT; gig_a BIGINT; gig_b BIGINT; gig_c BIGINT;
  app_a BIGINT; app_b BIGINT; rejected_app BIGINT; assignment_a BIGINT;
  available_status BIGINT; pricing_model BIGINT; inr BIGINT; open_status BIGINT;
  submitted_status BIGINT; accepted_status BIGINT; pending_handoff BIGINT;
  test_count INTEGER := 0; affected INTEGER;
BEGIN
  BEGIN
  CREATE ROLE talentra_p2_candidate LOGIN;
  CREATE ROLE talentra_p2_employer LOGIN;
  CREATE ROLE talentra_p2_recruiter LOGIN;
  CREATE ROLE talentra_p2_outsider LOGIN;
  GRANT talentra_runtime TO talentra_p2_candidate, talentra_p2_employer, talentra_p2_recruiter, talentra_p2_outsider;
  GRANT talentra_p2_candidate, talentra_p2_employer, talentra_p2_recruiter, talentra_p2_outsider TO neondb_owner;
  INSERT INTO public.user_account(full_name,email) VALUES('Phase 2 Candidate','p2-candidate@example.invalid') RETURNING id INTO candidate_id;
  INSERT INTO public.user_account(full_name,email) VALUES('Phase 2 Employer','p2-employer@example.invalid') RETURNING id INTO employer_id;
  INSERT INTO public.user_account(full_name,email) VALUES('Phase 2 Recruiter','p2-recruiter@example.invalid') RETURNING id INTO recruiter_id;
  INSERT INTO public.user_account(full_name,email) VALUES('Phase 2 Outsider','p2-outsider@example.invalid') RETURNING id INTO outsider_id;
  INSERT INTO identity.db_principal(db_role_name,user_account_id) VALUES
    ('talentra_p2_candidate',candidate_id),('talentra_p2_employer',employer_id),
    ('talentra_p2_recruiter',recruiter_id),('talentra_p2_outsider',outsider_id);
  INSERT INTO identity.user_role(user_account_id,app_role_id,valid_from)
    SELECT candidate_id,id,CURRENT_TIMESTAMP - interval '2 hours' FROM identity.app_role WHERE code='candidate';
  INSERT INTO identity.user_role(user_account_id,app_role_id,valid_from)
    SELECT employer_id,id,CURRENT_TIMESTAMP - interval '2 hours' FROM identity.app_role WHERE code='employer';
  INSERT INTO identity.user_role(user_account_id,app_role_id,valid_from)
    SELECT recruiter_id,id,CURRENT_TIMESTAMP - interval '2 hours' FROM identity.app_role WHERE code='recruiter';
  INSERT INTO identity.user_role(user_account_id,app_role_id,valid_from)
    SELECT outsider_id,id,CURRENT_TIMESTAMP - interval '2 hours' FROM identity.app_role WHERE code='recruiter';
  INSERT INTO public.candidate_profile(user_account_id) VALUES(candidate_id) RETURNING id INTO candidate_profile_id;
  INSERT INTO organisation.account_profile(account_name,account_status_id)
    SELECT 'Phase 2 Account',id FROM organisation.account_status WHERE code='active' RETURNING id INTO account_a;
  INSERT INTO organisation.account_profile(account_name,account_status_id)
    SELECT 'Phase 2 Other Account',id FROM organisation.account_status WHERE code='active' RETURNING id INTO account_b;
  INSERT INTO public.organisation(name,account_profile_id,organisation_type_id,verification_status_id)
    SELECT 'Phase 2 Org A',account_a,t.id,s.id FROM organisation.organisation_type t CROSS JOIN public.verification_status s
      WHERE t.code='employer' AND s.code='pending' RETURNING id INTO org_a;
  INSERT INTO public.organisation(name,account_profile_id,organisation_type_id,verification_status_id)
    SELECT 'Phase 2 Org B',account_b,t.id,s.id FROM organisation.organisation_type t CROSS JOIN public.verification_status s
      WHERE t.code='employer' AND s.code='pending' RETURNING id INTO org_b;
  INSERT INTO public.organisation(name,account_profile_id,parent_organisation_id,organisation_type_id,verification_status_id)
    SELECT 'Phase 2 Child',account_a,org_a,t.id,s.id FROM organisation.organisation_type t CROSS JOIN public.verification_status s
      WHERE t.code='client' AND s.code='pending' RETURNING id INTO org_child;
  INSERT INTO organisation.organisation_member(organisation_id,user_account_id,valid_from)
    VALUES(org_a,employer_id,CURRENT_TIMESTAMP - interval '1 hour');
  INSERT INTO organisation.account_administrator(account_profile_id,user_account_id,valid_from)
    VALUES(account_a,employer_id,CURRENT_TIMESTAMP - interval '1 hour');
  INSERT INTO organisation.organisation_recruiter(organisation_id,recruiter_user_account_id,valid_from)
    VALUES(org_a,recruiter_id,CURRENT_TIMESTAMP - interval '1 hour') RETURNING id INTO mapping_id;
  INSERT INTO public.job_requirement(title,organisation_id,job_status_id,work_type_id,employment_type_id)
    SELECT 'Phase 2 Job A',org_a,s.id,w.id,e.id FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
      WHERE s.code='draft' AND w.code='onsite' AND e.code='permanent' RETURNING id INTO job_a;
  INSERT INTO public.job_requirement(title,organisation_id,job_status_id,work_type_id,employment_type_id)
    SELECT 'Phase 2 Job B',org_b,s.id,w.id,e.id FROM public.job_status s CROSS JOIN public.work_type w CROSS JOIN public.employment_type e
      WHERE s.code='draft' AND w.code='onsite' AND e.code='permanent' RETURNING id INTO job_b;
  INSERT INTO organisation.job_recruiter_assignment(job_requirement_id,organisation_id,recruiter_user_account_id,organisation_recruiter_id,valid_from)
    VALUES(job_a,org_a,recruiter_id,mapping_id,CURRENT_TIMESTAMP - interval '20 minutes');
  INSERT INTO public.application(candidate_profile_id,job_requirement_id,application_status_id)
    SELECT candidate_profile_id,job_a,id FROM public.application_status WHERE code='applied';
  INSERT INTO identity.user_block(candidate_profile_id,blocked_user_account_id) VALUES(candidate_profile_id,recruiter_id);
  SELECT id INTO inr FROM public.currency WHERE code='INR';
  SELECT id INTO available_status FROM gig.availability_status WHERE code='available';
  SELECT id INTO pricing_model FROM gig.pricing_model WHERE code='fixed';
  SELECT id INTO open_status FROM gig.request_status WHERE code='open';
  SELECT id INTO submitted_status FROM gig.application_status WHERE code='submitted';
  SELECT id INTO accepted_status FROM gig.application_status WHERE code='accepted';
  SELECT id INTO pending_handoff FROM gig.assignment_status WHERE code='pending_handoff';
  INSERT INTO gig.gig_worker_profile(user_account_id,public_name) VALUES(candidate_id,'Phase 2 Worker') RETURNING id INTO worker_id;
  INSERT INTO gig.gig_availability(gig_worker_profile_id,availability_status_id,available_from,available_to)
    VALUES(worker_id,available_status,CURRENT_TIMESTAMP + interval '1 day',CURRENT_TIMESTAMP + interval '4 days');
  INSERT INTO gig.gig_request(requester_organisation_id,requester_user_account_id,title,description,start_at,end_at,price_amount,pricing_model_id,currency_id,request_status_id)
    VALUES(org_a,employer_id,'Gig A','Short gig',CURRENT_TIMESTAMP + interval '1 day 1 hour',CURRENT_TIMESTAMP + interval '1 day 3 hours',100,pricing_model,inr,open_status) RETURNING id INTO gig_a;
  INSERT INTO gig.gig_request(requester_organisation_id,requester_user_account_id,title,description,start_at,end_at,price_amount,pricing_model_id,currency_id,request_status_id)
    VALUES(org_a,employer_id,'Gig B','Overlaps A',CURRENT_TIMESTAMP + interval '1 day 2 hours',CURRENT_TIMESTAMP + interval '1 day 4 hours',100,pricing_model,inr,open_status) RETURNING id INTO gig_b;
  INSERT INTO gig.gig_request(requester_organisation_id,requester_user_account_id,title,description,start_at,end_at,price_amount,pricing_model_id,currency_id,request_status_id)
    VALUES(org_a,employer_id,'Gig C','Rejected app',CURRENT_TIMESTAMP + interval '3 days',CURRENT_TIMESTAMP + interval '3 days 2 hours',100,pricing_model,inr,open_status) RETURNING id INTO gig_c;
  INSERT INTO gig.gig_application(gig_request_id,gig_worker_profile_id,application_status_id,decided_at,decision_by_user_account_id)
    VALUES(gig_a,worker_id,accepted_status,CURRENT_TIMESTAMP,employer_id) RETURNING id INTO app_a;
  INSERT INTO gig.gig_application(gig_request_id,gig_worker_profile_id,application_status_id,decided_at,decision_by_user_account_id)
    VALUES(gig_b,worker_id,accepted_status,CURRENT_TIMESTAMP,employer_id) RETURNING id INTO app_b;
  INSERT INTO gig.gig_application(gig_request_id,gig_worker_profile_id,application_status_id,decided_at,decision_by_user_account_id)
    SELECT gig_c,worker_id,id,CURRENT_TIMESTAMP,employer_id FROM gig.application_status WHERE code='rejected' RETURNING id INTO rejected_app;
  INSERT INTO gig.gig_assignment(gig_application_id,gig_request_id,gig_worker_profile_id,assignment_status_id,external_system_code,handoff_reference,assignment_start_at,assignment_end_at)
    VALUES(app_a,gig_a,worker_id,pending_handoff,'external','assignment-a',CURRENT_TIMESTAMP + interval '1 day 1 hour',CURRENT_TIMESTAMP + interval '1 day 3 hours') RETURNING id INTO assignment_a;
  INSERT INTO gig.fulfilment_event(gig_assignment_id,external_system_code,external_event_id,event_kind,observed_at)
    VALUES(assignment_a,'external','event-1','handoff',CURRENT_TIMESTAMP);
  INSERT INTO gig.gig_worker_list_entry(requester_organisation_id,gig_worker_profile_id,worker_list_type_id)
    SELECT org_a,worker_id,id FROM gig.worker_list_type WHERE code='blacklisted';

  BEGIN
    INSERT INTO organisation.organisation_recruiter(organisation_id,recruiter_user_account_id,valid_from,valid_to) VALUES(org_b,recruiter_id,CURRENT_TIMESTAMP - interval '30 minutes',NULL);
    RAISE EXCEPTION 'Test failed: overlapping recruiter-company mapping was accepted';
  EXCEPTION WHEN SQLSTATE '23P01' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO organisation.job_recruiter_assignment(job_requirement_id,organisation_id,recruiter_user_account_id,organisation_recruiter_id,valid_from) VALUES(job_a,org_a,recruiter_id,mapping_id,CURRENT_TIMESTAMP - interval '3 hours');
    RAISE EXCEPTION 'Test failed: recruiter assignment beyond mapping was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO organisation.job_recruiter_assignment(job_requirement_id,organisation_id,recruiter_user_account_id,organisation_recruiter_id,valid_from) VALUES(job_b,org_a,recruiter_id,mapping_id,CURRENT_TIMESTAMP - interval '20 minutes');
    RAISE EXCEPTION 'Test failed: recruiter assignment to another company job was accepted';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE organisation.organisation_recruiter SET valid_to=CURRENT_TIMESTAMP - interval '10 minutes' WHERE id=mapping_id;
    RAISE EXCEPTION 'Test failed: mapping cannot stop before its assignment was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO organisation.account_administrator(account_profile_id,user_account_id,valid_from) VALUES(account_a,employer_id,CURRENT_TIMESTAMP - interval '30 minutes');
    RAISE EXCEPTION 'Test failed: account administrator overlapping period was accepted';
  EXCEPTION WHEN SQLSTATE '23P01' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE public.organisation SET parent_organisation_id = org_child WHERE id = org_a;
    RAISE EXCEPTION 'Test failed: organisation hierarchy cycle was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO identity.user_block(candidate_profile_id,blocked_user_account_id) VALUES(candidate_profile_id,candidate_id);
    RAISE EXCEPTION 'Test failed: candidate self-block was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO identity.user_block(candidate_profile_id,blocked_user_account_id) VALUES(candidate_profile_id,recruiter_id);
    RAISE EXCEPTION 'Test failed: duplicate candidate block was accepted';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO identity.credential(user_account_id,credential_type_id,hash_algorithm_id,secret_hash) SELECT candidate_id, ct.id, ha.id, 'plain-secret' FROM identity.credential_type ct CROSS JOIN identity.hash_algorithm ha WHERE ct.code='api_key' AND ha.code='argon2id';
    RAISE EXCEPTION 'Test failed: plaintext credential shape was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_availability(gig_worker_profile_id,availability_status_id,available_from,available_to) VALUES(worker_id,available_status,CURRENT_TIMESTAMP + interval '1 day 2 hours',CURRENT_TIMESTAMP + interval '2 days');
    RAISE EXCEPTION 'Test failed: overlapping worker availability was accepted';
  EXCEPTION WHEN SQLSTATE '23P01' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_request(requester_organisation_id,requester_user_account_id,title,description,start_at,end_at,price_amount,pricing_model_id,currency_id,request_status_id) VALUES(org_a,employer_id,'Bad window','Invalid',CURRENT_TIMESTAMP + interval '3 days',CURRENT_TIMESTAMP + interval '2 days',100,pricing_model,inr,open_status);
    RAISE EXCEPTION 'Test failed: gig request invalid window was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE gig.gig_request SET start_at = start_at + interval '1 hour' WHERE id = gig_a;
    RAISE EXCEPTION 'Test failed: gig request window cannot change after application was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_application(gig_request_id,gig_worker_profile_id,application_status_id) VALUES(gig_b,worker_id,submitted_status);
    RAISE EXCEPTION 'Test failed: blacklisted worker cannot apply was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_assignment(gig_application_id,gig_request_id,gig_worker_profile_id,assignment_status_id,external_system_code,handoff_reference,assignment_start_at,assignment_end_at) VALUES(rejected_app,gig_c,worker_id,pending_handoff,'external','rejected',CURRENT_TIMESTAMP + interval '3 days',CURRENT_TIMESTAMP + interval '3 days 2 hours');
    RAISE EXCEPTION 'Test failed: rejected gig cannot be assigned was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_assignment(gig_application_id,gig_request_id,gig_worker_profile_id,assignment_status_id,external_system_code,handoff_reference,assignment_start_at,assignment_end_at) VALUES(app_b,gig_b,worker_id,pending_handoff,'external','assignment-b',CURRENT_TIMESTAMP + interval '1 day 2 hours',CURRENT_TIMESTAMP + interval '1 day 4 hours');
    RAISE EXCEPTION 'Test failed: gig assignment overlapping worker window was accepted';
  EXCEPTION WHEN SQLSTATE '23P01' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_assignment(gig_application_id,gig_request_id,gig_worker_profile_id,assignment_status_id,external_system_code,handoff_reference,assignment_start_at,assignment_end_at) VALUES(app_b,gig_b,worker_id,pending_handoff,'external','assignment-b',CURRENT_TIMESTAMP + interval '1 day 3 hours',CURRENT_TIMESTAMP + interval '1 day 4 hours');
    RAISE EXCEPTION 'Test failed: assignment window must match gig request was accepted';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.gig_rating(gig_assignment_id,requester_user_account_id,rating_value) VALUES(assignment_a,employer_id,5);
    RAISE EXCEPTION 'Test failed: rating before completed fulfilment was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE gig.gig_application SET application_status_id=(SELECT id FROM gig.application_status WHERE code='rejected'), decided_at=CURRENT_TIMESTAMP, decision_by_user_account_id=employer_id WHERE id=app_a;
    RAISE EXCEPTION 'Test failed: assigned application cannot become rejected was accepted';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    INSERT INTO gig.fulfilment_event(gig_assignment_id,external_system_code,external_event_id,event_kind,observed_at) VALUES(assignment_a,'external','event-1','status',CURRENT_TIMESTAMP);
    RAISE EXCEPTION 'Test failed: duplicate external event was accepted';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE gig.fulfilment_event SET event_kind='changed' WHERE external_event_id='event-1';
    RAISE EXCEPTION 'Test failed: fulfilment event update was accepted';
  EXCEPTION WHEN SQLSTATE '55000' THEN
    test_count := test_count + 1;
  END;

  BEGIN
    UPDATE identity.audit_event SET action_code='changed' WHERE entity_table='gig_assignment';
    RAISE EXCEPTION 'Test failed: audit event update was accepted';
  EXCEPTION WHEN SQLSTATE '55000' THEN
    test_count := test_count + 1;
  END;

  IF (SELECT count(*) FROM identity.audit_event WHERE entity_table='gig_assignment') <> 1 THEN
    RAISE EXCEPTION 'Gig assignment audit missing';
  END IF;
  test_count := test_count + 1;
  IF (SELECT count(*) FROM identity.audit_event WHERE entity_table='job_requirement') < 2 THEN
    RAISE EXCEPTION 'Job audit missing';
  END IF;
  test_count := test_count + 1;
  SET ROLE talentra_p2_candidate;
  IF identity.actor_user_id() <> candidate_id THEN RAISE EXCEPTION 'Candidate principal mapping failed'; END IF;
  IF (SELECT count(*) FROM public.candidate_profile WHERE id=candidate_profile_id) <> 1 THEN
    RAISE EXCEPTION 'Candidate cannot read own profile'; END IF;
  test_count := test_count + 1;
  RESET ROLE;
  SET ROLE talentra_p2_recruiter;
  IF identity.actor_user_id() <> recruiter_id THEN RAISE EXCEPTION 'Recruiter principal mapping failed'; END IF;
  IF (SELECT count(*) FROM public.job_requirement WHERE id=job_a) <> 1 OR
     (SELECT count(*) FROM public.job_requirement WHERE id=job_b) <> 0 THEN
    RAISE EXCEPTION 'Recruiter job scoping failed'; END IF;
  test_count := test_count + 1;
  IF (SELECT count(*) FROM public.candidate_profile WHERE id=candidate_profile_id) <> 0 THEN
    RAISE EXCEPTION 'Candidate block did not hide profile'; END IF;
  test_count := test_count + 1;
  UPDATE public.job_requirement SET title='Updated by assigned recruiter' WHERE id=job_a;
  GET DIAGNOSTICS affected = ROW_COUNT;
  IF affected <> 1 THEN RAISE EXCEPTION 'Assigned recruiter could not update job'; END IF;
  test_count := test_count + 1;
  UPDATE public.job_requirement SET title='Unauthorized' WHERE id=job_b;
  GET DIAGNOSTICS affected = ROW_COUNT;
  IF affected <> 0 THEN RAISE EXCEPTION 'Recruiter updated another company job'; END IF;
  test_count := test_count + 1;
  BEGIN
    INSERT INTO public.candidate_profile(user_account_id) VALUES(outsider_id);
    RAISE EXCEPTION 'Recruiter registered a candidate';
  EXCEPTION WHEN SQLSTATE '42501' THEN test_count := test_count + 1;
  END;
  BEGIN
    INSERT INTO identity.user_role(user_account_id,app_role_id)
      SELECT recruiter_id,id FROM identity.app_role WHERE code='super_admin';
    RAISE EXCEPTION 'Recruiter escalated role';
  EXCEPTION WHEN SQLSTATE '42501' THEN test_count := test_count + 1;
  END;
  BEGIN
    PERFORM identity.role_has_permission(employer_id, 'admin.manage_roles');
    RAISE EXCEPTION 'Recruiter called internal role helper';
  EXCEPTION WHEN SQLSTATE '42501' THEN test_count := test_count + 1;
  END;
  RESET ROLE;
  SET ROLE talentra_p2_outsider;
  IF (SELECT count(*) FROM public.job_requirement WHERE id=job_a) <> 0 THEN
    RAISE EXCEPTION 'Unassigned recruiter saw job'; END IF;
  test_count := test_count + 1;
  RESET ROLE;
  SET ROLE talentra_p2_employer;
  IF (SELECT count(*) FROM public.job_requirement WHERE id=job_a) <> 1 THEN
    RAISE EXCEPTION 'Employer cannot read own job'; END IF;
  IF (SELECT count(*) FROM public.job_requirement WHERE id=job_b) <> 0 THEN
    RAISE EXCEPTION 'Employer saw unrelated organisation job'; END IF;
  test_count := test_count + 1;
  RESET ROLE;
  IF (SELECT count(*) FROM identity.audit_event WHERE entity_table='job_requirement' AND actor_user_account_id=recruiter_id AND action_code='UPDATE') <> 1 THEN
    RAISE EXCEPTION 'Recruiter job update audit missing'; END IF;
  test_count := test_count + 1;
  UPDATE gig.gig_assignment SET assignment_status_id = (SELECT id FROM gig.assignment_status WHERE code='completed'), reconciled_at=CURRENT_TIMESTAMP WHERE id=assignment_a;
  INSERT INTO gig.gig_rating(gig_assignment_id,requester_user_account_id,rating_value) VALUES(assignment_a,employer_id,5);
  test_count := test_count + 1;
  BEGIN
    UPDATE gig.gig_assignment SET assignment_status_id=(SELECT id FROM gig.assignment_status WHERE code='pending_handoff') WHERE id=assignment_a;
    RAISE EXCEPTION 'Rated assignment became pending';
  EXCEPTION WHEN SQLSTATE '23514' THEN test_count := test_count + 1;
  END;
  IF test_count <> 36 THEN RAISE EXCEPTION 'Unexpected check count: %', test_count; END IF;
  RAISE EXCEPTION 'Phase 2 validation passed' USING ERRCODE='Z0002';
  EXCEPTION WHEN SQLSTATE 'Z0002' THEN RAISE NOTICE '36 Phase 2 checks passed; fixture rows and roles rolled back';
  END;
END $phase2_tests$;
