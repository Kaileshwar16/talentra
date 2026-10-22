# 04 Schema rating scorecard

Team self-review, not acceptance. Score 0 missing, 1 partial, 2 reviewable; 8/10 is an internal threshold.

| Criterion | Score | Evidence / gap |
| --- | ---: | --- |
| Metric, target, unit and basis | 2 | NFR-01 uses docket row counts; NFR-13 shows the 60-read/s calculation; NFR-10 has 100% policy coverage and provisional 24-month review |
| Measurement method and evidence | 2 | Query, role, refresh and restore methods defined |
| Environment and workload distinction | 2 | Local laptop-scale versus full-scale model and production separated |
| Approval and uncertainty | 2 | Proposals and pending decisions are labelled |
| Complete numeric targets | 1 | Every row is numeric, but per-entity retention values and approval of RTO/RPO/latency remain open |
| **Total** | **9/10** | Schema works; NFR register cannot pass target acceptance yet |

The score rates the representation and honesty of unknowns. It does not imply that all NFR targets have been accepted or met.
