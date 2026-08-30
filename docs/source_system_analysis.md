# Source system analysis

## PMS export (CSV)

One row per billed transaction: a reference, a date, a room or folio identifier, a
description, and an amount. The most reliably structured of the three sources, but the
one most exposed to manual entry — a rebooked or corrected charge can appear as two
rows instead of one, which the ingestion validator has to be able to catch (see
[`data_quality.md`](data_quality.md)).

## Cash register (Excel)

A daily worksheet per period, hand-maintained, with a summary row mixed in among the
transaction rows on the same sheet. Column position is more reliable than column name
here — headers drift between periods even though the underlying shape doesn't. Parsing
this source correctly means anchoring on the *shape* of a valid transaction row, not
assuming a fixed header contract.

## Card terminal reports (scanned, TPA)

A small printed terminal slip per day, scanned or photographed — **not a
transaction list**. Confirmed by opening the real files: each slip shows only
day-level totals (`Pagamento`/`Devolução`/`Pay by Link`/`Saldo`, each a count
+ a euro total), never individual card transactions. A single scanned file
can also hold more than one day's slip — `Relatório TPA 9_10_11.pdf` is three
independent slips (09/04, 10/04, 11/04) photographed on one page, not a
combined 3-day report. There's no table here for a layout model to segment,
so extraction uses Azure AI Document Intelligence's `prebuilt-read` (plain
OCR text) and a regex against the slip's fixed labels — see
[`decisions/0002-document-intelligence-for-scanned-sources.md`](decisions/0002-document-intelligence-for-scanned-sources.md).
Because there's no per-field confidence score from `prebuilt-read`, validity
is checked against the slip's own arithmetic
(`Pagamento − Devolução == Saldo`) instead.

## Municipal tax (TTM) — corrected: not a fourth source

Originally assumed to be a scanned periodic rollup report. It isn't, for
this reconciliation window — confirmed by opening the real
`cash_register` and `pms` files together, and by a real cross-check against
the hotel's own operational knowledge of how TTM is actually handled:

- **Paid in cash**: shows up as a tagged row inside `cash_register`'s own
  daily sheets (`Descrição` like `TTM #12`), sometimes with a
  `Documento / Nº Factura` that matches a real PMS `Documento Nº` exactly —
  confirmed for two real cases (`320/FCT26`, `550/FCT26`).
- **Paid any other way**: folded into the PMS stay invoice's total, with no
  separately extractable line anywhere. Only 15 of 618 real PMS invoices in
  this dataset are cash at all — the rest of TTM is genuinely invisible as
  a separate figure, and this project doesn't invent one.
- **The inter-property deposit rows**: a real, expected exception, not a data error —
  only this property has a safe on-site, so a sister property's cash TTM
  gets deposited here for physical cash-custody reasons and belongs to a
  PMS export this repo doesn't have. See `reconciliation_rules.md`.

There is no `municipal_tax` ingestion pipeline as a result — see
`architecture.md`.

## What this means for ingestion

PMS and cash register both need a validator built around "does this row
look like a plausible transaction." Card terminal needs one built around
"does this slip's own arithmetic check out," since there's no per-field
confidence score to lean on. All three produce the same normalized shape —
see [`data_dictionary.md`](data_dictionary.md) — but the checks that get them
there differ by necessity, not by accident.
