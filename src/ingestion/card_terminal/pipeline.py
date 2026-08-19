"""Orchestrates reader → extractor → validator → bronze load for the card
terminal (TPA) source. Called by src/pipelines/run_ingestion.py.
"""


def run(receipts_directory: str, ingestion_run_id: str) -> None:
    """Process every pending receipt in `receipts_directory` into bronze."""
    raise NotImplementedError
