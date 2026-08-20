# Data dictionary — canonical fields

Every source is normalized onto the same field set before it reaches staging, so the
intermediate and marts layers never need to know which source a row came from.

| Canonical field | Type | Notes |
|---|---|---|
| `source_system` | string | `pms` \| `cash_register` \| `card_terminal` — see note below on municipal tax |
| `transaction_date` | date | Normalized to ISO 8601 regardless of source format |
| `transaction_ref` | string, nullable | Present for PMS; present for card terminal only where the slip's `Documento/Nº Factura` was filled in; absent for cash register |
| `amount` | numeric(12,2) | Always positive; direction is implied by `source_system`, never by sign |
| `currency` | string | ISO 4217 — expected to be constant in this dataset, kept explicit anyway |
| `payment_method` | string, nullable | Cash, card network, or null where the source doesn't distinguish |
| `is_ttm_payment` | bool | `cash_register` only — set when `Descrição` matches a guest-level TTM tag (see `reconciliation_rules.md`) |
| `is_inter_property_deposit` | bool | `cash_register` only — set for the "TTM Alfama" exception (see `reconciliation_rules.md`) |
| `extraction_confidence` | float, nullable | See note below — no longer populated the way this was originally designed |
| `ingestion_run_id` | string | Ties every row back to the ingestion run that produced it |
| `raw_ref` | string | Pointer back to the bronze row this was normalized from — see `architecture.md` |

## Municipal tax isn't its own `source_system` value

Corrected after inspecting the real files (see `source_system_analysis.md`):
there's no standalone municipal tax document for this reconciliation window.
A cash TTM payment is a tagged row inside `cash_register`; a non-cash TTM
payment has no separately extractable line anywhere — it's inside the PMS
stay invoice's total. `is_ttm_payment` on a `cash_register` row is how this
shows up in the canonical shape, not a fourth `source_system` value.

## Why `extraction_confidence` exists, and why it's often null now

Azure AI Document Intelligence returns a per-field confidence score for
structured/layout extraction. Card terminal's real slips have no table to
segment, though (three slips photographed on one page, no form fields), so
extraction there uses `prebuilt-read` (plain OCR text + regex) instead of a
layout model — see `docs/decisions/0002-document-intelligence-for-scanned-sources.md`.
`prebuilt-read` doesn't return a per-field score, so `extraction_confidence`
is null for card terminal rows; validity there is checked by the slip's own
internal arithmetic (`Pagamento − Devolução == Saldo`) instead.
