"""PostgreSQL connection and bronze-load helpers shared by all four ingestion
pipelines. Connection details are read from environment variables — see
.env.example — never hardcoded.
"""

import pandas as pd


def get_connection():
    """Return a psycopg2/SQLAlchemy connection using env-configured credentials."""
    raise NotImplementedError


def load_to_bronze(df: pd.DataFrame, source_system: str, ingestion_run_id: str) -> int:
    """Append `df` to the bronze table, tagging every row with `source_system`
    and `ingestion_run_id`. Returns the number of rows written. Never
    truncates or overwrites — bronze is append-only, see
    docs/decisions/0001-preserve-raw-before-normalizing.md."""
    raise NotImplementedError
