# B66 seed validation and coverage gap register

Run on 2026-10-17 against Neon project `jolly-pond-45332483`, production branch `br-jolly-dawn-azv4gh54`, database `neondb`. [Read-only checks](../queries/b66_seed_quality.sql) and [exact results](b66-seed-quality-results.json) cover selected docket §5 data standards and seed distribution. DQ04 hit one transient MCP transport error; the same query succeeded on retry. No data or schema was changed.

## Results

| Check | Observed | Interpretation |
| --- | --- | --- |
| DQ01 volume | 250k candidates, 25k jobs, 1.25m applications | 25% of B60/B61 laptop-scale target |
| DQ01 candidate detail | 0 education, experience, skill, language and resume rows | Required profile domains exist in schema but are absent from bulk seed |
| DQ01 recruiter assignments | 0 job assignments | B62 recruiter scope cannot be demonstrated with the seed |
| DQ02 email | 250,040 non-null emails; 0 mixed case, malformed or normalized duplicate values | Format check passed for present data; regex is a screening rule, not full RFC validation |
| DQ02 phone | 0 phone contacts | E.164 check reports zero violations because there is no phone data; **untested** |
| DQ03 ranges/money | 0 reversed salary bounds, salaries without currency, negative payments or wallet balances | Passed for 18,750 jobs with at least one salary bound, 10 payments and 10 wallets; education/experience date checks are vacuous |
| DQ04 relationships | 0 missing candidate, job or status references across 1.25m applications | Passed for current seed |
| DQ05 catalog | 0 unvalidated constraints among 2,571 checked constraints | Passed catalog validity check; not a substitute for behavior tests |
| DQ06 gig windows | 0 overlapping active assignment pairs | Current 100-assignment seed has no overlap; rejection of an attempted overlap remains untested |
| DQ07 marts | 10 funnel rows, latest date 2026-10-16, sum `applied_count` 500 versus 1.25m source applications | Mart is not reconciled after the bulk expansion; exact semantics must be defined before comparing totals |
| DQ08 missing salary | 6,250 jobs have both salary bounds null | May represent undisclosed salary; requires a documented null reason, not a guessed zero |
| DQ09 uniqueness | 0 duplicate candidate-job pairs | Passed for current seed |

## Docket §5 rule-group coverage

| Rule group | Current evidence | Remaining gap |
| --- | --- | --- |
| 1 Naming; 8 physical object naming | Phase 1–4 catalog exports | Run a complete exception/naming audit across production objects |
| 2 Keys and constraints | DQ04/DQ05/DQ09 pass; prior phase SQL tests on test branch | Repeat transactional/limit tests on production-equivalent branch; validate app role behavior |
| 3 Standard domains | DQ02/DQ03 checks for email, phone, range, salary/currency | Phone and profile detail data absent; no full column-by-column domain audit |
| 4 Audit and lifecycle | Audit table and seed event exist | Sensitive-action coverage, deletion and retention behavior untested |
| 5 Nullability and unknown values | Salary null count measured | Written nullable-column justifications and unknown/not-applicable distinctions incomplete |
| 6 Sensitive data classification | Phase docs include some classes | Complete column classification and encryption/masking evidence outstanding |
| 7 Multilingual data | Saved seed report has multilingual names | UI translation completeness, fallback and user-content language metadata untested |
| 9 Licence, devices and sessions | Phase 3 schema/test suite exists | Concurrent login/device-cap behavior on production-equivalent branch untested |
| 10 Money, subscriptions and history | DQ03 monetary checks; phase test suite | Append-only/compensation/refund and period-overlap cases need production-equivalent negative tests |

## Coverage gaps to close

1. **Capacity and scale (B60/B61):** a larger isolated environment or capacity change is required before the 1m/100k/5m measured dataset. Do not load the rest into the current 1 GiB production branch.
2. **Representative candidate data (B60):** seed education, experience, skill, language, resume and contact rows with realistic distributions, international names and deliberate edge cases. Rerun DQ02/DQ03 against nonempty rows.
3. **Recruiter and gig negative cases (B62):** seed assigned jobs for mapped recruiters and attempt overlapping active gig windows inside rollback-only tests. The production view layout must be reconciled first.
4. **Analytics (B64/B66):** define the funnel grain and metric semantics, refresh after the final bulk seed, then reconcile a declared cohort/source query. The current 10 rows cannot stand for the full application population.
5. **Data dictionary/security:** finish per-column nullability, sensitive class, masking/retention and rule enforcement mapping; see [production Phase 2 reconciliation](production-phase2-reconciliation.md).

**B66 deliverable status:** validation report complete for the current partial seed, with explicit gaps and failures. The **seed does not pass full docket validation**. B67–B69 module query validations remain open.
