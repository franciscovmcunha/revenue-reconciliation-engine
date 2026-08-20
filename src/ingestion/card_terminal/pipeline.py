import pandas as pd
from src.ingestion.card_terminal.reader import list_pending_receipts
from src.ingestion.card_terminal.extractor import extract_card_terminal_rows
from src.ingestion.card_terminal.validator import validate_card_terminal_rows
from src.common.db import load_to_bronze

#------------------------------------------
#         CARD TERMINAL PIPELINE
#------------------------------------------


def run(receipts_directory: str, ingestion_run_id: str) -> None:
    rows = [extract_card_terminal_rows(p) for p in list_pending_receipts(receipts_directory)]
    extracted = pd.concat(rows, ignore_index=True) if rows else pd.DataFrame()
    result = validate_card_terminal_rows(extracted)
    load_to_bronze(result.valid_rows, source_system="card_terminal", ingestion_run_id=ingestion_run_id)
    print(f"card_terminal: {len(result.valid_rows)} processed, "
          f"{len(result.low_confidence_rows)} inconsistent, {len(result.rejected_rows)} rejected")
