-- Singular test: fails if fact_missing_transactions grows beyond an
-- acceptable volume threshold for a single ingestion run — a spike here
-- usually means a source stopped arriving, not that revenue actually
-- disappeared. See docs/business_problem.md.
--
-- The threshold is a share of each pairing's own total comparisons, not an
-- absolute row count, so it scales with however much data has actually
-- been ingested rather than assuming a fixed volume.

with missing_by_pairing as (
    select
        source_b,
        count(*) filter (where outcome = 'missing') as missing_count,
        count(*) as total_count
    from {{ ref('fact_reconciliation') }}
    group by 1
)

select *
from missing_by_pairing
where missing_count::float / nullif(total_count, 0) > 0.5
