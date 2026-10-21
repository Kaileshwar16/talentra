# 05 Output document — Business Workflow Analysis

The [WF-01–12 catalogue](../nfr-workflows.md) is the authoritative trigger, actor, core flow and failure-path inventory. Together with the [FEAT-01–12 inventory](../actors-goals-features.md), it maps every must-have capability to a workflow. These diagrams expose the main handoffs and decisions; the exception table below defines recovery intent.

## Candidate, job and controlled sourcing

```mermaid
flowchart LR
  A[WF-01 Candidate registers] --> B{Identity and consent valid?}
  B -- No --> X[Reject or review; log reason]
  B -- Yes --> C[Profile and history]
  C --> D[WF-02 Search published job]
  D --> E{Open and eligible?}
  E -- No --> Y[Explain denial]
  E -- Yes --> F[Apply once; record stage event]
  F --> G[Employer decision or withdrawal]
  H[WF-04 Verify company and recruiter mapping] --> I[WF-03 Check assignment, block and scope]
  I -- Allow --> J[WF-06 Approved sourcing and outreach]
  I -- Deny --> K[Audit denial]
  J --> F
```

## Gig, money and external handoff

```mermaid
flowchart LR
  A[WF-05 Gig request and worker bid] --> B{Available, unique, eligible?}
  B -- No --> X[Reject bid or resolve overlap]
  B -- Yes --> C[Accept assignment]
  C --> D[WF-11 Signed external handoff]
  D --> E{Callback valid and new?}
  E -- No --> Y[Quarantine, deduplicate or retry]
  E -- Yes --> F[Reconcile fulfilment status]
  G[WF-08 Subscribe or recharge] --> H{Payment confirmed?}
  H -- No --> Z[Retry or mark pending]
  H -- Yes --> I[Append ledger event and invoice]
  I --> J{Refund or reversal?}
  J -- Yes --> K[Compensating ledger entry]
```

## Sessions, communications and evidence

```mermaid
flowchart LR
  A[WF-07 Allocate seat and device] --> B{Within active limit?}
  B -- No --> X[Deny and audit]
  B -- Yes --> C[Session until revoke or expiry]
  D[WF-09 Preference and alert] --> E{Consented channel?}
  E -- No --> Y[Suppress and record]
  E -- Yes --> F[Queue, deliver, reconcile]
  G[WF-10 Refresh marts] --> H{Fresh and reconciled?}
  H -- No --> Z[Flag stale or mismatched KPI]
  H -- Yes --> I[Publish metrics]
  J[WF-12 Seed, validate and restore] --> K{Constraints, access and recovery pass?}
  K -- No --> L[Hold sign-off and record defect]
  K -- Yes --> M[Evidence ready for review]
```

## Exception catalogue and test intent

| WF | Trigger or failure | Response and evidence | Test intent |
| --- | --- | --- | --- |
| 01 | Duplicate identity, consent withdrawn | Reject duplicate; stop disallowed processing and audit request | Unique identity and consent-state test |
| 02 | Closed job, duplicate apply, illegal stage | Reject transition atomically; preserve event history | State-machine and uniqueness test |
| 03 | Cross-company, stale assignment, block | Deny before contact; audit actor and reason | Two-account/blocked-party test |
| 04 | Hierarchy cycle or overlapping mapping | Reject invalid mapping; retain prior state | Constraint and date-overlap test |
| 05 | Overlap, repeat bid, provider timeout | Reject invalid bid; retry handoff with stable key | Concurrency and idempotency test |
| 06 | Job closed to consultant or stale recruiter | Reject sourcing/outreach; audit denial | Scope and duplicate-recipient test |
| 07 | Seat cap race or revoked device | Enforce cap transactionally; terminate revoked session | Concurrent-login test |
| 08 | Duplicate webhook, refund, low balance | Apply once; compensate with new ledger entry | Replayed-callback and balance test |
| 09 | Opt-out or delivery exhaustion | Suppress or dead-letter; keep privacy-safe evidence | Preference and retry test |
| 10 | Late source event or wrong mart total | Mark stale; reconcile to source before publish | Refresh/funnel reconciliation test |
| 11 | Bad signature, duplicate/out-of-order callback | Quarantine or ignore idempotently; reconcile provider state | Callback-order and trust test |
| 12 | Capacity, constraint or restore failure | Hold gate and record exact environment/failure | Seed quality, role and restore test |

Reviewers still need to decide who owns several exception policies and to verify diagram states against implemented contracts. The [decision register](../decisions-and-gaps.md) keeps G1 open pending that review.
