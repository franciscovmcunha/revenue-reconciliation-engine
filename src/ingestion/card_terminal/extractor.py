"""Extracts structured transaction fields from a scanned card terminal
receipt via Azure AI Document Intelligence (src.common.document_intelligence_client).
"""

import pandas as pd

CARD_TERMINAL_MODEL_ID = "card-terminal-receipt"  # Document Intelligence custom model ID


def extract_card_terminal_rows(file_path: str) -> pd.DataFrame:
    """Analyze one receipt and return its transactions as canonical-shaped
    rows, each carrying `extraction_confidence` per docs/data_dictionary.md."""
    raise NotImplementedError
