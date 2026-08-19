# The business problem

## Four numbers that should agree, and usually don't exactly

For any given day, a hotel can point to four different records of "how much revenue
came in": what the PMS billed, what the cash register took in, what the card network
settled, and what was declared for municipal tourist tax. When these are reconciled
manually — spreadsheet by spreadsheet, month by month — small discrepancies get
absorbed into "close enough" long before anyone can say precisely why two numbers
don't match.

That's expensive in a way that's easy to underestimate: a systematic billing error
that's 2% off doesn't look urgent on any single day, but compounds across a full year
of transactions into a real, hard-to-explain gap in reported revenue.

## What "solved" looks like

Not a single dashboard that shows the four totals side by side — that's what a
spreadsheet already does. The bar this project sets is: every unmatched transaction is
individually identifiable, tagged with *why* it didn't match (missing from one source,
amount mismatch, date mismatch, duplicate), and small enough in volume that a human can
actually act on the list — not just acknowledge that a gap exists.

## Why this is a data engineering problem, not a finance problem

The finance logic (what counts as a match, what tolerance is acceptable, which source
is authoritative when two disagree) is genuinely simple once written down — see
[`reconciliation_rules.md`](reconciliation_rules.md). What makes this hard is getting
four independently-produced, inconsistently-formatted sources into one comparable shape
without silently losing or double-counting a transaction along the way. That's the part
this repository is actually about.
