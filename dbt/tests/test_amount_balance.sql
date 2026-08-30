-- Singular test: fails if fact_reconciliation contains a "matched" outcome
-- whose amount difference exceeds the configured tolerance — a matched row
-- should never disagree by more than var('reconciliation_tolerance') allows.

select *
from {{ ref('fact_reconciliation') }}
where outcome = 'matched'
  and amount_difference > {{ var('reconciliation_tolerance') }}
