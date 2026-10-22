# Presenter notes — Stage 1 discovery

## Opening

“We used the Talentra docket as the source of obligations and organized discovery into five linked questions: what is required, who acts, what features are needed, how well they must work, and how each workflow handles success and failure.”

For each step, **A** defines the output structure, **B** rates that structure in a team self-review, and **C** contains the actual Talentra findings. All 15 files are prepared. Gate G1 remains open for owner review.

Use the [requirement graph](requirement-graph.html) to show how one source statement becomes a requirement, actor link, feature and workflow. Use the [graphical schema hierarchy](schema-hierarchy.html) to show the separate database structure: `talentra_local` → schema → table → columns, then switch to foreign-key relationships. The schema page is an offline snapshot of the local database catalog.

## 01 · Requirement Analysis

“The legacy problem is inconsistent candidate, job and application records and no unified pipeline view. We grouped the docket into 18 requirements and four explicit exclusions, each with a source, priority, actor and ambiguity note. The full-scale target is a design for 10 million candidate profiles; the laptop proof target is one million.”

Show the [requirement output](01-requirements/output-document.md). Explain that sentence-level mapping and B1–B82 artifact trace are still open.

## 02 · Stakeholders and Roles

“We identified 16 actor categories, including candidates, employers, recruiters, distinct administrator roles, auditors, support staff, regulators, scheduled workers and a database engineer. The permission matrix defines allowed scopes and denials. Recruiters can only act on assigned jobs for their company, and candidate blocks must prevent visibility.”

Show the [stakeholder output](02-stakeholders/output-document.md). State that sensitive roles still need owner approval and real role tests.

## 03 · Feature Discovery

“Twelve feature groups connect requirements to workflows. We compared documented candidate and employer capabilities of Naukri, Monster and LinkedIn. Talentra’s combined hiring, gig handoff and financial record is a proposed opportunity; public pages do not prove competitor absence or Talentra superiority.”

Show the [feature output](03-features/output-document.md). Avoid an unsupported “we exceed all competitors” claim.

## 04 · NFR Discovery

“The local seed measures one million candidates, 100,000 jobs and five million applications. We have proposed numeric latency, load, availability, recovery, privacy and accessibility targets, with test methods. The 60-read-per-second load is derived from assumptions that the product owner must validate.”

Show the [NFR output](04-nfr/output-document.md). Personal-data retention periods and acceptance of proposed targets remain open; local counts do not prove production speed or access control.

## 05 · Workflow Analysis

“Twelve workflows cover every must-have feature group. Each records a trigger, actors, decisions and output. The exception catalogue includes cancellation, refund, retry, timeout, denied access and duplicate events.”

Show the [workflow output](05-workflows/output-document.md). Exception ownership and state transitions require domain-owner review.

## Close and request

“The document set is ready for independent review. Please assign product/domain, security/privacy and database/operations reviewers. We will record their decisions in the [gate register](decisions-and-gaps.md) and close G1 only after the outstanding checks pass.”
