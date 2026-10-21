"""Generate the Phase 2 PostgreSQL migration from the reviewed entity definitions."""
from pathlib import Path

root = Path(__file__).resolve().parent
tables = {}
fks = []
uniques = []
checks = []
extra = []
lookups = {}


def table(name, columns=''):
    tables[name] = ['id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY']
    tables[name] += [line.strip() for line in columns.splitlines() if line.strip()]


def fk(name, target, column=None, nullable=False, target_key='id'):
    col = column or target.split('.')[-1] + '_id'
    tables[name].append(f'{col} BIGINT' + ('' if nullable else ' NOT NULL'))
    fks.append((name, col, target, target_key))


def unique(name, *columns):
    uniques.append((name, columns))


def check(name, expression):
    checks.append((name, expression))


def lookup(name, codes, more=''):
    table(name, '''code VARCHAR(80) NOT NULL UNIQUE
display_name VARCHAR(150) NOT NULL
active BOOLEAN NOT NULL DEFAULT TRUE
sort_order INTEGER NOT NULL DEFAULT 0
reference_code_id BIGINT''' + ('\n' + more if more else ''))
    fks.append((name, 'reference_code_id', 'public.reference_code', 'id'))
    unique(name, 'reference_code_id')
    lookups[name] = codes.split()


# Administration. Neon Auth owns browser credentials; platform-issued secrets are
# represented only by hashes and authentication sessions by references/digests.
lookup('identity.account_status', 'pending active suspended closed')
lookup('identity.credential_type', 'neon_auth api_key recovery')
lookup('identity.hash_algorithm', 'argon2id bcrypt external')
lookup('identity.consent_type', 'terms privacy marketing profile_visibility')
lookup('identity.session_status', 'active expired revoked')

table('identity.app_role', '''code VARCHAR(60) NOT NULL UNIQUE
display_name VARCHAR(150) NOT NULL
active BOOLEAN NOT NULL DEFAULT TRUE''')
table('identity.permission', '''code VARCHAR(100) NOT NULL UNIQUE
description VARCHAR(500) NOT NULL''')
table('identity.role_permission')
fk('identity.role_permission', 'identity.app_role')
fk('identity.role_permission', 'identity.permission')
unique('identity.role_permission', 'app_role_id', 'permission_id')
table('identity.user_role', '''valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
valid_to TIMESTAMPTZ''')
fk('identity.user_role', 'public.user_account')
fk('identity.user_role', 'identity.app_role')
check('identity.user_role', 'valid_to IS NULL OR valid_to > valid_from')
unique('identity.user_role', 'id', 'user_account_id')
table('identity.db_principal', '''db_role_name NAME NOT NULL UNIQUE''')
fk('identity.db_principal', 'public.user_account')
unique('identity.db_principal', 'user_account_id')
table('identity.credential', '''secret_hash VARCHAR(500)
external_reference VARCHAR(500)
issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
expires_at TIMESTAMPTZ
revoked_at TIMESTAMPTZ''')
fk('identity.credential', 'public.user_account')
fk('identity.credential', 'identity.credential_type')
fk('identity.credential', 'identity.hash_algorithm')
check('identity.credential', '(secret_hash IS NULL) <> (external_reference IS NULL)')
check('identity.credential', 'expires_at IS NULL OR expires_at > issued_at')
check('identity.credential', 'revoked_at IS NULL OR revoked_at >= issued_at')
table('identity.session_record', '''neon_auth_session_id UUID UNIQUE
session_digest CHAR(64) NOT NULL UNIQUE CHECK (session_digest ~ '^[a-f0-9]{64}$')
started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
expires_at TIMESTAMPTZ NOT NULL
ended_at TIMESTAMPTZ
last_activity_at TIMESTAMPTZ''')
fk('identity.session_record', 'public.user_account')
fk('identity.session_record', 'identity.session_status')
check('identity.session_record', 'expires_at > started_at')
check('identity.session_record', 'ended_at IS NULL OR ended_at >= started_at')
table('identity.user_consent', '''consent_version VARCHAR(40) NOT NULL
granted BOOLEAN NOT NULL
recorded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
withdrawn_at TIMESTAMPTZ''')
fk('identity.user_consent', 'public.user_account')
fk('identity.user_consent', 'identity.consent_type')
fk('identity.user_consent', 'public.language', nullable=True)
unique('identity.user_consent', 'user_account_id', 'consent_type_id', 'consent_version', 'recorded_at')
check('identity.user_consent', 'withdrawn_at IS NULL OR (granted AND withdrawn_at >= recorded_at)')
table('identity.user_block', '''reason VARCHAR(500)''')
fk('identity.user_block', 'public.candidate_profile')
fk('identity.user_block', 'public.user_account', column='blocked_user_account_id', nullable=True)
fk('identity.user_block', 'public.organisation', column='blocked_organisation_id', nullable=True)
check('identity.user_block', 'num_nonnulls(blocked_user_account_id, blocked_organisation_id) = 1')
table('identity.audit_event', '''action_code VARCHAR(100) NOT NULL
entity_schema VARCHAR(80) NOT NULL
entity_table VARCHAR(100) NOT NULL
entity_id BIGINT
occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
request_id UUID
source_ip INET
details JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(details) = 'object')''')
fk('identity.audit_event', 'public.user_account', column='actor_user_account_id', nullable=True)
table('identity.system_error_log', '''error_code VARCHAR(100) NOT NULL
severity VARCHAR(40) NOT NULL
component_name VARCHAR(100) NOT NULL
safe_message VARCHAR(2000) NOT NULL
occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
correlation_id UUID''')

