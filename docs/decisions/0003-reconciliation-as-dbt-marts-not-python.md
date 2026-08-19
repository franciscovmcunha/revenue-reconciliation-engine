# 0003 — Reconciliation logic lives in dbt marts, not in Python

## Context
Comparing sources against each other (matching, mismatch, missing — see
`reconciliation_rules.md`) could be implemented either as Python running after
ingestion, or as SQL modeled through dbt on top of the bronze/staging tables.

## Decision
All comparison logic is modeled in dbt (intermediate and marts layers). Python's
responsibility ends once a source's rows are validated and loaded into bronze.

## Why
Reconciliation rules change more often than ingestion code does — a tolerance value,
a matching key, a new exception category are business-logic edits, not parsing
changes. Keeping that logic in dbt models means it's testable with dbt's own test
framework, documented alongside the models it applies to, and reviewable by reading
SQL rather than by reading Python across multiple files. It also means ingestion code
never needs to be touched to change how two sources are compared.

## Trade-off accepted
Anyone maintaining this project needs to be comfortable reading dbt-modeled SQL to
understand the reconciliation logic, not just Python — a reasonable expectation given
the rest of the analytics layer is already dbt.
