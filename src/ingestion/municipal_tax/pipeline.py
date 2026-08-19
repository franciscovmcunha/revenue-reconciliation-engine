"""Orchestrates reader → extractor → validator → bronze load for the
municipal tax (TTM) source. Called by src/pipelines/run_ingestion.py.
"""


def run(reports_directory: str, ingestion_run_id: str) -> None:
    """Process every pending TTM report in `reports_directory` into bronze."""
    raise NotImplementedError
