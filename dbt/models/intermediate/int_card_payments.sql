-- Card terminal transactions, ready to match against PMS.

select *
from {{ ref('int_revenue') }}
where source_system = 'card_terminal'
