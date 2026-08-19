"""Tests for src.ingestion.municipal_tax.extractor — same mocked-client
approach as test_card_terminal_extractor.py.
"""

import pytest


@pytest.mark.skip(reason="extractor not implemented yet")
def test_period_rollup_is_not_treated_as_a_transaction():
    raise NotImplementedError
