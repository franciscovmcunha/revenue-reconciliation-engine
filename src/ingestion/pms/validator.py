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
    reasons: dict[int, str] = {}
    missing_document_number = (
        parsed["document_number"].isna() | (parsed["document_number"].astype(str).str.strip() == "")
    )
    for idx in parsed.index[missing_document_number]:
        reasons.setdefault(
            idx,
            "missing_document_number"
        )

    for idx in parsed.index[missing_document_number]:
        reasons[idx] = "missing_document_number"

    return ValidationResult(
        valid_rows=parsed[~missing_document_number].copy(),
        rejected_rows=parsed[missing_document_number].copy(),
        rejection_reasons=reasons,
    )
