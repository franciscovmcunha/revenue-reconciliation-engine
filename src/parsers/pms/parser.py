import pandas as pd

from .schema import DATE_COLUMNS, MONEY_COLUMNS, COLUMN_MAPPING


def rename_columns(df):
    df = df.copy()
    return df.rename(columns=COLUMN_MAPPING)

def parse_dates(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convert all date columns to datetime.
    """

    df = df.copy()

    for column in DATE_COLUMNS:

        df[column] = pd.to_datetime(
            df[column],
            format="%d/%m/%Y",
            errors="coerce"
        )

    return df


def parse_money(df):

    df = df.copy()

    for column in MONEY_COLUMNS:

        df[column] = (
            df[column]
            .astype(str)
            .str.strip()
            .replace("", None)
        )

        df[column] = pd.to_numeric(
            df[column],
            errors="coerce"
        )

    return df


def parse_strings(df: pd.DataFrame) -> pd.DataFrame:
    """
    Strip leading/trailing whitespace from every string column.
    """

    df = df.copy()

    string_columns = df.select_dtypes(include="object").columns

    for column in string_columns:

        df[column] = df[column].str.strip()

    return df


# def parse(df: pd.DataFrame) -> pd.DataFrame:
#     """
#     Execute every parsing step.
#     """

def parse(df):

    df = rename_columns(df)

    df = parse_dates(df)

    df = parse_money(df)

    df = parse_strings(df)

    return df