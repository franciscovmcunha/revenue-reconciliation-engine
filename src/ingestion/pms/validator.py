import pandas as pd
from dataclasses import dataclass

#------------------------------------------
#              PMS VALIDATOR
#------------------------------------------


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    rejected_rows: pd.DataFrame
    rejection_reasons: dict[int, str]


def validate_pms_rows(parsed: pd.DataFrame) -> ValidationResult:
    # structural completeness only — "is this row worth landing at all".
    # Business validity (amount sign, duplicates) is dbt's job now, applied
    # after bronze, not before it — docs/decisions/0001-preserve-raw-before-normalizing.md
    reasons: dict[int, str] = {}
    missing_document_number = (
        parsed["document_number"].isna() | (parsed["document_number"].astype(str).str.strip() == "")
    )
    for idx in parsed.index[missing_document_number]:
        reasons[idx] = "missing_document_number"
    return ValidationResult(
        parsed[~missing_document_number].copy(),
        parsed[missing_document_number].copy(),
        reasons,
    )
