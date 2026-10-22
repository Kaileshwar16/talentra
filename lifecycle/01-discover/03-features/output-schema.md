# 03 Output schema definition — Feature Discovery

The output is a feature inventory that a product owner can use to decide scope. Each row must say who benefits, what changes for them, why the source calls for it, and how a reviewer will recognize it. The priority values are `Must`, `Should` and `Differentiator hypothesis`; a mixed row must state which detail belongs to which class.

| Field | Required content | Example from this pack |
| --- | --- | --- |
| `feature_id` and name | Unique stable `FEAT-##` and plain-language capability | `FEAT-08 — Subscription, wallet and refund ledger` |
| `outcome` and actor | User-visible reason and `ACT-##` | Employer sees one explainable balance; ACT-02 |
| `priority` and source | Class plus `REQ-##` and docket section | Must; REQ-10, sections 4–5 |
| `workflow` and dependencies | `WF-##` and required earlier records | WF-08; identity, account, provider reference |
| `acceptance` | Observable allow, deny and recovery behavior | Duplicate payment callback creates no second credit |
| `evidence_state` and question | Designed, locally tested or unverified; owner of open choice | Refund timing still needs finance owner |

Every in-scope requirement must be represented by a feature or a stated structural obligation. Every Must feature must appear in a workflow and a test intent. Optional insights must keep a source or be marked `NEW-INSIGHT` until approved.

The competitor matrix must show at least Naukri, Monster and LinkedIn, an official page for each claimed capability, a direct Talentra comparison and an evidence limit. `Unverified` means the inspected public material did not establish the capability; it never means the competitor lacks it. Validate ID uniqueness, referenced REQ/ACT/WF IDs, Must coverage and source dates before review.
