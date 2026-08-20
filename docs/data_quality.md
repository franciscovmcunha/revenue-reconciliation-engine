# Data quality

## Validation happens per source, before anything is compared

Each of the three ingestion pipelines validates its own rows before they reach bronze —
plausible date ranges, non-negative amounts, a resolvable `source_system` — so a
malformed row from one source can never masquerade as a legitimate "missing
transaction" in another. A row that fails validation is logged and excluded, never
silently coerced into something valid-looking.

## OCR-specific validation

Rows extracted via Azure AI Document Intelligence carry an `extraction_confidence`
score (see [`data_dictionary.md`](data_dictionary.md)). Below a documented threshold, a
field is treated as unverified rather than corrected or guessed at — a low-confidence
amount is far more useful flagged as "needs a human look" than silently accepted or
silently dropped.

## Every ingestion run reports its own outcome

Rows processed, rows rejected, and rows flagged low-confidence are counted per run and
per source — visible numbers, not something only discoverable by reading logs after
the fact. A run that processes 100% of a source's rows but at unusually low average
confidence is treated as worth reviewing, even though nothing in it technically failed.

## Real source data never leaves this machine

Real PMS exports, cash register workbooks, and scanned terminal/tax reports are
processed locally, under `data/raw/` (git-ignored — see `.gitignore`). Nothing under
that path is ever committed. Sample data in `data/sample/` is synthetic, generated to
match the shape described in [`data_dictionary.md`](data_dictionary.md), and contains
no real transactions, amounts, or supplier names.
