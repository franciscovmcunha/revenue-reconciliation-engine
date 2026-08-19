"""Validates parsed cash register rows before they reach bronze — see
docs/data_quality.md.
"""

import pandas as pd
from dataclasses import dataclass


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    rejected_rows: pd.DataFrame
    rejection_reasons: dict[int, str]


def validate_cash_register_rows(parsed: pd.DataFrame) -> ValidationResult:
    """Check plausible date ranges and non-negative amounts; exclude summary
    rows that were misread as transaction rows."""
    raise NotImplementedError
