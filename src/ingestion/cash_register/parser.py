"""Maps raw cash register sheets onto the canonical field set. Anchors on
row *shape* rather than header text — see docs/source_system_analysis.md on
why header position, not header name, is the reliable signal here.
"""

import pandas as pd


def parse_cash_register_rows(raw_sheets: dict[str, pd.DataFrame]) -> pd.DataFrame:
    """Return a single DataFrame across all sheets, with the canonical
    columns, `source_system="cash_register"` set on every row."""
    raise NotImplementedError
