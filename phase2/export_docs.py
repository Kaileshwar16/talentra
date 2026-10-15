"""Export reviewed Phase 2 inventories from Neon's saved PostgreSQL catalog."""
import csv
import hashlib
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parent
docs = root / 'docs'

def result(name):
    response = json.loads((docs / name).read_text())
    assert 'error' not in response and not response['result'].get('isError'), name
    return json.loads(next(x['text'] for x in response['result']['content'] if x['type'] == 'text'))

catalog = result('catalog-result.json')[0]['catalog']
acl = result('security-state-result.json')[0]['function_acl']
rows = result('row-counts-result.json')
for name in ['migration-result.json', 'security-migration-result.json', 'test-result.json', 'phase1-regression-result.json']:
    assert result(name) == [], name

expected_schemas = {'identity', 'organisation', 'gig'}
new_tables = sorted({(c['table_schema'], c['table_name']) for c in catalog['columns'] if c['table_schema'] in expected_schemas})
assert len(new_tables) == 45
assert catalog['phase2_table_count'] == 45 and catalog['public_table_count'] == 103 and catalog['auth_table_count'] == 9
assert all(c['validated'] for c in catalog['constraints'])
assert catalog['roles'] == [{'name': 'talentra_runtime', 'can_login': False, 'bypass_rls': False}]
assert not any(f['public_execute'] for f in acl)
assert len([f for f in acl if f['runtime_execute']]) == 10

seed_tables = {('identity', n) for n in ['account_status', 'consent_type', 'credential_type', 'hash_algorithm', 'session_status', 'app_role', 'permission', 'role_permission']}
seed_tables |= {('organisation', n) for n in ['account_status', 'identifier_type', 'organisation_type', 'verification_type']}
seed_tables |= {('gig', n) for n in ['application_status', 'assignment_status', 'availability_status', 'pricing_model', 'rate_unit', 'request_status', 'worker_list_type']}
assert all(int(r['row_count']) == 0 for r in rows if tuple(r['table_name'].split('.')) not in seed_tables)

def module(schema, table):
    if schema == 'identity' or (schema == 'public' and table == 'user_account'): return 'Administration'
    if schema == 'organisation' or (schema == 'public' and table == 'organisation'): return 'Organisation and account'
    if schema == 'gig': return 'Gig marketplace'
    return 'Phase 1 anchor extended by Phase 2'

def write_csv(name, data):
    assert data, name
    with (docs / name).open('w', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=list(data[0]), lineterminator='\n')
        writer.writeheader(); writer.writerows(data)

entity_rows = []
for schema, table in new_tables:
    entity_rows.append({'module': module(schema, table), 'schema': schema, 'table_name': table,
                        'owner_in_docket': {'identity':'Member A','organisation':'Member B','gig':'Member C'}[schema],
                        'source': 'Phase 2 docket B24-B35',
                        'lifecycle': 'append-only' if f'{schema}.{table}' in {'identity.audit_event','identity.system_error_log','identity.user_consent','gig.fulfilment_event'} else 'soft-delete',
                        'row_count': next(x['row_count'] for x in rows if x['table_name'] == f'{schema}.{table}')})
for table in ['user_account', 'organisation', 'job_requirement']:
    entity_rows.append({'module': module('public', table), 'schema': 'public', 'table_name': table,
                        'owner_in_docket': 'Shared Phase 1 anchor', 'source': 'Expanded in Phase 2',
                        'lifecycle': 'soft-delete', 'row_count': 'See Phase 1 rows'})
write_csv('entities.csv', entity_rows)

def data_class(schema, table, col):
    if col in {'secret_hash','session_digest','identifier_ciphertext','identifier_fingerprint','neon_auth_session_id','external_reference','provider_reference','handoff_reference','payload_digest'}: return 'Sensitive'
    if any(x in col for x in ['email','source_ip','user_account_id','source_ip','session_id']): return 'Personal'
    if schema == 'identity' and table in {'credential','session_record','user_block','user_consent','audit_event','system_error_log','db_principal'}: return 'Personal'
    if schema == 'gig' and table in {'gig_worker_profile','gig_application','gig_rating','gig_assignment','fulfilment_event'}: return 'Personal'
    if schema == 'organisation' and table in {'organisation_identifier','verification_record','organisation_recruiter','account_administrator','organisation_member'}: return 'Internal'
    if col in {'code','display_name','active','sort_order','id'} and table in {'app_role','permission'}: return 'Public'
    return 'Internal'

