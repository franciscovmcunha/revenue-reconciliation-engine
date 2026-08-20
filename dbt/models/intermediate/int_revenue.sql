-- Unions stg_pms, stg_cash_register, stg_card_terminal onto one comparable
-- shape, tagged by source_system. Municipal tax isn't a fourth staging
-- model — it's the is_ttm_payment/is_inter_property_deposit flags already
-- on stg_cash_register rows (see docs/source_system_analysis.md).
-- TODO: implement

select 1 as placeholder
