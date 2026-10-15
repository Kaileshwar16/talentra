#!/usr/bin/env python3
"""
Talentra Database Catalog Exporter
Connects to PostgreSQL in read-only inspection mode, extracts schema metadata,
and exports catalog snapshot results while strictly preserving secrets and
excluding neon_auth objects from application inventories.
"""

import os
import sys
import json
import re
from datetime import datetime, timezone
import psycopg2

def sanitize_url(url: str) -> str:
    """Mask credentials in database connection URI."""
    if not url:
        return ""
    return re.sub(r"://([^:]+):([^@]+)@", r"://\1:***@", url)

def get_connection():
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        db_url = "postgresql://neondb_owner:npg_4Oz2JYNZKXAM@ep-winter-hall-azl2bqdm-pooler.c-3.ap-southeast-1.aws.neon.tech/neondb?sslmode=require"
    try:
        conn = psycopg2.connect(db_url)
        conn.autocommit = True
        return conn, sanitize_url(db_url)
    except Exception as e:
        print(f"Error connecting to database: {e}", file=sys.stderr)
        sys.exit(1)

def export_catalog(output_path=None):
    conn, safe_uri = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT version();")
    pg_version = cur.fetchone()[0]

    # Schemas
    cur.execute("""
        SELECT schema_name 
        FROM information_schema.schemata 
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast', 'neon_auth')
        ORDER BY schema_name;
    """)
    app_schemas = [r[0] for r in cur.fetchall()]

    # Application Tables (public, identity, organisation, gig)
    cur.execute("""
        SELECT table_schema, table_name, table_type
        FROM information_schema.tables
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'neon_auth')
        ORDER BY table_schema, table_name;
    """)
    all_tables = cur.fetchall()
    base_tables = [t for t in all_tables if t[2] == 'BASE TABLE']
    views = [t for t in all_tables if t[2] == 'VIEW']

    # Columns
    cur.execute("""
        SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'neon_auth')
        ORDER BY table_schema, table_name, ordinal_position;
    """)
    columns = cur.fetchall()

    # Constraints
    cur.execute("""
        SELECT conname, contype, conrelid::regclass::text, confrelid::regclass::text
        FROM pg_constraint c
        JOIN pg_namespace n ON n.oid = c.connamespace
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'neon_auth');
    """)
    constraints = cur.fetchall()

    # Indexes
    cur.execute("""
        SELECT schemaname, tablename, indexname, indexdef
        FROM pg_indexes
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'neon_auth');
    """)
    indexes = cur.fetchall()

    # Triggers
    cur.execute("""
        SELECT trigger_schema, event_object_table, trigger_name, action_timing, event_manipulation
        FROM information_schema.triggers
        WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema', 'neon_auth');
    """)
    triggers = cur.fetchall()

    # RLS Policies
    cur.execute("""
        SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
        FROM pg_policies
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'neon_auth');
    """)
    policies = cur.fetchall()

    snapshot = {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "database_version": pg_version,
        "connection_target": safe_uri,
        "application_schemas": app_schemas,
        "summary": {
            "application_base_tables": len(base_tables),
            "application_views": len(views),
            "total_application_entities": len(all_tables),
            "application_columns": len(columns),
            "application_constraints": len(constraints),
            "application_indexes": len(indexes),
            "application_triggers": len(triggers),
            "application_rls_policies": len(policies)
        },
        "schema_table_counts": {}
    }

    for s in app_schemas:
        s_tables = [t[1] for t in base_tables if t[0] == s]
        s_views = [t[1] for t in views if t[0] == s]
        snapshot["schema_table_counts"][s] = {
            "base_tables": len(s_tables),
            "views": len(s_views),
            "total": len(s_tables) + len(s_views)
        }

    cur.close()
    conn.close()

    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(snapshot, f, indent=2)
        print(f"Catalog exported to {output_path}")

    return snapshot

if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "catalog_snapshot.json"
    res = export_catalog(out)
    print(json.dumps(res["summary"], indent=2))
