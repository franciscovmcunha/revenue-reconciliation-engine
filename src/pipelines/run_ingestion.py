import uuid
from src.utils.config import CASH_REGISTER, CARD_TERMINAL, PMS
from src.ingestion.pms import pipeline as pms
from src.ingestion.cash_register import pipeline as cash_register
from src.ingestion.card_terminal import pipeline as card_terminal
import logging

#------------------------------------------
#              RUN INGESTION
#------------------------------------------


def main() -> None:
    run_id = str(uuid.uuid4())
    pms.run(run_id)
    for workbook in sorted(CASH_REGISTER.glob("*.xlsx")):
        cash_register.run(str(workbook), run_id)
    card_terminal.run(str(CARD_TERMINAL), run_id)


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    )

    main()