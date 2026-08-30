import pandas as pd
from src.ingestion.cash_register.reader import read_cash_register_workbook
from src.ingestion.cash_register.parser import parse_cash_register_rows
import pytest

#------------------------------------------
#             CASH REGISTER TESTS
#------------------------------------------

@pytest.mark.excel
def test_real_excel_spreadsheet():
    workbook = read_cash_register_workbook(
        "data/raw/cash_register/Folha de Caixa Diaria - Janeiro.xlsx"
    )
    print(workbook.keys())

    for sheet_name, sheet in workbook.items():
        print(f"\n--- SHEET: {sheet_name} ---")
        print(sheet.head(15))



def _fake_sheet(day=4, month=5, transaction_rows=None):
    transaction_rows = transaction_rows or []
    rows = [
        [None, None, None, None, None, None, None, None],
        [None, "Data", pd.Timestamp(2026, month, day), None, None, None, None, None],
        [None, None, None, None, None, None, None, None],
        [None, "Tipo", "Descrição / Fornecedor", "Documento / Nº Factura",
         "Data do \nDocumento", "Valor do \nDocumento", "CRÉDITO", "DÉBITO"],  
    ]
    rows.extend(transaction_rows)
    rows.append([None, None, None, None, None, "Saldo inicial", "Saldo final", None])
    return pd.DataFrame(rows)


def test_excludes_summary_rows():
    transaction = [None, "Fundo de caixa", "TTM#12", None, None, None, 48, None]
    sheet = _fake_sheet(transaction_rows=[transaction])
    result = parse_cash_register_rows({"4": sheet}, expected_month=5)
    assert len(result) == 1
    assert result.iloc[0]["amount"] == 48.0


def test_excludes_sheet_from_unexpected_month():
    transaction = [None, "Fundo de caixa", "Estadia", None, None, None, 100, None]
    sheet = _fake_sheet(day=1, month=3, transaction_rows=[transaction])
    result = parse_cash_register_rows({"1": sheet}, expected_month=5)
    assert len(result) == 0


def test_ttm_guest_payment_is_tagged():
    transaction = [None, "Fundo de caixa", "TTM#12", None, None, None, 48, None]
    sheet = _fake_sheet(transaction_rows=[transaction])
    result = parse_cash_register_rows({"4": sheet}, expected_month=5)
    assert result.iloc[0]["is_ttm_payment"] == True
    assert result.iloc[0]["is_inter_property_deposit"] == False


def test_reforco_transfer_is_not_tagged_as_ttm_payment():
    transaction = [None, "Fundo de caixa", "Reforço de FC desde TTM", None, None, None, 16, None]
    sheet = _fake_sheet(transaction_rows=[transaction])
    result = parse_cash_register_rows({"1": sheet}, expected_month=5)
    assert result.iloc[0]["is_ttm_payment"] == False


def test_sister_property_ttm_is_flagged_as_inter_property():
    # "sister-property" matches the default SISTER_PROPERTY_MARKER
    # (src/utils/config.py) -- a real deployment sets that env var to the
    # actual sister property's name; see docs/reconciliation_rules.md,
    # "The inter-property deposit exception".
    transaction = [None, "Fundo de caixa", "TTM sister-property", "129/FCTAYH26", None, None, 32, None]
    sheet = _fake_sheet(transaction_rows=[transaction])
    result = parse_cash_register_rows({"8": sheet}, expected_month=5)
    assert result.iloc[0]["is_ttm_payment"] == True
    assert result.iloc[0]["is_inter_property_deposit"] == True