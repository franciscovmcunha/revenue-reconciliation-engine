# Reconciliation rules

## Three outcomes, never more

Every comparison between sources resolves to exactly one of three outcomes — kept
deliberately simple so the exception list stays something a human can act on:

- **Matched** — the same transaction (or, for a tagged TTM cash payment, the
  same date + amount) appears across the expected sources within tolerance.
- **Mismatch** — the transaction exists in more than one source, but the amount or
  date disagrees beyond tolerance.
- **Missing** — the transaction exists in one source and not in another where it was
  expected to.

## Matching keys

Transaction-level sources (PMS, card terminal) match on `transaction_date` +
`amount` within a small tolerance window, falling back to `transaction_ref` when both
sides have one — a reference match is stronger evidence than a date/amount match and
is preferred whenever it's available. Cash register rows, which have no reference,
always match on date + amount.

## Municipal tax (TTM) — a tagged subset of cash register, not a fourth source

Confirmed against the real files: there's no standalone municipal tax
document for this reconciliation window. TTM only leaves a separately
reconcilable trace when a guest pays it in cash — as a `cash_register` row
whose `Descrição` matches a guest-level TTM tag (`TTM #<room>`,
`TTM#<room>`, or similar — never the "Reforço ... desde TTM" rows, which are
internal till transfers, not guest payments). When TTM is paid by any other
method, it's folded into the PMS stay invoice's total with no separately
extractable line anywhere — there is nothing to reconcile it against, and
this project doesn't invent a number for it.

Matching a tagged `cash_register` TTM row against PMS:
1. If the row has a `Documento / Nº Factura` reference, match it exactly
   against the PMS `Documento Nº` — this is the strongest possible evidence
   (confirmed real for two cases: `320/FCT26`, `550/FCT26`).
2. If it doesn't, fall back to date + amount, restricted to PMS rows where
   `Forma Pagamento = "Dinheiro"` (cash) — matching a cash TTM entry against
   a card-paid PMS invoice would never be correct regardless of how close
   the amount is.

### The inter-property deposit exception — expected, not a mismatch

Some tagged rows reference a different property in the group (a
business-specific marker — see `SISTER_PROPERTY_MARKER` in
`src/utils/config.py`) and will never resolve against this repo's PMS
export. This isn't a data error: only this property has a safe on site, so
cash TTM collected on behalf of a sister property with no safe of its own
gets deposited into this till anyway, purely for physical cash-custody
reasons. These rows are real money, correctly present in `cash_register`,
but they are **not this property's revenue** — they must be flagged as
`is_inter_property_deposit` and excluded from this property's own
PMS-vs-cash-register reconciliation, not reported as a missing/unmatched
transaction. Whether they ever get matched against the other property's
own PMS export is out of scope until that export is part of this project.

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
