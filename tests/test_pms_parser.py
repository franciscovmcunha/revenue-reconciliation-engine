import pandas as pd
from src.ingestion.pms.parser import (
    BRONZE_COLUMNS,
    parse_pms_rows
)
from src.ingestion.pms.validator import validate_pms_rows


#------------------------------------------
#           PMS PARSER TESTS
#------------------------------------------


def _pms_row(
        ref="440/FCT26",
        cancelled="Cancelado",
        amount="48.00",
        date="04/05/2026",
        method="Dinheiro"
        ):
    row = {
    raw_column: None
    for raw_column in BRONZE_COLUMNS
    }
    row.update({
        "Documento Nº": ref,
        "Cancelado": cancelled,
        "Data": date,
        "Valor": amount,
        "Forma Pagamento": method,
    })

    return row


def test_parses_all_canonical_columns():
    raw = pd.DataFrame([
    _pms_row()])
    result = parse_pms_rows(raw)
    assert set(result.columns) == set(
        BRONZE_COLUMNS.values()
    )
    assert result.iloc[0]["document_number"] == "440/FCT26"


def test_cancelled_rows_is_preserved():
    raw = pd.DataFrame([
    _pms_row()])
    result = parse_pms_rows(raw)
    assert result.iloc[0]["is_cancelled"] == "Cancelado"


# #------------------------------------------
# #          PMS VALIDATOR TESTS
# #------------------------------------------


def test_same_document_number_with_different_payment_methods_is_allowed():
    parsed = pd.DataFrame({
        "document_number": [
            "440/FCT26",
            "440/FCT26",
        ],
        "invoice_date": pd.to_datetime([
            "2026-05-04",
            "2026-05-04",
        ]),
        "gross_amount": [
            48.0,
            120.0,
        ],
        "payment_method": [
            "Dinheiro",
            "Cartão",
        ],
    })

    result = validate_pms_rows(parsed)

    assert len(result.valid_rows) == 2
    assert len(result.rejected_rows) == 0