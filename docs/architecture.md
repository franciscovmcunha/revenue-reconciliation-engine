# Architecture

## Three sources, two ingestion mechanisms — municipal tax is not a fourth

| Source | Format | Ingestion path |
|---|---|---|
| PMS | CSV export | pandas — direct parse |
| Cash register | Excel workbook | pandas — direct parse |
| Card terminal (TPA) | Scanned receipt (PDF/photo) | Azure AI Document Intelligence (`prebuilt-read`) → OCR text → regex |

Municipal tax (TTM) turned out, on inspecting the real files, not to be a
separate document at all for this reconciliation window: when a guest pays
TTM in cash, it's a tagged row inside `cash_register`'s own daily sheets
(`Descrição` containing `TTM #<room>`); when paid any other way, it's folded
into the PMS stay invoice with no separately extractable line anywhere. See
`docs/source_system_analysis.md`, "Municipal tax (TTM)" for the full
correction and the evidence behind it.

## Layout

```
src/
├── common/
│   ├── document_intelligence_client.py   # thin wrapper over the Azure SDK client — card_terminal only
│   ├── normalization.py                  # shared date/monetary normalization (NumPy)
│   └── db.py                             # PostgreSQL connection + bronze load helpers
├── ingestion/
│   ├── pms/              # reader → parser → validator → pipeline
│   ├── cash_register/    # reader → parser → validator → pipeline
│   │                     #   parser.py also tags TTM-cash rows (see reconciliation_rules.md)
│   └── card_terminal/    # reader → extractor (Document Intelligence) → validator → pipeline
└── pipelines/
    ├── run_ingestion.py       # runs all three source pipelines into bronze
    └── run_reconciliation.py  # triggers dbt after bronze is loaded
```

Each source package has the same four-stage shape (`reader` → `parser`/`extractor` →
`validator` → `pipeline`) regardless of whether it's a structured or scanned source —
consistent shape across sources means adding a fifth source later means writing the
same four files again, not inventing a new pattern.

## From bronze to exceptions (dbt)

```
dbt/models/
├── staging/       # 1:1 with each source, typed and renamed onto canonical fields
├── intermediate/  # per-source revenue rollups, ready to compare
└── marts/         # fact_reconciliation, fact_payment_exceptions, fact_missing_transactions
```

Reconciliation logic — matching, flagging a mismatch, flagging a missing transaction —
lives in the intermediate/marts layer in dbt, not in Python. Ingestion code's job ends
at "clean, validated rows in bronze"; comparing sources against each other is business
logic that changes independently of how any one source is parsed, and dbt's testing and
documentation make that logic reviewable on its own.
