from .schema import EXPECTED_COLUMNS

#=========================================================================
#                               VALIDATOR
#=========================================================================

def validate_schema(df):

    received = list(df.columns)

    if received != EXPECTED_COLUMNS:

        missing = [
            c for c in EXPECTED_COLUMNS
            if c not in received
        ]

        extra = [
            c for c in received
            if c not in EXPECTED_COLUMNS
        ]

        raise ValueError(
            f"""
Invalid PMS schema.

Missing columns:
{missing}

Unexpected columns:
{extra}
"""
        )


def validate_empty(df):

    if df.empty:

        raise ValueError(
            "PMS dataframe is empty."
        )


def validate(df):

    validate_empty(df)

    validate_schema(df)