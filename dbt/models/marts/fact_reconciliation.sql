-- One row per comparison outcome (matched/mismatch/missing) from
-- int_reconciliation — the primary deliverable table of this project.

select
    row_number() over (order by transaction_date, pms_raw_ref, other_raw_ref) as reconciliation_id,
    source_a,
    source_b,
    pms_raw_ref,
    other_raw_ref,
    transaction_date,
    pms_amount,
    other_amount,
    amount_difference,
    match_method,
    outcome
from {{ ref('int_reconciliation') }}
