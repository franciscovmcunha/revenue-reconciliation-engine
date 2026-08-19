"""Locates scanned municipal tourist tax (TTM) report files — no extraction
here, that's extractor.py's job via Document Intelligence.
"""


def list_pending_reports(directory: str) -> list[str]:
    """Return file paths for TTM reports not yet processed in this ingestion run."""
    raise NotImplementedError
