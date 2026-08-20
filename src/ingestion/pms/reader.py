from src.utils.config import PMS
import pandas as pd
import numpy as np

#------------------------------------------
#                PMS READER
#------------------------------------------


pms_files = PMS.glob("*.csv")

def read_pms_export() -> pd.DataFrame:
        frames = [pd.read_csv(file, sep=";", encoding="utf-8-sig") for file in pms_files]
        return pd.concat(frames, ignore_index=True)
    
