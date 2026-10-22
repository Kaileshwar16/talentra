# 04 Output schema definition — NFR Discovery

The output is a testable quality register. A reader should be able to repeat the measurement and tell whether a number came from the docket or from a team proposal.

| Field | Required content | Example from this pack |
| --- | --- | --- |
| `nfr_id`, attribute | Unique `NFR-##` and quality question | NFR-13, peak read load |
| `metric`, `target`, `unit` | A number with denominator or time window | 60 reads/second for 30 minutes; p95 ≤500 ms |
| `workload`, `environment` | Data volume, query mix, hardware and role context | 1m candidates, 100k jobs, 5m applications on named local machine |
| `basis`, `status` | Docket section or calculation; `Docket` or `Proposal` | 1% active/day × 50 reads × 10 peak is a proposal |
| `method`, `artifact` | Exact measurement and where evidence is stored | Request samples with p50/p95/p99 and errors |
| `owner`, `decision` | Person/role who can accept or revise a proposal | Product/database owner to confirm load model |

For privacy retention, the numeric completeness target is 100% of personal-data entities with an approved period. A proposed 24-month candidate inactivity review is explicitly provisional; the actual per-entity periods remain a decision. This avoids presenting an invented legal deadline as fact.

Validate that each NFR has a number and test method, workload and environment where relevant, and approval owner for proposals. Local seed counts cannot prove production latency, availability or access control. A proposal is not marked met until its test is run under the accepted workload.
