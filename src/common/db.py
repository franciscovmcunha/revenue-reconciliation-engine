import pandas as pd
from sqlalchemy import create_engine
from src.utils.config import (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)

_engine = None


#------------------------------------------
#         POSTGRESQL CONNECTION
#------------------------------------------

def get_connection():
    global _engine
    if _engine is None:
        url = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
        _engine = create_engine(url)
    return _engine

#------------------------------------------
#         LOAD BRONZE LAYER
#------------------------------------------

def load_to_bronze(df: pd.DataFrame, source_system: str, ingestion_run_id: str) -> int:
    df = df.copy()
    df["source_system"] = source_system
    df["ingestion_run_id"] = ingestion_run_id
    df.to_sql(source_system, con=get_connection(), schema="bronze", if_exists="append", index=False)
    return len(df)

