"""Locates and hands off scanned card terminal (TPA) receipt files — no
extraction here, that's extractor.py's job via Document Intelligence.
"""


def list_pending_receipts(directory: str) -> list[str]:
    """Return file paths for receipts (PDF/image) not yet processed in this
    ingestion run."""
    raise NotImplementedError
