"""Validates parsed PMS rows before they reach bronze — see
docs/data_quality.md for what "valid" means and why failures are counted,
not silently dropped.
"""

import pandas as pd
from dataclasses import dataclass


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    rejected_rows: pd.DataFrame
    rejection_reasons: dict[int, str]


def validate_pms_rows(parsed: pd.DataFrame) -> ValidationResult:
    """Check plausible date ranges, non-negative amounts, and duplicate
    detection specific to PMS (a rebooked/corrected charge appearing twice —
    see docs/source_system_analysis.md)."""
    raise NotImplementedError
