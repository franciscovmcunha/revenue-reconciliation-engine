# 0001 — Preserve each source's raw row before normalizing it

## Context
Every source is normalized onto one canonical shape (`data_dictionary.md`) before
comparison. Normalization logic — and, for the two OCR-derived sources, extraction
logic — can have bugs or edge cases that weren't anticipated.

## Decision
Every row written to bronze keeps a `raw_ref` pointer back to the original row (or,
for OCR sources, the original extracted field set) before any normalization is
applied. Normalization reads from bronze and writes to staging; it never overwrites
the bronze row it came from.

## Why
When a normalization rule turns out to be wrong for an edge case, the fix needs to be
re-run against the original data, not against an already-transformed value. Without
this, diagnosing "why did this transaction get flagged as a mismatch" would require
re-extracting or re-parsing the original file from scratch instead of just querying
bronze.

## Trade-off accepted
Bronze storage grows with every ingestion run and is rarely queried directly outside
of debugging. Acceptable at this project's data volumes.
