"""Orchestrates reader → parser → validator → bronze load for the PMS source.
Called by src/pipelines/run_ingestion.py — never invoked from another
source's pipeline.
"""


def run(file_path: str, ingestion_run_id: str) -> None:
    """Read, parse, validate, and load one PMS export file into bronze."""
    raise NotImplementedError
