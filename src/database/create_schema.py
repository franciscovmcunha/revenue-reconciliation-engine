from sqlalchemy import text

from .connection import engine


SCHEMAS = [
    "bronze",
    "silver",
    "gold",
]


def create_schemas() -> None:
    """
    Creates all database schemas if they do not already exist.
    """

    with engine.begin() as connection:

        for schema in SCHEMAS:

            connection.execute(
                text(
                    f"CREATE SCHEMA IF NOT EXISTS {schema};"
                )
            )

            print(f"Schema '{schema}' ready.")