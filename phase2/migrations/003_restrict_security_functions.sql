-- Limit direct calls to Phase 2 security helpers. Row policies keep the
-- minimal entry points they require; internal role-lookup functions stay owner-only.
BEGIN;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA identity, organisation, gig FROM PUBLIC;

GRANT EXECUTE ON FUNCTION identity.actor_user_id(),
  identity.has_permission(TEXT),
  identity.can_view_candidate(BIGINT),
  identity.can_read_job(BIGINT),
  identity.can_manage_job(BIGINT),
  identity.can_create_job(BIGINT),
  identity.can_read_organisation(BIGINT),
  identity.can_manage_gig_request(BIGINT),
  identity.can_read_gig_request(BIGINT),
  identity.can_read_gig_application(BIGINT)
TO talentra_runtime;

COMMIT;
