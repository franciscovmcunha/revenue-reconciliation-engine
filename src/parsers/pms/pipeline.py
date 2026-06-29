from pandas import DataFrame

from .reader import read_pms_csvs
from .validator import validate
from .parser import parse

#=========================================================================
#                         PMS INGESTION PIPELINE
#-------------------------------------------------------------------------
#STEPS: 
# 1. Read every CSV from data/raw/pms
# 2. Validate raw schema
# 3. Parse and convert data types
# 4. Return Bronze DataFrame
#=========================================================================


def run() -> DataFrame:

    df = read_pms_csvs()

    validate(df)

    df = parse(df)

    return df