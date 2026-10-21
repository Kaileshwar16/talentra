# 05 Output schema definition — Business Workflow Analysis

Each workflow requires a stable `WF-ID`, trigger, initiating and participating actors, preconditions, main path, decisions, state transitions, persisted records/events, success outcome, exception and recovery paths, authorization rule, feature links and test intent. A diagram may group workflows if its nodes retain the IDs and the catalogue supplies the detailed branches.

Validate that every `Must` feature has a workflow, every workflow has at least one exception, denied actions are auditable where sensitive, retries are idempotent at external boundaries, and terminal states do not silently revert. Cross-check actors and permissions against the persona matrix.
