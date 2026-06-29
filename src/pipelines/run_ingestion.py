from src.database.create_schema import create_schemas
from src.database.load_to_postgres import load_dataframe

from src.parsers.pms.pipeline import run


def main():

    print("Creating database schemas...")

    create_schemas()

    print("Running PMS pipeline...")

    pms_df = run()

    load_dataframe(
        dataframe=pms_df,
        schema="bronze",
        table="pms",
        if_exists="replace"
    )

    print("Done.")


if __name__ == "__main__":
    main()