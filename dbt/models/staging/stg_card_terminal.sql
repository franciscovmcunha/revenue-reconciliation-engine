-- Types and renames bronze.card_terminal rows (Document Intelligence output)
-- onto the canonical field set, preserving extraction_confidence.
-- TODO: implement — select from {{ source('bronze', 'card_terminal') }}

select 1 as placeholder
