-- Read-only PostgreSQL catalog snapshot for the offline schema hierarchy.
-- Run against the local talentra_local database. No application rows are read.
SELECT jsonb_build_object(
  'database', current_database(),
  'capturedAtUtc', to_char(current_timestamp AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
  'objects', (
    SELECT jsonb_agg(
      jsonb_build_object(
        'schema', n.nspname,
        'name', c.relname,
        'kind', CASE c.relkind WHEN 'r' THEN 'table' WHEN 'p' THEN 'partitioned table'
                  WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' END,
        'columns', (
          SELECT coalesce(jsonb_agg(jsonb_build_object(
            'name', a.attname,
            'type', format_type(a.atttypid, a.atttypmod),
            'nullable', NOT a.attnotnull,
            'primaryKey', EXISTS (
              SELECT 1 FROM pg_constraint pk
              WHERE pk.conrelid = c.oid AND pk.contype = 'p' AND a.attnum = ANY(pk.conkey)
            )
          ) ORDER BY a.attnum), '[]'::jsonb)
          FROM pg_attribute a
          WHERE a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
        ),
        'foreignKeys', (
          SELECT coalesce(jsonb_agg(jsonb_build_object(
            'name', fk.conname,
            'column', from_col.attname,
            'toSchema', target_n.nspname,
            'toTable', target_c.relname,
            'toColumn', target_col.attname
          ) ORDER BY fk.conname, key_pair.i), '[]'::jsonb)
          FROM pg_constraint fk
          JOIN LATERAL generate_subscripts(fk.conkey, 1) AS key_pair(i) ON true
          JOIN pg_attribute from_col ON from_col.attrelid = c.oid AND from_col.attnum = fk.conkey[key_pair.i]
          JOIN pg_class target_c ON target_c.oid = fk.confrelid
          JOIN pg_namespace target_n ON target_n.oid = target_c.relnamespace
          JOIN pg_attribute target_col ON target_col.attrelid = target_c.oid AND target_col.attnum = fk.confkey[key_pair.i]
          WHERE fk.conrelid = c.oid AND fk.contype = 'f'
        )
      ) ORDER BY n.nspname, c.relname
    )
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname IN ('public', 'identity', 'organisation', 'gig', 'neon_auth')
      AND c.relkind IN ('r', 'p', 'v', 'm')
  )
);
