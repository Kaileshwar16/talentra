"""Phase 2 role, row-access, audit, and cross-entity integrity SQL."""
import csv
from pathlib import Path

statements = []

def add(sql):
    statements.append(sql.strip().rstrip(';'))


add('''CREATE FUNCTION identity.actor_user_id() RETURNS BIGINT
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT p.user_account_id
  FROM identity.db_principal p
  JOIN public.user_account u ON u.id = p.user_account_id
  WHERE p.db_role_name = COALESCE(NULLIF(current_setting('role', true), 'none'), session_user)::name
    AND p.deleted_at IS NULL AND u.deleted_at IS NULL
  LIMIT 1
$$''')
add('''CREATE FUNCTION identity.role_has_permission(p_user_id BIGINT, p_code TEXT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_account u
    JOIN identity.account_status s ON s.id = u.account_status_id AND s.code = 'active'
    JOIN identity.user_role ur ON ur.user_account_id = u.id
    JOIN identity.app_role r ON r.id = ur.app_role_id
    JOIN identity.role_permission rp ON rp.app_role_id = r.id
    JOIN identity.permission p ON p.id = rp.permission_id
    WHERE u.id = p_user_id AND u.deleted_at IS NULL AND r.active
      AND ur.deleted_at IS NULL AND ur.valid_from <= CURRENT_TIMESTAMP
      AND (ur.valid_to IS NULL OR ur.valid_to > CURRENT_TIMESTAMP)
      AND p.code = p_code
  )
$$''')
add('''CREATE FUNCTION identity.has_permission(p_code TEXT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
  SELECT COALESCE(identity.role_has_permission(identity.actor_user_id(), p_code), FALSE)
$$''')
add('''CREATE FUNCTION identity.is_organisation_member(p_user_id BIGINT, p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM organisation.organisation_member m
    WHERE m.user_account_id = p_user_id AND m.organisation_id = p_organisation_id
      AND m.deleted_at IS NULL AND m.valid_from <= CURRENT_TIMESTAMP
      AND (m.valid_to IS NULL OR m.valid_to > CURRENT_TIMESTAMP)
  ) OR EXISTS (
    SELECT 1 FROM organisation.account_administrator a
    JOIN public.organisation o ON o.account_profile_id = a.account_profile_id
    WHERE a.user_account_id = p_user_id AND o.id = p_organisation_id
      AND a.deleted_at IS NULL AND a.valid_from <= CURRENT_TIMESTAMP
      AND (a.valid_to IS NULL OR a.valid_to > CURRENT_TIMESTAMP)
  )
$$''')
add('''CREATE FUNCTION identity.is_assigned_recruiter(p_user_id BIGINT, p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM organisation.job_recruiter_assignment a
    JOIN organisation.organisation_recruiter m ON m.id = a.organisation_recruiter_id
    JOIN public.job_requirement j ON j.id = a.job_requirement_id AND j.organisation_id = a.organisation_id
    WHERE a.job_requirement_id = p_job_id AND a.recruiter_user_account_id = p_user_id
      AND m.recruiter_user_account_id = p_user_id AND m.organisation_id = j.organisation_id
      AND a.deleted_at IS NULL AND m.deleted_at IS NULL
      AND a.valid_from <= CURRENT_TIMESTAMP AND (a.valid_to IS NULL OR a.valid_to > CURRENT_TIMESTAMP)
      AND m.valid_from <= CURRENT_TIMESTAMP AND (m.valid_to IS NULL OR m.valid_to > CURRENT_TIMESTAMP)
  )
$$''')
add('''CREATE FUNCTION identity.can_manage_organisation(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN identity.role_has_permission(actor, 'organisation.manage_own')
    AND identity.is_organisation_member(actor, p_organisation_id);
END $$''')
add('''CREATE FUNCTION identity.can_read_organisation(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN (identity.role_has_permission(actor, 'organisation.read_own')
      AND (identity.is_organisation_member(actor, p_organisation_id)
        OR EXISTS (SELECT 1 FROM organisation.organisation_recruiter r
          WHERE r.organisation_id = p_organisation_id AND r.recruiter_user_account_id = actor
            AND r.deleted_at IS NULL AND r.valid_from <= CURRENT_TIMESTAMP
            AND (r.valid_to IS NULL OR r.valid_to > CURRENT_TIMESTAMP))));
END $$''')
add('''CREATE FUNCTION identity.can_read_job_as_staff(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); org_id BIGINT; is_open BOOLEAN;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT organisation_id, open_to_consultants INTO org_id, is_open
    FROM public.job_requirement WHERE id = p_job_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'job.read_org')
    AND identity.is_organisation_member(actor, org_id) THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'job.read_assigned')
    AND identity.is_assigned_recruiter(actor, p_job_id) THEN RETURN TRUE; END IF;
  RETURN is_open AND identity.role_has_permission(actor, 'job.read_consultant_open');
END $$''')
add('''CREATE FUNCTION identity.can_read_job(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE actor BIGINT := identity.actor_user_id();
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  IF identity.can_read_job_as_staff(p_job_id) THEN RETURN TRUE; END IF;
  RETURN identity.role_has_permission(actor, 'job.read_published') AND EXISTS (
    SELECT 1 FROM public.job_requirement j JOIN public.job_status s ON s.id = j.job_status_id
    WHERE j.id = p_job_id AND j.deleted_at IS NULL AND s.code = 'published'
      AND (j.deadline IS NULL OR j.deadline > CURRENT_TIMESTAMP));
END $$''')
add('''CREATE FUNCTION identity.can_manage_job(p_job_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); org_id BIGINT;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT organisation_id INTO org_id FROM public.job_requirement WHERE id = p_job_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  RETURN (identity.role_has_permission(actor, 'job.write_org') AND identity.is_organisation_member(actor, org_id))
    OR (identity.role_has_permission(actor, 'job.write_assigned') AND identity.is_assigned_recruiter(actor, p_job_id));
END $$''')
add('''CREATE FUNCTION identity.can_create_job(p_organisation_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
  SELECT identity.has_permission('admin.manage_roles') OR
    (identity.has_permission('job.write_org') AND identity.is_organisation_member(identity.actor_user_id(), p_organisation_id))
$$''')
add('''CREATE FUNCTION identity.can_view_candidate(p_candidate_id BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, organisation, public AS $$
DECLARE actor BIGINT := identity.actor_user_id(); owner_id BIGINT;
BEGIN
  IF actor IS NULL THEN RETURN FALSE; END IF;
  SELECT user_account_id INTO owner_id FROM public.candidate_profile
    WHERE id = p_candidate_id AND deleted_at IS NULL;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF actor = owner_id AND identity.role_has_permission(actor, 'profile.read_own') THEN RETURN TRUE; END IF;
  IF identity.role_has_permission(actor, 'admin.manage_roles') THEN RETURN TRUE; END IF;
  IF NOT identity.role_has_permission(actor, 'profile.read_applicant') THEN RETURN FALSE; END IF;
  IF EXISTS (SELECT 1 FROM identity.user_block b WHERE b.candidate_profile_id = p_candidate_id
    AND b.deleted_at IS NULL AND (b.blocked_user_account_id = actor OR
       EXISTS (SELECT 1 FROM public.organisation o WHERE o.id = b.blocked_organisation_id
         AND (identity.is_organisation_member(actor, o.id) OR
              EXISTS (SELECT 1 FROM organisation.organisation_recruiter r
                WHERE r.organisation_id = o.id AND r.recruiter_user_account_id = actor
                  AND r.deleted_at IS NULL AND r.valid_from <= CURRENT_TIMESTAMP
                  AND (r.valid_to IS NULL OR r.valid_to > CURRENT_TIMESTAMP))))))
  THEN RETURN FALSE; END IF;
  RETURN EXISTS (SELECT 1 FROM public.application a
    WHERE a.candidate_profile_id = p_candidate_id AND a.deleted_at IS NULL
      AND identity.can_read_job_as_staff(a.job_requirement_id))
    OR EXISTS (SELECT 1 FROM public.job_shortlist s
      WHERE s.candidate_profile_id = p_candidate_id AND s.deleted_at IS NULL
        AND identity.can_read_job_as_staff(s.job_requirement_id));
END $$''')

