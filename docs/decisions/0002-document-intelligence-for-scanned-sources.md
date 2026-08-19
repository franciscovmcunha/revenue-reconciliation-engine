# 0002 — Use Azure AI Document Intelligence for scanned sources, not general OCR

## Context
Two of the four sources (card terminal reports, municipal tax reports) exist only as
scanned PDFs or photographed receipts. Plain OCR (text extraction) recovers characters,
but reconciliation needs specific structured fields — a date, an amount, a reference —
not a wall of unstructured text to re-parse afterward.

## Decision
Use Azure AI Document Intelligence's structured extraction (prebuilt or custom models,
depending on the document layout) instead of running general OCR and writing regex
against the output.

## Why
General OCR turns a scanned document into a text blob that still has to be parsed —
which reintroduces the same "no fixed schema" problem this project already has to
solve for the structured sources, except now on noisier, error-prone text. Structured
document extraction returns typed fields with a per-field confidence score directly,
which both simplifies the ingestion code and gives the data-quality layer
(`data_quality.md`) something concrete to validate against.

## Trade-off accepted
A cloud API dependency and per-document cost, versus a self-hosted OCR library. At the
volume these two sources actually produce, the cost is small relative to the accuracy
and confidence-scoring gained; that trade-off would need revisiting at a much larger
scanned-document volume.
