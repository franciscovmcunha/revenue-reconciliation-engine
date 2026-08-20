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

PAYBYRD = RAW_DATA / "paybyrd"

PMS = RAW_DATA / "pms"

# No MUNICIPAL_TAX path — municipal tax isn't a separate source for this
# reconciliation window. See docs/source_system_analysis.md, "Municipal tax
# (TTM)" for why: it's a derived check inside cash_register's own data.

#------------------------------------------
#                  AZURE
#------------------------------------------

AZURE_DOCUMENT_ENDPOINT = os.getenv("AZURE_DOCUMENT_ENDPOINT")
AZURE_DOCUMENT_KEY = os.getenv("AZURE_DOCUMENT_KEY")

#------------------------------------------
#                POSTGRESQL
#------------------------------------------


DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")