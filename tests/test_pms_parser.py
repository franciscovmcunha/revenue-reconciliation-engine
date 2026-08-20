import pandas as pd
from src.ingestion.pms.parser import parse_pms_rows
from src.ingestion.pms.validator import validate_pms_rows

#------------------------------------------
#           PMS PARSER TESTS
#------------------------------------------


def _pms_row(ref="440/FCT26", cancelled="", amount="48.00", date="04/05/2026", method="Dinheiro"):
    return {
        "Documento Nº": ref,
        "Cancelado": cancelled,
        "Data": date,
        "Valor": amount,
        "Forma Pagamento": method,
    }


def test_parses_all_canonical_columns():
    raw = pd.DataFrame([_pms_row()])
    result = parse_pms_rows(raw)
    assert set(result.columns) == {
        "transaction_ref", "transaction_date", "amount", "payment_method", "source_system"
    }
    assert result.iloc[0]["transaction_ref"] == "440/FCT26"


def test_amount_is_always_positive():
    raw = pd.DataFrame([_pms_row(amount="-48.00")])
    result = parse_pms_rows(raw)
    assert (result["amount"] >= 0).all()


def test_cancelled_rows_are_excluded():
    raw = pd.DataFrame([_pms_row(ref="440/FCT26"), _pms_row(ref="441/FCT26", cancelled="Cancelado")])
    result = parse_pms_rows(raw)
    assert len(result) == 1
    assert result.iloc[0]["transaction_ref"] == "440/FCT26"


#------------------------------------------
#          PMS VALIDATOR TESTS
#------------------------------------------


def test_duplicate_transaction_ref_is_rejected():
    parsed = pd.DataFrame({
        "transaction_ref": ["440/FCT26", "440/FCT26"],
        "transaction_date": pd.to_datetime(["2026-05-04", "2026-05-04"]),
        "amount": [48.0, 48.0],
        "payment_method": ["Dinheiro", "Dinheiro"],
        "source_system": ["pms", "pms"],
    })
    result = validate_pms_rows(parsed)
    assert len(result.valid_rows) == 1
    assert len(result.rejected_rows) == 1