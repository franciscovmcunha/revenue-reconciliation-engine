import pandas as pd
from src.ingestion.card_terminal.extractor import _SLIP
from src.ingestion.card_terminal.validator import validate_card_terminal_rows

#------------------------------------------
#          CARD TERMINAL TESTS
#------------------------------------------


def test_slip_regex_finds_one_slip():
    text = """Data do relatório 01/01
    Pagamento
    Valor total 494,00 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 494,00 €"""
    matches = list(_SLIP.finditer(text))
    assert len(matches) == 1
    assert matches[0].group("date") == "01/01"
    assert matches[0].group("pay_total") == "494,00"


def test_slip_regex_handles_space_as_thousands_separator():
    text = """Data do relatório 10/04
    Pagamento
    Valor total 2 984,89 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 2 984,89 €"""
    matches = list(_SLIP.finditer(text))
    assert len(matches) == 1
    assert matches[0].group("pay_total") == "2 984,89"


def test_slip_regex_finds_multiple_slips_on_one_page():
    text = """Data do relatório 09/04
    Pagamento
    Valor total 2 326,15 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 2 326,15 €

    Data do relatório 10/04
    Pagamento
    Valor total 2 984,89 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 2 984,89 €"""
    matches = list(_SLIP.finditer(text))
    assert len(matches) == 2
    assert matches[0].group("date") == "09/04"
    assert matches[1].group("date") == "10/04"


def test_internally_consistent_slip_is_valid():
    extracted = pd.DataFrame([{"amount": "494,00", "refund_amount": "0,00", "saldo_amount": "494,00"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 1
    assert result.valid_rows.iloc[0]["amount"] == 494.00  # catches the x100 bug directly


def test_amount_with_thousands_separator_parses_correctly():
    extracted = pd.DataFrame([{"amount": "2 326,15", "refund_amount": "0,00", "saldo_amount": "2 326,15"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 1
    assert result.valid_rows.iloc[0]["amount"] == 2326.15


def test_inconsistent_slip_is_flagged_not_corrected():
    extracted = pd.DataFrame([{"amount": "494,00", "refund_amount": "0,00", "saldo_amount": "400,00"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 0
    assert len(result.low_confidence_rows) == 1