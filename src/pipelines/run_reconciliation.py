"""Entry point that triggers the dbt run (staging → intermediate → marts)
after bronze has been loaded, then prints a summary of the exception marts.
"""


def main() -> None:
    """Shell out to `dbt run` + `dbt test` against the configured target,
    then query fact_reconciliation for a matched/mismatch/missing summary."""
    raise NotImplementedError


if __name__ == "__main__":
    main()
