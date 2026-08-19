"""Entry point that runs all four source pipelines into bronze for one
ingestion run. Each source's failure is isolated — one source failing does
not prevent the other three from loading.
"""


def main() -> None:
    """Generate an ingestion_run_id, run pms/cash_register/card_terminal/
    municipal_tax pipelines against data/raw/, and print a per-source summary
    (rows processed/rejected/low-confidence — see docs/data_quality.md)."""
    raise NotImplementedError


if __name__ == "__main__":
    main()
