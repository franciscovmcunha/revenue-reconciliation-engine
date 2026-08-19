# Source system analysis

## PMS export (CSV)

One row per billed transaction: a reference, a date, a room or folio identifier, a
description, and an amount. The most reliably structured of the four sources, but the
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

A printed settlement report per terminal per day, scanned to PDF or photographed.
There is no structured export at all — Azure AI Document Intelligence extracts the
transaction table from the scan, and what comes back needs the same validation any
OCR-derived data needs: a wrong digit read from a scan looks exactly like a valid
transaction unless it's cross-checked against something else (in this case, the PMS
and cash register totals for the same day).

## Municipal tax reports (scanned, TTM)

A periodic report, also arriving as a scanned document, aggregating accommodation and
bar revenue for tax declaration purposes. Unlike the other three sources, this one is
already a rollup rather than a transaction list — it reconciles against the *sum* of
the other sources for the period, not against individual transactions.

## What this means for ingestion

Two sources need a validator built around "does this row look like a plausible
transaction" (PMS, cash register); two need a validator built around "does this
extracted field look like what OCR is likely to get wrong" (card terminal, municipal
tax). Both eventually produce the same normalized shape — see
[`data_dictionary.md`](data_dictionary.md) — but the checks that get them there are
different by necessity, not by accident.
