# Reconciliation rules

## Three outcomes, never more

Every comparison between sources resolves to exactly one of three outcomes — kept
deliberately simple so the exception list stays something a human can act on:

- **Matched** — the same transaction (or, for the municipal tax rollup, the same
  period total) appears across the expected sources within tolerance.
- **Mismatch** — the transaction exists in more than one source, but the amount or
  date disagrees beyond tolerance.
- **Missing** — the transaction exists in one source and not in another where it was
  expected to.

## Matching keys

Transaction-level sources (PMS, card terminal) match on `transaction_date` +
`amount` within a small tolerance window, falling back to `transaction_ref` when both
sides have one — a reference match is stronger evidence than a date/amount match and
is preferred whenever it's available. Cash register rows, which have no reference,
always match on date + amount. The municipal tax rollup matches on period totals, not
individual transactions, against the sum of the other three sources for that period.

## Tolerance, not exactness

Amounts are compared with a small absolute tolerance rather than requiring an exact
match — rounding differences between systems are expected and are not, by themselves,
a reconciliation exception. The tolerance is a named, documented constant (see
`dbt/models/intermediate/intermediate.yml`), not a magic number buried in a query, so
it can be revisited without hunting through SQL to find where it's used.

## Which source is authoritative

None of them, by default. A mismatch is reported as a mismatch between two sources —
the pipeline does not decide which one is "right." That decision is a human judgment
call informed by the specific case, and baking an assumption about it into the pipeline
would hide exactly the kind of discrepancy this project exists to surface.
