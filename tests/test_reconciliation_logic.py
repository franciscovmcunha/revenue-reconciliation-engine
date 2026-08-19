"""End-to-end-ish tests for the three reconciliation outcomes described in
docs/reconciliation_rules.md — matched, mismatch, missing — run against
synthetic fixtures, never against data/raw/.
"""

import pytest


@pytest.mark.skip(reason="reconciliation logic lives in dbt — see dbt/tests/ instead")
def test_matched_within_tolerance():
    raise NotImplementedError


@pytest.mark.skip(reason="reconciliation logic lives in dbt — see dbt/tests/ instead")
def test_mismatch_beyond_tolerance():
    raise NotImplementedError


@pytest.mark.skip(reason="reconciliation logic lives in dbt — see dbt/tests/ instead")
def test_missing_transaction_flagged_not_dropped():
    raise NotImplementedError
