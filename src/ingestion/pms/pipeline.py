from src.ingestion.pms.reader import read_pms_export
from src.ingestion.pms.parser import parse_pms_rows
from src.ingestion.pms.validator import validate_pms_rows
from src.common.db import load_to_bronze

#------------------------------------------
#                PMS PIPELINE
#------------------------------------------


def run(file_path: str, ingestion_run_id: str) -> None:
    raw = read_pms_export()
    parsed = parse_pms_rows(raw)
    result = validate_pms_rows(parsed)
    load_to_bronze(result.valid_rows, source_system="pms", ingestion_run_id=ingestion_run_id)
    print(f"pms: {len(result.valid_rows)} processed, {len(result.rejected_rows)} rejected")
