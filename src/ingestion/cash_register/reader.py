import pandas as pd

#------------------------------------------
#           CASH REGISTER READER
#------------------------------------------


def read_cash_register_workbook(file_path: str) -> dict[str, pd.DataFrame]:
    return pd.read_excel(file_path, sheet_name=None, header=None)
