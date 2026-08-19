"""Reads a cash register Excel workbook into a raw pandas DataFrame per
sheet — one sheet per period, per docs/source_system_analysis.md."""

import pandas as pd


def read_cash_register_workbook(file_path: str) -> dict[str, pd.DataFrame]:
    """Return one raw DataFrame per sheet, keyed by sheet name."""
    raise NotImplementedError
