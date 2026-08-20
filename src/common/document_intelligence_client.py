from dataclasses import dataclass
from azure.ai.documentintelligence import DocumentIntelligenceClient as _AzureClient
from azure.core.credentials import AzureKeyCredential


@dataclass
class ExtractedField:
    name: str
    value: str
    confidence: float


@dataclass
class ExtractionResult:
    fields: list[ExtractedField]
    raw_response: dict


class DocumentIntelligenceClient:
    def __init__(self, endpoint: str, api_key: str) -> None:
        self._client = _AzureClient(endpoint=endpoint, credential=AzureKeyCredential(api_key))

    def analyze_document(self, file_path: str, model_id: str) -> ExtractionResult:
        with open(file_path, "rb") as f:
            poller = self._client.begin_analyze_document(model_id, f)
        result = poller.result()
        fields = [ExtractedField(name="content", value=result.content, confidence=1.0)]
        return ExtractionResult(fields=fields, raw_response=result.as_dict())