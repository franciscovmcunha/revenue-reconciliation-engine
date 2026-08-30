-- Union of all three staging models onto one comparable shape
-- (docs/data_dictionary.md's canonical fields). Every downstream model
-- reads this instead of the individual stg_ models.

select * from {{ ref('stg_pms') }}
union all
select * from {{ ref('stg_cash_register') }}
union all
select * from {{ ref('stg_card_terminal') }}
