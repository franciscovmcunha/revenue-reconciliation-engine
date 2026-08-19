"""Maps the raw PMS DataFrame onto the canonical field set in
docs/data_dictionary.md, using src.common.normalization for amount/date fields.
"""

import pandas as pd


def parse_pms_rows(raw: pd.DataFrame) -> pd.DataFrame:
    """Return a DataFrame with exactly the canonical columns, normalized,
    with `source_system="pms"` set on every row."""
    raise NotImplementedError