# Organisation and account. public.organisation is the existing Phase 1 anchor.
lookup('organisation.account_status', 'pending active suspended closed')
lookup('organisation.organisation_type', 'employer client institution agency')
lookup('organisation.identifier_type', 'tax registration vat gst other')
lookup('organisation.verification_type', 'company_registration tax_identifier address other')
table('organisation.account_profile', '''account_name VARCHAR(150) NOT NULL''')
fk('organisation.account_profile', 'organisation.account_status')
table('organisation.organisation_location', '''location_name VARCHAR(150)
address_line_1 VARCHAR(250) NOT NULL
address_line_2 VARCHAR(250)
postal_code VARCHAR(30)
is_primary BOOLEAN NOT NULL DEFAULT FALSE''')
fk('organisation.organisation_location', 'public.organisation')
fk('organisation.organisation_location', 'public.city', nullable=True)
table('organisation.organisation_identifier', '''identifier_ciphertext BYTEA NOT NULL
identifier_fingerprint CHAR(64) NOT NULL CHECK (identifier_fingerprint ~ '^[a-f0-9]{64}$')
verified_at TIMESTAMPTZ''')
fk('organisation.organisation_identifier', 'public.organisation')
fk('organisation.organisation_identifier', 'public.country')
fk('organisation.organisation_identifier', 'organisation.identifier_type')
unique('organisation.organisation_identifier', 'country_id', 'identifier_type_id', 'identifier_fingerprint')
table('organisation.verification_record', '''provider_code VARCHAR(80) NOT NULL
provider_reference VARCHAR(200)
checked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
verified_at TIMESTAMPTZ
failure_code VARCHAR(80)''')
fk('organisation.verification_record', 'public.organisation')
fk('organisation.verification_record', 'organisation.verification_type')
fk('organisation.verification_record', 'public.verification_status')
unique('organisation.verification_record', 'provider_code', 'provider_reference')
table('organisation.organisation_recruiter', '''valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
valid_to TIMESTAMPTZ''')
fk('organisation.organisation_recruiter', 'public.organisation')
fk('organisation.organisation_recruiter', 'public.user_account', column='recruiter_user_account_id')
unique('organisation.organisation_recruiter', 'id', 'organisation_id', 'recruiter_user_account_id')
check('organisation.organisation_recruiter', 'valid_to IS NULL OR valid_to > valid_from')
table('organisation.account_administrator', '''valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
valid_to TIMESTAMPTZ''')
fk('organisation.account_administrator', 'organisation.account_profile')
fk('organisation.account_administrator', 'public.user_account')
check('organisation.account_administrator', 'valid_to IS NULL OR valid_to > valid_from')
table('organisation.organisation_member', '''valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
valid_to TIMESTAMPTZ''')
fk('organisation.organisation_member', 'public.organisation')
fk('organisation.organisation_member', 'public.user_account')
check('organisation.organisation_member', 'valid_to IS NULL OR valid_to > valid_from')
table('organisation.job_recruiter_assignment', '''valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
valid_to TIMESTAMPTZ''')
fk('organisation.job_recruiter_assignment', 'public.job_requirement')
fk('organisation.job_recruiter_assignment', 'public.organisation')
fk('organisation.job_recruiter_assignment', 'public.user_account', column='recruiter_user_account_id')
fk('organisation.job_recruiter_assignment', 'organisation.organisation_recruiter', column='organisation_recruiter_id')
check('organisation.job_recruiter_assignment', 'valid_to IS NULL OR valid_to > valid_from')

