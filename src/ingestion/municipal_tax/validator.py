"""Validates extracted municipal tax rows — see docs/data_quality.md."""

import pandas as pd
from dataclasses import dataclass


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    low_confidence_rows: pd.DataFrame
    rejected_rows: pd.DataFrame


def validate_municipal_tax_rows(extracted: pd.DataFrame) -> ValidationResult:
    """Same confidence-threshold approach as card_terminal — see
    src/ingestion/card_terminal/validator.py."""
    raise NotImplementedError
