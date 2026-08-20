import numpy as np
import pandas as pd


#------------------------------------------
#         COMMON DATA NORMALIZATION
#------------------------------------------

#------------------------------------------
#         MONATARY NORMALIZATION 
#------------------------------------------

def normalize_amount(raw_amounts: pd.Series) -> np.ndarray:
    cleaned = raw_amounts.astype(str).str.replace(",", "", regex=False)
    values = pd.to_numeric(cleaned, errors="coerce").to_numpy()
    return np.abs(np.round(values, 2))

#------------------------------------------
#         DATES NORMALIZATION 
#------------------------------------------

def normalize_date(raw_dates: pd.Series, source_format: str | None = None) -> pd.Series:
    if source_format:
        return pd.to_datetime(raw_dates, format=source_format, errors="coerce")
    return pd.to_datetime(raw_dates, dayfirst=True, errors="coerce")

#------------------------------------------
#         DBT TOLERANCE RULE 
#------------------------------------------

def within_tolerance(a: np.ndarray, b: np.ndarray, tolerance: float) -> np.ndarray:
    return np.abs(a - b) <= tolerance
