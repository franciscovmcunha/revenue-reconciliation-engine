-- Distinct payment methods observed across all three sources.

select distinct
    source_system,
    payment_method
from {{ ref('int_revenue') }}
where payment_method is not null
order by source_system, payment_method
