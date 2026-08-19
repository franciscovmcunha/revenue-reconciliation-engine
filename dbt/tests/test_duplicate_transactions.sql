-- Singular test: fails if the same transaction_ref appears more than once
-- within the same source_system in int_revenue (a rebooked/corrected charge
-- counted twice — see docs/source_system_analysis.md).
-- TODO: implement

select 1 as placeholder where false
