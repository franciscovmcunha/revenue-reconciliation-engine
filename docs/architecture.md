# Architecture

## Four sources, two ingestion mechanisms

| Source | Format | Ingestion path |
|---|---|---|
| PMS | CSV export | pandas — direct parse |
| Cash register | Excel workbook | pandas — direct parse |
| Card terminal (TPA) | Scanned receipt (PDF/image) | Azure AI Document Intelligence → structured fields |
| Municipal tax (TTM) | Scanned PDF report | Azure AI Document Intelligence → structured fields |

The two structured sources and the two scanned sources end up in the same shape by the
time they reach bronze — the split exists only at ingestion, never downstream of it.

## Layout

```
src/
├── common/
│   ├── document_intelligence_client.py   # thin wrapper over the Azure SDK client
│   ├── normalization.py                  # shared date/monetary normalization (NumPy)
│   └── db.py                             # PostgreSQL connection + bronze load helpers
├── ingestion/
│   ├── pms/              # reader → parser → validator → pipeline
│   ├── cash_register/    # reader → parser → validator → pipeline
│   ├── card_terminal/    # reader → extractor (Document Intelligence) → validator → pipeline
│   └── municipal_tax/    # reader → extractor (Document Intelligence) → validator → pipeline
└── pipelines/
    ├── run_ingestion.py       # runs all four source pipelines into bronze
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
