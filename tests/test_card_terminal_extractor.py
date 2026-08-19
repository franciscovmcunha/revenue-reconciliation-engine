"""Tests for src.ingestion.card_terminal.extractor — mocks the Document
Intelligence client so these run without real Azure credentials or real
scanned receipts.
"""

import pytest


@pytest.mark.skip(reason="extractor not implemented yet")
def test_low_confidence_field_is_flagged_not_corrected():
    raise NotImplementedError


@pytest.mark.skip(reason="extractor not implemented yet")
def test_extraction_confidence_is_preserved_to_canonical_row():
    raise NotImplementedError
