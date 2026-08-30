-- Singular test: fails if the same transaction_ref appears more than once
-- within the same source_system in int_revenue (a rebooked/corrected charge
-- counted twice — see docs/source_system_analysis.md).

select
    source_system,
    transaction_ref,
    count(*) as occurrences
from {{ ref('int_revenue') }}
where transaction_ref is not null
group by 1, 2
having count(*) > 1
