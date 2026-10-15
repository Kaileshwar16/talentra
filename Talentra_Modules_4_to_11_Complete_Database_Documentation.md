# Talentra — Complete Database Documentation for Modules 4–11

> **Scope:** Modules 4–11 from the supplied `Pasted text(6).txt` PostgreSQL schema dump. This is a schema inventory and implementation contract, not a claim that every requested feature already exists in the database. All field definitions and SQL constraints below are taken from the supplied dump. Where the requested capability is absent, it is explicitly listed as a gap and any suggested schema is labelled **proposed**, not source-defined.

## Module ownership and phase

| Module | Phase | Owner |
|---|---|---|
| 4. Administration | Phase 2 | Member A |
| 5. Organisation and Account | Phase 2 | Member B |
| 6. Gig Marketplace | Phase 2 | Member C |
| 7. Licences, Seats, Devices and Sessions | Phase 3 | Assigned member |
| 8. Sourcing and Consultant Requests | Phase 3 | Assigned member |
| 9. Subscriptions, Wallet, Payments and Download History | Phase 3 | Assigned member |
| 10. Notifications, Preferences and Community | Phase 4 | Whole team |
| 11. Analytics Layer and Reporting Marts | Phase 4 | Assigned member |

## Important source and scope notes

- Source inspected: `Pasted text(6).txt` (legacy/expanded PostgreSQL schema dump). It includes `public`, `gig`, `identity`, `organisation`, and `neon_auth` schemas.
- **`neon_auth` is intentionally excluded** from this documentation, including its provider-managed tables. Do not edit or recreate provider-managed authentication tables as part of these modules.
- A separate, newer PostgreSQL baseline (`Pasted text(7).txt`) contains 103 tables and does **not** contain many of the module-specific entities present in this expanded dump. Treat this document as describing the expanded dump only; reconcile it against the active Neon database before migrations.
- The schema dump defines columns, primary keys, inline/table constraints, indexes, and a small number of RLS enablement statements. A declared FK is only treated as database-enforced when a `REFERENCES` clause or FK constraint appears in the source. A column named `*_id` by itself does not prove a foreign key.
- Trigger bodies, row-level security policies, application-service validation, provider billing workflows, and retention jobs are not assumed unless represented in the source SQL.
- Table names repeated in multiple modules are shared dependencies; their full entity definition is included once in the module where it is first listed and referenced in later modules.

## 4. Administration — Phase 2 — Member A

**Entities in this module:** 59 source tables listed (including shared entities).

### `audit_event`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "audit_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `actor_user_account_id` | `bigint` |
| `action_code` | `varchar(100) NOT NULL` |
| `entity_type` | `varchar(100) NOT NULL` |
| `entity_id` | `bigint` |
| `outcome` | `varchar(30) NOT NULL` |
| `occurred_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `ip_address` | `inet` |
| `user_agent` | `text` |
| `correlation_id` | `uuid` |
| `request_id` | `varchar(100)` |
| `reason` | `text` |
| `before_data` | `jsonb` |
| `after_data` | `jsonb` |
| `metadata` | `jsonb DEFAULT '{}' NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "audit_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `audit_event_pkey` on ("id")
- `idx_audit_event_actor_time` on ("actor_user_account_id","occurred_at")
- `idx_audit_event_entity_time` on ("entity_type","entity_id","occurred_at")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.audit_event`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."audit_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `action_code` | `varchar(100) NOT NULL` |
| `entity_schema` | `varchar(80) NOT NULL` |
| `entity_table` | `varchar(100) NOT NULL` |
| `entity_id` | `bigint` |
| `occurred_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `request_id` | `uuid` |
| `source_ip` | `inet` |
| `details` | `jsonb DEFAULT '{}' NOT NULL` |
| `actor_user_account_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."audit_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "audit_event_details_check" CHECK ((jsonb_typeof(details) = 'object'::text))`

**Indexes in source dump**

- UNIQUE `audit_event_pkey` on ("id")
- `idx_audit_event_actor_user_account_id` on ("actor_user_account_id")
- `idx_audit_event_created_by` on ("created_by")
- `idx_audit_event_updated_by` on ("updated_by")
- `idx_identity_audit_time` on ("occurred_at","entity_table")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `system_error_log`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "system_error_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `error_code` | `varchar(100)` |
| `severity` | `varchar(20) NOT NULL` |
| `service_name` | `varchar(100)` |
| `operation_name` | `varchar(150)` |
| `message` | `text NOT NULL` |
| `stack_reference` | `text` |
| `correlation_id` | `uuid` |
| `occurred_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `resolved_at` | `timestamp with time zone` |
| `resolution_note` | `text` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "system_error_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `system_error_log_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.system_error_log`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."system_error_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `error_code` | `varchar(100) NOT NULL` |
| `severity` | `varchar(40) NOT NULL` |
| `component_name` | `varchar(100) NOT NULL` |
| `safe_message` | `varchar(2000) NOT NULL` |
| `occurred_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `correlation_id` | `uuid` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."system_error_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_system_error_log_created_by` on ("created_by")
- `idx_system_error_log_updated_by` on ("updated_by")
- UNIQUE `system_error_log_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `permission`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `permission_code` | `varchar(120) NOT NULL CONSTRAINT "permission_permission_code_key" UNIQUE` |
| `permission_name` | `varchar(150) NOT NULL` |
| `module_code` | `varchar(60) NOT NULL` |
| `description` | `text` |
| `is_sensitive` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"permission_code" varchar(120) NOT NULL CONSTRAINT "permission_permission_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `permission_permission_code_key` on ("permission_code")
- UNIQUE `permission_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.permission`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(100) NOT NULL CONSTRAINT "permission_code_key" UNIQUE` |
| `description` | `varchar(500) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(100) NOT NULL CONSTRAINT "permission_code_key" UNIQUE`

**Indexes in source dump**

- `idx_permission_created_by` on ("created_by")
- `idx_permission_updated_by` on ("updated_by")
- UNIQUE `permission_code_key` on ("code")
- UNIQUE `permission_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `role_permission`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "role_permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `account_role_id` | `bigint NOT NULL` |
| `permission_id` | `bigint NOT NULL` |
| `granted_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `granted_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "role_permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "role_permission_account_role_id_permission_id_key" UNIQUE("account_role_id","permission_id")`

**Indexes in source dump**

- UNIQUE `role_permission_account_role_id_permission_id_key` on ("account_role_id","permission_id")
- UNIQUE `role_permission_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.role_permission`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."role_permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `app_role_id` | `bigint NOT NULL` |
| `permission_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."role_permission_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "role_permission_app_role_id_permission_id_key" UNIQUE("app_role_id","permission_id")`

**Indexes in source dump**

- `idx_role_permission_app_role_id` on ("app_role_id")
- `idx_role_permission_created_by` on ("created_by")
- `idx_role_permission_permission_id` on ("permission_id")
- `idx_role_permission_updated_by` on ("updated_by")
- UNIQUE `role_permission_app_role_id_permission_id_key` on ("app_role_id","permission_id")
- UNIQUE `role_permission_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `account_role`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `role_code` | `varchar(60) NOT NULL CONSTRAINT "account_role_role_code_key" UNIQUE` |
| `role_name` | `varchar(120) NOT NULL` |
| `description` | `text` |
| `is_system_role` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"role_code" varchar(60) NOT NULL CONSTRAINT "account_role_role_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `account_role_pkey` on ("id")
- UNIQUE `account_role_role_code_key` on ("role_code")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `account_status_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `previous_status` | `varchar(30)` |
| `new_status` | `varchar(30) NOT NULL` |
| `change_reason` | `text` |
| `changed_by` | `bigint` |
| `changed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `account_status_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `login_attempt`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "login_attempt_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint` |
| `login_identifier` | `varchar(254) NOT NULL` |
| `attempted_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `ip_address` | `inet` |
| `user_agent` | `text` |
| `attempt_result` | `varchar(30) NOT NULL` |
| `failure_reason_code` | `varchar(50)` |
| `correlation_id` | `uuid` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "login_attempt_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_login_attempt_identifier_time` on ("login_identifier","attempted_at")
- UNIQUE `login_attempt_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `support_ticket`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "support_ticket_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `ticket_number` | `varchar(40) NOT NULL CONSTRAINT "support_ticket_ticket_number_key" UNIQUE` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `assigned_user_account_id` | `bigint` |
| `subject` | `varchar(200) NOT NULL` |
| `description` | `text NOT NULL` |
| `category_code` | `varchar(60)` |
| `priority` | `varchar(20) DEFAULT 'NORMAL' NOT NULL` |
| `ticket_status` | `varchar(30) DEFAULT 'OPEN' NOT NULL` |
| `opened_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `resolved_at` | `timestamp with time zone` |
| `closed_at` | `timestamp with time zone` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "support_ticket_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"ticket_number" varchar(40) NOT NULL CONSTRAINT "support_ticket_ticket_number_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `support_ticket_pkey` on ("id")
- UNIQUE `support_ticket_ticket_number_key` on ("ticket_number")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `support_ticket_message`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "support_ticket_message_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `support_ticket_id` | `bigint NOT NULL` |
| `author_user_account_id` | `bigint NOT NULL` |
| `message_body` | `text NOT NULL` |
| `is_internal` | `boolean DEFAULT false NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "support_ticket_message_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `support_ticket_message_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `faq_article`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "faq_article_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `faq_code` | `varchar(60) NOT NULL CONSTRAINT "faq_article_faq_code_key" UNIQUE` |
| `category_code` | `varchar(60)` |
| `language_code` | `varchar(10) DEFAULT 'en' NOT NULL` |
| `question` | `text NOT NULL` |
| `answer` | `text NOT NULL` |
| `is_published` | `boolean DEFAULT false NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "faq_article_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"faq_code" varchar(60) NOT NULL CONSTRAINT "faq_article_faq_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `faq_article_faq_code_key` on ("faq_code")
- UNIQUE `faq_article_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `consent_record`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "consent_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `consent_type` | `varchar(60) NOT NULL` |
| `policy_version` | `varchar(40) NOT NULL` |
| `consent_status` | `varchar(20) NOT NULL` |
| `captured_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `withdrawn_at` | `timestamp with time zone` |
| `capture_method` | `varchar(40)` |
| `source_ip` | `inet` |
| `evidence_reference` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "consent_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "consent_record_consent_status_check" CHECK (((consent_status)::text = ANY ((ARRAY['GRANTED'::character varying, 'DENIED'::character varying, 'WITHDRAWN'::character varying])::text[])))`

**Indexes in source dump**

- UNIQUE `consent_record_pkey` on ("id")
- `idx_consent_user_type_time` on ("user_account_id","consent_type","captured_at")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.consent_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."consent_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "consent_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "consent_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."consent_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "consent_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "consent_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `consent_type_code_key` on ("code")
- UNIQUE `consent_type_pkey` on ("id")
- UNIQUE `consent_type_reference_code_id_key` on ("reference_code_id")
- `idx_consent_type_created_by` on ("created_by")
- `idx_consent_type_reference_code_id` on ("reference_code_id")
- `idx_consent_type_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.user_consent`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_consent_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `consent_version` | `varchar(40) NOT NULL` |
| `granted` | `boolean NOT NULL` |
| `recorded_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `withdrawn_at` | `timestamp with time zone` |
| `user_account_id` | `bigint NOT NULL` |
| `consent_type_id` | `bigint NOT NULL` |
| `language_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_consent_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_consent_user_account_id_consent_type_id_consent_versio_key" UNIQUE("user_account_id","consent_type_id","consent_version","recorded_at")`
- `CONSTRAINT "user_consent_check" CHECK (((withdrawn_at IS NULL) OR (granted AND (withdrawn_at >= recorded_at))))`

**Indexes in source dump**

