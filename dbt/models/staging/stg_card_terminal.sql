-- Card terminal (TPA) bronze rows, extracted via Azure AI Document
-- Intelligence (prebuilt-read + regex -- see docs/decisions/0002), typed
-- and renamed onto the canonical field set.
--
-- transaction_date arrives as a partial or ambiguous string, differently
-- per terminal_provider (see src/ingestion/card_terminal/extractor.py's
-- two regexes, and tests/test_card_terminal_extractor.py for confirmed
-- real examples of each):
--   - paybyrd: "dd/mm" only, no year at all ("Data do relatório 01/01").
--   - abanca: "yy-mm-dd" (year first, e.g. "26-04-30" = 2026-04-30) -- NOT
--     day-month-year, despite the dash-separated look of a European date.
-- paybyrd's missing year is filled in from `reconciliation_year`
-- (dbt_project.yml) rather than inferred from anything in the source --
-- see the var's own comment for why. transaction_ref is always null:
-- the extractor doesn't currently capture an invoice/document reference
-- from either slip format, so there's nothing to put there yet.

select
    null::text as transaction_ref,
    case
        when "transaction_date" ~ '^\d{2}/\d{2}$'
            then to_date("transaction_date" || '/' || '{{ var("reconciliation_year") }}', 'DD/MM/YYYY')
        when "transaction_date" ~ '^\d{2}-\d{2}-\d{2}$'
            then to_date("transaction_date", 'YY-MM-DD')
        else null
    end as transaction_date,
    amount::numeric(12, 2) as amount,
    'EUR' as currency,
    null::text as payment_method,
    'card_terminal' as source_system,
    null::boolean as is_ttm_payment,
    null::boolean as is_inter_property_deposit,
    extraction_confidence,
    ingestion_run_id,
    ctid::text as raw_ref
from {{ source('bronze', 'card_terminal') }}
