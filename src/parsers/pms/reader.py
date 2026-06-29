
from pathlib import Path

import pandas as pd

from src.utils.config import PMS_FOLDER

# ==============================================================================
# INGESTION & MERGE
#===============================================================================


def read_pms_csvs() -> pd.DataFrame:
    """
    Reads every PMS CSV found in data/raw/pms
    and returns a single concatenated DataFrame.
    """

    csv_files = sorted(PMS_FOLDER.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found in {PMS_FOLDER}"
        )

    dataframes = []

    for file in csv_files:

        print(f"Reading: {file.name}")

        df = pd.read_csv(
            filepath_or_buffer=file,
            sep=";",
            encoding="utf-8",
            dtype=str,
            keep_default_na=True
        )

        dataframes.append(df)

    bronze_df = pd.concat(
        dataframes,
        ignore_index=True
    )

    print(f"\nLoaded {len(csv_files)} CSV file(s)")
    print(f"Rows: {len(bronze_df)}")
    print(f"Columns: {len(bronze_df.columns)}")

    return bronze_df