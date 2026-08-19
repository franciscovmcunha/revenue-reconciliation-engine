"""Tests for src.ingestion.cash_register.parser — validates that summary rows
are excluded and transaction rows are correctly anchored by shape, not header
text (docs/source_system_analysis.md).
"""

import pytest


@pytest.mark.skip(reason="parser not implemented yet")
def test_excludes_summary_rows():
    raise NotImplementedError


@pytest.mark.skip(reason="parser not implemented yet")
def test_handles_header_drift_between_periods():
    raise NotImplementedError
