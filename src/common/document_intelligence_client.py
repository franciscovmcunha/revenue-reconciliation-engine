"""Thin wrapper over the Azure AI Document Intelligence SDK, shared by every
ingestion path that reads from a scanned document (card_terminal, municipal_tax).

Responsible for: authenticating against the configured endpoint/key, submitting
a document for analysis, and returning the extracted fields with their
per-field confidence score — nothing source-specific belongs here, that lives
in each source's own `extractor.py`.
"""

from dataclasses import dataclass


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
    """Wraps `azure.ai.documentintelligence.DocumentIntelligenceClient`.

    Configuration (endpoint, API key) is read from environment variables —
    see `.env.example`. Never hardcode credentials here.
    """

    def __init__(self, endpoint: str, api_key: str) -> None:
        raise NotImplementedError

    def analyze_document(self, file_path: str, model_id: str) -> ExtractionResult:
        """Submit `file_path` for analysis against `model_id` and return the
        extracted fields. `model_id` differs between card_terminal and
        municipal_tax — each extractor passes its own."""
        raise NotImplementedError
