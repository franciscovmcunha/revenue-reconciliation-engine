-- PMS bronze rows typed and renamed onto the canonical field set
-- (docs/data_dictionary.md). One row per billed transaction.
--
-- Cancelled invoices ("Cancelado") are excluded here, before the row ever
-- reaches the canonical shape -- a voided PMS invoice was never real
-- revenue and has no cash/card payment to reconcile against.

select
    document_number as transaction_ref,
    invoice_date::date as transaction_date,
    abs(net_amount)::numeric(12, 2) as amount,
    currency,
    payment_method,
    'pms' as source_system,
    null::boolean as is_ttm_payment,
    null::boolean as is_inter_property_deposit,
    null::float as extraction_confidence,
    ingestion_run_id,
    ctid::text as raw_ref
from {{ source('bronze', 'pms') }}
where is_cancelled is null or trim(is_cancelled) = ''
