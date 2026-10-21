# 01 Schema rating scorecard

Rubric fixed before rating: each criterion earns 0 (missing), 1 (partial), or 2 (clear and reviewable); 8/10 is an internal green threshold, not a playbook rule. This is a team self-review, not stakeholder acceptance.

| Criterion | Score | Evidence / correction |
| --- | ---: | --- |
| Covers problem, scope, requirements, rules and questions | 2 | Separate required sections and IDs |
| Source-to-requirement trace | 2 | Source section and explicit exclusion required |
| Actor and downstream links | 2 | Actor mandatory; feature, workflow and test intents linked |
| Ambiguity and decisions | 2 | Question impact, owner and decision status explicit |
| Mechanical and human validation | 1 | Invariants defined; sentence-level source audit still needs a reviewer |
| **Total** | **9/10** | Schema is usable; output acceptance is a separate decision |

Challenge to the rubric: a source-section pointer may hide multiple obligations in one paragraph. Reviewers must inspect the docket sentence by sentence before G1, not merely count IDs.
