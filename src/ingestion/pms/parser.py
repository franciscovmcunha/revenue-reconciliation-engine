import pandas as pd
from src.common.normalization import normalize_date

#------------------------------------------
#                PMS PARSER
#------------------------------------------

# 1:1 rename onto bronze.pms's existing columns — every raw column is kept,
# none dropped. Business rules (cancellations, canonical field selection)
# belong in dbt staging, not here — docs/decisions/0001-preserve-raw-before-normalizing.md
BRONZE_COLUMNS = {
    "Avançado": "is_advanced",
    "Cancelado": "is_cancelled",
    "Regularizado": "is_regularized",
    "Processado": "is_processed",
    "Fiscal": "is_fiscal",
    "Tipo Doc.": "document_type",
    "Documento Nº": "document_number",
    "Titular": "invoice_holder",
    "Nº. Fiscal": "tax_number",
    "Data": "invoice_date",
    "Hora": "invoice_time",
    "Valor": "gross_amount",
    "Valor Liquido": "net_amount",
    "Moeda Estrangeira": "foreign_currency_amount",
    "Moeda": "currency",
    "Código": "company_code",
    "Empresa": "company",
    "Voucher": "voucher",
    "Utilizador": "user_email",
    "=> Para Conta": "transfer_account",
    "Ref. Factura": "invoice_reference",
    "Ref. Nota Crédito": "credit_note_reference",
    "Externo": "external_reference",
    "Nº da Assinatura Fiscal": "fiscal_signature_number",
    "Forma Pagamento": "payment_method",
    "Cartão": "card_brand",
    "Nº Cartão": "card_number",
    "Nº Fatura Eletrônica": "electronic_invoice_number",
    "Reserva": "reservation_number",
    "Titular da Reserva": "reservation_holder",
    "ID Pagamento Externo": "external_payment_id",
}


def _parse_raw_amount(raw_amounts: pd.Series) -> pd.Series:
    # only strips the thousands separator so Postgres can store a real
    # double precision value — no abs(), no business rule, sign stays
    # exactly as the source had it
    cleaned = raw_amounts.astype(str).str.replace(",", "", regex=False)
    return pd.to_numeric(cleaned, errors="coerce")


def parse_pms_rows(raw: pd.DataFrame) -> pd.DataFrame:
    df = raw.rename(columns=BRONZE_COLUMNS)[list(BRONZE_COLUMNS.values())].copy()
    df["invoice_date"] = normalize_date(df["invoice_date"])
    df["gross_amount"] = _parse_raw_amount(df["gross_amount"])
    df["net_amount"] = _parse_raw_amount(df["net_amount"])
    return df
