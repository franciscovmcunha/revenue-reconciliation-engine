import pytest
from src.common.document_intelligence_client import DocumentIntelligenceClient
from src.ingestion.card_terminal.extractor import (
AZURE_DOCUMENT_ENDPOINT,
AZURE_DOCUMENT_KEY,
CARD_TERMINAL_MODEL_ID)



#------------------------------------------
#         AZURE CARD TERMINAL TEST
#------------------------------------------

@pytest.mark.azure
def test_abanca_ocr_text():
    client = DocumentIntelligenceClient(endpoint=AZURE_DOCUMENT_ENDPOINT, api_key=AZURE_DOCUMENT_KEY)
    result = client.analyze_document(
        "/Users/vitormoraespc/Developer/revenue-reconciliation-engine/data/raw/paybyrd/april/Relatório TPA 30_4.pdf",
        model_id=CARD_TERMINAL_MODEL_ID
    )

    text = result.fields[0].value
    print("\n----- OCR TEXT -----\n")
    print(text)
