"""Shared normalization used by every source before rows reach bronze — see
docs/data_dictionary.md for the canonical field set this normalizes onto.

Uses NumPy for vectorized monetary rounding/tolerance comparisons across a
source's full set of rows at once, rather than row-by-row in pure Python.
"""

import numpy as np
import pandas as pd


def normalize_amount(raw_amounts: pd.Series) -> np.ndarray:
    """Parse a column of raw amount strings/values (which vary in decimal
    separator and currency symbol by source) into a NumPy array of floats,
    always positive, rounded to 2 decimal places."""
    raise NotImplementedError


def normalize_date(raw_dates: pd.Series, source_format: str | None = None) -> pd.Series:
    """Parse a column of raw date strings into ISO 8601 dates. `source_format`
    is only required for sources with a known, non-standard format."""
    raise NotImplementedError


def within_tolerance(a: np.ndarray, b: np.ndarray, tolerance: float) -> np.ndarray:
    """Vectorized comparison used by the dbt tolerance rule in
    docs/reconciliation_rules.md — kept here so both Python-side validation
    and any Python-side spot-checks use the exact same definition of
    "within tolerance" that the dbt models use."""
    raise NotImplementedError
