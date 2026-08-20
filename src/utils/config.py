from pathlib import Path
import os
from dotenv import load_dotenv

load_dotenv()

#------------------------------------------
#                LOAD DATA
#------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

RAW_DATA = PROJECT_ROOT / "data" / "raw"

CASH_REGISTER = RAW_DATA / "cash_register"

CARD_TERMINAL = RAW_DATA / "paybyrd"

PMS = RAW_DATA / "pms"

#------------------------------------------
#                  AZURE
#------------------------------------------

AZURE_DOCUMENT_ENDPOINT = os.getenv("AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT")
AZURE_DOCUMENT_KEY = os.getenv("AZURE_DOCUMENT_INTELLIGENCE_KEY")

#------------------------------------------
#                POSTGRESQL
#------------------------------------------

DB_HOST = os.getenv("POSTGRES_HOST")
DB_PORT = os.getenv("POSTGRES_PORT")
DB_NAME = os.getenv("POSTGRES_DB")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")