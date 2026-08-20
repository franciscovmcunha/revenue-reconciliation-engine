from pathlib import Path

#------------------------------------------
#          CARD TERMINAL READER
#------------------------------------------


def list_pending_receipts(directory: str) -> list[str]:
    return sorted(str(p) for p in Path(directory).glob("*/*.pdf"))  # one subfolder per month