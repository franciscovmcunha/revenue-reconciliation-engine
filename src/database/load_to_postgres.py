import pandas as pd

from sqlalchemy import inspect

from .connection import engine


def load_dataframe(
    dataframe: pd.DataFrame,
    schema: str,
    table: str,
    if_exists: str = "replace"
) -> None:
    """
    Load a pandas DataFrame into PostgreSQL.

    Parameters
    ----------
    dataframe : pd.DataFrame
        DataFrame to load.

    schema : str
        Destination schema.

    table : str
        Destination table.

    if_exists : str
        "fail"
        "replace"
        "append"
    """

    inspector = inspect(engine)

    schemas = inspector.get_schema_names()

    if schema not in schemas:
        raise ValueError(
            f"Schema '{schema}' does not exist."
        )

    dataframe.to_sql(
        name=table,
        con=engine,
        schema=schema,
        if_exists=if_exists,
        index=False,
        method="multi"
    )

    print(
        f"Successfully loaded {len(dataframe)} rows into {schema}.{table}"
    )