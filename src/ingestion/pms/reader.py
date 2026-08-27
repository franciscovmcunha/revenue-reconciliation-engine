from src.utils.config import PMS
import pandas as pd

#------------------------------------------
#                PMS READER
#------------------------------------------


def read_pms_export() -> pd.DataFrame:
        files = list(PMS.glob("*.csv"))
        if not files:
                return pd.DataFrame()
        frames = [pd.read_csv(file, sep=";", encoding="utf-8-sig") for file in files]
        return pd.concat(frames, ignore_index=True)
    

