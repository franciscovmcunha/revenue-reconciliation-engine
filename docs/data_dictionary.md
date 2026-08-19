# Data dictionary — canonical fields

Every source is normalized onto the same field set before it reaches staging, so the
intermediate and marts layers never need to know which source a row came from.

| Canonical field | Type | Notes |
|---|---|---|
| `source_system` | string | `pms` \| `cash_register` \| `card_terminal` \| `municipal_tax` |
| `transaction_date` | date | Normalized to ISO 8601 regardless of source format |
| `transaction_ref` | string, nullable | Present for PMS and card terminal; absent for cash register and municipal tax rollups |
| `amount` | numeric(12,2) | Always positive; direction is implied by `source_system`, never by sign |
| `currency` | string | ISO 4217 — expected to be constant in this dataset, kept explicit anyway |
| `payment_method` | string, nullable | Cash, card network, or null where the source doesn't distinguish |
| `extraction_confidence` | float, nullable | Only populated for OCR-derived sources (card terminal, municipal tax) |
| `ingestion_run_id` | string | Ties every row back to the ingestion run that produced it |
| `raw_ref` | string | Pointer back to the bronze row this was normalized from — see `architecture.md` |

## Why `extraction_confidence` exists

Azure AI Document Intelligence returns a confidence score per extracted field. That
score is preserved all the way to staging rather than discarded after ingestion — a
low-confidence field that happens to still "look" reconcilable is exactly the kind of
false match a purely numeric comparison would miss.
