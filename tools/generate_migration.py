#!/usr/bin/env python3
"""
Talentra Migration Generator Utility
Creates boilerplate for new PostgreSQL migrations adhering to Talentra engineering rules:
- Transaction envelope (BEGIN / COMMIT)
- Conservative lock and statement timeouts
- Clear phase/module metadata header
- Rollback and dependency guidance
"""

import os
import sys

TEMPLATE = """-- =============================================================================
-- Migration: {filename}
-- Phase: {phase}
-- Module Coverage: {modules}
-- Description: {description}
-- Dependencies: {dependencies}
-- Platform: PostgreSQL 18 on Neon
-- =============================================================================

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';

-- 1. Entity definitions and schema alterations


-- 2. Constraints and Indexes


-- 3. Security policies and triggers


COMMIT;

-- Rollback Guidance:
-- If deployment fails, review system logs and execute compensating DDL in reverse order.
"""

def generate_migration(phase: int, name: str, modules: str, description: str, target_dir: str):
    os.makedirs(target_dir, exist_ok=True)
    filename = f"{name}.sql"
    filepath = os.path.join(target_dir, filename)

    content = TEMPLATE.format(
        filename=filename,
        phase=f"Phase {phase}",
        modules=modules,
        description=description,
        dependencies=f"Prior migrations up to Phase {phase - 1}" if phase > 1 else "None (Initial)"
    )

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Created migration boilerplate: {filepath}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: generate_migration.py <phase_num> <migration_name> [modules] [description]")
        sys.exit(1)
    phase = int(sys.argv[1])
    name = sys.argv[2]
    mods = sys.argv[3] if len(sys.argv) > 3 else "Module X"
    desc = sys.argv[4] if len(sys.argv) > 4 else "New feature migration"
    out_dir = f"phase{phase}/migrations"
    generate_migration(phase, name, mods, desc, out_dir)
