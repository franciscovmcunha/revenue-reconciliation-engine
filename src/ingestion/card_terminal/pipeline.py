import logging

import pandas as pd

from src.common.db import load_to_bronze
from src.ingestion.card_terminal.extractor import extract_card_terminal_rows
from src.ingestion.card_terminal.reader import list_pending_receipts
from src.ingestion.card_terminal.validator import validate_card_terminal_rows


logger = logging.getLogger(__name__)


# ------------------------------------------
#         CARD TERMINAL PIPELINE
# ------------------------------------------

def run(receipts_directory: str, ingestion_run_id: str) -> None:
    files = list(list_pending_receipts(receipts_directory))
    rows = []

    total = len(files)

    logger.info("card_terminal: %d files found", total)

    for position, file_path in enumerate(files, start=1):
        logger.info(
            "card_terminal: processing %d/%d - %s",
            position,
            total,
            file_path,
        )

        try:
            df = extract_card_terminal_rows(file_path)
            rows.append(df)

            logger.info(
                "card_terminal: completed %d/%d - %s",
                position,
                total,
                file_path,
            )

        except RuntimeError:
            logger.exception(
                "card_terminal: failed %d/%d - %s",
                position,
                total,
                file_path,
            )

    extracted = (
        pd.concat(rows, ignore_index=True)
        if rows
        else pd.DataFrame()
    )

    result = validate_card_terminal_rows(extracted)

    load_to_bronze(
        result.valid_rows,
        source_system="card_terminal",
        ingestion_run_id=ingestion_run_id,
    )

    logger.info(
        "card_terminal: %d processed, %d inconsistent, %d rejected",
        len(result.valid_rows),
        len(result.low_confidence_rows),
        len(result.rejected_rows),
    )