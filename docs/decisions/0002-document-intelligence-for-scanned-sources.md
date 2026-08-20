# 0002 — Use Azure AI Document Intelligence for scanned sources

> **Update, after inspecting the real files:** this ADR originally assumed two
> scanned sources (card terminal, municipal tax) and a structured-extraction
> approach for both. Neither held. Municipal tax isn't a separate document
> for this reconciliation window at all (see `docs/source_system_analysis.md`)
> — this ADR now applies to card terminal only. And card terminal's real
> slips have no table for a structured/layout model to segment (a scanned
> page can hold several independent slips at once) — so the "Decision" below
> is narrower than first written: `prebuilt-read` (OCR text) + regex, not a
> layout/form model. The reasoning in "Why" for using Document Intelligence
> at all (over a self-hosted OCR library) still holds; the specific model
> choice underneath it doesn't.

## Context
Card terminal reports exist only as scanned PDFs or photographed receipts. Plain OCR
(text extraction) recovers characters, but reconciliation needs specific fields — a
date, an amount — not a wall of unstructured text to re-parse from scratch each time.

## Decision
Use Azure AI Document Intelligence over a self-hosted OCR library. Within that:
`prebuilt-read` (plain OCR text), parsed with a regex against the slip's fixed labels
— not a layout/form model, since there is no table or form structure to segment, and
a scanned page can hold more than one independent slip.

## Why
A self-hosted OCR library still leaves you writing the extraction and confidence
logic yourself; Document Intelligence's managed OCR is a cheap, reliable text layer
to build the regex on top of. `prebuilt-read` doesn't return a per-field confidence
score the way a layout model would — validity here is checked against the slip's own
arithmetic (`Pagamento − Devolução == Saldo`) instead, see `data_quality.md`.

## Trade-off accepted
A cloud API dependency and per-document cost, versus a self-hosted OCR library. At the
volume this source actually produces (~150 scans across 5 months), the cost is small
relative to the reliability gained; worth revisiting only at a much larger volume.