# Gig is a separate transactional lifecycle: no inverse bids or in-platform fulfilment.
lookup('gig.availability_status', 'available unavailable')
lookup('gig.request_status', 'draft open paused filled cancelled completed')
lookup('gig.pricing_model', 'fixed hourly daily')
lookup('gig.application_status', 'submitted accepted rejected withdrawn')
lookup('gig.assignment_status', 'pending_handoff handed_off in_progress completed failed cancelled')
lookup('gig.rate_unit', 'hour day project')
lookup('gig.worker_list_type', 'favourite blacklisted')
table('gig.gig_worker_profile', '''public_name VARCHAR(150) NOT NULL
bio VARCHAR(4000)
is_active BOOLEAN NOT NULL DEFAULT TRUE''')
fk('gig.gig_worker_profile', 'public.user_account')
fk('gig.gig_worker_profile', 'public.city', column='home_city_id', nullable=True)
unique('gig.gig_worker_profile', 'user_account_id')
table('gig.gig_service', '''service_name VARCHAR(150) NOT NULL
description VARCHAR(2000)
rate_amount NUMERIC(18,2) NOT NULL CHECK (rate_amount >= 0)''')
fk('gig.gig_service', 'gig.gig_worker_profile')
fk('gig.gig_service', 'public.currency')
fk('gig.gig_service', 'gig.rate_unit')
unique('gig.gig_service', 'gig_worker_profile_id', 'service_name')
table('gig.gig_availability', '''available_from TIMESTAMPTZ NOT NULL
available_to TIMESTAMPTZ NOT NULL''')
fk('gig.gig_availability', 'gig.gig_worker_profile')
fk('gig.gig_availability', 'gig.availability_status')
check('gig.gig_availability', 'available_to > available_from')
table('gig.gig_request', '''title VARCHAR(150) NOT NULL
description TEXT NOT NULL
start_at TIMESTAMPTZ NOT NULL
end_at TIMESTAMPTZ NOT NULL
price_amount NUMERIC(18,2) NOT NULL CHECK (price_amount >= 0)
source_timezone VARCHAR(100) NOT NULL DEFAULT 'UTC' ''')
fk('gig.gig_request', 'public.organisation', column='requester_organisation_id')
fk('gig.gig_request', 'public.user_account', column='requester_user_account_id')
fk('gig.gig_request', 'gig.pricing_model')
fk('gig.gig_request', 'public.currency')
fk('gig.gig_request', 'gig.request_status')
check('gig.gig_request', 'end_at > start_at')
unique('gig.gig_request', 'id', 'requester_organisation_id')
table('gig.gig_application', '''proposed_amount NUMERIC(18,2) CHECK (proposed_amount >= 0)
submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
decided_at TIMESTAMPTZ''')
fk('gig.gig_application', 'gig.gig_request')
fk('gig.gig_application', 'gig.gig_worker_profile')
fk('gig.gig_application', 'gig.application_status')
fk('gig.gig_application', 'public.currency', column='proposed_currency_id', nullable=True)
fk('gig.gig_application', 'public.user_account', column='decision_by_user_account_id', nullable=True)
check('gig.gig_application', '(proposed_amount IS NULL) = (proposed_currency_id IS NULL)')
check('gig.gig_application', '(decided_at IS NULL) = (decision_by_user_account_id IS NULL)')
unique('gig.gig_application', 'gig_request_id', 'gig_worker_profile_id')
unique('gig.gig_application', 'id', 'gig_request_id', 'gig_worker_profile_id')
table('gig.gig_assignment', '''external_system_code VARCHAR(80) NOT NULL
handoff_reference VARCHAR(200) NOT NULL
assignment_start_at TIMESTAMPTZ NOT NULL
assignment_end_at TIMESTAMPTZ NOT NULL
handed_off_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
reconciled_at TIMESTAMPTZ
estimated_earnings NUMERIC(18,2) CHECK (estimated_earnings >= 0)
total_earnings NUMERIC(18,2) CHECK (total_earnings >= 0)
projected_earnings NUMERIC(18,2) CHECK (projected_earnings >= 0)''')
fk('gig.gig_assignment', 'gig.gig_application')
fk('gig.gig_assignment', 'gig.gig_request')
fk('gig.gig_assignment', 'gig.gig_worker_profile')
fk('gig.gig_assignment', 'gig.assignment_status')
for col in ['estimated', 'total', 'projected']:
    fk('gig.gig_assignment', 'public.currency', column=f'{col}_currency_id', nullable=True)
    check('gig.gig_assignment', f'({col}_earnings IS NULL) = ({col}_currency_id IS NULL)')
