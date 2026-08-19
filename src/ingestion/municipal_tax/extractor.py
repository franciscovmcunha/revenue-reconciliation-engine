"""Extracts the declared period revenue total from a scanned municipal
tourist tax (TTM) report via Azure AI Document Intelligence.
"""

import pandas as pd

MUNICIPAL_TAX_MODEL_ID = "municipal-tax-report"  # Document Intelligence custom model ID


def extract_municipal_tax_rows(file_path: str) -> pd.DataFrame:
    """Analyze one TTM report and return its declared period total as a
    canonical-shaped row (a rollup, not individual transactions — see
    docs/source_system_analysis.md)."""
    raise NotImplementedError