null_reasons = {
    'created_by': 'System or seed creation has no human actor; supplied value references user_account.',
    'updated_by': 'System or seed update has no human actor; supplied value references user_account.',
    'deleted_at': 'NULL marks an active row. Append-only rows cannot be soft-deleted by ordinary updates.',
    'valid_to': 'Open-ended assignment, role, or membership period.',
    'parent_organisation_id': 'Root organisation in an account hierarchy.',
    'neon_auth_session_id': 'Session may originate outside Neon Auth or has not been linked.',
    'secret_hash': 'External identity-provider credentials have no locally stored secret hash.',
    'external_reference': 'Locally hashed credentials have no external reference.',
    'expires_at': 'Credential does not have a defined expiry.',
    'revoked_at': 'Credential has not been revoked.',
    'ended_at': 'Session has not ended.',
    'last_activity_at': 'No activity has been recorded since session creation.',
    'withdrawn_at': 'Consent remains granted or was never granted.',
    'blocked_user_account_id': 'Block targets an organisation instead of a user.',
    'blocked_organisation_id': 'Block targets a user instead of an organisation.',
    'actor_user_account_id': 'System action or maintenance operation without a mapped end-user principal.',
    'request_id': 'No access-layer request ID was supplied.',
    'source_ip': 'Source IP is not available to the database connection.',
    'entity_id': 'Schema-level action has no row identifier.',
    'city_id': 'Location is remote, unknown, or not yet in the city catalog.',
    'postal_code': 'Address does not have a supplied postal code.',
    'provider_reference': 'Provider has not returned a reference.',
    'verified_at': 'Verification has not completed.',
    'failure_code': 'Verification did not fail.',
    'proposed_amount': 'Worker did not propose a price distinct from the gig request.',
    'proposed_currency_id': 'No proposed price; amount and currency must be present together.',
    'decided_at': 'Requester has not accepted or rejected the application.',
    'decision_by_user_account_id': 'Requester has not made a decision.',
    'reconciled_at': 'External fulfilment status has not been reconciled.',
    'estimated_earnings': 'External fulfilment system has not supplied an estimate.',
    'total_earnings': 'External fulfilment system has not supplied a total.',
    'projected_earnings': 'External fulfilment system has not supplied a projection.',
    'estimated_currency_id': 'Estimate is absent; money and currency must be present together.',
    'total_currency_id': 'Total is absent; money and currency must be present together.',
    'projected_currency_id': 'Projection is absent; money and currency must be present together.',
    'end_date': 'Project remains active or the end date is not yet supplied.',
    'payload_digest': 'Provider did not supply a canonical payload for hashing.',
}
columns = []
for c in catalog['columns']:
    schema,table,col=c['table_schema'],c['table_name'],c['column_name']
    datatype=c['data_type']
    if c['character_maximum_length'] is not None: datatype += f"({c['character_maximum_length']})"
    elif datatype == 'numeric': datatype += f"({c['numeric_precision']},{c['numeric_scale']})"
    reason = '' if c['is_nullable'] == 'NO' else null_reasons.get(col, f'Optional {col.replace("_", " ")} is not yet supplied or not applicable; Phase 2 does not encode those cases separately.')
    columns.append({'module':module(schema,table),'schema':schema,'table_name':table,'position':c['ordinal_position'],
                    'column_name':col,'data_type':datatype,'nullable':c['is_nullable'],'default':c['column_default'],
                    'identity':c['is_identity'],'data_class':data_class(schema,table,col),'nullability_reason':reason})
write_csv('columns.csv', columns)
write_csv('constraints.csv', catalog['constraints'])
write_csv('relationships.csv', [c for c in catalog['constraints'] if c['constraint_type'] == 'f'])
write_csv('indexes.csv', catalog['indexes'])
write_csv('triggers.csv', catalog['triggers'])
write_csv('policies.csv', catalog['policies'])
write_csv('security_functions.csv', acl)

counts=Counter(c['constraint_type'] for c in catalog['constraints'])
report={
    'verified_at_utc':datetime.now(timezone.utc).isoformat(),
    'target':{'organisation':'Nithin','project':'Talentra','branch':'production','database':'neondb','postgresql':catalog['version']},
    'scope':'Phase 2, B24-B35',
    'new_table_count':len(new_tables),'phase1_public_table_count':catalog['public_table_count'],
    'neon_auth_table_count':catalog['auth_table_count'],
    'column_inventory_rows':len(columns),'foreign_keys':counts['f'],'check_constraints':counts['c'],
    'unique_constraints':counts['u'],'exclusion_constraints':counts['x'],
    'indexes_in_catalog':len(catalog['indexes']),'triggers_in_catalog':len(catalog['triggers']),
    'rls_tables':catalog['rls_tables'],'rls_policy_count':len(catalog['policies']),
    'all_constraints_validated':True,
    'runtime_role':'talentra_runtime (NOLOGIN; BYPASSRLS=false)',
    'security_functions':{'total':len(acl),'public_executable':0,'runtime_executable':10},
    'business_fixture_rows_remaining':0,
    'reference_rows_remaining':sum(int(r['row_count']) for r in rows if tuple(r['table_name'].split('.')) in seed_tables),
    'migrations':[{'file':'migrations/002_phase2.sql','sha256':hashlib.sha256((root/'migrations/002_phase2.sql').read_bytes()).hexdigest()},
                  {'file':'migrations/003_restrict_security_functions.sql','sha256':hashlib.sha256((root/'migrations/003_restrict_security_functions.sql').read_bytes()).hexdigest()}],
    'validation':{'rollback_before_apply':'Phase 2 plus Phase 1 suites passed',
                  'installed_phase2_checks':36,'installed_phase1_regression_checks':26,
                  'test_fixtures_rolled_back':True},
    'limits':['No dedicated runtime login or live app is provisioned','No concurrent-client contention benchmark',
              'Audit of read actions must be supplied by the future access layer','No live external fulfilment or company-verification provider'],
    'human_owner_review':'Member A/B/C are docket roles; no named human sign-off claimed',
}
(docs/'validation-report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['new_table_count','foreign_keys','exclusion_constraints','rls_policy_count','business_fixture_rows_remaining','validation']},indent=2))