check('gig.gig_assignment', 'assignment_end_at > assignment_start_at')
unique('gig.gig_assignment', 'gig_application_id')
unique('gig.gig_assignment', 'external_system_code', 'handoff_reference')
table('gig.gig_worker_list_entry')
fk('gig.gig_worker_list_entry', 'public.organisation', column='requester_organisation_id')
fk('gig.gig_worker_list_entry', 'gig.gig_worker_profile')
fk('gig.gig_worker_list_entry', 'gig.worker_list_type')
unique('gig.gig_worker_list_entry', 'requester_organisation_id', 'gig_worker_profile_id')
table('gig.gig_rating', '''rating_value SMALLINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5)
review_text VARCHAR(2000)''')
fk('gig.gig_rating', 'gig.gig_assignment')
fk('gig.gig_rating', 'public.user_account', column='requester_user_account_id')
unique('gig.gig_rating', 'gig_assignment_id')
table('gig.fulfilment_event', '''external_system_code VARCHAR(80) NOT NULL
external_event_id VARCHAR(200) NOT NULL
event_kind VARCHAR(80) NOT NULL
observed_at TIMESTAMPTZ NOT NULL
received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
payload_digest CHAR(64) CHECK (payload_digest ~ '^[a-f0-9]{64}$')''')
fk('gig.fulfilment_event', 'gig.gig_assignment')
unique('gig.fulfilment_event', 'external_system_code', 'external_event_id')
table('gig.worker_project', '''title VARCHAR(150) NOT NULL
project_role VARCHAR(150) NOT NULL
start_date DATE NOT NULL
end_date DATE
outcome VARCHAR(4000)''')
fk('gig.worker_project', 'gig.gig_worker_profile')
check('gig.worker_project', 'end_date IS NULL OR end_date >= start_date')


meta = ['created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP',
        'created_by BIGINT', 'updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP',
        'updated_by BIGINT', 'deleted_at TIMESTAMPTZ']
statements = ["SET LOCAL lock_timeout = '5s'", "SET LOCAL statement_timeout = '120s'",
              'CREATE EXTENSION IF NOT EXISTS btree_gist',
              'CREATE SCHEMA identity', 'CREATE SCHEMA organisation', 'CREATE SCHEMA gig',
              'CREATE ROLE talentra_runtime NOLOGIN']
for name, columns in tables.items():
    statements.append('CREATE TABLE ' + name + ' (\n  ' + ',\n  '.join(columns + meta) + '\n)')

for name, col, target, key in fks:
    statements.append(f'ALTER TABLE {name} ADD FOREIGN KEY ({col}) REFERENCES {target}({key}) ON UPDATE RESTRICT ON DELETE RESTRICT')
    statements.append(f'CREATE INDEX idx_{name.split(".")[-1]}_{col} ON {name} ({col})')
for name in tables:
    for col in ('created_by', 'updated_by'):
        statements.append(f'ALTER TABLE {name} ADD FOREIGN KEY ({col}) REFERENCES public.user_account(id) ON UPDATE RESTRICT ON DELETE RESTRICT')
        statements.append(f'CREATE INDEX idx_{name.split(".")[-1]}_{col} ON {name} ({col})')
