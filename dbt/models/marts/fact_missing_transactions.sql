-- Transactions present in one source and absent where expected, from
-- fact_reconciliation.

select
    reconciliation_id,
    source_a,
    source_b,
    transaction_date,
    case when pms_raw_ref is not null then 'pms' else source_b end as present_in,
    coalesce(pms_amount, other_amount) as amount
from {{ ref('fact_reconciliation') }}
where outcome = 'missing'
order by transaction_date
