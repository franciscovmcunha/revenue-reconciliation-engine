import pandas as pd
from src.ingestion.card_terminal.extractor import (
_PAYBYRD_SLIP,
_ABANCA_SLIP)
from src.ingestion.card_terminal.validator import validate_card_terminal_rows

#------------------------------------------
#          CARD TERMINAL TESTS
#------------------------------------------


#------------------------------------------
#                 PAYBYRD
#------------------------------------------

def test_paybyrd_regex_finds_one_slip():
    text = """Data do relatório 01/01
    Pagamento
    Valor total 494,00 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 494,00 €"""
    matches = list(_PAYBYRD_SLIP.finditer(text))
    assert len(matches) == 1
    assert matches[0].group("date") == "01/01"
    assert matches[0].group("pay_total") == "494,00"



def test_paybyrd_regex_handles_thousands():
    text = """Data do relatório 10/04
    Pagamento
    Valor total 2 984,89 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 2 984,89 €"""
    matches = list(_PAYBYRD_SLIP.finditer(text))
    assert len(matches) == 1
    assert matches[0].group("pay_total") == "2 984,89"


def test_paybyrd_regex_finds_multiple_slips():
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
    matches = list(_PAYBYRD_SLIP.finditer(text))
    assert len(matches) == 2
    assert matches[0].group("date") == "09/04"
    assert matches[1].group("date") == "10/04"


#------------------------------------------
#                 ABANCA
#------------------------------------------

def test_abanca_regex_finds_one_slip():
    text = """
    PORTUGAL ON HOLIDAYS ALECRIM AO CHIADO Ident. TPA: 01114402
    26-04-30 16:55:32 Per:030 Tr:004 Mg687
    TOTAIS TPA
    Conta396003040029633
    COMPRA
    002
    1049,30 €
    MC C TRAV
    002
    Valor
    1049,30+ €
    Desc. :
    19,41+ €
    TOTAL A MOVIMENTAR
    1029,89+ €
    TPA DESATIVADO
    """

    matches = list(_ABANCA_SLIP.finditer(text))

    assert len(matches) == 1
    assert matches[0].group("terminal_id") == "01114402"
    assert matches[0].group("date") == "26-04-30"
    assert matches[0].group("pay_total") == "1049,30"
    assert matches[0].group("saldo_total") == "1029,89"

def test_abanca_regex_parses_second_terminal():
    text = """
    PORTUGAL ON HOLIDAYS ALECRIM AO CHIADO Ident. TPA: 01114402
    26-04-30 16:55:32 Per:030 Tr:004 Mg687
    TOTAIS TPA
    Conta396003040029633
    COMPRA
    002
    1049,30 €
    MC C TRAV
    002
    Valor
    1049,30+ €
    Desc. :
    19,41+ €
    TOTAL A MOVIMENTAR
    1029,89+ €
    TPA DESATIVADO
    """

    matches = list(_ABANCA_SLIP.finditer(text))

    assert len(matches) == 1
    assert matches[0].group("terminal_id") == "01114402"
    assert matches[0].group("pay_total") == "1049,30"
    assert matches[0].group("saldo_total") == "1029,89"

def test_abanca_regex_finds_multiple_slips():
    text = """
    PORTUGAL ON HOLIDAYS ALECRIM AO CHIADO Ident. TPA: 01114403
    26-04-30 16:55:14 Per:029 Tr:003 Mg686
    TOTAIS TPA
    Conta396043440029633
    COMPRA
    003
    2049,30 €
    MC C TRAV
    002
    Valor
    2049,30+ €
    Desc. :
    29,41+ €
    TOTAL A MOVIMENTAR
    2029,89+ €
    TPA DESATIVADO

    PORTUGAL ON HOLIDAYS ALECRIM AO CHIADO Ident. TPA: 01114402
    26-04-30 16:55:32 Per:030 Tr:004 Mg687
    TOTAIS TPA
    Conta396003040029633
    COMPRA
    002
    1049,30 €
    MC C TRAV
    002
    Valor
    1049,30+ €
    Desc. :
    19,41+ €
    TOTAL A MOVIMENTAR
    1029,89+ €
    TPA DESATIVADO
    """

    matches = list(_ABANCA_SLIP.finditer(text))

    assert len(matches) == 2
    assert matches[0].group("terminal_id") == "01114403"
    assert matches[1].group("terminal_id") == "01114402"

#------------------------------------------
#           PAYBYRD AND ABANCA
#------------------------------------------

def test_mixed_page_finds_paybyrd_and_abanca():
    text = """
    Data do relatório 22/04
    Pagamento
    Valor total 1 563,85 €
    Devolução
    Valor total -0,00 €
    Saldo
    Valor total 1 563,85 €

    PORTUGAL ON HOLIDAYS ALECRIM AO CHIADO Ident. TPA: 01114402
    26-04-30 16:55:32 Per:030 Tr:004 Mg687
    TOTAIS TPA
    Conta396003040029633
    COMPRA
    002
    1049,30 €
    MC C TRAV
    002
    Valor
    1049,30+ €
    Desc. :
    19,41+ €
    TOTAL A MOVIMENTAR
    1029,89+ €
    TPA DESATIVADO
    """

    paybyrd_matches = list(
        _PAYBYRD_SLIP.finditer(text)
    )

    abanca_matches = list(
        _ABANCA_SLIP.finditer(text)
    )

    assert len(paybyrd_matches) == 1
    assert len(abanca_matches) == 1


#------------------------------------------
#      VALIDATE CARD TERMINAL TESTS
#------------------------------------------

def test_internally_consistent_slip_is_valid():
    extracted = pd.DataFrame([{"amount": "494,00", "refund_amount": "0,00", "saldo_amount": "494,00"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 1
    assert result.valid_rows.iloc[0]["amount"] == 494.00  


def test_amount_with_thousands_separator_parses_correctly():
    extracted = pd.DataFrame([{"amount": "2 326,15", "refund_amount": "0,00", "saldo_amount": "2 326,15"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 1
    assert result.valid_rows.iloc[0]["amount"] == 2326.15


def test_inconsistent_slip_is_flagged():
    extracted = pd.DataFrame([{"amount": "494,00", "refund_amount": "0,00", "saldo_amount": "400,00"}])
    result = validate_card_terminal_rows(extracted)
    assert len(result.valid_rows) == 0
    assert len(result.low_confidence_rows) == 1