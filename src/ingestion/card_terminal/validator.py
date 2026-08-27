import pandas as pd
from dataclasses import dataclass

#------------------------------------------
#         CARD TERMINAL VALIDATOR
#------------------------------------------


@dataclass
class ValidationResult:
    valid_rows: pd.DataFrame
    low_confidence_rows: pd.DataFrame
    rejected_rows: pd.DataFrame


LOW_CONFIDENCE_THRESHOLD = 0.01


def _parse_slip_amount(raw: pd.Series) -> pd.Series:
    cleaned = raw.astype(str).str.replace(" ", "", regex=False).str.replace(",", ".", regex=False)
    return pd.to_numeric(cleaned, errors="coerce")


def validate_card_terminal_rows(extracted: pd.DataFrame) -> ValidationResult:
    if extracted.empty:
        return ValidationResult(extracted, extracted, extracted)
    for col in ("amount", "refund_amount", "saldo_amount"):
        extracted[col] = _parse_slip_amount(extracted[col])
    missing = extracted[["amount", "refund_amount", "saldo_amount"]].isna().any(axis=1)
    consistent = (extracted["amount"] - extracted["refund_amount"] - extracted["saldo_amount"]).abs() <= LOW_CONFIDENCE_THRESHOLD
    valid = ~missing & consistent
    low_confidence = ~missing & ~consistent
    return ValidationResult(extracted[valid].copy(), extracted[low_confidence].copy(), extracted[missing].copy())