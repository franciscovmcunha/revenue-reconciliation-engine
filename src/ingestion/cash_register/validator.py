import pandas as pd
from dataclasses import dataclass


#------------------------------------------
#         CASH REGISTER VALIDATOR
#------------------------------------------

@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    rejected_rows: pd.DataFrame
    rejection_reasons: dict[int, list[str]]


def validate_cash_register_rows(parsed: pd.DataFrame) -> ValidationResult:
    reasons: dict[int, str] = {}
    bad_amount = parsed["amount"].isna() | (parsed["amount"] < 0)
    bad_date = parsed["transaction_date"].isna()
    for idx in parsed.index[bad_amount]:
        reasons[idx] = "invalid_amount"
    for idx in parsed.index[bad_date]:
        reasons.setdefault(idx, "invalid_date")
    bad = bad_amount | bad_date
    return ValidationResult(parsed[~bad].copy(), parsed[bad].copy(), reasons)