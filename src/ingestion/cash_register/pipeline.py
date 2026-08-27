import unicodedata
from pathlib import Path
import logging
from src.ingestion.cash_register.reader import read_cash_register_workbook
from src.ingestion.cash_register.parser import parse_cash_register_rows
from src.ingestion.cash_register.validator import validate_cash_register_rows
from src.common.db import load_to_bronze

#------------------------------------------
#         CASH REGISTER PIPELINE
#------------------------------------------

logger = logging.getLogger(__name__)


CANONICAL_MONTH = {
    1: "Janeiro", 
    2: "Fevereiro", 
    3: "Março", 
    4: "Abril", 
    5: "Maio"}
MONTH_NUMBER = {
    v: k 
    for k, v in CANONICAL_MONTH.items()}


def run(file_path: str, ingestion_run_id: str) -> None:
    stem = unicodedata.normalize("NFC", Path(file_path).stem)
    expected_month = next(n for name, n in MONTH_NUMBER.items() if name in stem)
    raw_sheets = read_cash_register_workbook(file_path)
    parsed = parse_cash_register_rows(raw_sheets, expected_month)
    result = validate_cash_register_rows(parsed)
    load_to_bronze(result.valid_rows, source_system="cash_register", ingestion_run_id=ingestion_run_id)
    logger.info(   
        "cash_register (%s): %d processed, %d rejected",
        file_path,
        len(result.valid_rows),
        len(result.rejected_rows),
    )