for name, columns in uniques:
    statements.append(f'ALTER TABLE {name} ADD UNIQUE ({", ".join(columns)})')
for name, expression in checks:
    statements.append(f'ALTER TABLE {name} ADD CHECK ({expression})')

# Phase 1 anchors are expanded in place, preserving all references from Phase 1.
statements += [
    'ALTER TABLE public.user_account ADD COLUMN account_status_id BIGINT',
    'ALTER TABLE public.user_account ADD COLUMN email_verified_at TIMESTAMPTZ',
    'ALTER TABLE public.user_account ADD COLUMN last_login_at TIMESTAMPTZ',
    'ALTER TABLE public.user_account ADD FOREIGN KEY (account_status_id) REFERENCES identity.account_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'CREATE INDEX idx_user_account_account_status_id ON public.user_account(account_status_id)',
    'ALTER TABLE public.organisation ADD COLUMN account_profile_id BIGINT',
    'ALTER TABLE public.organisation ADD COLUMN parent_organisation_id BIGINT',
    'ALTER TABLE public.organisation ADD COLUMN organisation_type_id BIGINT',
    'ALTER TABLE public.organisation ADD COLUMN verification_status_id BIGINT',
    'ALTER TABLE public.organisation ADD COLUMN verified_at TIMESTAMPTZ',
    'ALTER TABLE public.organisation ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE',
    'ALTER TABLE public.organisation ADD COLUMN description TEXT',
    'ALTER TABLE public.organisation ADD FOREIGN KEY (account_profile_id) REFERENCES organisation.account_profile(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE public.organisation ADD FOREIGN KEY (parent_organisation_id) REFERENCES public.organisation(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE public.organisation ADD FOREIGN KEY (organisation_type_id) REFERENCES organisation.organisation_type(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE public.organisation ADD FOREIGN KEY (verification_status_id) REFERENCES public.verification_status(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE public.organisation ADD CHECK (parent_organisation_id IS NULL OR parent_organisation_id <> id)',
    'ALTER TABLE public.organisation ADD UNIQUE (id, account_profile_id)',
    'ALTER TABLE public.organisation ADD FOREIGN KEY (parent_organisation_id, account_profile_id) REFERENCES public.organisation(id, account_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'CREATE INDEX idx_organisation_account_profile_id ON public.organisation(account_profile_id)',
    'CREATE INDEX idx_organisation_parent_organisation_id ON public.organisation(parent_organisation_id)',
    'ALTER TABLE public.job_requirement ADD UNIQUE (id, organisation_id)',
    'ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (job_requirement_id, organisation_id) REFERENCES public.job_requirement(id, organisation_id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE organisation.job_recruiter_assignment ADD FOREIGN KEY (organisation_recruiter_id, organisation_id, recruiter_user_account_id) REFERENCES organisation.organisation_recruiter(id, organisation_id, recruiter_user_account_id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_application_id, gig_request_id, gig_worker_profile_id) REFERENCES gig.gig_application(id, gig_request_id, gig_worker_profile_id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE gig.gig_request ADD UNIQUE (id, start_at, end_at)',
    'ALTER TABLE gig.gig_assignment ADD FOREIGN KEY (gig_request_id, assignment_start_at, assignment_end_at) REFERENCES gig.gig_request(id, start_at, end_at) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'ALTER TABLE identity.session_record ADD FOREIGN KEY (neon_auth_session_id) REFERENCES neon_auth.session(id) ON UPDATE RESTRICT ON DELETE RESTRICT',
]

