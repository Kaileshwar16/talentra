# 02 Output schema definition — Stakeholders, Personas and Roles

| Field / section | Type and rule | Required |
| --- | --- | --- |
| `actors[]` | Unique `ACT-##`, human/system classification, source, frequency/trigger, requirement IDs | Yes |
| `personas[]` | Actor ID, goal, context, top task, pain/failure, data needed, constraint, success signal | One per materially distinct actor |
| `role_permissions[]` | Role, resource, action, scope predicate, allow/deny, enforcing layer, audit expectation | Yes for every docket privilege |
| `interactions[]` | Initiator, other actor, workflow ID, handoff and failure owner | Yes for cross-actor flows |
| `review_questions[]` | Ambiguous privilege, risk, proposed resolution, owner and acceptance status | Yes where undecided |

Validation: every mandatory requirement has at least one actor; each permission has an explicit scope and enforcement owner; guest and service actors are included; candidates own their registration; recruiter permissions never imply registering a candidate; blocked-party and same-company rules appear as denials. A proposed permission is not labeled implemented. See [the output](output-document.md).
