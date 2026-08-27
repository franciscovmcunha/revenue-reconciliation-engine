import re
import pandas as pd
from typing import Any
from src.common.document_intelligence_client import DocumentIntelligenceClient
from src.utils.config import AZURE_DOCUMENT_ENDPOINT, AZURE_DOCUMENT_KEY

#------------------------------------------
#         CARD TERMINAL EXTRACTOR
#------------------------------------------

CARD_TERMINAL_MODEL_ID = "prebuilt-read"

_PAYBYRD_SLIP = re.compile(
    r"Data do relatório\s+(?P<date>\d{2}/\d{2}).*?"
    r"Pagamento.*?Valor total\s+(?P<pay_total>[\d.,\s]+?)\s*€.*?"
    r"Devolução.*?Valor total\s+-?\s*(?P<refund_total>[\d.,\s]+?)\s*€.*?"
    r"Saldo.*?Valor total\s+(?P<saldo_total>[\d.,\s]+?)\s*€",
    re.DOTALL,
)

_ABANCA_SLIP = re.compile(
    r"Ident\.?\s*TPA:\s*(?P<terminal_id>\d+).*?"
    r"(?P<date>\d{2}-\d{2}-\d{2}).*?"
    r"TOTAIS\s+TPA.*?"
    r"COMPRA\s+\d+\s+(?P<pay_total>[\d.,\s]+?)\s*€.*?"
    r"TOTAL\s+A\s+MOVIMENTAR\s+(?P<saldo_total>[\d.,\s]+?)\s*\+?\s*€",
    re.DOTALL | re.IGNORECASE,
)


_client = DocumentIntelligenceClient(endpoint=AZURE_DOCUMENT_ENDPOINT, api_key=AZURE_DOCUMENT_KEY,)

def _extract_paybyrd_rows(
    text: str,
    file_path: str,
) -> list[dict]:
    return [
        {
            "transaction_date": match.group("date"),
            "amount": match.group("pay_total"),
            "refund_amount": match.group("refund_total"),
            "saldo_amount": match.group("saldo_total"),
            "extraction_confidence": None,
            "source_file": file_path,
            "source_system": "card_terminal",
            "terminal_provider": "paybyrd",
        }
        for match in _PAYBYRD_SLIP.finditer(text)
        ]


def _extract_abanca_rows(
    text: str,
    file_path: str,
) -> list[dict[str, Any]]:
    return [
        {
            "transaction_date": match.group("date"),
            "amount": match.group("pay_total"),
            "refund_amount": "0",
            "saldo_amount": match.group("saldo_total"),
            "extraction_confidence": None,
            "source_file": file_path,
            "source_system": "card_terminal",
            "terminal_provider": "abanca",           
        }
        for match in _ABANCA_SLIP.finditer(text)
    ]


def extract_card_terminal_rows(file_path: str) -> pd.DataFrame:
    result = _client.analyze_document(file_path, model_id=CARD_TERMINAL_MODEL_ID)
    text = result.fields[0].value
    paybyrd_rows = _extract_paybyrd_rows(
        text,
        file_path,
    )

    abanca_rows = _extract_abanca_rows(
        text,
        file_path,
    )
    rows = paybyrd_rows + abanca_rows
    return pd.DataFrame(rows)