# Non-overlap applies to live mappings and booked assignments. Adjacent [) windows
# are allowed; historical rows with deleted_at remain auditable but are excluded.
statements += [
    "ALTER TABLE identity.user_role ADD CONSTRAINT ex_user_role_no_overlap EXCLUDE USING gist (user_account_id WITH =, app_role_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE organisation.organisation_recruiter ADD CONSTRAINT ex_recruiter_company_no_overlap EXCLUDE USING gist (recruiter_user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE organisation.account_administrator ADD CONSTRAINT ex_account_admin_no_overlap EXCLUDE USING gist (account_profile_id WITH =, user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE organisation.organisation_member ADD CONSTRAINT ex_organisation_member_no_overlap EXCLUDE USING gist (organisation_id WITH =, user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE organisation.job_recruiter_assignment ADD CONSTRAINT ex_job_recruiter_assignment_no_overlap EXCLUDE USING gist (job_requirement_id WITH =, recruiter_user_account_id WITH =, tstzrange(valid_from, valid_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE gig.gig_assignment ADD CONSTRAINT ex_gig_assignment_worker_no_overlap EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(assignment_start_at, assignment_end_at, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "ALTER TABLE gig.gig_availability ADD CONSTRAINT ex_gig_availability_worker_no_overlap EXCLUDE USING gist (gig_worker_profile_id WITH =, tstzrange(available_from, available_to, '[)') WITH &&) WHERE (deleted_at IS NULL)",
    "CREATE UNIQUE INDEX uq_organisation_primary_location ON organisation.organisation_location(organisation_id) WHERE is_primary AND deleted_at IS NULL",
    "CREATE UNIQUE INDEX uq_identity_block_user ON identity.user_block(candidate_profile_id, blocked_user_account_id) WHERE blocked_user_account_id IS NOT NULL AND deleted_at IS NULL",
    "CREATE UNIQUE INDEX uq_identity_block_org ON identity.user_block(candidate_profile_id, blocked_organisation_id) WHERE blocked_organisation_id IS NOT NULL AND deleted_at IS NULL",
    "CREATE UNIQUE INDEX uq_gig_available_window ON gig.gig_availability(gig_worker_profile_id, available_from, available_to) WHERE deleted_at IS NULL",
    "CREATE INDEX idx_identity_audit_time ON identity.audit_event(occurred_at, entity_table)",
    "CREATE INDEX idx_gig_request_org_window ON gig.gig_request(requester_organisation_id, start_at, end_at) WHERE deleted_at IS NULL",
]

for name, codes in lookups.items():
    rows = ', '.join("('%s', '%s', %s)" % (code, code.replace('_', ' ').title(), i) for i, code in enumerate(codes))
    statements.append(f'INSERT INTO {name} (code, display_name, sort_order) VALUES {rows}')
    statements.append(f"INSERT INTO public.reference_code (domain_code, code, display_name, active, sort_order) SELECT '{name}', code, display_name, active, sort_order FROM {name}")
    statements.append(f"UPDATE {name} l SET reference_code_id = r.id FROM public.reference_code r WHERE r.domain_code = '{name}' AND r.code = l.code")
    statements.append(f'ALTER TABLE {name} ALTER COLUMN reference_code_id SET NOT NULL')
statements.append("INSERT INTO public.reference_translation (reference_code_id, language_id, display_name) SELECT r.id, l.id, r.display_name FROM public.reference_code r CROSS JOIN public.language l WHERE r.domain_code IN (" + ', '.join("'" + k + "'" for k in lookups) + ") AND l.code = 'en'")
statements.append("UPDATE public.user_account SET account_status_id = (SELECT id FROM identity.account_status WHERE code = 'active') WHERE account_status_id IS NULL")
statements.append('ALTER TABLE public.user_account ALTER COLUMN account_status_id SET NOT NULL')
statements.append("CREATE FUNCTION identity.default_active_account_status_id() RETURNS BIGINT LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = pg_catalog, identity AS $$ SELECT id FROM identity.account_status WHERE code = 'active' $$")
statements.append('ALTER TABLE public.user_account ALTER COLUMN account_status_id SET DEFAULT identity.default_active_account_status_id()')

