import re
import pandas as pd
from src.common.normalization import normalize_amount, normalize_date

#------------------------------------------
#           CASH REGISTER PARSER
#------------------------------------------

TTM_GUEST_PAYMENT = re.compile(r"ttm", re.IGNORECASE)
TTM_INTERNAL_TRANSFER = re.compile(r"reforço|desde ttm", re.IGNORECASE)
INTER_PROPERTY_MARKER = re.compile(r"alfama", re.IGNORECASE)

KNOWN_COLUMNS = [
    "Tipo", "Descrição / Fornecedor", "Documento / Nº Factura",
    "Data do \nDocumento", "Valor do \nDocumento", "CRÉDITO", "DÉBITO",
]


def _find_header_row(sheet: pd.DataFrame) -> int | None:
    for i, value in sheet.iloc[:, 1].items():
        if value == "Tipo":
            return i
    return None


def _sheet_date(sheet: pd.DataFrame):
    for _, row in sheet.iterrows():
        if row.iloc[1] == "Data":
            return row.iloc[2]
    return None


def parse_cash_register_rows(raw_sheets: dict[str, pd.DataFrame], expected_month: int) -> pd.DataFrame:
    parsed = []
    for sheet in raw_sheets.values(): 
        header_row = _find_header_row(sheet)
        if header_row is None:
            continue
        date = _sheet_date(sheet)
        if date is not None and date.month != expected_month:
            continue
        body = sheet.iloc[header_row + 1:].copy()
        body.columns = sheet.iloc[header_row]
        body = body.dropna(subset=["Tipo"])
        if body.empty:
            continue
        body = body.loc[:, KNOWN_COLUMNS].copy()
        body["sheet_date"] = date
        parsed.append(body)

    if not parsed:
        return pd.DataFrame()

    df = pd.concat(parsed, ignore_index=True)
    df["amount"] = normalize_amount(df["CRÉDITO"].fillna(df["DÉBITO"]))
    df["transaction_date"] = normalize_date(df["Data do \nDocumento"].fillna(df["sheet_date"]))
    df["till_category"] = df["Tipo"]
    df["source_system"] = "cash_register"

    descricao = df["Descrição / Fornecedor"].fillna("")
    is_ttm = descricao.str.contains(TTM_GUEST_PAYMENT) & ~descricao.str.contains(TTM_INTERNAL_TRANSFER)
    df["is_ttm_payment"] = is_ttm
    df["is_inter_property_deposit"] = is_ttm & descricao.str.contains(INTER_PROPERTY_MARKER)
    return df