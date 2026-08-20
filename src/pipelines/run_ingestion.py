"""Entry point that runs all three source pipelines into bronze for one
ingestion run. Each source's failure is isolated — one source failing does
not prevent the other two from loading.

Municipal tax (TTM) is deliberately not a fourth pipeline here — it's a
derived check inside cash_register's own data, not a separate source for
this reconciliation window. See docs/source_system_analysis.md.
"""


def main() -> None:
    """Generate an ingestion_run_id, run pms/cash_register/card_terminal
    pipelines against data/raw/, and print a per-source summary (rows
    processed/rejected/low-confidence — see docs/data_quality.md)."""
    raise NotImplementedError


if __name__ == "__main__":
    main()