# Existing Phase 1 organisation rows may exist in another environment. Give them
# a real account row before requiring the new account/organisation type fields.
statements.append("INSERT INTO organisation.account_profile(account_name, account_status_id) SELECT 'Legacy organisation ' || o.id, s.id FROM public.organisation o CROSS JOIN organisation.account_status s WHERE s.code = 'active' AND o.account_profile_id IS NULL")
statements.append("UPDATE public.organisation o SET account_profile_id = a.id FROM organisation.account_profile a WHERE a.account_name = 'Legacy organisation ' || o.id AND o.account_profile_id IS NULL")
statements.append("UPDATE public.organisation SET organisation_type_id = (SELECT id FROM organisation.organisation_type WHERE code = 'employer') WHERE organisation_type_id IS NULL")
statements.append("UPDATE public.organisation SET verification_status_id = (SELECT id FROM public.verification_status WHERE code = 'pending') WHERE verification_status_id IS NULL")
statements += ['ALTER TABLE public.organisation ALTER COLUMN account_profile_id SET NOT NULL',
               'ALTER TABLE public.organisation ALTER COLUMN organisation_type_id SET NOT NULL',
               'ALTER TABLE public.organisation ALTER COLUMN verification_status_id SET NOT NULL']

roles = ['super_admin', 'admin', 'account_admin', 'guest', 'candidate', 'employer', 'recruiter', 'consultant', 'placement_officer']
perms = ['profile.read_own', 'profile.write_own', 'profile.read_applicant', 'job.read_published', 'job.read_org', 'job.write_org', 'job.read_assigned', 'job.write_assigned', 'job.read_consultant_open', 'organisation.read_own', 'organisation.manage_own', 'gig.worker.manage', 'gig.request.manage', 'gig.assignment.review', 'admin.manage_roles', 'admin.read_audit']
statements.append('INSERT INTO identity.app_role(code, display_name) VALUES ' + ', '.join("('%s','%s')" % (r, r.replace('_', ' ').title()) for r in roles))
statements.append('INSERT INTO identity.permission(code, description) VALUES ' + ', '.join("('%s','%s')" % (p, p.replace('_', ' ').replace('.', ': ').title()) for p in perms))
role_perms = {
    'guest': ['job.read_published'],
    'candidate': ['profile.read_own', 'profile.write_own', 'job.read_published', 'gig.worker.manage'],
    'employer': ['profile.read_applicant', 'job.read_org', 'job.write_org', 'organisation.read_own', 'gig.request.manage', 'gig.assignment.review'],
    'recruiter': ['profile.read_applicant', 'job.read_assigned', 'job.write_assigned', 'organisation.read_own'],
    'consultant': ['profile.read_applicant', 'job.read_consultant_open'],
    'placement_officer': ['job.read_published'],
    'account_admin': ['profile.read_applicant', 'job.read_org', 'job.write_org', 'organisation.read_own', 'organisation.manage_own', 'gig.request.manage', 'gig.assignment.review'],
    'admin': perms,
    'super_admin': perms,
}
for role, permissions in role_perms.items():
    statements.append("INSERT INTO identity.role_permission(app_role_id, permission_id) SELECT r.id, p.id FROM identity.app_role r JOIN identity.permission p ON p.code IN (" + ', '.join("'" + p + "'" for p in permissions) + f") WHERE r.code = '{role}'")

statements.append('GRANT USAGE ON SCHEMA public, identity, organisation, gig TO talentra_runtime')
statements.append('GRANT SELECT, INSERT, UPDATE ON public.candidate_profile, public.job_requirement TO talentra_runtime')
statements.append('GRANT SELECT ON public.organisation TO talentra_runtime')
statements.append('GRANT SELECT ON gig.gig_worker_profile, gig.gig_request, gig.gig_application, gig.gig_assignment TO talentra_runtime')
statements.append('GRANT USAGE ON SEQUENCE public.candidate_profile_id_seq, public.job_requirement_id_seq TO talentra_runtime')

# Further functions, triggers and row policies are emitted from the companion
# security module to keep entity definitions and policy logic separately reviewable.
from security_sql import statements as security_statements, add_entity_triggers
add_entity_triggers(tables)
statements.extend(security_statements)

header = '''-- Talentra Phase 2 / docket B24-B35. Run once after Phase 1.
-- Includes Administration, Organisation/account, and Gig marketplace.
-- The app principal is a dedicated database login role mapped to user_account;
-- shared runtime roles never trust client-writable custom GUCs for identity.
'''
output = root / 'migrations/002_phase2.sql'
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(header + '\nBEGIN;\n\n' + ';\n\n'.join(statements) + ';\n\nCOMMIT;\n')
print(f'{len(tables)} new tables, {len(statements)} statements, {len(output.read_bytes())} bytes')
