# 05 Output schema definition — Business Workflow Analysis

The output is one readable card per workflow, supported by a diagram and exception catalogue. Each card must answer: who starts this, what happens next, what decision changes the route, what is saved, and what happens when it fails?

| Field | Required content | Example from this pack |
| --- | --- | --- |
| `workflow_id`, trigger | Unique `WF-##` and initiating event | WF-08 starts when employer subscribes or recharges |
| `actors`, preconditions | ACT IDs and access/payment conditions | Employer ACT-02, gateway ACT-10; verified account |
| `steps`, decision | Ordered main path and branch condition | Pending order → keyed confirmation → credit; was payment confirmed once? |
| `output`, records | State/event and who can see it | Entitlement, invoice reference and append-only ledger events |
| `exceptions`, recovery | Cancel, retry, timeout, refund or denial where applicable | Timeout stays pending; duplicate callback ignored; refund compensates |
| `feature`, `test` | FEAT ID and test intent | FEAT-08; replay callback and check one credit |

The diagram is an overview, so its labels must retain WF IDs and must not replace the detailed card. Each Must feature must appear in at least one workflow. A failed external action must retain an idempotency key and a visible terminal or review state.

Validate that every `Must` feature has a workflow, every workflow has at least one exception, denied actions are auditable where sensitive, retries are idempotent at external boundaries, and terminal states do not silently revert. Cross-check actors and permissions against the persona matrix.
