# 04 Output schema definition — NFR Discovery

One NFR record requires `NFR-ID`, quality attribute, metric, target and unit, population/workload, measurement method, evidence artifact, source/basis, status (`Docket`, `Proposal`, `Undetermined`), owner, and decision or exception. A target supplied by the docket must remain distinct from a team proposal. Missing values remain explicit decisions rather than invented acceptance criteria.

Validate every target is measurable, each test has a workload and environment, every proposal has an approval owner, and every undetermined target has a decision path. Database-scale evidence must identify the exact environment; local seed counts cannot prove production latency, availability or access control.
