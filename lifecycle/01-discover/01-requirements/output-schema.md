# 01 Output schema definition — Requirement Analysis Docket

The output is a versioned requirements docket, not a database table. Each requirement is one record; related actors, features, workflows, rules and tests are linked by stable IDs rather than repeated prose.

| Field / section | Type and rule | Required |
| --- | --- | --- |
| `problem` | One statement naming the current failure and desired outcome | Yes |
| `scope.in` / `scope.out` | Explicit sourced boundaries; every exclusion has an ID `OS-##` | Yes |
| `requirements[]` | Unique `REQ-##`, atomic statement, source section, `M/E/S` priority, at least one actor ID, acceptance intent, ambiguity, evidence state | Yes |
| `business_rules[]` | Unique rule ID, trigger, condition, allowed/denied outcome, owning requirement | Yes where the docket states a rule |
| `data_domains[]` | Domain, tier, owning requirement, missing-field question | Yes |
| `questions[]` | Unique `Q-##`, impact rank, decision owner, deadline/next action, affected requirement IDs | Yes for unresolved items |
| `trace[]` | Source section → requirement or explicit out-of-scope ID; requirement → actor/feature/workflow/test intent | Yes |
| `decisions[]` | ID, choice, reason, source, status (`proposed/accepted/rejected`) and owner | Yes |

Validation: IDs are unique; no mandatory requirement lacks source, actor or acceptance intent; no assumption is presented as a docket fact; Tier 1, Tier 2 and rule groups are checked against the PDF. Exit check: every substantive brief statement maps to a requirement or exclusion, and high-impact questions have named decision owners. See [the output](output-document.md).

**Filled example:** The docket's recruiter company rule is `REQ-03`, source section 3, priority M, actor ACT-03, feature FEAT-03 and workflow WF-03. The acceptance intent is to allow an assigned job at the recruiter's company and deny the same recruiter's request for another company's job. The remaining ambiguity is where the production read path enforces the rule. This is the level of detail each docket row should support; the sentence-level audit remains open.
