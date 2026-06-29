#=========================================================================
#                               SCHEAMAS
#=========================================================================

EXPECTED_COLUMNS = [
    "Avançado",
    "Cancelado",
    "Regularizado",
    "Processado",
    "Fiscal",
    "Tipo Doc.",
    "Documento Nº",
    "Titular",
    "Nº. Fiscal",
    "Data",
    "Hora",
    "Valor",
    "Valor Liquido",
    "Moeda Estrangeira",
    "Moeda",
    "Código",
    "Empresa",
    "Voucher",
    "Utilizador",
    "=> Para Conta",
    "Ref. Factura",
    "Ref. Nota Crédito",
    "Externo",
    "Nº da Assinatura Fiscal",
    "Forma Pagamento",
    "Cartão",
    "Nº Cartão",
    "Nº Fatura Eletrônica",
    "Reserva",
    "Titular da Reserva",
    "ID Pagamento Externo",
]

COLUMN_MAPPING = {
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

DATE_COLUMNS = [
    "invoice_date",
]

MONEY_COLUMNS = [
    "gross_amount",
    "net_amount",
]

INTEGER_COLUMNS = [
]

REQUIRED_COLUMNS = [
    "Documento Nº",
    "Tipo Doc.",
    "Data",
    "Valor",
]