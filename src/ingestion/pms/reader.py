from src.utils.config import PMS
import pandas as pd
import numpy as np

#------------------------------------------
#                PMS READER
#------------------------------------------

frames = []

pms_files = PMS.glob("*.csv")

for file in pms_files:
    df = pd.read_csv(file, sep=";")
    frames.append(df)

df = pd.concat(frames, ignore_index=True)
    