add('''CREATE FUNCTION identity.audit_sensitive_change() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE row_id BIGINT;
BEGIN
  row_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END;
  INSERT INTO identity.audit_event(actor_user_account_id, action_code, entity_schema, entity_table,
      entity_id, request_id, details)
  VALUES (identity.actor_user_id(), TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME, row_id,
      NULLIF(current_setting('talentra.request_id', true), '')::UUID,
      jsonb_build_object('transaction_id', txid_current()));
  RETURN COALESCE(NEW, OLD);
END $$''')
add('''CREATE FUNCTION identity.validate_db_principal() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = NEW.db_role_name AND rolcanlogin) THEN
    RAISE EXCEPTION 'Principal must name an existing login role' USING ERRCODE = '23514';
  END IF;
  IF NOT pg_has_role(NEW.db_role_name, 'talentra_runtime', 'member') THEN
    RAISE EXCEPTION 'Principal role must inherit talentra_runtime' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_db_principal BEFORE INSERT OR UPDATE ON identity.db_principal FOR EACH ROW EXECUTE FUNCTION identity.validate_db_principal()')
add('''CREATE FUNCTION identity.validate_credential() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity AS $$
DECLARE algorithm TEXT;
BEGIN
  SELECT code INTO algorithm FROM identity.hash_algorithm WHERE id = NEW.hash_algorithm_id;
  IF (algorithm = 'external') <> (NEW.external_reference IS NOT NULL) THEN
    RAISE EXCEPTION 'External credentials require an external reference; local credentials require a hash' USING ERRCODE = '23514';
  END IF;
  IF algorithm = 'argon2id' AND NEW.secret_hash NOT LIKE '$argon2id$%' THEN
    RAISE EXCEPTION 'Expected an Argon2id hash' USING ERRCODE = '23514';
  END IF;
  IF algorithm = 'bcrypt' AND NEW.secret_hash !~ '^[$]2[aby][$]' THEN
    RAISE EXCEPTION 'Expected a bcrypt hash' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_credential BEFORE INSERT OR UPDATE ON identity.credential FOR EACH ROW EXECUTE FUNCTION identity.validate_credential()')
add('''CREATE FUNCTION organisation.initialise_anchor() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, public AS $$
BEGIN
  IF NEW.account_profile_id IS NULL THEN
    INSERT INTO organisation.account_profile(account_name, account_status_id, created_by, updated_by)
    SELECT NEW.name, s.id, NEW.created_by, NEW.updated_by
      FROM organisation.account_status s WHERE s.code = 'active'
      RETURNING id INTO NEW.account_profile_id;
  END IF;
  IF NEW.organisation_type_id IS NULL THEN
    SELECT id INTO NEW.organisation_type_id FROM organisation.organisation_type WHERE code = 'employer';
  END IF;
  IF NEW.verification_status_id IS NULL THEN
    SELECT id INTO NEW.verification_status_id FROM public.verification_status WHERE code = 'pending';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER initialise_anchor BEFORE INSERT ON public.organisation FOR EACH ROW EXECUTE FUNCTION organisation.initialise_anchor()')
add('''CREATE FUNCTION identity.validate_block() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, identity, public AS $$
DECLARE owner_id BIGINT;
BEGIN
  SELECT user_account_id INTO owner_id FROM public.candidate_profile WHERE id = NEW.candidate_profile_id;
  IF NEW.blocked_user_account_id = owner_id THEN
    RAISE EXCEPTION 'A candidate cannot block their own account' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_block BEFORE INSERT OR UPDATE ON identity.user_block FOR EACH ROW EXECUTE FUNCTION identity.validate_block()')
add('''CREATE FUNCTION organisation.prevent_hierarchy_cycle() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, public AS $$
BEGIN
  PERFORM 1 FROM organisation.account_profile WHERE id = NEW.account_profile_id FOR UPDATE;
  IF NEW.parent_organisation_id IS NOT NULL THEN
    IF EXISTS (WITH RECURSIVE ancestors(id) AS (
      SELECT NEW.parent_organisation_id
      UNION
      SELECT o.parent_organisation_id FROM public.organisation o
        JOIN ancestors a ON o.id = a.id WHERE o.parent_organisation_id IS NOT NULL
    ) SELECT 1 FROM ancestors WHERE id = NEW.id) THEN
      RAISE EXCEPTION 'Organisation hierarchy cycle' USING ERRCODE = '23514';
    END IF;
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER prevent_hierarchy_cycle BEFORE INSERT OR UPDATE OF parent_organisation_id, account_profile_id ON public.organisation FOR EACH ROW EXECUTE FUNCTION organisation.prevent_hierarchy_cycle()')
add('''CREATE FUNCTION organisation.validate_recruiter_assignment() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation, identity, public AS $$
DECLARE mapping organisation.organisation_recruiter%ROWTYPE;
BEGIN
  SELECT * INTO mapping FROM organisation.organisation_recruiter WHERE id = NEW.organisation_recruiter_id FOR UPDATE;
  IF mapping.deleted_at IS NOT NULL OR mapping.organisation_id <> NEW.organisation_id
     OR mapping.recruiter_user_account_id <> NEW.recruiter_user_account_id
     OR NOT (tstzrange(mapping.valid_from, mapping.valid_to, '[)') @>
             tstzrange(NEW.valid_from, NEW.valid_to, '[)')) THEN
    RAISE EXCEPTION 'Assignment must be within a valid recruiter-company mapping' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM identity.user_role ur JOIN identity.app_role r ON r.id = ur.app_role_id
    WHERE ur.user_account_id = NEW.recruiter_user_account_id AND r.code = 'recruiter'
      AND ur.deleted_at IS NULL AND ur.valid_from <= NEW.valid_from
      AND (ur.valid_to IS NULL OR (NEW.valid_to IS NOT NULL AND ur.valid_to >= NEW.valid_to))) THEN
    RAISE EXCEPTION 'Recruiter role must cover assignment' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_recruiter_assignment BEFORE INSERT OR UPDATE ON organisation.job_recruiter_assignment FOR EACH ROW EXECUTE FUNCTION organisation.validate_recruiter_assignment()')
add('''CREATE FUNCTION organisation.validate_mapping_change() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, organisation AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM organisation.job_recruiter_assignment a
    WHERE a.organisation_recruiter_id = NEW.id AND a.deleted_at IS NULL
      AND NOT (tstzrange(NEW.valid_from, NEW.valid_to, '[)') @>
               tstzrange(a.valid_from, a.valid_to, '[)'))) THEN
    RAISE EXCEPTION 'Recruiter mapping must cover its job assignments' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_mapping_change BEFORE UPDATE OF valid_from, valid_to ON organisation.organisation_recruiter FOR EACH ROW EXECUTE FUNCTION organisation.validate_mapping_change()')

add('''CREATE FUNCTION gig.validate_request_window() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig AS $$
BEGIN
  IF (NEW.start_at, NEW.end_at) IS DISTINCT FROM (OLD.start_at, OLD.end_at)
    AND EXISTS (SELECT 1 FROM gig.gig_application WHERE gig_request_id = OLD.id) THEN
      RAISE EXCEPTION 'Cannot change a gig window after applications exist' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_request_window BEFORE UPDATE OF start_at, end_at ON gig.gig_request FOR EACH ROW EXECUTE FUNCTION gig.validate_request_window()')
add('''CREATE FUNCTION gig.validate_application() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig, identity, public AS $$
DECLARE status_code TEXT; org_id BIGINT; request_status TEXT;
BEGIN
  SELECT code INTO status_code FROM gig.application_status WHERE id = NEW.application_status_id;
  SELECT r.requester_organisation_id, s.code INTO org_id, request_status
    FROM gig.gig_request r JOIN gig.request_status s ON s.id = r.request_status_id
    WHERE r.id = NEW.gig_request_id FOR UPDATE OF r;
  IF TG_OP = 'UPDATE' AND (NEW.gig_request_id <> OLD.gig_request_id OR NEW.gig_worker_profile_id <> OLD.gig_worker_profile_id) THEN
    RAISE EXCEPTION 'Gig application worker and request are immutable' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' AND status_code <> 'accepted'
    AND EXISTS (SELECT 1 FROM gig.gig_assignment WHERE gig_application_id = OLD.id) THEN
    RAISE EXCEPTION 'An assigned application must remain accepted' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'INSERT' AND request_status <> 'open' THEN
    RAISE EXCEPTION 'Gig request is not open' USING ERRCODE = '23514';
  END IF;
  IF EXISTS (SELECT 1 FROM gig.gig_worker_list_entry e JOIN gig.worker_list_type t ON t.id = e.worker_list_type_id
    WHERE e.requester_organisation_id = org_id AND e.gig_worker_profile_id = NEW.gig_worker_profile_id
      AND t.code = 'blacklisted' AND e.deleted_at IS NULL) THEN
    RAISE EXCEPTION 'Worker is blacklisted by requester' USING ERRCODE = '23514';
  END IF;
  IF status_code IN ('accepted', 'rejected') THEN
    IF NEW.decided_at IS NULL OR NEW.decision_by_user_account_id IS NULL
      OR NOT identity.is_organisation_member(NEW.decision_by_user_account_id, org_id) THEN
      RAISE EXCEPTION 'Requester decision requires an authorised organisation member' USING ERRCODE = '23514';
    END IF;
  ELSIF NEW.decided_at IS NOT NULL OR NEW.decision_by_user_account_id IS NOT NULL THEN
    RAISE EXCEPTION 'Undecided application cannot carry a requester decision' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_application BEFORE INSERT OR UPDATE ON gig.gig_application FOR EACH ROW EXECUTE FUNCTION gig.validate_application()')
add('''CREATE FUNCTION gig.validate_assignment() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig AS $$
DECLARE app_status TEXT; app_worker BIGINT; app_request BIGINT;
BEGIN
  SELECT s.code, a.gig_worker_profile_id, a.gig_request_id
    INTO app_status, app_worker, app_request
    FROM gig.gig_application a JOIN gig.application_status s ON s.id = a.application_status_id
    WHERE a.id = NEW.gig_application_id FOR UPDATE OF a;
  IF app_status <> 'accepted' OR app_worker <> NEW.gig_worker_profile_id OR app_request <> NEW.gig_request_id THEN
    RAISE EXCEPTION 'Assignment requires an accepted application for the same worker and request' USING ERRCODE = '23514';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM gig.gig_availability v JOIN gig.availability_status s ON s.id = v.availability_status_id
    WHERE v.gig_worker_profile_id = NEW.gig_worker_profile_id AND v.deleted_at IS NULL
      AND s.code = 'available' AND v.available_from <= NEW.assignment_start_at
      AND v.available_to >= NEW.assignment_end_at) THEN
    RAISE EXCEPTION 'Worker availability must cover the full gig window' USING ERRCODE = '23514';
  END IF;
  IF TG_OP = 'UPDATE' AND EXISTS (SELECT 1 FROM gig.gig_rating WHERE gig_assignment_id = OLD.id)
    AND (SELECT code FROM gig.assignment_status WHERE id = NEW.assignment_status_id) <> 'completed' THEN
    RAISE EXCEPTION 'A rated assignment must remain completed' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_assignment BEFORE INSERT OR UPDATE ON gig.gig_assignment FOR EACH ROW EXECUTE FUNCTION gig.validate_assignment()')
add('''CREATE FUNCTION gig.validate_rating() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, gig, identity AS $$
DECLARE org_id BIGINT; status_code TEXT;
BEGIN
  SELECT r.requester_organisation_id, s.code INTO org_id, status_code
    FROM gig.gig_assignment a JOIN gig.assignment_status s ON s.id = a.assignment_status_id
    JOIN gig.gig_request r ON r.id = a.gig_request_id
    WHERE a.id = NEW.gig_assignment_id;
  IF status_code <> 'completed' OR NOT identity.is_organisation_member(NEW.requester_user_account_id, org_id) THEN
    RAISE EXCEPTION 'Only the requester can rate a completed gig' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$''')
add('CREATE TRIGGER validate_rating BEFORE INSERT OR UPDATE ON gig.gig_rating FOR EACH ROW EXECUTE FUNCTION gig.validate_rating()')

# Every new business table receives the Phase 1 updated_at trigger. Append-only
# records reject any mutation, including TRUNCATE.
append_only = {'identity.audit_event', 'identity.system_error_log', 'identity.user_consent',
               'gig.fulfilment_event'}
def add_entity_triggers(table_names):
    for name in table_names:
        if name in append_only:
            add(f'CREATE TRIGGER reject_mutation BEFORE UPDATE OR DELETE ON {name} FOR EACH ROW EXECUTE FUNCTION public.talentra_reject_mutation()')
            add(f'CREATE TRIGGER reject_truncate BEFORE TRUNCATE ON {name} FOR EACH STATEMENT EXECUTE FUNCTION public.talentra_reject_mutation()')
        else:
            add(f'CREATE TRIGGER set_updated_at BEFORE UPDATE ON {name} FOR EACH ROW EXECUTE FUNCTION public.talentra_set_updated_at()')

# Audit records carry identifiers, action, transaction and optional request ID;
# no password, token, tax ID, or raw PII is copied into the log.
audited = [
    'public.user_account', 'public.candidate_profile', 'public.job_requirement', 'public.organisation',
    'identity.credential', 'identity.user_role', 'identity.db_principal', 'identity.user_block',
    'identity.user_consent', 'identity.session_record',
    'organisation.account_profile', 'organisation.organisation_identifier', 'organisation.verification_record',
    'organisation.organisation_recruiter', 'organisation.account_administrator',
    'organisation.organisation_member', 'organisation.job_recruiter_assignment',
    'gig.gig_worker_profile', 'gig.gig_request', 'gig.gig_application', 'gig.gig_assignment',
    'gig.gig_worker_list_entry', 'gig.gig_rating', 'gig.fulfilment_event',
]
with (Path(__file__).resolve().parent.parent / 'phase1/docs/columns.csv').open(newline='') as inventory:
    audited.extend('public.' + row['table_name'] for row in csv.DictReader(inventory)
                   if row['data_class'] in {'Personal', 'Sensitive'})
audited = sorted(set(audited))
for name in audited:
    add(f'CREATE TRIGGER audit_sensitive_change AFTER INSERT OR UPDATE OR DELETE ON {name} FOR EACH ROW EXECUTE FUNCTION identity.audit_sensitive_change()')

add('''CREATE FUNCTION identity.can_manage_gig_request(p_request_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig, public AS $$
  SELECT identity.has_permission('admin.manage_roles') OR
    (identity.has_permission('gig.request.manage') AND EXISTS (
      SELECT 1 FROM gig.gig_request r WHERE r.id = p_request_id AND r.deleted_at IS NULL
      AND identity.is_organisation_member(identity.actor_user_id(), r.requester_organisation_id)))
$$''')
add('''CREATE FUNCTION identity.can_read_gig_request(p_request_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig, public AS $$
  SELECT identity.can_manage_gig_request(p_request_id) OR EXISTS (
    SELECT 1 FROM gig.gig_request r JOIN gig.request_status s ON s.id = r.request_status_id
    WHERE r.id = p_request_id AND r.deleted_at IS NULL AND s.code = 'open'
      AND identity.has_permission('gig.worker.manage')) OR EXISTS (
    SELECT 1 FROM gig.gig_application a JOIN gig.gig_worker_profile w ON w.id = a.gig_worker_profile_id
    WHERE a.gig_request_id = p_request_id AND a.deleted_at IS NULL
      AND w.user_account_id = identity.actor_user_id())
$$''')
add('''CREATE FUNCTION identity.can_read_gig_application(p_application_id BIGINT) RETURNS BOOLEAN
LANGUAGE SQL STABLE SECURITY DEFINER
SET search_path = pg_catalog, identity, gig AS $$
  SELECT EXISTS (SELECT 1 FROM gig.gig_application a JOIN gig.gig_worker_profile w ON w.id = a.gig_worker_profile_id
    WHERE a.id = p_application_id AND a.deleted_at IS NULL
      AND (w.user_account_id = identity.actor_user_id() OR identity.can_manage_gig_request(a.gig_request_id)))
$$''')

# Policies run for the restricted group and every member login. An owner account
# with BYPASSRLS remains the migration/maintenance principal; never use it in apps.
for name in ['public.candidate_profile', 'public.job_requirement', 'public.organisation',
             'gig.gig_worker_profile', 'gig.gig_request', 'gig.gig_application', 'gig.gig_assignment']:
    add(f'ALTER TABLE {name} ENABLE ROW LEVEL SECURITY')

add('CREATE POLICY read_candidate ON public.candidate_profile FOR SELECT TO talentra_runtime USING (identity.can_view_candidate(id))')
add("CREATE POLICY insert_candidate ON public.candidate_profile FOR INSERT TO talentra_runtime WITH CHECK (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own'))")
add("CREATE POLICY update_candidate ON public.candidate_profile FOR UPDATE TO talentra_runtime USING (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own')) WITH CHECK (user_account_id = identity.actor_user_id() AND identity.has_permission('profile.write_own'))")
add('CREATE POLICY read_job ON public.job_requirement FOR SELECT TO talentra_runtime USING (identity.can_read_job(id))')
add('CREATE POLICY insert_job ON public.job_requirement FOR INSERT TO talentra_runtime WITH CHECK (identity.can_create_job(organisation_id))')
add('CREATE POLICY update_job ON public.job_requirement FOR UPDATE TO talentra_runtime USING (identity.can_manage_job(id)) WITH CHECK (identity.can_manage_job(id))')
add('CREATE POLICY read_organisation ON public.organisation FOR SELECT TO talentra_runtime USING (identity.can_read_organisation(id))')
add("CREATE POLICY read_worker ON gig.gig_worker_profile FOR SELECT TO talentra_runtime USING (user_account_id = identity.actor_user_id() OR identity.has_permission('admin.manage_roles') OR EXISTS (SELECT 1 FROM gig.gig_application a WHERE a.gig_worker_profile_id = id AND identity.can_manage_gig_request(a.gig_request_id)))")
add('CREATE POLICY read_gig_request ON gig.gig_request FOR SELECT TO talentra_runtime USING (identity.can_read_gig_request(id))')
add('CREATE POLICY read_gig_application ON gig.gig_application FOR SELECT TO talentra_runtime USING (identity.can_read_gig_application(id))')
add('CREATE POLICY read_gig_assignment ON gig.gig_assignment FOR SELECT TO talentra_runtime USING (identity.can_read_gig_application(gig_application_id))')

# The limited API role can write own profile and employer-owned jobs; gig writes
# are currently through trusted service transactions with explicit authorization.
add('GRANT SELECT ON gig.gig_service, gig.gig_availability TO talentra_runtime')
add('ALTER TABLE gig.gig_service ENABLE ROW LEVEL SECURITY')
add('ALTER TABLE gig.gig_availability ENABLE ROW LEVEL SECURITY')
add('CREATE POLICY read_gig_service ON gig.gig_service FOR SELECT TO talentra_runtime USING (EXISTS (SELECT 1 FROM gig.gig_worker_profile w WHERE w.id = gig_worker_profile_id AND w.user_account_id = identity.actor_user_id()))')
add('CREATE POLICY read_gig_availability ON gig.gig_availability FOR SELECT TO talentra_runtime USING (EXISTS (SELECT 1 FROM gig.gig_worker_profile w WHERE w.id = gig_worker_profile_id AND w.user_account_id = identity.actor_user_id()))')
