"""Validates extracted card terminal rows — see docs/data_quality.md on
OCR-specific validation (the extraction_confidence threshold)."""

import pandas as pd
from dataclasses import dataclass


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    low_confidence_rows: pd.DataFrame
    rejected_rows: pd.DataFrame


LOW_CONFIDENCE_THRESHOLD = 0.0  # placeholder — see docs/data_quality.md


def validate_card_terminal_rows(extracted: pd.DataFrame) -> ValidationResult:
    """Split rows into valid, low-confidence (flagged, not corrected), and
    rejected (implausible even before comparing against other sources)."""
    raise NotImplementedError