- `idx_user_consent_consent_type_id` on ("consent_type_id")
- `idx_user_consent_created_by` on ("created_by")
- `idx_user_consent_language_id` on ("language_id")
- `idx_user_consent_updated_by` on ("updated_by")
- `idx_user_consent_user_account_id` on ("user_account_id")
- UNIQUE `user_consent_pkey` on ("id")
- UNIQUE `user_consent_user_account_id_consent_type_id_consent_versio_key` on ("user_account_id","consent_type_id","consent_version","recorded_at")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.db_principal`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."db_principal_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `db_role_name` | `name NOT NULL CONSTRAINT "db_principal_db_role_name_key" UNIQUE` |
| `user_account_id` | `bigint NOT NULL CONSTRAINT "db_principal_user_account_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."db_principal_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"db_role_name" name NOT NULL CONSTRAINT "db_principal_db_role_name_key" UNIQUE`
- Inline: `"user_account_id" bigint NOT NULL CONSTRAINT "db_principal_user_account_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `db_principal_db_role_name_key` on ("db_role_name")
- UNIQUE `db_principal_pkey` on ("id")
- UNIQUE `db_principal_user_account_id_key` on ("user_account_id")
- `idx_db_principal_created_by` on ("created_by")
- `idx_db_principal_updated_by` on ("updated_by")
- `idx_db_principal_user_account_id` on ("user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.app_role`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."app_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(60) NOT NULL CONSTRAINT "app_role_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."app_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(60) NOT NULL CONSTRAINT "app_role_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `app_role_code_key` on ("code")
- UNIQUE `app_role_pkey` on ("id")
- `idx_app_role_created_by` on ("created_by")
- `idx_app_role_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.account_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."account_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "account_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "account_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."account_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "account_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "account_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `account_status_code_key` on ("code")
- UNIQUE `account_status_pkey` on ("id")
- UNIQUE `account_status_reference_code_id_key` on ("reference_code_id")
- `idx_account_status_created_by` on ("created_by")
- `idx_account_status_reference_code_id` on ("reference_code_id")
- `idx_account_status_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `reference_code`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "reference_code_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `domain_code` | `varchar(80) NOT NULL` |
| `code` | `varchar(80) NOT NULL` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "reference_code_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_reference_code_6" UNIQUE("domain_code","code")`

**Indexes in source dump**

- `idx_reference_code_created_by` on ("created_by")
- `idx_reference_code_updated_by` on ("updated_by")
- UNIQUE `reference_code_pkey` on ("id")
- UNIQUE `uq_reference_code_6` on ("domain_code","code")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `reference_translation`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "reference_translation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `display_name` | `varchar(150) NOT NULL` |
| `reference_code_id` | `bigint NOT NULL` |
| `language_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "reference_translation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_reference_translation_4" UNIQUE("reference_code_id","language_id")`

**Indexes in source dump**

- `idx_reference_translation_created_by` on ("created_by")
- `idx_reference_translation_language_id` on ("language_id")
- `idx_reference_translation_reference_code_id` on ("reference_code_id")
- `idx_reference_translation_updated_by` on ("updated_by")
- UNIQUE `reference_translation_pkey` on ("id")
- UNIQUE `uq_reference_translation_4` on ("reference_code_id","language_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `ui_translation`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "ui_translation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `translation_key` | `varchar(160) NOT NULL` |
| `translated_text` | `varchar(2000) NOT NULL` |
| `language_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "ui_translation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_ui_translation_4" UNIQUE("translation_key","language_id")`

**Indexes in source dump**

- `idx_ui_translation_created_by` on ("created_by")
- `idx_ui_translation_language_id` on ("language_id")
- `idx_ui_translation_updated_by` on ("updated_by")
- UNIQUE `ui_translation_pkey` on ("id")
- UNIQUE `uq_ui_translation_4` on ("translation_key","language_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `industry`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "industry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "industry_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "industry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "industry_code_key" UNIQUE`

**Indexes in source dump**

- `idx_industry_created_by` on ("created_by")
- `idx_industry_updated_by` on ("updated_by")
- UNIQUE `industry_code_key` on ("code")
- UNIQUE `industry_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `job_role`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "job_role_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "job_role_code_key" UNIQUE`

**Indexes in source dump**

- `idx_job_role_created_by` on ("created_by")
- `idx_job_role_updated_by` on ("updated_by")
- UNIQUE `job_role_code_key` on ("code")
- UNIQUE `job_role_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `activity_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "activity_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "activity_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_activity_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "activity_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "activity_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_activity_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `activity_type_code_key` on ("code")
- UNIQUE `activity_type_pkey` on ("id")
- `idx_activity_type_created_by` on ("created_by")
- `idx_activity_type_reference_code_id` on ("reference_code_id")
- `idx_activity_type_updated_by` on ("updated_by")
- UNIQUE `uq_activity_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `candidate_activity_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_activity_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "candidate_activity_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_candidate_activity_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_activity_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "candidate_activity_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_candidate_activity_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `candidate_activity_type_code_key` on ("code")
- UNIQUE `candidate_activity_type_pkey` on ("id")
- `idx_candidate_activity_type_created_by` on ("created_by")
- `idx_candidate_activity_type_reference_code_id` on ("reference_code_id")
- `idx_candidate_activity_type_updated_by` on ("updated_by")
- UNIQUE `uq_candidate_activity_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `job_event_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_event_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "job_event_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_job_event_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_event_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "job_event_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_job_event_type_6" UNIQUE`

**Indexes in source dump**

- `idx_job_event_type_created_by` on ("created_by")
- `idx_job_event_type_reference_code_id` on ("reference_code_id")
- `idx_job_event_type_updated_by` on ("updated_by")
- UNIQUE `job_event_type_code_key` on ("code")
- UNIQUE `job_event_type_pkey` on ("id")
- UNIQUE `uq_job_event_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `hiring_stage_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "hiring_stage_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "hiring_stage_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_hiring_stage_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "hiring_stage_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "hiring_stage_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_hiring_stage_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `hiring_stage_type_code_key` on ("code")
- UNIQUE `hiring_stage_type_pkey` on ("id")
- `idx_hiring_stage_type_created_by` on ("created_by")
- `idx_hiring_stage_type_reference_code_id` on ("reference_code_id")
- `idx_hiring_stage_type_updated_by` on ("updated_by")
- UNIQUE `uq_hiring_stage_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `verification_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "verification_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "verification_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_verification_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "verification_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "verification_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_verification_status_6" UNIQUE`

**Indexes in source dump**

- `idx_verification_status_created_by` on ("created_by")
- `idx_verification_status_reference_code_id` on ("reference_code_id")
- `idx_verification_status_updated_by` on ("updated_by")
- UNIQUE `uq_verification_status_6` on ("reference_code_id")
- UNIQUE `verification_status_code_key` on ("code")
- UNIQUE `verification_status_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `document_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "document_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "document_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_document_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "document_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "document_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_document_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `document_type_code_key` on ("code")
- UNIQUE `document_type_pkey` on ("id")
- `idx_document_type_created_by` on ("created_by")
- `idx_document_type_reference_code_id` on ("reference_code_id")
- `idx_document_type_updated_by` on ("updated_by")
- UNIQUE `uq_document_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `education_level`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "education_level_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "education_level_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_education_level_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "education_level_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "education_level_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_education_level_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `education_level_code_key` on ("code")
- UNIQUE `education_level_pkey` on ("id")
- `idx_education_level_created_by` on ("created_by")
- `idx_education_level_reference_code_id` on ("reference_code_id")
- `idx_education_level_updated_by` on ("updated_by")
- UNIQUE `uq_education_level_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `employment_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "employment_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "employment_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_employment_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "employment_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "employment_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_employment_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `employment_type_code_key` on ("code")
- UNIQUE `employment_type_pkey` on ("id")
- `idx_employment_type_created_by` on ("created_by")
- `idx_employment_type_reference_code_id` on ("reference_code_id")
- `idx_employment_type_updated_by` on ("updated_by")
- UNIQUE `uq_employment_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `experience_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "experience_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "experience_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_experience_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "experience_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "experience_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_experience_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `experience_type_code_key` on ("code")
- UNIQUE `experience_type_pkey` on ("id")
- `idx_experience_type_created_by` on ("created_by")
- `idx_experience_type_reference_code_id` on ("reference_code_id")
- `idx_experience_type_updated_by` on ("updated_by")
- UNIQUE `uq_experience_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `proficiency_level`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "proficiency_level_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "proficiency_level_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_proficiency_level_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "proficiency_level_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "proficiency_level_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_proficiency_level_6" UNIQUE`

**Indexes in source dump**

- `idx_proficiency_level_created_by` on ("created_by")
- `idx_proficiency_level_reference_code_id` on ("reference_code_id")
- `idx_proficiency_level_updated_by` on ("updated_by")
- UNIQUE `proficiency_level_code_key` on ("code")
- UNIQUE `proficiency_level_pkey` on ("id")
- UNIQUE `uq_proficiency_level_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `question_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "question_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "question_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_question_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "question_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "question_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_question_type_6" UNIQUE`

**Indexes in source dump**

- `idx_question_type_created_by` on ("created_by")
- `idx_question_type_reference_code_id` on ("reference_code_id")
- `idx_question_type_updated_by` on ("updated_by")
- UNIQUE `question_type_code_key` on ("code")
- UNIQUE `question_type_pkey` on ("id")
- UNIQUE `uq_question_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `application_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "application_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_application_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "application_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_application_status_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `application_status_code_key` on ("code")
- UNIQUE `application_status_pkey` on ("id")
- `idx_application_status_created_by` on ("created_by")
- `idx_application_status_reference_code_id` on ("reference_code_id")
- `idx_application_status_updated_by` on ("updated_by")
- UNIQUE `uq_application_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `interview_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "interview_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "interview_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_interview_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "interview_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "interview_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_interview_status_6" UNIQUE`

**Indexes in source dump**

- `idx_interview_status_created_by` on ("created_by")
- `idx_interview_status_reference_code_id` on ("reference_code_id")
- `idx_interview_status_updated_by` on ("updated_by")
- UNIQUE `interview_status_code_key` on ("code")
- UNIQUE `interview_status_pkey` on ("id")
- UNIQUE `uq_interview_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `offer_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "offer_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "offer_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_offer_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "offer_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "offer_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_offer_status_6" UNIQUE`

**Indexes in source dump**

- `idx_offer_status_created_by` on ("created_by")
- `idx_offer_status_reference_code_id` on ("reference_code_id")
- `idx_offer_status_updated_by` on ("updated_by")
- UNIQUE `offer_status_code_key` on ("code")
- UNIQUE `offer_status_pkey` on ("id")
- UNIQUE `uq_offer_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `job_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "job_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_job_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "job_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_job_status_6" UNIQUE`

**Indexes in source dump**

- `idx_job_status_created_by` on ("created_by")
- `idx_job_status_reference_code_id` on ("reference_code_id")
- `idx_job_status_updated_by` on ("updated_by")
- UNIQUE `job_status_code_key` on ("code")
- UNIQUE `job_status_pkey` on ("id")
- UNIQUE `uq_job_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `job_position_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_position_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "job_position_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_job_position_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_position_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "job_position_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_job_position_status_6" UNIQUE`

**Indexes in source dump**

- `idx_job_position_status_created_by` on ("created_by")
- `idx_job_position_status_reference_code_id` on ("reference_code_id")
- `idx_job_position_status_updated_by` on ("updated_by")
- UNIQUE `job_position_status_code_key` on ("code")
- UNIQUE `job_position_status_pkey` on ("id")
- UNIQUE `uq_job_position_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `referral_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "referral_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "referral_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_referral_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "referral_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "referral_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_referral_status_6" UNIQUE`

**Indexes in source dump**

- `idx_referral_status_created_by` on ("created_by")
- `idx_referral_status_reference_code_id` on ("reference_code_id")
- `idx_referral_status_updated_by` on ("updated_by")
- UNIQUE `referral_status_code_key` on ("code")
- UNIQUE `referral_status_pkey` on ("id")
- UNIQUE `uq_referral_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `withdrawal_outcome`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "withdrawal_outcome_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "withdrawal_outcome_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_withdrawal_outcome_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "withdrawal_outcome_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "withdrawal_outcome_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_withdrawal_outcome_6" UNIQUE`

**Indexes in source dump**

- `idx_withdrawal_outcome_created_by` on ("created_by")
- `idx_withdrawal_outcome_reference_code_id` on ("reference_code_id")
- `idx_withdrawal_outcome_updated_by` on ("updated_by")
- UNIQUE `uq_withdrawal_outcome_6` on ("reference_code_id")
- UNIQUE `withdrawal_outcome_code_key` on ("code")
- UNIQUE `withdrawal_outcome_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `stage_decision`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "stage_decision_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "stage_decision_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_stage_decision_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "stage_decision_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "stage_decision_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_stage_decision_6" UNIQUE`

**Indexes in source dump**

- `idx_stage_decision_created_by` on ("created_by")
- `idx_stage_decision_reference_code_id` on ("reference_code_id")
- `idx_stage_decision_updated_by` on ("updated_by")
- UNIQUE `stage_decision_code_key` on ("code")
- UNIQUE `stage_decision_pkey` on ("id")
- UNIQUE `uq_stage_decision_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `eligibility_decision`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "eligibility_decision_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "eligibility_decision_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_eligibility_decision_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "eligibility_decision_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "eligibility_decision_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_eligibility_decision_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `eligibility_decision_code_key` on ("code")
- UNIQUE `eligibility_decision_pkey` on ("id")
- `idx_eligibility_decision_created_by` on ("created_by")
- `idx_eligibility_decision_reference_code_id` on ("reference_code_id")
- `idx_eligibility_decision_updated_by` on ("updated_by")
- UNIQUE `uq_eligibility_decision_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `score_scale`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "score_scale_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "score_scale_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_score_scale_6" UNIQUE` |
| `maximum_score` | `numeric(7, 3) DEFAULT '100' NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "score_scale_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_score_scale_8" UNIQUE("id","maximum_score")`
- `CONSTRAINT "score_scale_maximum_score_check" CHECK ((maximum_score > (0)::numeric))`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "score_scale_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_score_scale_6" UNIQUE`

**Indexes in source dump**

- `idx_score_scale_created_by` on ("created_by")
- `idx_score_scale_reference_code_id` on ("reference_code_id")
- `idx_score_scale_updated_by` on ("updated_by")
- UNIQUE `score_scale_code_key` on ("code")
- UNIQUE `score_scale_pkey` on ("id")
- UNIQUE `uq_score_scale_6` on ("reference_code_id")
- UNIQUE `uq_score_scale_8` on ("id","maximum_score")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `salary_period`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "salary_period_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "salary_period_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_salary_period_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "salary_period_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "salary_period_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_salary_period_6" UNIQUE`

**Indexes in source dump**

- `idx_salary_period_created_by` on ("created_by")
- `idx_salary_period_reference_code_id` on ("reference_code_id")
- `idx_salary_period_updated_by` on ("updated_by")
- UNIQUE `salary_period_code_key` on ("code")
- UNIQUE `salary_period_pkey` on ("id")
- UNIQUE `uq_salary_period_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `work_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "work_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "work_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_work_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "work_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "work_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_work_type_6" UNIQUE`

**Indexes in source dump**

- `idx_work_type_created_by` on ("created_by")
- `idx_work_type_reference_code_id` on ("reference_code_id")
- `idx_work_type_updated_by` on ("updated_by")
- UNIQUE `uq_work_type_6` on ("reference_code_id")
- UNIQUE `work_type_code_key` on ("code")
- UNIQUE `work_type_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `currency`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "currency_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `char(3) NOT NULL CONSTRAINT "currency_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `minor_unit` | `smallint DEFAULT 2 NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "currency_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "currency_code_check" CHECK ((code ~ '^[A-Z]{3}$'::text))`
- `CONSTRAINT "currency_minor_unit_check" CHECK (((minor_unit >= 0) AND (minor_unit <= 4)))`
- Inline: `"code" char(3) NOT NULL CONSTRAINT "currency_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `currency_code_key` on ("code")
- UNIQUE `currency_pkey` on ("id")
- `idx_currency_created_by` on ("created_by")
- `idx_currency_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `country`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "country_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `char(2) NOT NULL CONSTRAINT "country_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `phone_calling_code` | `varchar(8)` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "country_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "country_code_check" CHECK ((code ~ '^[A-Z]{2}$'::text))`
- Inline: `"code" char(2) NOT NULL CONSTRAINT "country_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `country_code_key` on ("code")
- UNIQUE `country_pkey` on ("id")
- `idx_country_created_by` on ("created_by")
- `idx_country_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `state`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "state_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(20)` |
| `display_name` | `varchar(150) NOT NULL` |
| `country_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "state_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_state_4" UNIQUE("country_id","code")`
- `CONSTRAINT "uq_state_5" UNIQUE("country_id","display_name")`

**Indexes in source dump**

- `idx_state_country_id` on ("country_id")
- `idx_state_created_by` on ("created_by")
- `idx_state_updated_by` on ("updated_by")
- UNIQUE `state_pkey` on ("id")
- UNIQUE `uq_state_4` on ("country_id","code")
- UNIQUE `uq_state_5` on ("country_id","display_name")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `city`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "city_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `display_name` | `varchar(150) NOT NULL` |
| `state_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "city_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_city_3" UNIQUE("state_id","display_name")`

**Indexes in source dump**

- UNIQUE `city_pkey` on ("id")
- `idx_city_created_by` on ("created_by")
- `idx_city_state_id` on ("state_id")
- `idx_city_updated_by` on ("updated_by")
- UNIQUE `uq_city_3` on ("state_id","display_name")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `language`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "language_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(35) NOT NULL CONSTRAINT "language_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "language_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(35) NOT NULL CONSTRAINT "language_code_key" UNIQUE`

**Indexes in source dump**

- `idx_language_created_by` on ("created_by")
- `idx_language_updated_by` on ("updated_by")
- UNIQUE `language_code_key` on ("code")
- UNIQUE `language_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `qualification`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "qualification_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "qualification_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "qualification_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "qualification_code_key" UNIQUE`

**Indexes in source dump**

- `idx_qualification_created_by` on ("created_by")
- `idx_qualification_updated_by` on ("updated_by")
- UNIQUE `qualification_code_key` on ("code")
- UNIQUE `qualification_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `skill`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "skill_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "skill_code_key" UNIQUE`

**Indexes in source dump**

- `idx_skill_created_by` on ("created_by")
- `idx_skill_updated_by` on ("updated_by")
- UNIQUE `skill_code_key` on ("code")
- UNIQUE `skill_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `subject`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "subject_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "subject_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "subject_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "subject_code_key" UNIQUE`

**Indexes in source dump**

- `idx_subject_created_by` on ("created_by")
- `idx_subject_updated_by` on ("updated_by")
- UNIQUE `subject_code_key` on ("code")
- UNIQUE `subject_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `social_platform`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "social_platform_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "social_platform_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_social_platform_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "social_platform_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "social_platform_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_social_platform_6" UNIQUE`

**Indexes in source dump**

- `idx_social_platform_created_by` on ("created_by")
- `idx_social_platform_reference_code_id` on ("reference_code_id")
- `idx_social_platform_updated_by` on ("updated_by")
- UNIQUE `social_platform_code_key` on ("code")
- UNIQUE `social_platform_pkey` on ("id")
- UNIQUE `uq_social_platform_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `accomplishment_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "accomplishment_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "accomplishment_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_accomplishment_type_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "accomplishment_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "accomplishment_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_accomplishment_type_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `accomplishment_type_code_key` on ("code")
- UNIQUE `accomplishment_type_pkey` on ("id")
- `idx_accomplishment_type_created_by` on ("created_by")
- `idx_accomplishment_type_reference_code_id` on ("reference_code_id")
- `idx_accomplishment_type_updated_by` on ("updated_by")
- UNIQUE `uq_accomplishment_type_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `course_enrolment_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "course_enrolment_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "course_enrolment_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "uq_course_enrolment_status_6" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "course_enrolment_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "course_enrolment_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "uq_course_enrolment_status_6" UNIQUE`

**Indexes in source dump**

- UNIQUE `course_enrolment_status_code_key` on ("code")
- UNIQUE `course_enrolment_status_pkey` on ("id")
- `idx_course_enrolment_status_created_by` on ("created_by")
- `idx_course_enrolment_status_reference_code_id` on ("reference_code_id")
- `idx_course_enrolment_status_updated_by` on ("updated_by")
- UNIQUE `uq_course_enrolment_status_6` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

## 5. Organisation and Account — Phase 2 — Member B

**Entities in this module:** 29 source tables listed (including shared entities).

### `organisation`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `name` | `varchar(150) NOT NULL` |
| `website_url` | `varchar(2048)` |
| `city_id` | `bigint` |
| `industry_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |
| `account_profile_id` | `bigint NOT NULL` |
| `parent_organisation_id` | `bigint` |
| `organisation_type_id` | `bigint NOT NULL` |
| `verification_status_id` | `bigint NOT NULL` |
| `verified_at` | `timestamp with time zone` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `description` | `text` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_id_account_profile_id_key" UNIQUE("id","account_profile_id")`
- `CONSTRAINT "organisation_check" CHECK (((parent_organisation_id IS NULL) OR (parent_organisation_id <> id)))`

**Indexes in source dump**

- `idx_organisation_account_profile_id` on ("account_profile_id")
- `idx_organisation_city_id` on ("city_id")
- `idx_organisation_created_by` on ("created_by")
- `idx_organisation_industry_id` on ("industry_id")
- `idx_organisation_parent_organisation_id` on ("parent_organisation_id")
- `idx_organisation_updated_by` on ("updated_by")
- UNIQUE `organisation_id_account_profile_id_key` on ("id","account_profile_id")
- UNIQUE `organisation_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `organisation.account_profile`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `account_name` | `varchar(150) NOT NULL` |
| `account_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `account_profile_pkey` on ("id")
- `idx_account_profile_account_status_id` on ("account_status_id")
- `idx_account_profile_created_by` on ("created_by")
- `idx_account_profile_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.account_administrator`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_administrator_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `valid_from` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `account_profile_id` | `bigint NOT NULL` |
| `user_account_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_administrator_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "account_administrator_check" CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))`

**Indexes in source dump**

- UNIQUE `account_administrator_pkey` on ("id")
- `ex_account_admin_no_overlap` on ("account_profile_id","user_account_id","tstzrange(valid_from, valid_to, '[)'::text)")
- `idx_account_administrator_account_profile_id` on ("account_profile_id")
- `idx_account_administrator_created_by` on ("created_by")
- `idx_account_administrator_updated_by` on ("updated_by")
- `idx_account_administrator_user_account_id` on ("user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.account_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "account_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "account_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."account_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "account_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "account_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `account_status_code_key` on ("code")
- UNIQUE `account_status_pkey` on ("id")
- UNIQUE `account_status_reference_code_id_key` on ("reference_code_id")
- `idx_account_status_created_by` on ("created_by")
- `idx_account_status_reference_code_id` on ("reference_code_id")
- `idx_account_status_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.identifier_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."identifier_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "identifier_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "identifier_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."identifier_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "identifier_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "identifier_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `identifier_type_code_key` on ("code")
- UNIQUE `identifier_type_pkey` on ("id")
- UNIQUE `identifier_type_reference_code_id_key` on ("reference_code_id")
- `idx_identifier_type_created_by` on ("created_by")
- `idx_identifier_type_reference_code_id` on ("reference_code_id")
- `idx_identifier_type_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.organisation_identifier`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_identifier_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `identifier_ciphertext` | `bytea NOT NULL` |
| `identifier_fingerprint` | `char(64) NOT NULL` |
| `verified_at` | `timestamp with time zone` |
| `organisation_id` | `bigint NOT NULL` |
| `country_id` | `bigint NOT NULL` |
| `identifier_type_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_identifier_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_identifier_country_id_identifier_type_id_ident_key" UNIQUE("country_id","identifier_type_id","identifier_fingerprint")`
- `CONSTRAINT "organisation_identifier_identifier_fingerprint_check" CHECK ((identifier_fingerprint ~ '^[a-f0-9]{64}$'::text))`

**Indexes in source dump**

- `idx_organisation_identifier_country_id` on ("country_id")
- `idx_organisation_identifier_created_by` on ("created_by")
- `idx_organisation_identifier_identifier_type_id` on ("identifier_type_id")
- `idx_organisation_identifier_organisation_id` on ("organisation_id")
- `idx_organisation_identifier_updated_by` on ("updated_by")
- UNIQUE `organisation_identifier_country_id_identifier_type_id_ident_key` on ("country_id","identifier_type_id","identifier_fingerprint")
- UNIQUE `organisation_identifier_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.organisation_location`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_location_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `location_name` | `varchar(150)` |
| `address_line_1` | `varchar(250) NOT NULL` |
| `address_line_2` | `varchar(250)` |
| `postal_code` | `varchar(30)` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `organisation_id` | `bigint NOT NULL` |
| `city_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_location_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_organisation_location_city_id` on ("city_id")
- `idx_organisation_location_created_by` on ("created_by")
- `idx_organisation_location_organisation_id` on ("organisation_id")
- `idx_organisation_location_updated_by` on ("updated_by")
- UNIQUE `organisation_location_pkey` on ("id")
- UNIQUE `uq_organisation_primary_location` on ("organisation_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.organisation_member`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_member_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `valid_from` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `organisation_id` | `bigint NOT NULL` |
| `user_account_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_member_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_member_check" CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))`

**Indexes in source dump**

- `ex_organisation_member_no_overlap` on ("organisation_id","user_account_id","tstzrange(valid_from, valid_to, '[)'::text)")
- `idx_organisation_member_created_by` on ("created_by")
- `idx_organisation_member_organisation_id` on ("organisation_id")
- `idx_organisation_member_updated_by` on ("updated_by")
- `idx_organisation_member_user_account_id` on ("user_account_id")
- UNIQUE `organisation_member_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.organisation_recruiter`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_recruiter_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `valid_from` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `organisation_id` | `bigint NOT NULL` |
| `recruiter_user_account_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_recruiter_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_recruiter_id_organisation_id_recruiter_user_ac_key" UNIQUE("id","organisation_id","recruiter_user_account_id")`
- `CONSTRAINT "organisation_recruiter_check" CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))`

**Indexes in source dump**

- `ex_recruiter_company_no_overlap` on ("recruiter_user_account_id","tstzrange(valid_from, valid_to, '[)'::text)")
- `idx_organisation_recruiter_created_by` on ("created_by")
- `idx_organisation_recruiter_organisation_id` on ("organisation_id")
- `idx_organisation_recruiter_recruiter_user_account_id` on ("recruiter_user_account_id")
- `idx_organisation_recruiter_updated_by` on ("updated_by")
- UNIQUE `organisation_recruiter_id_organisation_id_recruiter_user_ac_key` on ("id","organisation_id","recruiter_user_account_id")
- UNIQUE `organisation_recruiter_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.organisation_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "organisation_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "organisation_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."organisation_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "organisation_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "organisation_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_organisation_type_created_by` on ("created_by")
- `idx_organisation_type_reference_code_id` on ("reference_code_id")
- `idx_organisation_type_updated_by` on ("updated_by")
- UNIQUE `organisation_type_code_key` on ("code")
- UNIQUE `organisation_type_pkey` on ("id")
- UNIQUE `organisation_type_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.verification_record`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."verification_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `provider_code` | `varchar(80) NOT NULL` |
| `provider_reference` | `varchar(200)` |
| `checked_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `verified_at` | `timestamp with time zone` |
| `failure_code` | `varchar(80)` |
| `organisation_id` | `bigint NOT NULL` |
| `verification_type_id` | `bigint NOT NULL` |
| `verification_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."verification_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "verification_record_provider_code_provider_reference_key" UNIQUE("provider_code","provider_reference")`

**Indexes in source dump**

- `idx_verification_record_created_by` on ("created_by")
- `idx_verification_record_organisation_id` on ("organisation_id")
- `idx_verification_record_updated_by` on ("updated_by")
- `idx_verification_record_verification_status_id` on ("verification_status_id")
- `idx_verification_record_verification_type_id` on ("verification_type_id")
- UNIQUE `verification_record_pkey` on ("id")
- UNIQUE `verification_record_provider_code_provider_reference_key` on ("provider_code","provider_reference")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.verification_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."verification_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "verification_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "verification_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."verification_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "verification_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "verification_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_verification_type_created_by` on ("created_by")
- `idx_verification_type_reference_code_id` on ("reference_code_id")
- `idx_verification_type_updated_by` on ("updated_by")
- UNIQUE `verification_type_code_key` on ("code")
- UNIQUE `verification_type_pkey` on ("id")
- UNIQUE `verification_type_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `account_profile`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `account_code` | `varchar(60) NOT NULL CONSTRAINT "account_profile_account_code_key" UNIQUE` |
| `account_name` | `varchar(200) NOT NULL` |
| `account_type` | `varchar(40) NOT NULL` |
| `account_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `primary_organisation_id` | `bigint` |
| `billing_email` | `varchar(254)` |
| `preferred_language_code` | `varchar(10) DEFAULT 'en' NOT NULL` |
| `timezone_name` | `varchar(60)` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"account_code" varchar(60) NOT NULL CONSTRAINT "account_profile_account_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `account_profile_account_code_key` on ("account_code")
- UNIQUE `account_profile_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `account_organisation`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_organisation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `account_profile_id` | `bigint NOT NULL` |
| `organisation_id` | `bigint NOT NULL` |
| `relationship_type` | `varchar(40) DEFAULT 'PRIMARY' NOT NULL` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `valid_from` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `valid_until` | `timestamp with time zone` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "account_organisation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "account_organisation_account_profile_id_organisation_id_rel_key" UNIQUE("account_profile_id","organisation_id","relationship_type")`
- `CONSTRAINT "account_organisation_check" CHECK (((valid_until IS NULL) OR (valid_until > valid_from)))`

**Indexes in source dump**

- UNIQUE `account_organisation_account_profile_id_organisation_id_rel_key` on ("account_profile_id","organisation_id","relationship_type")
- UNIQUE `account_organisation_pkey` on ("id")
- UNIQUE `uq_account_primary_organisation` on ("account_profile_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `account_role` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_account`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_account_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `full_name` | `varchar(150) NOT NULL` |
| `email` | `varchar(254) NOT NULL CONSTRAINT "user_account_email_key" UNIQUE` |
| `neon_auth_user_id` | `uuid CONSTRAINT "user_account_neon_auth_user_id_key" UNIQUE` |
| `language_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |
| `account_status_id` | `bigint DEFAULT identity.default_active_account_status_id() NOT NULL` |
| `email_verified_at` | `timestamp with time zone` |
| `last_login_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_account_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_account_email_check" CHECK ((((email)::text = lower((email)::text)) AND ((email)::text ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'::text)))`
- Inline: `"email" varchar(254) NOT NULL CONSTRAINT "user_account_email_key" UNIQUE`
- Inline: `"neon_auth_user_id" uuid CONSTRAINT "user_account_neon_auth_user_id_key" UNIQUE`

**Indexes in source dump**

- `idx_user_account_account_status_id` on ("account_status_id")
- `idx_user_account_created_by` on ("created_by")
- `idx_user_account_language_id` on ("language_id")
- `idx_user_account_updated_by` on ("updated_by")
- UNIQUE `user_account_email_key` on ("email")
- UNIQUE `user_account_neon_auth_user_id_key` on ("neon_auth_user_id")
- UNIQUE `user_account_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `user_role`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `account_role_id` | `bigint NOT NULL` |
| `scope_type` | `varchar(30) DEFAULT 'GLOBAL' NOT NULL` |
| `scope_organisation_id` | `bigint` |
| `valid_from` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `valid_until` | `timestamp with time zone` |
| `assigned_by` | `bigint` |
| `assignment_reason` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_role_check" CHECK (((valid_until IS NULL) OR (valid_until > valid_from)))`

**Indexes in source dump**

- `idx_user_role_user_active` on ("user_account_id","valid_until")
- UNIQUE `user_role_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_account_admin`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_account_admin_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `user_account_id` | `bigint NOT NULL` |
| `admin_type` | `varchar(40) DEFAULT 'ACCOUNT_ADMIN' NOT NULL` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `valid_from` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `valid_until` | `timestamp with time zone` |
| `appointed_by` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_account_admin_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_account_admin_organisation_id_user_account_id__key" UNIQUE("organisation_id","user_account_id","admin_type")`
- `CONSTRAINT "organisation_account_admin_check" CHECK (((valid_until IS NULL) OR (valid_until > valid_from)))`

**Indexes in source dump**

- UNIQUE `organisation_account_admin_organisation_id_user_account_id__key` on ("organisation_id","user_account_id","admin_type")
- UNIQUE `organisation_account_admin_pkey` on ("id")
- UNIQUE `uq_organisation_primary_admin` on ("organisation_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_external_system`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_external_system_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `system_code` | `varchar(60) NOT NULL` |
| `external_organisation_reference` | `varchar(200) NOT NULL` |
| `sync_direction` | `varchar(20) DEFAULT 'INBOUND' NOT NULL` |
| `last_synced_at` | `timestamp with time zone` |
| `sync_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `last_error` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_external_system_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_external_system_system_code_external_organisat_key" UNIQUE("system_code","external_organisation_reference")`

**Indexes in source dump**

- UNIQUE `organisation_external_system_pkey` on ("id")
- UNIQUE `organisation_external_system_system_code_external_organisat_key` on ("system_code","external_organisation_reference")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_hierarchy`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_hierarchy_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `parent_organisation_id` | `bigint NOT NULL` |
| `child_organisation_id` | `bigint NOT NULL` |
| `relationship_type` | `varchar(40) DEFAULT 'SUBSIDIARY' NOT NULL` |
| `valid_from` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `valid_until` | `timestamp with time zone` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_hierarchy_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_hierarchy_parent_organisation_id_child_organis_key" UNIQUE("parent_organisation_id","child_organisation_id","relationship_type")`
- `CONSTRAINT "organisation_hierarchy_check" CHECK ((parent_organisation_id <> child_organisation_id))`
- `CONSTRAINT "organisation_hierarchy_check1" CHECK (((valid_until IS NULL) OR (valid_until > valid_from)))`

**Indexes in source dump**

- UNIQUE `organisation_hierarchy_parent_organisation_id_child_organis_key` on ("parent_organisation_id","child_organisation_id","relationship_type")
- UNIQUE `organisation_hierarchy_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_identifier`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_identifier_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `country_id` | `bigint NOT NULL` |
| `identifier_type` | `varchar(50) NOT NULL` |
| `identifier_value_encrypted` | `text NOT NULL` |
| `identifier_fingerprint` | `varchar(128) NOT NULL` |
| `issued_by` | `varchar(150)` |
| `valid_from` | `date` |
| `valid_until` | `date` |
| `verification_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_identifier_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_identifier_country_id_identifier_type_identifi_key" UNIQUE("country_id","identifier_type","identifier_fingerprint")`
- `CONSTRAINT "organisation_identifier_check" CHECK (((valid_until IS NULL) OR (valid_from IS NULL) OR (valid_until >= valid_from)))`

**Indexes in source dump**

- UNIQUE `organisation_identifier_country_id_identifier_type_identifi_key` on ("country_id","identifier_type","identifier_fingerprint")
- UNIQUE `organisation_identifier_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_location`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_location_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `location_name` | `varchar(150)` |
| `location_type` | `varchar(40) NOT NULL` |
| `address_line_1` | `varchar(255)` |
| `address_line_2` | `varchar(255)` |
| `city_id` | `bigint` |
| `state_id` | `bigint` |
| `country_id` | `bigint` |
| `postal_code` | `varchar(20)` |
| `latitude` | `numeric(9, 6)` |
| `longitude` | `numeric(9, 6)` |
| `is_headquarters` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_location_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_location_latitude_check" CHECK (((latitude IS NULL) OR ((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))))`
- `CONSTRAINT "organisation_location_longitude_check" CHECK (((longitude IS NULL) OR ((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))))`

**Indexes in source dump**

- UNIQUE `organisation_location_pkey` on ("id")
- UNIQUE `uq_organisation_hq` on ("organisation_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_recruiter`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_recruiter_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `recruiter_user_account_id` | `bigint NOT NULL` |
| `recruiter_type` | `varchar(40) DEFAULT 'INTERNAL' NOT NULL` |
| `mapping_status` | `varchar(30) DEFAULT 'ACTIVE' NOT NULL` |
| `valid_from` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `valid_until` | `timestamp with time zone` |
| `mapped_by` | `bigint` |
| `mapping_reason` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_recruiter_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "organisation_recruiter_check" CHECK (((valid_until IS NULL) OR (valid_until > valid_from)))`

**Indexes in source dump**

- UNIQUE `organisation_recruiter_pkey` on ("id")
- UNIQUE `uq_organisation_recruiter_active` on ("organisation_id","recruiter_user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_status_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `previous_status` | `varchar(30)` |
| `new_status` | `varchar(30) NOT NULL` |
| `changed_by` | `bigint` |
| `reason` | `text` |
| `changed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `organisation_status_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_verification`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_verification_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_id` | `bigint NOT NULL` |
| `verification_type` | `varchar(50) NOT NULL` |
| `provider_name` | `varchar(100)` |
| `provider_reference` | `varchar(200)` |
| `outcome` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `verification_token_reference` | `text` |
| `requested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `completed_at` | `timestamp with time zone` |
| `expires_at` | `timestamp with time zone` |
| `reviewed_by` | `bigint` |
| `review_notes` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_verification_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `organisation_verification_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_verification_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_verification_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `organisation_verification_id` | `bigint NOT NULL` |
| `previous_outcome` | `varchar(30)` |
| `new_outcome` | `varchar(30) NOT NULL` |
| `changed_by` | `bigint` |
| `change_reason` | `text` |
| `changed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation_verification_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `organisation_verification_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `user_block`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_block_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `blocker_user_account_id` | `bigint NOT NULL` |
| `blocked_user_account_id` | `bigint` |
| `blocked_organisation_id` | `bigint` |
| `block_reason` | `varchar(60)` |
| `notes` | `text` |
| `blocked_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `unblocked_at` | `timestamp with time zone` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_block_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_block_check" CHECK ((blocker_user_account_id <> blocked_user_account_id))`
- `CONSTRAINT "user_block_check1" CHECK ((num_nonnulls(blocked_user_account_id, blocked_organisation_id) = 1))`

**Indexes in source dump**

- `idx_user_block_blocker_active` on ("blocker_user_account_id","blocked_at")
- UNIQUE `user_block_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.user_block`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_block_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `reason` | `varchar(500)` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `blocked_user_account_id` | `bigint` |
| `blocked_organisation_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_block_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_block_check" CHECK ((num_nonnulls(blocked_user_account_id, blocked_organisation_id) = 1))`

**Indexes in source dump**

- `idx_user_block_blocked_organisation_id` on ("blocked_organisation_id")
- `idx_user_block_blocked_user_account_id` on ("blocked_user_account_id")
- `idx_user_block_candidate_profile_id` on ("candidate_profile_id")
- `idx_user_block_created_by` on ("created_by")
- `idx_user_block_updated_by` on ("updated_by")
- UNIQUE `uq_identity_block_org` on ("candidate_profile_id","blocked_organisation_id")
- UNIQUE `uq_identity_block_user` on ("candidate_profile_id","blocked_user_account_id")
- UNIQUE `user_block_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation.job_recruiter_assignment`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."job_recruiter_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `valid_from` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `job_requirement_id` | `bigint NOT NULL` |
| `organisation_id` | `bigint NOT NULL` |
| `recruiter_user_account_id` | `bigint NOT NULL` |
| `organisation_recruiter_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "organisation"."job_recruiter_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "job_recruiter_assignment_check" CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))`

**Indexes in source dump**

- `ex_job_recruiter_assignment_no_overlap` on ("job_requirement_id","recruiter_user_account_id","tstzrange(valid_from, valid_to, '[)'::text)")
- `idx_job_recruiter_assignment_created_by` on ("created_by")
- `idx_job_recruiter_assignment_job_requirement_id` on ("job_requirement_id")
- `idx_job_recruiter_assignment_organisation_id` on ("organisation_id")
- `idx_job_recruiter_assignment_organisation_recruiter_id` on ("organisation_recruiter_id")
- `idx_job_recruiter_assignment_recruiter_user_account_id` on ("recruiter_user_account_id")
- `idx_job_recruiter_assignment_updated_by` on ("updated_by")
- UNIQUE `job_recruiter_assignment_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

## 6. Gig Marketplace — Phase 2 — Member C

**Entities in this module:** 32 source tables listed (including shared entities).

### `gig_application`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_application_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_request_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `application_status` | `varchar(30) DEFAULT 'SUBMITTED' NOT NULL` |
| `proposed_price` | `numeric(14, 2)` |
| `currency_code` | `char(3) NOT NULL` |
| `proposed_rate` | `numeric(14, 2)` |
| `proposed_hours` | `numeric(8, 2)` |
| `availability_note` | `text` |
| `cover_note` | `text` |
| `applied_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `decided_at` | `timestamp with time zone` |
| `decided_by` | `bigint` |
| `decision_reason` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_application_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_application_gig_request_id_gig_worker_profile_id_key" UNIQUE("gig_request_id","gig_worker_profile_id")`
- `CONSTRAINT "gig_application_proposed_hours_check" CHECK (((proposed_hours IS NULL) OR (proposed_hours > (0)::numeric)))`
- `CONSTRAINT "gig_application_proposed_price_check" CHECK (((proposed_price IS NULL) OR (proposed_price >= (0)::numeric)))`
- `CONSTRAINT "gig_application_proposed_rate_check" CHECK (((proposed_rate IS NULL) OR (proposed_rate >= (0)::numeric)))`

**Indexes in source dump**

- UNIQUE `gig_application_gig_request_id_gig_worker_profile_id_key` on ("gig_request_id","gig_worker_profile_id")
- UNIQUE `gig_application_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_application_status_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_application_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_application_id` | `bigint NOT NULL` |
| `previous_status` | `varchar(30)` |
| `new_status` | `varchar(30) NOT NULL` |
| `changed_by` | `bigint` |
| `reason` | `text` |
| `changed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_application_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `gig_application_status_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_assignment`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_application_id` | `bigint NOT NULL CONSTRAINT "gig_assignment_gig_application_id_key" UNIQUE` |
| `gig_request_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `assignment_status` | `varchar(30) DEFAULT 'ACCEPTED' NOT NULL` |
| `scheduled_start_at` | `timestamp with time zone NOT NULL` |
| `scheduled_end_at` | `timestamp with time zone NOT NULL` |
| `agreed_amount` | `numeric(14, 2) NOT NULL` |
| `currency_code` | `char(3) NOT NULL` |
| `agreed_rate` | `numeric(14, 2)` |
| `rate_period` | `varchar(20)` |
| `accepted_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `cancelled_at` | `timestamp with time zone` |
| `cancellation_reason` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_assignment_agreed_amount_check" CHECK ((agreed_amount >= (0)::numeric))`
- `CONSTRAINT "gig_assignment_agreed_rate_check" CHECK (((agreed_rate IS NULL) OR (agreed_rate >= (0)::numeric)))`
- `CONSTRAINT "gig_assignment_check" CHECK ((scheduled_end_at > scheduled_start_at))`
- Inline: `"gig_application_id" bigint NOT NULL CONSTRAINT "gig_assignment_gig_application_id_key" UNIQUE`

**Indexes in source dump**

- `ex_gig_assignment_worker_overlap` on ("gig_worker_profile_id","tstzrange(scheduled_start_at, scheduled_end_at, '[)'::text)")
- UNIQUE `gig_assignment_gig_application_id_key` on ("gig_application_id")
- UNIQUE `gig_assignment_pkey` on ("id")
- `idx_gig_assignment_worker_window` on ("gig_worker_profile_id","scheduled_start_at","scheduled_end_at")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_earnings_reconciliation`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_earnings_reconciliation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_assignment_id` | `bigint NOT NULL` |
| `external_system_code` | `varchar(60) NOT NULL` |
| `external_earnings_reference` | `varchar(200) NOT NULL` |
| `earnings_type` | `varchar(30) NOT NULL` |
| `estimated_amount` | `numeric(14, 2)` |
| `actual_amount` | `numeric(14, 2)` |
| `projected_amount` | `numeric(14, 2)` |
| `currency_code` | `char(3) NOT NULL` |
| `source_updated_at` | `timestamp with time zone` |
| `reconciled_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `reconciliation_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `source_payload` | `jsonb` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_earnings_reconciliation_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_earnings_reconciliation_external_system_code_external_e_key" UNIQUE("external_system_code","external_earnings_reference")`
- `CONSTRAINT "gig_earnings_reconciliation_actual_amount_check" CHECK (((actual_amount IS NULL) OR (actual_amount >= (0)::numeric)))`
- `CONSTRAINT "gig_earnings_reconciliation_estimated_amount_check" CHECK (((estimated_amount IS NULL) OR (estimated_amount >= (0)::numeric)))`
- `CONSTRAINT "gig_earnings_reconciliation_projected_amount_check" CHECK (((projected_amount IS NULL) OR (projected_amount >= (0)::numeric)))`

**Indexes in source dump**

- UNIQUE `gig_earnings_reconciliation_external_system_code_external_e_key` on ("external_system_code","external_earnings_reference")
- UNIQUE `gig_earnings_reconciliation_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_event`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_request_id` | `bigint` |
| `gig_application_id` | `bigint` |
| `gig_assignment_id` | `bigint` |
| `actor_user_account_id` | `bigint` |
| `event_type` | `varchar(60) NOT NULL` |
| `event_payload` | `jsonb DEFAULT '{}' NOT NULL` |
| `occurred_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `correlation_id` | `uuid` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_event_check" CHECK ((num_nonnulls(gig_request_id, gig_application_id, gig_assignment_id) >= 1))`

**Indexes in source dump**

- UNIQUE `gig_event_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_fulfilment_handoff`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_fulfilment_handoff_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_assignment_id` | `bigint NOT NULL` |
| `external_system_code` | `varchar(60) NOT NULL` |
| `external_handoff_reference` | `varchar(200) NOT NULL` |
| `handoff_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `sent_at` | `timestamp with time zone` |
| `acknowledged_at` | `timestamp with time zone` |
| `last_reconciled_at` | `timestamp with time zone` |
| `external_status` | `varchar(60)` |
| `last_error` | `text` |
| `idempotency_key` | `varchar(150) NOT NULL CONSTRAINT "gig_fulfilment_handoff_idempotency_key_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_fulfilment_handoff_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_fulfilment_handoff_external_system_code_external_handof_key" UNIQUE("external_system_code","external_handoff_reference")`
- Inline: `"idempotency_key" varchar(150) NOT NULL CONSTRAINT "gig_fulfilment_handoff_idempotency_key_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_fulfilment_handoff_external_system_code_external_handof_key` on ("external_system_code","external_handoff_reference")
- UNIQUE `gig_fulfilment_handoff_idempotency_key_key` on ("idempotency_key")
- UNIQUE `gig_fulfilment_handoff_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_rating`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_rating_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_assignment_id` | `bigint NOT NULL CONSTRAINT "gig_rating_gig_assignment_id_key" UNIQUE` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `overall_rating` | `numeric(2, 1) NOT NULL` |
| `quality_rating` | `numeric(2, 1)` |
| `communication_rating` | `numeric(2, 1)` |
| `punctuality_rating` | `numeric(2, 1)` |
| `review_text` | `text` |
| `visibility` | `varchar(20) DEFAULT 'PUBLIC' NOT NULL` |
| `rated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_rating_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_rating_communication_rating_check" CHECK (((communication_rating >= (1)::numeric) AND (communication_rating <= (5)::numeric)))`
- `CONSTRAINT "gig_rating_overall_rating_check" CHECK (((overall_rating >= (1)::numeric) AND (overall_rating <= (5)::numeric)))`
- `CONSTRAINT "gig_rating_punctuality_rating_check" CHECK (((punctuality_rating >= (1)::numeric) AND (punctuality_rating <= (5)::numeric)))`
- `CONSTRAINT "gig_rating_quality_rating_check" CHECK (((quality_rating >= (1)::numeric) AND (quality_rating <= (5)::numeric)))`
- Inline: `"gig_assignment_id" bigint NOT NULL CONSTRAINT "gig_rating_gig_assignment_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_rating_gig_assignment_id_key` on ("gig_assignment_id")
- UNIQUE `gig_rating_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_request`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_request_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_code` | `varchar(60) NOT NULL CONSTRAINT "gig_request_gig_code_key" UNIQUE` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `requester_organisation_id` | `bigint` |
| `gig_title` | `varchar(200) NOT NULL` |
| `gig_description` | `text NOT NULL` |
| `service_category` | `varchar(100)` |
| `gig_status` | `varchar(30) DEFAULT 'DRAFT' NOT NULL` |
| `pricing_model` | `varchar(20) NOT NULL` |
| `price_amount` | `numeric(14, 2)` |
| `rate_amount` | `numeric(14, 2)` |
| `currency_code` | `char(3) NOT NULL` |
| `rate_period` | `varchar(20)` |
| `expected_hours` | `numeric(8, 2)` |
| `start_window` | `timestamp with time zone NOT NULL` |
| `end_window` | `timestamp with time zone NOT NULL` |
| `location_type` | `varchar(30) DEFAULT 'REMOTE' NOT NULL` |
| `city_id` | `bigint` |
| `country_id` | `bigint` |
| `is_consultant_open` | `boolean DEFAULT false NOT NULL` |
| `application_deadline` | `timestamp with time zone` |
| `external_fulfilment_required` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_request_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_request_check" CHECK ((end_window > start_window))`
- `CONSTRAINT "gig_request_expected_hours_check" CHECK (((expected_hours IS NULL) OR (expected_hours > (0)::numeric)))`
- `CONSTRAINT "gig_request_price_amount_check" CHECK (((price_amount IS NULL) OR (price_amount >= (0)::numeric)))`
- `CONSTRAINT "gig_request_pricing_model_check" CHECK (((pricing_model)::text = ANY ((ARRAY['FIXED'::character varying, 'RATE'::character varying, 'NEGOTIABLE'::character varying])::text[])))`
- `CONSTRAINT "gig_request_rate_amount_check" CHECK (((rate_amount IS NULL) OR (rate_amount >= (0)::numeric)))`
- Inline: `"gig_code" varchar(60) NOT NULL CONSTRAINT "gig_request_gig_code_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_request_gig_code_key` on ("gig_code")
- UNIQUE `gig_request_pkey` on ("id")
- `idx_gig_request_status_window` on ("gig_status","start_window","end_window")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_request_skill`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_request_skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_request_id` | `bigint NOT NULL` |
| `skill_id` | `bigint NOT NULL` |
| `is_mandatory` | `boolean DEFAULT true NOT NULL` |
| `minimum_proficiency_code` | `varchar(30)` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_request_skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_request_skill_gig_request_id_skill_id_key" UNIQUE("gig_request_id","skill_id")`

**Indexes in source dump**

- UNIQUE `gig_request_skill_gig_request_id_skill_id_key` on ("gig_request_id","skill_id")
- UNIQUE `gig_request_skill_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_service`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_service_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `service_code` | `varchar(60)` |
| `service_title` | `varchar(180) NOT NULL` |
| `service_description` | `text` |
| `industry_id` | `bigint` |
| `base_rate` | `numeric(14, 2)` |
| `currency_code` | `char(3) NOT NULL` |
| `rate_period` | `varchar(20) DEFAULT 'HOUR' NOT NULL` |
| `minimum_engagement_hours` | `numeric(8, 2)` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_service_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_service_base_rate_check" CHECK (((base_rate IS NULL) OR (base_rate >= (0)::numeric)))`
- `CONSTRAINT "gig_service_minimum_engagement_hours_check" CHECK (((minimum_engagement_hours IS NULL) OR (minimum_engagement_hours > (0)::numeric)))`

**Indexes in source dump**

- UNIQUE `gig_service_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_service_skill`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_service_skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_service_id` | `bigint NOT NULL` |
| `skill_id` | `bigint NOT NULL` |
| `proficiency_level_code` | `varchar(30)` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_service_skill_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_service_skill_gig_service_id_skill_id_key" UNIQUE("gig_service_id","skill_id")`

**Indexes in source dump**

- UNIQUE `gig_service_skill_gig_service_id_skill_id_key` on ("gig_service_id","skill_id")
- UNIQUE `gig_service_skill_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_worker_availability`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_availability_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `available_from` | `timestamp with time zone NOT NULL` |
| `available_until` | `timestamp with time zone NOT NULL` |
| `availability_status` | `varchar(30) DEFAULT 'AVAILABLE' NOT NULL` |
| `recurrence_rule` | `text` |
| `timezone_name` | `varchar(60) NOT NULL` |
| `notes` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_availability_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_worker_availability_check" CHECK ((available_until > available_from))`

**Indexes in source dump**

- UNIQUE `gig_worker_availability_pkey` on ("id")
- `idx_gig_availability_worker_window` on ("gig_worker_profile_id","available_from","available_until")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_worker_list`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_list_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `requester_organisation_id` | `bigint` |
| `list_name` | `varchar(120) NOT NULL` |
| `list_type` | `varchar(20) NOT NULL` |
| `description` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_list_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_worker_list_list_type_check" CHECK (((list_type)::text = ANY ((ARRAY['FAVOURITE'::character varying, 'BLACKLIST'::character varying])::text[])))`

**Indexes in source dump**

- UNIQUE `gig_worker_list_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_worker_list_entry`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_list_entry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `gig_worker_list_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `reason` | `text` |
| `added_by` | `bigint` |
| `added_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `removed_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_list_entry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_worker_list_entry_gig_worker_list_id_gig_worker_profile_key" UNIQUE("gig_worker_list_id","gig_worker_profile_id")`

**Indexes in source dump**

- UNIQUE `gig_worker_list_entry_gig_worker_list_id_gig_worker_profile_key` on ("gig_worker_list_id","gig_worker_profile_id")
- UNIQUE `gig_worker_list_entry_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_worker_profile`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL CONSTRAINT "gig_worker_profile_user_account_id_key" UNIQUE` |
| `candidate_profile_id` | `bigint` |
| `worker_display_name` | `varchar(150) NOT NULL` |
| `worker_bio` | `text` |
| `worker_status` | `varchar(30) DEFAULT 'PENDING' NOT NULL` |
| `verification_status` | `varchar(30) DEFAULT 'UNVERIFIED' NOT NULL` |
| `home_city_id` | `bigint` |
| `home_country_id` | `bigint` |
| `timezone_name` | `varchar(60)` |
| `profile_visibility` | `varchar(30) DEFAULT 'PUBLIC' NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig_worker_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"user_account_id" bigint NOT NULL CONSTRAINT "gig_worker_profile_user_account_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_worker_profile_pkey` on ("id")
- UNIQUE `gig_worker_profile_user_account_id_key` on ("user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.application_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."application_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "application_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "application_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."application_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "application_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "application_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `application_status_code_key` on ("code")
- UNIQUE `application_status_pkey` on ("id")
- UNIQUE `application_status_reference_code_id_key` on ("reference_code_id")
- `idx_application_status_created_by` on ("created_by")
- `idx_application_status_reference_code_id` on ("reference_code_id")
- `idx_application_status_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.assignment_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."assignment_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "assignment_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "assignment_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."assignment_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "assignment_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "assignment_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `assignment_status_code_key` on ("code")
- UNIQUE `assignment_status_pkey` on ("id")
- UNIQUE `assignment_status_reference_code_id_key` on ("reference_code_id")
- `idx_assignment_status_created_by` on ("created_by")
- `idx_assignment_status_reference_code_id` on ("reference_code_id")
- `idx_assignment_status_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.availability_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."availability_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "availability_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "availability_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."availability_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "availability_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "availability_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `availability_status_code_key` on ("code")
- UNIQUE `availability_status_pkey` on ("id")
- UNIQUE `availability_status_reference_code_id_key` on ("reference_code_id")
- `idx_availability_status_created_by` on ("created_by")
- `idx_availability_status_reference_code_id` on ("reference_code_id")
- `idx_availability_status_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.fulfilment_event`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."fulfilment_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `external_system_code` | `varchar(80) NOT NULL` |
| `external_event_id` | `varchar(200) NOT NULL` |
| `event_kind` | `varchar(80) NOT NULL` |
| `observed_at` | `timestamp with time zone NOT NULL` |
| `received_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `payload_digest` | `char(64)` |
| `gig_assignment_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."fulfilment_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "fulfilment_event_external_system_code_external_event_id_key" UNIQUE("external_system_code","external_event_id")`
- `CONSTRAINT "fulfilment_event_payload_digest_check" CHECK ((payload_digest ~ '^[a-f0-9]{64}$'::text))`

**Indexes in source dump**

- UNIQUE `fulfilment_event_external_system_code_external_event_id_key` on ("external_system_code","external_event_id")
- UNIQUE `fulfilment_event_pkey` on ("id")
- `idx_fulfilment_event_created_by` on ("created_by")
- `idx_fulfilment_event_gig_assignment_id` on ("gig_assignment_id")
- `idx_fulfilment_event_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.gig_application`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_application_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `proposed_amount` | `numeric(18, 2)` |
| `submitted_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `decided_at` | `timestamp with time zone` |
| `gig_request_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `application_status_id` | `bigint NOT NULL` |
| `proposed_currency_id` | `bigint` |
| `decision_by_user_account_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_application_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_application_gig_request_id_gig_worker_profile_id_key" UNIQUE("gig_request_id","gig_worker_profile_id")`
- `CONSTRAINT "gig_application_id_gig_request_id_gig_worker_profile_id_key" UNIQUE("id","gig_request_id","gig_worker_profile_id")`
- `CONSTRAINT "gig_application_check" CHECK (((proposed_amount IS NULL) = (proposed_currency_id IS NULL)))`
- `CONSTRAINT "gig_application_check1" CHECK (((decided_at IS NULL) = (decision_by_user_account_id IS NULL)))`
- `CONSTRAINT "gig_application_proposed_amount_check" CHECK ((proposed_amount >= (0)::numeric))`

**Indexes in source dump**

- UNIQUE `gig_application_gig_request_id_gig_worker_profile_id_key` on ("gig_request_id","gig_worker_profile_id")
- UNIQUE `gig_application_id_gig_request_id_gig_worker_profile_id_key` on ("id","gig_request_id","gig_worker_profile_id")
- UNIQUE `gig_application_pkey` on ("id")
- `idx_gig_application_application_status_id` on ("application_status_id")
- `idx_gig_application_created_by` on ("created_by")
- `idx_gig_application_decision_by_user_account_id` on ("decision_by_user_account_id")
- `idx_gig_application_gig_request_id` on ("gig_request_id")
- `idx_gig_application_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_gig_application_proposed_currency_id` on ("proposed_currency_id")
- `idx_gig_application_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.gig_assignment`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `external_system_code` | `varchar(80) NOT NULL` |
| `handoff_reference` | `varchar(200) NOT NULL` |
| `assignment_start_at` | `timestamp with time zone NOT NULL` |
| `assignment_end_at` | `timestamp with time zone NOT NULL` |
| `handed_off_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `reconciled_at` | `timestamp with time zone` |
| `estimated_earnings` | `numeric(18, 2)` |
| `total_earnings` | `numeric(18, 2)` |
| `projected_earnings` | `numeric(18, 2)` |
| `gig_application_id` | `bigint NOT NULL CONSTRAINT "gig_assignment_gig_application_id_key" UNIQUE` |
| `gig_request_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `assignment_status_id` | `bigint NOT NULL` |
| `estimated_currency_id` | `bigint` |
| `total_currency_id` | `bigint` |
| `projected_currency_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_assignment_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_assignment_external_system_code_handoff_reference_key" UNIQUE("external_system_code","handoff_reference")`
- `CONSTRAINT "gig_assignment_check" CHECK (((estimated_earnings IS NULL) = (estimated_currency_id IS NULL)))`
- `CONSTRAINT "gig_assignment_check1" CHECK (((total_earnings IS NULL) = (total_currency_id IS NULL)))`
- `CONSTRAINT "gig_assignment_check2" CHECK (((projected_earnings IS NULL) = (projected_currency_id IS NULL)))`
- `CONSTRAINT "gig_assignment_check3" CHECK ((assignment_end_at > assignment_start_at))`
- `CONSTRAINT "gig_assignment_estimated_earnings_check" CHECK ((estimated_earnings >= (0)::numeric))`
- `CONSTRAINT "gig_assignment_projected_earnings_check" CHECK ((projected_earnings >= (0)::numeric))`
- `CONSTRAINT "gig_assignment_total_earnings_check" CHECK ((total_earnings >= (0)::numeric))`
- Inline: `"gig_application_id" bigint NOT NULL CONSTRAINT "gig_assignment_gig_application_id_key" UNIQUE`

**Indexes in source dump**

- `ex_gig_assignment_worker_no_overlap` on ("gig_worker_profile_id","tstzrange(assignment_start_at, assignment_end_at, '[)'::text)")
- UNIQUE `gig_assignment_external_system_code_handoff_reference_key` on ("external_system_code","handoff_reference")
- UNIQUE `gig_assignment_gig_application_id_key` on ("gig_application_id")
- UNIQUE `gig_assignment_pkey` on ("id")
- `idx_gig_assignment_assignment_status_id` on ("assignment_status_id")
- `idx_gig_assignment_created_by` on ("created_by")
- `idx_gig_assignment_estimated_currency_id` on ("estimated_currency_id")
- `idx_gig_assignment_gig_application_id` on ("gig_application_id")
- `idx_gig_assignment_gig_request_id` on ("gig_request_id")
- `idx_gig_assignment_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_gig_assignment_projected_currency_id` on ("projected_currency_id")
- `idx_gig_assignment_total_currency_id` on ("total_currency_id")
- `idx_gig_assignment_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.gig_availability`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_availability_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `available_from` | `timestamp with time zone NOT NULL` |
| `available_to` | `timestamp with time zone NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `availability_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_availability_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_availability_check" CHECK ((available_to > available_from))`

**Indexes in source dump**

- `ex_gig_availability_worker_no_overlap` on ("gig_worker_profile_id","tstzrange(available_from, available_to, '[)'::text)")
- UNIQUE `gig_availability_pkey` on ("id")
- `idx_gig_availability_availability_status_id` on ("availability_status_id")
- `idx_gig_availability_created_by` on ("created_by")
- `idx_gig_availability_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_gig_availability_updated_by` on ("updated_by")
- UNIQUE `uq_gig_available_window` on ("gig_worker_profile_id","available_from","available_to")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.gig_rating`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_rating_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `rating_value` | `smallint NOT NULL` |
| `review_text` | `varchar(2000)` |
| `gig_assignment_id` | `bigint NOT NULL CONSTRAINT "gig_rating_gig_assignment_id_key" UNIQUE` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_rating_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_rating_rating_value_check" CHECK (((rating_value >= 1) AND (rating_value <= 5)))`
- Inline: `"gig_assignment_id" bigint NOT NULL CONSTRAINT "gig_rating_gig_assignment_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_rating_gig_assignment_id_key` on ("gig_assignment_id")
- UNIQUE `gig_rating_pkey` on ("id")
- `idx_gig_rating_created_by` on ("created_by")
- `idx_gig_rating_gig_assignment_id` on ("gig_assignment_id")
- `idx_gig_rating_requester_user_account_id` on ("requester_user_account_id")
- `idx_gig_rating_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.gig_request`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_request_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `title` | `varchar(150) NOT NULL` |
| `description` | `text NOT NULL` |
| `start_at` | `timestamp with time zone NOT NULL` |
| `end_at` | `timestamp with time zone NOT NULL` |
| `price_amount` | `numeric(18, 2) NOT NULL` |
| `source_timezone` | `varchar(100) DEFAULT 'UTC' NOT NULL` |
| `requester_organisation_id` | `bigint NOT NULL` |
| `requester_user_account_id` | `bigint NOT NULL` |
| `pricing_model_id` | `bigint NOT NULL` |
| `currency_id` | `bigint NOT NULL` |
| `request_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_request_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_request_id_requester_organisation_id_key" UNIQUE("id","requester_organisation_id")`
- `CONSTRAINT "gig_request_id_start_at_end_at_key" UNIQUE("id","start_at","end_at")`
- `CONSTRAINT "gig_request_check" CHECK ((end_at > start_at))`
- `CONSTRAINT "gig_request_price_amount_check" CHECK ((price_amount >= (0)::numeric))`

**Indexes in source dump**

- UNIQUE `gig_request_id_requester_organisation_id_key` on ("id","requester_organisation_id")
- UNIQUE `gig_request_id_start_at_end_at_key` on ("id","start_at","end_at")
- UNIQUE `gig_request_pkey` on ("id")
- `idx_gig_request_created_by` on ("created_by")
- `idx_gig_request_currency_id` on ("currency_id")
- `idx_gig_request_org_window` on ("requester_organisation_id","start_at","end_at")
- `idx_gig_request_pricing_model_id` on ("pricing_model_id")
- `idx_gig_request_request_status_id` on ("request_status_id")
- `idx_gig_request_requester_organisation_id` on ("requester_organisation_id")
- `idx_gig_request_requester_user_account_id` on ("requester_user_account_id")
- `idx_gig_request_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.gig_service`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_service_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `service_name` | `varchar(150) NOT NULL` |
| `description` | `varchar(2000)` |
| `rate_amount` | `numeric(18, 2) NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `currency_id` | `bigint NOT NULL` |
| `rate_unit_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_service_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_service_gig_worker_profile_id_service_name_key" UNIQUE("gig_worker_profile_id","service_name")`
- `CONSTRAINT "gig_service_rate_amount_check" CHECK ((rate_amount >= (0)::numeric))`

**Indexes in source dump**

- UNIQUE `gig_service_gig_worker_profile_id_service_name_key` on ("gig_worker_profile_id","service_name")
- UNIQUE `gig_service_pkey` on ("id")
- `idx_gig_service_created_by` on ("created_by")
- `idx_gig_service_currency_id` on ("currency_id")
- `idx_gig_service_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_gig_service_rate_unit_id` on ("rate_unit_id")
- `idx_gig_service_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.gig_worker_list_entry`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_worker_list_entry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `requester_organisation_id` | `bigint NOT NULL` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `worker_list_type_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_worker_list_entry_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "gig_worker_list_entry_requester_organisation_id_gig_worker__key" UNIQUE("requester_organisation_id","gig_worker_profile_id")`

**Indexes in source dump**

- UNIQUE `gig_worker_list_entry_pkey` on ("id")
- UNIQUE `gig_worker_list_entry_requester_organisation_id_gig_worker__key` on ("requester_organisation_id","gig_worker_profile_id")
- `idx_gig_worker_list_entry_created_by` on ("created_by")
- `idx_gig_worker_list_entry_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_gig_worker_list_entry_requester_organisation_id` on ("requester_organisation_id")
- `idx_gig_worker_list_entry_updated_by` on ("updated_by")
- `idx_gig_worker_list_entry_worker_list_type_id` on ("worker_list_type_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.gig_worker_profile`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_worker_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `public_name` | `varchar(150) NOT NULL` |
| `bio` | `varchar(4000)` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `user_account_id` | `bigint NOT NULL CONSTRAINT "gig_worker_profile_user_account_id_key" UNIQUE` |
| `home_city_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."gig_worker_profile_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"user_account_id" bigint NOT NULL CONSTRAINT "gig_worker_profile_user_account_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `gig_worker_profile_pkey` on ("id")
- UNIQUE `gig_worker_profile_user_account_id_key` on ("user_account_id")
- `idx_gig_worker_profile_created_by` on ("created_by")
- `idx_gig_worker_profile_home_city_id` on ("home_city_id")
- `idx_gig_worker_profile_updated_by` on ("updated_by")
- `idx_gig_worker_profile_user_account_id` on ("user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **Yes**. This does not establish that any RLS policy exists.

### `gig.pricing_model`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."pricing_model_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "pricing_model_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "pricing_model_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."pricing_model_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "pricing_model_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "pricing_model_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_pricing_model_created_by` on ("created_by")
- `idx_pricing_model_reference_code_id` on ("reference_code_id")
- `idx_pricing_model_updated_by` on ("updated_by")
- UNIQUE `pricing_model_code_key` on ("code")
- UNIQUE `pricing_model_pkey` on ("id")
- UNIQUE `pricing_model_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.rate_unit`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."rate_unit_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "rate_unit_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "rate_unit_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."rate_unit_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "rate_unit_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "rate_unit_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_rate_unit_created_by` on ("created_by")
- `idx_rate_unit_reference_code_id` on ("reference_code_id")
- `idx_rate_unit_updated_by` on ("updated_by")
- UNIQUE `rate_unit_code_key` on ("code")
- UNIQUE `rate_unit_pkey` on ("id")
- UNIQUE `rate_unit_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.request_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."request_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "request_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "request_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."request_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "request_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "request_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_request_status_created_by` on ("created_by")
- `idx_request_status_reference_code_id` on ("reference_code_id")
- `idx_request_status_updated_by` on ("updated_by")
- UNIQUE `request_status_code_key` on ("code")
- UNIQUE `request_status_pkey` on ("id")
- UNIQUE `request_status_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.worker_list_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."worker_list_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "worker_list_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "worker_list_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."worker_list_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "worker_list_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "worker_list_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_worker_list_type_created_by` on ("created_by")
- `idx_worker_list_type_reference_code_id` on ("reference_code_id")
- `idx_worker_list_type_updated_by` on ("updated_by")
- UNIQUE `worker_list_type_code_key` on ("code")
- UNIQUE `worker_list_type_pkey` on ("id")
- UNIQUE `worker_list_type_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig.worker_project`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."worker_project_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `title` | `varchar(150) NOT NULL` |
| `project_role` | `varchar(150) NOT NULL` |
| `start_date` | `date NOT NULL` |
| `end_date` | `date` |
| `outcome` | `varchar(4000)` |
| `gig_worker_profile_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "gig"."worker_project_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "worker_project_check" CHECK (((end_date IS NULL) OR (end_date >= start_date)))`

**Indexes in source dump**

- `idx_worker_project_created_by` on ("created_by")
- `idx_worker_project_gig_worker_profile_id` on ("gig_worker_profile_id")
- `idx_worker_project_updated_by` on ("updated_by")
- UNIQUE `worker_project_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

## 7. Licences, Seats, Devices and Sessions — Phase 3 — Assigned member

**Entities in this module:** 24 source tables listed (including shared entities).

### `user_credential`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_credential_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `credential_type` | `varchar(30) NOT NULL` |
| `credential_identifier` | `varchar(254) NOT NULL` |
| `secret_hash` | `text` |
| `secret_reference` | `text` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `verified_at` | `timestamp with time zone` |
| `expires_at` | `timestamp with time zone` |
| `last_used_at` | `timestamp with time zone` |
| `failed_attempt_count` | `integer DEFAULT 0 NOT NULL` |
| `locked_until` | `timestamp with time zone` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_credential_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_credential_credential_type_credential_identifier_key" UNIQUE("credential_type","credential_identifier")`
- `CONSTRAINT "user_credential_failed_attempt_count_check" CHECK ((failed_attempt_count >= 0))`

**Indexes in source dump**

- UNIQUE `user_credential_credential_type_credential_identifier_key` on ("credential_type","credential_identifier")
- UNIQUE `user_credential_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.credential`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."credential_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `secret_hash` | `varchar(500)` |
| `external_reference` | `varchar(500)` |
| `issued_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `expires_at` | `timestamp with time zone` |
| `revoked_at` | `timestamp with time zone` |
| `user_account_id` | `bigint NOT NULL` |
| `credential_type_id` | `bigint NOT NULL` |
| `hash_algorithm_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."credential_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "credential_check" CHECK (((secret_hash IS NULL) <> (external_reference IS NULL)))`
- `CONSTRAINT "credential_check1" CHECK (((expires_at IS NULL) OR (expires_at > issued_at)))`
- `CONSTRAINT "credential_check2" CHECK (((revoked_at IS NULL) OR (revoked_at >= issued_at)))`

**Indexes in source dump**

- UNIQUE `credential_pkey` on ("id")
- `idx_credential_created_by` on ("created_by")
- `idx_credential_credential_type_id` on ("credential_type_id")
- `idx_credential_hash_algorithm_id` on ("hash_algorithm_id")
- `idx_credential_updated_by` on ("updated_by")
- `idx_credential_user_account_id` on ("user_account_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.credential_type`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."credential_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "credential_type_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "credential_type_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."credential_type_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "credential_type_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "credential_type_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `credential_type_code_key` on ("code")
- UNIQUE `credential_type_pkey` on ("id")
- UNIQUE `credential_type_reference_code_id_key` on ("reference_code_id")
- `idx_credential_type_created_by` on ("created_by")
- `idx_credential_type_reference_code_id` on ("reference_code_id")
- `idx_credential_type_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.hash_algorithm`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."hash_algorithm_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "hash_algorithm_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "hash_algorithm_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."hash_algorithm_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "hash_algorithm_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "hash_algorithm_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `hash_algorithm_code_key` on ("code")
- UNIQUE `hash_algorithm_pkey` on ("id")
- UNIQUE `hash_algorithm_reference_code_id_key` on ("reference_code_id")
- `idx_hash_algorithm_created_by` on ("created_by")
- `idx_hash_algorithm_reference_code_id` on ("reference_code_id")
- `idx_hash_algorithm_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.session_record`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."session_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `neon_auth_session_id` | `uuid CONSTRAINT "session_record_neon_auth_session_id_key" UNIQUE` |
| `session_digest` | `char(64) NOT NULL CONSTRAINT "session_record_session_digest_key" UNIQUE` |
| `started_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `expires_at` | `timestamp with time zone NOT NULL` |
| `ended_at` | `timestamp with time zone` |
| `last_activity_at` | `timestamp with time zone` |
| `user_account_id` | `bigint NOT NULL` |
| `session_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."session_record_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "session_record_check" CHECK ((expires_at > started_at))`
- `CONSTRAINT "session_record_check1" CHECK (((ended_at IS NULL) OR (ended_at >= started_at)))`
- `CONSTRAINT "session_record_session_digest_check" CHECK ((session_digest ~ '^[a-f0-9]{64}$'::text))`
- Inline: `"neon_auth_session_id" uuid CONSTRAINT "session_record_neon_auth_session_id_key" UNIQUE`
- Inline: `"session_digest" char(64) NOT NULL CONSTRAINT "session_record_session_digest_key" UNIQUE`

**Indexes in source dump**

- `idx_session_record_created_by` on ("created_by")
- `idx_session_record_session_status_id` on ("session_status_id")
- `idx_session_record_updated_by` on ("updated_by")
- `idx_session_record_user_account_id` on ("user_account_id")
- UNIQUE `session_record_neon_auth_session_id_key` on ("neon_auth_session_id")
- UNIQUE `session_record_pkey` on ("id")
- UNIQUE `session_record_session_digest_key` on ("session_digest")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.session_status`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."session_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `code` | `varchar(80) NOT NULL CONSTRAINT "session_status_code_key" UNIQUE` |
| `display_name` | `varchar(150) NOT NULL` |
| `active` | `boolean DEFAULT true NOT NULL` |
| `sort_order` | `integer DEFAULT 0 NOT NULL` |
| `reference_code_id` | `bigint NOT NULL CONSTRAINT "session_status_reference_code_id_key" UNIQUE` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."session_status_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"code" varchar(80) NOT NULL CONSTRAINT "session_status_code_key" UNIQUE`
- Inline: `"reference_code_id" bigint NOT NULL CONSTRAINT "session_status_reference_code_id_key" UNIQUE`

**Indexes in source dump**

- `idx_session_status_created_by` on ("created_by")
- `idx_session_status_reference_code_id` on ("reference_code_id")
- `idx_session_status_updated_by` on ("updated_by")
- UNIQUE `session_status_code_key` on ("code")
- UNIQUE `session_status_pkey` on ("id")
- UNIQUE `session_status_reference_code_id_key` on ("reference_code_id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.db_principal` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_role`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `valid_from` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `user_account_id` | `bigint NOT NULL` |
| `app_role_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity"."user_role_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_role_id_user_account_id_key" UNIQUE("id","user_account_id")`
- `CONSTRAINT "user_role_check" CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))`

**Indexes in source dump**

- `ex_user_role_no_overlap` on ("user_account_id","app_role_id","tstzrange(valid_from, valid_to, '[)'::text)")
- `idx_user_role_app_role_id` on ("app_role_id")
- `idx_user_role_created_by` on ("created_by")
- `idx_user_role_updated_by` on ("updated_by")
- `idx_user_role_user_account_id` on ("user_account_id")
- UNIQUE `user_role_id_user_account_id_key` on ("id","user_account_id")
- UNIQUE `user_role_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `identity.permission` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.role_permission` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.account_status` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.app_role` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_consent` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.consent_type` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_block` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.system_error_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity_session`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity_session_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `session_token_hash` | `text NOT NULL CONSTRAINT "identity_session_session_token_hash_key" UNIQUE` |
| `device_id` | `bigint` |
| `ip_address` | `inet` |
| `user_agent` | `text` |
| `source_timezone` | `varchar(60)` |
| `started_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `last_activity_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `expires_at` | `timestamp with time zone NOT NULL` |
| `ended_at` | `timestamp with time zone` |
| `end_reason` | `varchar(40)` |
| `session_status` | `varchar(30) DEFAULT 'ACTIVE' NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "identity_session_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "identity_session_check" CHECK ((expires_at > started_at))`
- `CONSTRAINT "identity_session_check1" CHECK (((ended_at IS NULL) OR (ended_at >= started_at)))`
- Inline: `"session_token_hash" text NOT NULL CONSTRAINT "identity_session_session_token_hash_key" UNIQUE`

**Indexes in source dump**

- UNIQUE `identity_session_pkey` on ("id")
- UNIQUE `identity_session_session_token_hash_key` on ("session_token_hash")
- `idx_identity_session_user_status` on ("user_account_id","session_status","expires_at")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `login_attempt` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_account` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_role` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `permission` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `role_permission` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_preference`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_preference_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `preference_key` | `varchar(100) NOT NULL` |
| `preference_value` | `jsonb NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "user_preference_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "user_preference_user_account_id_preference_key_key" UNIQUE("user_account_id","preference_key")`

**Indexes in source dump**

- UNIQUE `user_preference_pkey` on ("id")
- UNIQUE `user_preference_user_account_id_preference_key_key` on ("user_account_id","preference_key")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

## 8. Sourcing and Consultant Requests — Phase 3 — Assigned member

**Entities in this module:** 39 source tables listed (including shared entities).

### `gig_request` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_request_skill` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_service` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_service_skill` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_profile` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_availability` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_list` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_list_entry` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_application` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_application_status_history` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_assignment` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_fulfilment_handoff` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_earnings_reconciliation` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_rating` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_request` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_service` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_worker_profile` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_worker_list_entry` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.worker_project` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_application` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_assignment` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_availability` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.gig_rating` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.request_status` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.application_status` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.assignment_status` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.availability_status` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.fulfilment_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.pricing_model` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.rate_unit` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig.worker_list_type` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation_recruiter` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation_account_admin` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation.organisation_recruiter` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation.organisation_member` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation.job_recruiter_assignment` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_block` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_block` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

## 9. Subscriptions, Wallet, Payments and Download History — Phase 3 — Assigned member

**Entities in this module:** 14 source tables listed (including shared entities).

### `gig_earnings_reconciliation` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_assignment` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_application` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_rating` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `notification_delivery`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "notification_delivery_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `notification_type` | `varchar(60) NOT NULL` |
| `channel_code` | `varchar(30) NOT NULL` |
| `provider_name` | `varchar(80)` |
| `provider_message_reference` | `varchar(200)` |
| `delivery_status` | `varchar(30) DEFAULT 'QUEUED' NOT NULL` |
| `queued_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `sent_at` | `timestamp with time zone` |
| `delivered_at` | `timestamp with time zone` |
| `failed_at` | `timestamp with time zone` |
| `failure_code` | `varchar(80)` |
| `retry_count` | `integer DEFAULT 0 NOT NULL` |
| `correlation_id` | `uuid` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "notification_delivery_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "notification_delivery_retry_count_check" CHECK ((retry_count >= 0))`

**Indexes in source dump**

- `idx_notification_delivery_user_time` on ("user_account_id","queued_at")
- UNIQUE `notification_delivery_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `account_profile` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `account_organisation` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_account` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_preference` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.credential` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.session_record` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

## 10. Notifications, Preferences and Community — Phase 4 — Whole team

**Entities in this module:** 23 source tables listed (including shared entities).

### `notification_delivery` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `notification_preference`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "notification_preference_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `user_account_id` | `bigint NOT NULL` |
| `channel_code` | `varchar(30) NOT NULL` |
| `notification_category` | `varchar(60) NOT NULL` |
| `is_enabled` | `boolean DEFAULT true NOT NULL` |
| `quiet_hours_start` | `time` |
| `quiet_hours_end` | `time` |
| `timezone_name` | `varchar(60)` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "notification_preference_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "notification_preference_user_account_id_channel_code_notifi_key" UNIQUE("user_account_id","channel_code","notification_category")`

**Indexes in source dump**

- UNIQUE `notification_preference_pkey` on ("id")
- UNIQUE `notification_preference_user_account_id_channel_code_notifi_key` on ("user_account_id","channel_code","notification_category")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `user_preference` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `user_block` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_block` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `support_ticket` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `support_ticket_message` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `faq_article` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `consent_record` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.user_consent` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.consent_type` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `candidate_activity_log`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_activity_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `occurred_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `description` | `varchar(2000)` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `candidate_activity_type_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_activity_log_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `candidate_activity_log_pkey` on ("id")
- `idx_candidate_activity_log_candidate_activity_type_id` on ("candidate_activity_type_id")
- `idx_candidate_activity_log_candidate_profile_id` on ("candidate_profile_id")
- `idx_candidate_activity_log_created_by` on ("created_by")
- `idx_candidate_activity_log_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `profile_view_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "profile_view_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `viewed_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `viewer_id` | `bigint NOT NULL` |
| `organisation_id` | `bigint` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "profile_view_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_profile_view_history_candidate_profile_id` on ("candidate_profile_id")
- `idx_profile_view_history_created_by` on ("created_by")
- `idx_profile_view_history_organisation_id` on ("organisation_id")
- `idx_profile_view_history_updated_by` on ("updated_by")
- `idx_profile_view_history_viewer_id` on ("viewer_id")
- UNIQUE `profile_view_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `candidate_bookmark`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_bookmark_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `bookmarked_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `bookmarked_by` | `bigint NOT NULL` |
| `organisation_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_bookmark_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_candidate_bookmark_5" UNIQUE("candidate_profile_id","bookmarked_by")`

**Indexes in source dump**

- UNIQUE `candidate_bookmark_pkey` on ("id")
- `idx_candidate_bookmark_bookmarked_by` on ("bookmarked_by")
- `idx_candidate_bookmark_candidate_profile_id` on ("candidate_profile_id")
- `idx_candidate_bookmark_created_by` on ("created_by")
- `idx_candidate_bookmark_organisation_id` on ("organisation_id")
- `idx_candidate_bookmark_updated_by` on ("updated_by")
- UNIQUE `uq_candidate_bookmark_5` on ("candidate_profile_id","bookmarked_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `candidate_bookmark_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_bookmark_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `is_bookmarked` | `boolean DEFAULT true NOT NULL` |
| `changed_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `candidate_bookmark_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_bookmark_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `candidate_bookmark_history_pkey` on ("id")
- `idx_candidate_bookmark_history_candidate_bookmark_id` on ("candidate_bookmark_id")
- `idx_candidate_bookmark_history_created_by` on ("created_by")
- `idx_candidate_bookmark_history_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `referral_tracking`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "referral_tracking_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `referral_code` | `varchar(80) NOT NULL CONSTRAINT "referral_tracking_referral_code_key" UNIQUE` |
| `referred_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `referrer_id` | `bigint NOT NULL` |
| `candidate_profile_id` | `bigint` |
| `referral_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "referral_tracking_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- Inline: `"referral_code" varchar(80) NOT NULL CONSTRAINT "referral_tracking_referral_code_key" UNIQUE`

**Indexes in source dump**

- `idx_referral_tracking_candidate_profile_id` on ("candidate_profile_id")
- `idx_referral_tracking_created_by` on ("created_by")
- `idx_referral_tracking_referral_status_id` on ("referral_status_id")
- `idx_referral_tracking_referrer_id` on ("referrer_id")
- `idx_referral_tracking_updated_by` on ("updated_by")
- UNIQUE `referral_tracking_pkey` on ("id")
- UNIQUE `referral_tracking_referral_code_key` on ("referral_code")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `gig_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_rating` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_list` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_worker_list_entry` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `system_error_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.system_error_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

## 11. Analytics Layer and Reporting Marts — Phase 4 — Assigned member

**Entities in this module:** 22 source tables listed (including shared entities).

### `candidate_activity_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `profile_view_history` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `candidate_job_search_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_job_search_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `searched_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `search_text` | `varchar(1000)` |
| `filters` | `jsonb DEFAULT '{}' NOT NULL` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "candidate_job_search_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "candidate_job_search_history_filters_check" CHECK ((jsonb_typeof(filters) = 'object'::text))`

**Indexes in source dump**

- UNIQUE `candidate_job_search_history_pkey` on ("id")
- `idx_candidate_job_search_history_candidate_profile_id` on ("candidate_profile_id")
- `idx_candidate_job_search_history_created_by` on ("created_by")
- `idx_candidate_job_search_history_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `referral_tracking` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `job_status_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `changed_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `reason` | `varchar(2000)` |
| `job_requirement_id` | `bigint NOT NULL` |
| `job_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_job_status_history_created_by` on ("created_by")
- `idx_job_status_history_job_requirement_id` on ("job_requirement_id")
- `idx_job_status_history_job_status_id` on ("job_status_id")
- `idx_job_status_history_timeline` on ("job_requirement_id","changed_at")
- `idx_job_status_history_updated_by` on ("updated_by")
- UNIQUE `job_status_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `job_event`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `title` | `varchar(150) NOT NULL` |
| `starts_at` | `timestamp with time zone NOT NULL` |
| `ends_at` | `timestamp with time zone NOT NULL` |
| `source_timezone` | `varchar(100) DEFAULT 'UTC' NOT NULL` |
| `venue` | `varchar(500)` |
| `meeting_url` | `varchar(2048)` |
| `job_requirement_id` | `bigint NOT NULL` |
| `job_event_type_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "job_event_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "job_event_check" CHECK ((ends_at >= starts_at))`

**Indexes in source dump**

- `idx_job_event_created_by` on ("created_by")
- `idx_job_event_job_event_type_id` on ("job_event_type_id")
- `idx_job_event_job_requirement_id` on ("job_requirement_id")
- `idx_job_event_updated_by` on ("updated_by")
- UNIQUE `job_event_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `application_status_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `changed_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `reason` | `varchar(2000)` |
| `application_id` | `bigint NOT NULL` |
| `application_status_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_status_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- UNIQUE `application_status_history_pkey` on ("id")
- `idx_application_status_history_application_id` on ("application_id")
- `idx_application_status_history_application_status_id` on ("application_status_id")
- `idx_application_status_history_created_by` on ("created_by")
- `idx_application_status_history_timeline` on ("application_id","changed_at")
- `idx_application_status_history_updated_by` on ("updated_by")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `application_stage_result`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_stage_result_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `attempt_number` | `integer DEFAULT 1 NOT NULL` |
| `score` | `numeric(7, 3)` |
| `maximum_score` | `numeric(7, 3)` |
| `feedback` | `varchar(4000)` |
| `completed_at` | `timestamp with time zone` |
| `application_id` | `bigint NOT NULL` |
| `job_hiring_stage_id` | `bigint NOT NULL` |
| `job_requirement_id` | `bigint NOT NULL` |
| `stage_decision_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "application_stage_result_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_application_stage_result_10" UNIQUE("application_id","job_hiring_stage_id","attempt_number")`
- `CONSTRAINT "application_stage_result_attempt_number_check" CHECK ((attempt_number > 0))`
- `CONSTRAINT "application_stage_result_check" CHECK ((((score IS NULL) AND (maximum_score IS NULL)) OR ((score IS NOT NULL) AND (maximum_score IS NOT NULL) AND (score <= maximum_score))))`
- `CONSTRAINT "application_stage_result_maximum_score_check" CHECK ((maximum_score > (0)::numeric))`
- `CONSTRAINT "application_stage_result_score_check" CHECK ((score >= (0)::numeric))`

**Indexes in source dump**

- UNIQUE `application_stage_result_pkey` on ("id")
- `idx_application_stage_result_application_id` on ("application_id")
- `idx_application_stage_result_created_by` on ("created_by")
- `idx_application_stage_result_job_hiring_stage_id` on ("job_hiring_stage_id")
- `idx_application_stage_result_job_requirement_id` on ("job_requirement_id")
- `idx_application_stage_result_stage_decision_id` on ("stage_decision_id")
- `idx_application_stage_result_updated_by` on ("updated_by")
- UNIQUE `uq_application_stage_result_10` on ("application_id","job_hiring_stage_id","attempt_number")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `assessment_result`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "assessment_result_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `attempt_number` | `integer DEFAULT 1 NOT NULL` |
| `score` | `numeric(10, 3) NOT NULL` |
| `maximum_score` | `numeric(10, 3) NOT NULL` |
| `taken_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `candidate_profile_id` | `bigint NOT NULL` |
| `assessment_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "assessment_result_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`
- `CONSTRAINT "uq_assessment_result_7" UNIQUE("candidate_profile_id","assessment_id","attempt_number")`
- `CONSTRAINT "assessment_result_attempt_number_check" CHECK ((attempt_number > 0))`
- `CONSTRAINT "assessment_result_check" CHECK ((score <= maximum_score))`
- `CONSTRAINT "assessment_result_maximum_score_check" CHECK ((maximum_score > (0)::numeric))`
- `CONSTRAINT "assessment_result_score_check" CHECK ((score >= (0)::numeric))`

**Indexes in source dump**

- UNIQUE `assessment_result_pkey` on ("id")
- `idx_assessment_result_assessment_id` on ("assessment_id")
- `idx_assessment_result_candidate_profile_id` on ("candidate_profile_id")
- `idx_assessment_result_created_by` on ("created_by")
- `idx_assessment_result_updated_by` on ("updated_by")
- UNIQUE `uq_assessment_result_7` on ("candidate_profile_id","assessment_id","attempt_number")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `shortlist_history`

| Column | PostgreSQL definition |
|---|---|
| `id` | `bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "shortlist_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)` |
| `is_shortlisted` | `boolean DEFAULT true NOT NULL` |
| `changed_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `job_shortlist_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `created_by` | `bigint` |
| `updated_at` | `timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL` |
| `updated_by` | `bigint` |
| `deleted_at` | `timestamp with time zone` |

**Primary key / inline column constraints**

- `"id" bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "shortlist_history_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1)`

**Indexes in source dump**

- `idx_shortlist_history_created_by` on ("created_by")
- `idx_shortlist_history_job_shortlist_id` on ("job_shortlist_id")
- `idx_shortlist_history_updated_by` on ("updated_by")
- UNIQUE `shortlist_history_pkey` on ("id")

**Row-level security:** `ENABLE ROW LEVEL SECURITY` statement found for this exact table: **No evidence in supplied dump**. This does not establish that any RLS policy exists.

### `organisation_status_history` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `organisation_verification_history` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `gig_earnings_reconciliation` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `notification_delivery` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `login_attempt` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `audit_event` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `system_error_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `identity.system_error_log` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `support_ticket` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

### `support_ticket_message` — shared entity

Defined in an earlier module section; its definition is not duplicated here.

## Requested capabilities not represented as dedicated entities in the supplied dump

The following are important gaps: no matching dedicated tables were found for these concepts in the supplied expanded schema. They must not be represented as already implemented just because related tables exist.

| Requested capability | Source status | Design recommendation (proposed, not source-defined) |
|---|---|---|
| Licences / entitlements | No dedicated licence or entitlement table found | `product_licence`, `licence_entitlement`, `licence_assignment`, `licence_audit_event` with explicit validity and revocation rules. |
| Seat allocation | No seat or seat-allocation table found | `organisation_seat_pool`, `seat_assignment`, `seat_assignment_history`; enforce one active seat per user per product and allocation not exceeding purchased quantity. |
| Devices | No dedicated device registry found | `user_device` with device fingerprint hash, platform, first/last seen, trusted/revoked timestamps; avoid storing raw secrets or unnecessary fingerprint data. |
| Sessions | `identity.session_record`, `identity.session_status`, and `identity_session` exist in the expanded dump; verify exact FKs, token handling, expiry, and revocation before production use. | Ensure server-side expiry/revocation and hash tokens at rest; never store raw bearer tokens. |
| Subscriptions | No dedicated subscription/plan/renewal table found | `billing_plan`, `subscription`, `subscription_item`, `subscription_event`, `subscription_invoice` with provider IDs, status transitions, trial/cancellation dates, and idempotency keys. |
| Wallet / ledger | No dedicated wallet or double-entry ledger found | `wallet_account`, `wallet_transaction`, `wallet_ledger_entry`, `wallet_adjustment`; append-only ledger, idempotent posting, currency precision, no mutable balance-only source of truth. |
| Payments / refunds | No dedicated payment, refund, or webhook-inbox tables found | `payment`, `payment_refund`, `payment_provider_event`; unique provider event ID, verified webhook signatures, idempotent state transitions. |
| Download history | No dedicated download history table found | `download_event` with actor, asset, purpose, timestamp, outcome, request/correlation ID; do not log signed URLs or secrets. |
| Community | No dedicated post/comment/reaction/follow/community membership entities found | Add community entities only if product requirements confirm scope; include moderation state, report/audit trail, visibility and soft-delete policy. |
| Analytics marts | No dedicated warehouse fact/dimension/mart entities found | Design a separate analytics layer (`dim_date`, `dim_user`, `dim_organisation`, `dim_job`, `fact_application`, `fact_gig`, `fact_payment`, `fact_notification`) after event definitions and privacy/retention rules are agreed. |
| Analytics/reporting jobs | No dedicated report definition, report run, export job, or materialized mart control table found | Add `report_definition`, `report_run`, `report_export`, and refresh watermark/control records if required. |
| Notification templates and in-app inbox | Delivery and preference tables exist, but no template or in-app notification entity was found | Add `notification_template` and/or `user_notification` if template versioning and in-app unread state are required. |

## Cross-module rules and integrity checklist

The following list separates rules directly evidenced by schema constraints from rules that should be enforced by application logic or additional database migrations.

### Database-enforced rules evidenced by the dump

- All `NOT NULL`, `DEFAULT`, identity, primary-key, unique, check, and declared foreign-key rules shown under each entity are source-defined.
- `account_organisation` has a unique relationship tuple and a check requiring `valid_until` to be later than `valid_from` when supplied.
- `notification_delivery.retry_count` cannot be negative.
- `notification_preference` has one row per `(user_account_id, channel_code, notification_category)`.
- `identity.audit_event.details` must be a JSON object.
- `identity.credential` enforces exactly one of `secret_hash` and `external_reference` and validates expiry/revocation timestamps against issue time.
- Gig and organisation tables may have explicit RLS enablement statements; see each entity. RLS enabled alone is not a complete access-control policy.

### Application/business rules to enforce (not automatically guaranteed unless a constraint is shown)

- **Tenant isolation:** every organisation-owned read/write must scope through the authenticated organisation membership and authorised role; never trust a client-supplied `organisation_id` alone.
- **Administration:** privileged actions (role grants, account suspension, organisation verification, permission changes, billing/ledger adjustments) should emit immutable audit events with actor, target, timestamp, request ID, and reason.
- **Account lifecycle:** define allowed account status transitions; record actor and reason; revoke sessions and credentials when account is suspended or access is removed.
- **Organisation membership:** enforce one active primary organisation per account, membership uniqueness, role boundaries, and verification before enabling restricted actions. Verify whether any uniqueness index in the dump is partial or global before assuming it models only active rows.
- **Licences and seats:** do not allocate more active seats than paid entitlements; prevent duplicate active assignments; use transactional locking or serializable allocation to avoid concurrent over-allocation.
- **Devices and sessions:** expire and revoke server-side; rotate credentials after compromise; do not log secrets; require step-up authentication for high-risk administrative actions.
- **Gig marketplace:** enforce legal state transitions for request → application → assignment → fulfilment → rating/reconciliation; only the relevant requester, assigned worker, and authorised organisation actors may access records; prevent rating/reconciliation duplicates and out-of-order settlement.
- **Consultant sourcing:** scope consultant access to eligible requests and organisations; record request eligibility and consent; block relationships must be checked consistently across discovery, messaging, application, and assignment paths.
- **Billing and wallet:** use idempotency keys for payment/webhook processing; ledger entries must be append-only and balanced; reconcile provider settlements; use fixed-precision numeric values and explicit currency codes; never treat a mutable wallet balance as the sole financial record.
- **Notifications:** respect channel/category preferences and quiet hours; deduplicate retries; record provider references and failure outcomes; avoid placing sensitive personal data in message payloads or logs.
- **Community:** apply moderation, reporting, visibility, blocking, deletion, and retention rules consistently; ensure blocked users cannot bypass restrictions through secondary endpoints.
- **Analytics:** use documented event definitions, stable dimensions, timezone/currency normalization, data freshness markers, access controls, and privacy-aware aggregation. Separate operational writes from reporting refreshes where possible.
- **Soft deletion:** for entities with `deleted_at`, all normal reads must consistently filter deleted rows; define restoration and uniqueness behaviour explicitly.
- **Timestamps:** store instants as `timestamptz`; define whether business dates are interpreted in organisation/user timezone; avoid mixing local timestamps and UTC without an explicit convention.
- **Audit retention:** audit, login attempt, consent, payment, and security records should have explicit retention/access policies and should not be silently soft-deleted when regulatory or incident-response needs require immutability.

## Referential-integrity review notes

- The per-entity column tables preserve source column definitions. Inline `REFERENCES` clauses and table-level `FOREIGN KEY` constraints are printed exactly where detected.
- Some legacy dump sections contain similarly named entities in `public`, `gig`, `identity`, and `organisation`. Treat these as distinct tables, not aliases. Confirm intended canonical schema before merging or dropping duplicates.
- For every `*_id` column without a declared FK, verify whether it is intentionally application-managed or whether a migration is missing. Do not assume referential integrity from naming conventions.
- Indexes shown are the standalone index statements in the source dump. Validate whether production has additional indexes, partial indexes, extension indexes, or policies that are not in this file.

## Safe implementation sequence

1. Export the **live** Neon schema (tables, columns, PK/FK/unique/check constraints, indexes, triggers, policies, grants, extensions) and diff it against this source dump.
2. Decide which of the duplicate `public`, `gig`, `identity`, and `organisation` representations are canonical. Document a migration plan before renaming or consolidating them.
3. Implement missing module entities only after requirements are agreed; use a migration per capability and include rollback/forward-recovery notes.
4. Add constraints and indexes in migrations; add RLS policies and grants explicitly, then test as anonymous, normal user, organisation member, administrator, and service role.
5. Add concurrency tests for seat allocation and wallet posting, idempotency tests for payment/webhook events, state-transition tests for gig workflows, and tenant-isolation tests for all organisation-owned records.
6. Add schema-level tests that verify expected columns, constraints, indexes, RLS policies, and trigger functions in CI.

## Hackathon docket compliance rules for Modules 4–11

This section maps the requirements in `Talentra-Database-Design-Hackathon-Docket.pdf` to the current expanded schema. It does not silently mark a requirement compliant merely because a similarly named table exists.

| Docket rule / requirement | Schema evidence | Compliance status / action |
|---|---|---|
| Snake_case names; singular table names; `id` primary key | Most table and column names follow snake_case; several schemas contain parallel entities with duplicated concepts | **Partial.** Review singular naming and consolidate duplicate `public`, `gig`, `identity`, and `organisation` models deliberately. |
| Surrogate PK on every entity | Most listed entities declare `id` as a surrogate identity key | **Verify per entity.** The table definitions above show the actual declaration; do not infer a PK where one is not shown. |
| Every FK is enforced, with update/delete behaviour stated | FK clauses are shown where present in the source; many `*_id` columns may not have explicit FK clauses | **Gap to audit.** Add missing FK constraints and document `ON UPDATE` / `ON DELETE` behaviour. |
| Check constraints for business rules | Some checks exist, e.g. organisation relationship dates, credential timestamps, notification retry count, audit JSON type | **Partial.** Add date-window, amount/percentage, state-transition, licence, and seat constraints where applicable. |
| Concurrency and licence limits enforced in DB | No dedicated licence/seat model found | **Not implemented in source.** Requires schema and transaction/locking design. |
| Device limit enforced at login; active sessions counted; releases defined | Session-related tables exist, but no dedicated device registry or licence limit is evident | **Partial / gap.** Implement device registration, session-to-device relation, expiry/revocation and transactional limit check. |
| Standard money type and currency companion | `numeric` amount columns and currency lookup are present in parts of the schema; financial domain is incomplete | **Partial.** Every monetary amount must have an explicit currency code/ID, fixed precision, and documented rounding. |
| Email <= 254, lowercase and unique where account identity | Account tables contain email-like fields; uniqueness/canonicalisation must be checked per account identity column | **Verify.** Add lower-case canonicalisation and unique constraints where email uniquely identifies an account. |
| Phone in E.164 with country separated | Not proven for every phone field by the SQL type alone | **Document and validate** format at write boundary; keep country as separate data. |
| All business tables have created/updated metadata and deletion policy | Many entities have audit columns and some have `deleted_at`; not every table does | **Partial.** Classify each table as soft-delete or hard-delete and state retention/nullable-field justification. |
| Audit records append-only; every sensitive action audited | Audit event entities exist, but append-only permissions/triggers and coverage cannot be confirmed from this dump | **Not proven.** Deny update/delete to application roles and audit role changes, verification, blocks, session/device revocation, billing, downloads and administrative actions. |
| Sensitive data classified and protected | Some credential/verification tables exist; schema alone does not establish encryption or masking | **Security design required.** Tag columns Public/Internal/Personal/Sensitive; encrypt/tokenise/mask national IDs, tax IDs, payment references and credentials. |
| Multilingual UI keys and translations | `ui_translation`, `reference_translation`, and language master exist | **Partial.** Define fallback language and ensure UI labels are keys, not hard-coded user-visible strings. |
| Licences include max users and max devices/user | No dedicated licence/entitlement table found | **Not implemented in source.** Add positive integer checks and assignment history. |
| Sessions include device, start, last activity, end; expired/revoked excluded from count | Session records exist but must be verified for these fields and relationships | **Verify and extend.** Expired/revoked sessions must not consume active-device allowance. |
| Subscription periods do not overlap for a licence | No dedicated subscription model found | **Not implemented in source.** Add exclusion/transactional overlap prevention. |
| Payment and wallet ledgers append-only, correction by compensating entry | No dedicated payment/wallet ledger tables found | **Not implemented in source.** Add append-only ledger and provider idempotency keys. |
| Download/view history append-only with actor, subject, timestamp and credits | Profile view history exists; no dedicated profile download history found | **Partial.** Add download events and credit-debit linkage; enforce append-only semantics. |
| Gig request window and pricing; application accepted/rejected by requester | Gig request/application/assignment entities exist in legacy dump | **Verify.** Ensure start/end checks, fixed/rate pricing rules, and requester-controlled state transitions are constrained. |
| Gig fulfilment stays external; store handoff and reconciled earnings | Handoff and earnings reconciliation entities exist | **Boundary requirement.** Store external references and reconciliation facts only; do not model the platform as running fulfilment. |
| Candidate can block employers/recruiters/consultants and blocked party cannot see candidate | `user_block` and/or `identity.user_block` exists | **Partial.** Enforce in every profile search, view, download, outreach, and API path; test bypass routes. |
| Recruiter sees only jobs assigned to their company | Organisation recruiter/assignment tables exist, but effective row-level policies are not established by table presence | **Access-control test required.** Enforce in DB/RLS or trusted access layer; never rely on UI filtering. |
| Consultant sees only jobs open to consultants | No complete dedicated sourcing-request workflow is established by this schema alone | **Gap to verify.** Model consultant openness, request lifecycle, employer accept/decline and audit trail. |
| Recruiters cannot register candidates on their behalf | This is an access/workflow rule, not proven by a column | **Enforce in authorisation layer** and audit contact/outreach actions. |
| Every sensitive action recorded | Audit event tables exist, but coverage and immutability are not proven | **Required implementation and tests.** |
| Profile download history records recruiter/employer, candidate, timestamp and credit deduction | No dedicated download history entity found | **Not implemented in source.** Add append-only download event with actor, subject, timestamp, credit transaction and request ID. |
| Community posts and reactions | No dedicated community post/reaction entities found | **Optional/expected-domain gap.** Add only if community is in committed scope. |
| Analytics facts/dimensions, dashboard aggregates | Operational history/event tables exist; dedicated marts not found | **Not implemented in source.** Add analytics-prefixed facts/dimensions or materialized views and document refresh lineage. |

### Integration boundary rules

| Boundary | What the schema should store | Must not store / required control |
|---|---|---|
| Payment gateway | Provider transaction/order/refund references, status, amount, currency, idempotency key, timestamps | Do not store card/bank credentials; verify webhook signatures and make event handling idempotent. |
| Identity verification | Outcome/status, provider token/reference, timestamps and failure code | Do not store raw national identity numbers in clear text; encrypt/tokenise and restrict access. |
| Company/tax verification | Identifier type/country and lookup reference, status/history | Protect tax/registration identifiers and audit every verification action. |
| Gig fulfilment | External handoff reference, assignment state, reconciled estimated/actual/projected earnings | Platform records integration state; it does not execute fulfilment. |
| Notification providers | Channel, provider reference, delivery status, retries and failure codes | Minimise retained message bodies and avoid secrets/personal data in logs. |
| Legacy job/candidate systems | External source IDs, sync status, field ownership/conflict metadata | Define source of truth per field, idempotency, conflict policy and sync audit. |
| Mapping/geolocation | Optional coordinates/place reference with source and precision | Treat as optional; restrict precision/access when it reveals sensitive locations. |

### Data dictionary obligations still required

For each column in the entity inventory above, the team should add a project-level data dictionary annotation for: (1) sensitivity class (`Public`, `Internal`, `Personal`, `Sensitive`), (2) nullability justification, (3) retention and deletion behaviour, (4) owner/source of truth, (5) timezone/display handling, and (6) validation rules. These annotations are not all expressible in PostgreSQL DDL, so their absence from a table definition must not be mistaken for compliance.

## Entity coverage index

Unique source tables documented in this file: **142**.

- **4. Administration — Phase 2 — Member A**: `audit_event`, `identity.audit_event`, `system_error_log`, `identity.system_error_log`, `permission`, `identity.permission`, `role_permission`, `identity.role_permission`, `account_role`, `account_status_history`, `login_attempt`, `support_ticket`, `support_ticket_message`, `faq_article`, `consent_record`, `identity.consent_type`, `identity.user_consent`, `identity.db_principal`, `identity.app_role`, `identity.account_status`, `reference_code`, `reference_translation`, `ui_translation`, `industry`, `job_role`, `activity_type`, `candidate_activity_type`, `job_event_type`, `hiring_stage_type`, `verification_status`, `document_type`, `education_level`, `employment_type`, `experience_type`, `proficiency_level`, `question_type`, `application_status`, `interview_status`, `offer_status`, `job_status`, `job_position_status`, `referral_status`, `withdrawal_outcome`, `stage_decision`, `eligibility_decision`, `score_scale`, `salary_period`, `work_type`, `currency`, `country`, `state`, `city`, `language`, `qualification`, `skill`, `subject`, `social_platform`, `accomplishment_type`, `course_enrolment_status`
- **5. Organisation and Account — Phase 2 — Member B**: `organisation`, `organisation.account_profile`, `organisation.account_administrator`, `organisation.account_status`, `organisation.identifier_type`, `organisation.organisation_identifier`, `organisation.organisation_location`, `organisation.organisation_member`, `organisation.organisation_recruiter`, `organisation.organisation_type`, `organisation.verification_record`, `organisation.verification_type`, `account_profile`, `account_organisation`, `account_role`, `user_account`, `user_role`, `organisation_account_admin`, `organisation_external_system`, `organisation_hierarchy`, `organisation_identifier`, `organisation_location`, `organisation_recruiter`, `organisation_status_history`, `organisation_verification`, `organisation_verification_history`, `user_block`, `identity.user_block`, `organisation.job_recruiter_assignment`
- **6. Gig Marketplace — Phase 2 — Member C**: `gig_application`, `gig_application_status_history`, `gig_assignment`, `gig_earnings_reconciliation`, `gig_event`, `gig_fulfilment_handoff`, `gig_rating`, `gig_request`, `gig_request_skill`, `gig_service`, `gig_service_skill`, `gig_worker_availability`, `gig_worker_list`, `gig_worker_list_entry`, `gig_worker_profile`, `gig.application_status`, `gig.assignment_status`, `gig.availability_status`, `gig.fulfilment_event`, `gig.gig_application`, `gig.gig_assignment`, `gig.gig_availability`, `gig.gig_rating`, `gig.gig_request`, `gig.gig_service`, `gig.gig_worker_list_entry`, `gig.gig_worker_profile`, `gig.pricing_model`, `gig.rate_unit`, `gig.request_status`, `gig.worker_list_type`, `gig.worker_project`
- **7. Licences, Seats, Devices and Sessions — Phase 3 — Assigned member**: `user_credential`, `identity.credential`, `identity.credential_type`, `identity.hash_algorithm`, `identity.session_record`, `identity.session_status`, `identity.db_principal`, `identity.user_role`, `identity.permission`, `identity.role_permission`, `identity.audit_event`, `identity.account_status`, `identity.app_role`, `identity.user_consent`, `identity.consent_type`, `identity.user_block`, `identity.system_error_log`, `identity_session`, `login_attempt`, `user_account`, `user_role`, `permission`, `role_permission`, `user_preference`
- **8. Sourcing and Consultant Requests — Phase 3 — Assigned member**: `gig_request`, `gig_request_skill`, `gig_service`, `gig_service_skill`, `gig_worker_profile`, `gig_worker_availability`, `gig_worker_list`, `gig_worker_list_entry`, `gig_application`, `gig_application_status_history`, `gig_assignment`, `gig_event`, `gig_fulfilment_handoff`, `gig_earnings_reconciliation`, `gig_rating`, `gig.gig_request`, `gig.gig_service`, `gig.gig_worker_profile`, `gig.gig_worker_list_entry`, `gig.worker_project`, `gig.gig_application`, `gig.gig_assignment`, `gig.gig_availability`, `gig.gig_rating`, `gig.request_status`, `gig.application_status`, `gig.assignment_status`, `gig.availability_status`, `gig.fulfilment_event`, `gig.pricing_model`, `gig.rate_unit`, `gig.worker_list_type`, `organisation_recruiter`, `organisation_account_admin`, `organisation.organisation_recruiter`, `organisation.organisation_member`, `organisation.job_recruiter_assignment`, `user_block`, `identity.user_block`
- **9. Subscriptions, Wallet, Payments and Download History — Phase 3 — Assigned member**: `gig_earnings_reconciliation`, `gig_assignment`, `gig_application`, `gig_rating`, `notification_delivery`, `audit_event`, `identity.audit_event`, `account_profile`, `account_organisation`, `organisation`, `user_account`, `user_preference`, `identity.credential`, `identity.session_record`
- **10. Notifications, Preferences and Community — Phase 4 — Whole team**: `notification_delivery`, `notification_preference`, `user_preference`, `user_block`, `identity.user_block`, `support_ticket`, `support_ticket_message`, `faq_article`, `consent_record`, `identity.user_consent`, `identity.consent_type`, `candidate_activity_log`, `profile_view_history`, `candidate_bookmark`, `candidate_bookmark_history`, `referral_tracking`, `gig_event`, `gig_rating`, `gig_worker_list`, `gig_worker_list_entry`, `identity.audit_event`, `system_error_log`, `identity.system_error_log`
- **11. Analytics Layer and Reporting Marts — Phase 4 — Assigned member**: `candidate_activity_log`, `profile_view_history`, `candidate_job_search_history`, `referral_tracking`, `job_status_history`, `job_event`, `application_status_history`, `application_stage_result`, `assessment_result`, `shortlist_history`, `organisation_status_history`, `organisation_verification_history`, `gig_event`, `gig_earnings_reconciliation`, `notification_delivery`, `login_attempt`, `identity.audit_event`, `audit_event`, `system_error_log`, `identity.system_error_log`, `support_ticket`, `support_ticket_message`

---

*Generated from the supplied expanded schema dump. Proposed gaps and business rules are explicitly labelled; they are not claims about current database enforcement.*
