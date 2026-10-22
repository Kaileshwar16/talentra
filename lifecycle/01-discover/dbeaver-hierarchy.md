# Presenting the local Talentra database in DBeaver

Use this with the read-only `talentra_viewer` connection to `talentra_local` at `127.0.0.1:15432`. This is the local synthetic database, not Neon production. The [presentation SQL](dbeaver-presentation.sql) contains only `SELECT` statements.

For a browser-friendly overview before opening DBeaver, use the [graphical schema hierarchy](schema-hierarchy.html). It was generated from a read-only local PostgreSQL catalog snapshot; click a table to inspect its columns and foreign-key neighbors.

## The hierarchy to show

```text
talentra_local
├── public (195 physical tables): core profile, jobs, applications, commercial and shared modules
│   ├── user_account → candidate_profile → application → job_requirement → organisation
│   ├── subscriptions, wallet and wallet_transaction_ledger
│   ├── notification_preference, notification_delivery and analytics marts
│   └── populated gig examples: gig_request → gig_application → gig_assignment
├── identity (16 tables): roles, credentials, consent, blocks, sessions, audit
├── organisation (12 tables): account, verification, recruiter mapping
├── gig (17 physical design tables): request → application → assignment → fulfilment reference
└── neon_auth (2 local compatibility tables): foreign-key targets, not a business module
```

The table counts and core foreign-key links above were read from `talentra_local` on 22 October 2026. The `public` schema is large because several phased modules use it. The current `gig` physical tables have **zero rows**, while `public.gig_request`, `public.gig_application` and `public.gig_assignment` each have **100 synthetic rows**. Show `gig` for its design and `public` for gig data. Do not show all 195 public tables at once.

## Five-minute live walkthrough

| Time | Show in DBeaver | One sentence to say |
| --- | --- | --- |
| 0:00–0:30 | Connections → `talentra_local` → Schemas; expand `public`, `identity`, `organisation`, `gig` | “The database is organized by business responsibility; `public` holds the original core plus later shared modules.” |
| 0:30–1:30 | Core diagram: `user_account`, `candidate_profile`, `application`, `job_requirement`, `organisation` | “A candidate owns a profile, applies to a posted job, and the job belongs to an organisation.” |
| 1:30–2:15 | Open `application` Columns/Foreign Keys, then run the synthetic candidate query | “These are enforced references, and we can trace one candidate through five applications.” |
| 2:15–3:00 | Show `identity` and `organisation` schemas; point to `user_block`, `audit_event`, `job_recruiter_assignment` | “Access, audit and recruiter assignment are modelled explicitly, although production-role behavior still needs separate proof.” |
| 3:00–3:45 | Gig design diagram: `gig.gig_worker_profile`, `gig.gig_request`, `gig.gig_application`, `gig.gig_assignment`; then populated `public.gig_*` query | “Gig work has a separate physical model; this local seed's examples are in the public compatibility tables.” |
| 3:45–4:30 | Run core count query and show one finance/notification table | “The local seed has one million candidates, 100,000 jobs and five million applications, plus smaller operational examples.” |
| 4:30–5:00 | [Stage 1 index](README.md) and [gate register](decisions-and-gaps.md) | “These data examples support the discovery documents; G1 review and performance/security sign-off remain open.” |

## Make the hierarchy readable

1. In DBeaver **Connections**, expand only the current schema and use the filter bar to find the named tables. DBeaver documents the tree and filters in its [Connections guide](https://dbeaver.com/docs/dbeaver/Database-Navigator/) and [filter guide](https://dbeaver.com/docs/dbeaver/Filter-Database-Objects/).
2. Create a small custom ER diagram with **File → New → DBeaver → ER Diagram**. Name it `Talentra core hiring`. Add the five core tables above; create a second diagram named `Talentra gig`. DBeaver's [custom-diagram guide](https://dbeaver.com/docs/dbeaver/Custom-Diagrams/) describes this workflow.
3. In each diagram, right-click blank space → **Show Attributes → Any keys**; choose **Crow's Foot** notation and auto-arrange. Keep relationships visible, then export a PNG. These controls and export formats are in DBeaver's [diagram guide](https://dbeaver.com/docs/dbeaver/How-to-use-Diagrams/). Use `SVG` only if your DBeaver edition offers it.
4. Keep one SQL editor open with [dbeaver-presentation.sql](dbeaver-presentation.sql). Run one selected query at a time. Show only a small number of rows, then switch back to the diagram.

## Exact synthetic example

The candidate `seed5-00000001@talentra.example` currently has candidate ID `1`, the name `ليلى أحمد`, and five applications in this local database. `Phase 5 Job 000001` currently has job ID `1`. Both are synthetic; the SQL finds them by stable demo values rather than assuming every future seed preserves IDs.

## Accuracy notes

- The counts and sample IDs are local observations from 22 October 2026. Re-run the SQL before presenting if the seed changes. The physical `gig` schema currently has no sample rows.
- DBeaver's `talentra_viewer` bypasses row security for local inspection; this walkthrough is **not** a demonstration of real role isolation.
- Use the small diagrams to explain domain relationships. The full-schema diagram would be crowded and would obscure the main story.
