-- Mismatches only, from fact_reconciliation, with both sides' amount/date
-- shown side by side for human review.

select
    reconciliation_id,
    source_a,
    source_b,
    pms_raw_ref,
    other_raw_ref,
    transaction_date,
    pms_amount,
    other_amount,
    amount_difference,
    match_method
from {{ ref('fact_reconciliation') }}
where outcome = 'mismatch'
order by amount_difference desc
