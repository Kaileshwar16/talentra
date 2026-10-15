# Talentra database

This repository contains the Talentra database design source, the connected ER diagram, and the Phase 1 PostgreSQL implementation.

The [Phase 1 design and validation record](TALENTRA_SCHEMA.md) explains scope, table relationships, constraints, and what remains for later phases. The [migration](migrations/001_connected_er.sql) was applied to the `Talentra` Neon project (`production` branch, `neondb` database). The [constraint checks](tests/phase1_constraints.sql) ran successfully on that database and roll back their test data.

The original [hackathon docket](Talentra-Database-Design-Hackathon-Docket.pdf), [connected ER diagram](Talentra_Connected_ER_Diagram%20%281%29.png), and [older all-module SQL draft](talentra_schema.sql) are retained as source material. The older draft was not executed and should not be applied on top of the Phase 1 migration.

`docs/phase1/` contains the table, column, relationship, index, trigger, and validation exports from the installed schema. The docket is marked confidential, so keep this repository private unless its owner approves sharing it.
