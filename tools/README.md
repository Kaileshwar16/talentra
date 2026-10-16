# Talentra Database Automation & Validation Tools

This directory provides automated, reproducible Python CLI tools for managing, inspecting, and documenting the Talentra PostgreSQL 18 database architecture across all 11 modules and 4 phases.

## Security & Credential Hygiene
- **Zero Secrets Committed**: Tools read `DATABASE_URL` from the environment or secure local configuration. All printed strings and exported JSON snapshots mask passwords and credentials (`postgres://user:***@host/db`).
- **neon_auth Exclusion**: All tools explicitly filter out `neon_auth` schemas and tables to protect identity provider internals and respect hackathon scope boundaries.
- **Read-Only Default**: Catalog inspection operates with zero destructive commands (`DROP SCHEMA`, `DROP TABLE`, `TRUNCATE` are prohibited on live production).

---

## Tool Reference

### 1. `export_catalog.py`
Inspects the live database catalog and exports schema metadata, entity summaries, column inventories, constraint counts, index metrics, and trigger snapshots.

```bash
# Export catalog snapshot
python tools/export_catalog.py [output_path.json]
```

### 2. `export_docs.py`
Regenerates all required CSV and JSON phase deliverables directly from live PostgreSQL catalogs:
- `entities.csv`
- `columns.csv`
- `relationships.csv`
- `constraints.csv`
- `indexes.csv`
- `triggers.csv`
- `row-counts-result.json`
- `catalog-result.json`
- `scope.json`

```bash
# Regenerate documentation for all phases (1 through 4)
python tools/export_docs.py
```

### 3. `build_validation.py`
Executes SQL test suites (`phase1_constraints.sql`, `phase2_constraints.sql`, `phase3_constraints.sql`, `phase4_constraints.sql`), verifies SHA-256 migration hashes, checks catalog integrity, and generates `test-result.json`, `migration-result.json`, and `validation-report.json`.

```bash
# Run full cross-phase regression validation
python tools/build_validation.py
```
*Returns exit code 0 if all 102 checks pass, non-zero on failure.*

### 4. `generate_migration.py`
Scaffolds new migration files adhering to transaction safety, conservative lock timeouts, and standardized metadata headers.

```bash
python tools/generate_migration.py <phase_number> <migration_filename> "<module_coverage>" "<description>"
```
