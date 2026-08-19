"""Reads a PMS export file from disk into a raw pandas DataFrame — no parsing
or type conversion here, just getting the file's rows into memory."""

import pandas as pd


def read_pms_export(file_path: str) -> pd.DataFrame:
    """Read a PMS CSV export. Encoding and delimiter are source-specific
    quirks handled here, not assumed by the caller."""
    raise NotImplementedError
