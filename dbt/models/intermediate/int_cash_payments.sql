-- Cash register transactions, ready to match against PMS.
--
-- Only TTM-tagged rows are reconcilable against PMS at all (see
-- docs/reconciliation_rules.md) -- ordinary till entries (float top-ups,
-- supplier payments, and the rest of day-to-day cash movement) have no PMS
-- counterpart by nature and are excluded here, not flagged as missing.
-- Inter-property deposits ("TTM Alfama") are excluded too: real money,
-- correctly present in cash_register, but not this property's revenue.

select *
from {{ ref('int_revenue') }}
where source_system = 'cash_register'
  and is_ttm_payment = true
  and is_inter_property_deposit = false
