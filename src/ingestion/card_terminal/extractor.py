import re
import pandas as pd
from src.common.document_intelligence_client import DocumentIntelligenceClient
from src.utils.config import AZURE_DOCUMENT_ENDPOINT, AZURE_DOCUMENT_KEY

#------------------------------------------
#         CARD TERMINAL EXTRACTOR
#------------------------------------------

CARD_TERMINAL_MODEL_ID = "prebuilt-read"

_SLIP = re.compile(
    r"Data do relatório\s+(?P<date>\d{2}/\d{2}).*?"
    r"Pagamento.*?Valor total\s+(?P<pay_total>[\d.,\s]+?)\s*€.*?"
    r"Devolução.*?Valor total\s+-?\s*(?P<refund_total>[\d.,\s]+?)\s*€.*?"
    r"Saldo.*?Valor total\s+(?P<saldo_total>[\d.,\s]+?)\s*€",
    re.DOTALL,
)

_client = DocumentIntelligenceClient(endpoint=AZURE_DOCUMENT_ENDPOINT, api_key=AZURE_DOCUMENT_KEY)


def extract_card_terminal_rows(file_path: str) -> pd.DataFrame:
    result = _client.analyze_document(file_path, model_id=CARD_TERMINAL_MODEL_ID)
    text = result.fields[0].value
    rows = [
        {
            "transaction_date": m.group("date"),
            "amount": m.group("pay_total"),
            "refund_amount": m.group("refund_total"),
            "saldo_amount": m.group("saldo_total"),
            "extraction_confidence": None,
            "source_file": file_path,
            "source_system": "card_terminal",
        }
        for m in _SLIP.finditer(text)
    ]
    return pd.DataFrame(rows)