"""Orchestrates reader → parser → validator → bronze load for the cash
register source. Called by src/pipelines/run_ingestion.py.
"""


def run(file_path: str, ingestion_run_id: str) -> None:
    """Read, parse, validate, and load one cash register workbook into bronze."""
    raise NotImplementedError
