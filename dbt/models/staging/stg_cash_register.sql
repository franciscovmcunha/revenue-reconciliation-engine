-- Cash register bronze rows typed and renamed onto the canonical field
-- set. One row per recorded cash transaction.
--
-- transaction_ref comes from "Documento / Nº Factura" -- present only for
-- the subset of rows that reference a PMS invoice (chiefly tagged TTM
-- payments, see docs/reconciliation_rules.md). docs/data_dictionary.md
-- says this field is "absent for cash register"; that line predates the
-- real-file investigation reconciliation_rules.md documents and is
-- corrected here.

select
    nullif(trim("Documento / Nº Factura"), '') as transaction_ref,
    transaction_date::date as transaction_date,
    amount::numeric(12, 2) as amount,
    'EUR' as currency,
    'Dinheiro' as payment_method,
    'cash_register' as source_system,
    is_ttm_payment,
    is_inter_property_deposit,
    null::float as extraction_confidence,
    ingestion_run_id,
    ctid::text as raw_ref
from {{ source('bronze', 'cash_register') }}
