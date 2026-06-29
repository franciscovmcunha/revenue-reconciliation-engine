-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------


------------------------NULL ANALYSIS----------------------------
-- OBJECTIVE: ANALYZE NULL VALUE DISTRIBUTION ACROSS THE DATASET.
-----------------------------------------------------------------


WITH nulls_count AS (
	SELECT
		COUNT(*) AS invoices,
		SUM(CASE WHEN is_advanced IS NULL THEN 1 ELSE 0 END) AS is_advanced_nulls_count,
		
		SUM(CASE WHEN is_cancelled IS NULL THEN 1 ELSE 0 END) AS is_cancelled_nulls_count,

		SUM(CASE WHEN is_regularized IS NULL THEN 1 ELSE 0 END) AS is_regularized_nulls_count,

		SUM(CASE WHEN is_processed IS NULL THEN 1 ELSE 0 END) AS is_processed_nulls_count,

		SUM(CASE WHEN is_fiscal IS NULL THEN 1 ELSE 0 END) AS is_fiscal_nulls_count,

		SUM(CASE WHEN document_type IS NULL THEN 1 ELSE 0 END) AS document_type_nulls_count,

		SUM(CASE WHEN document_number IS NULL THEN 1 ELSE 0 END) AS document_number_nulls_count,

		SUM(CASE WHEN invoice_holder IS NULL THEN 1 ELSE 0 END) AS invoice_holder_nulls_count,

		SUM(CASE WHEN tax_number IS NULL THEN 1 ELSE 0 END) AS tax_number_nulls_count,

		SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS invoice_date_nulls_count,

		SUM(CASE WHEN invoice_time IS NULL THEN 1 ELSE 0 END) AS invoice_time_nulls_count,

		SUM(CASE WHEN gross_amount IS NULL THEN 1 ELSE 0 END) AS gross_amount_nulls_count,

		SUM(CASE WHEN net_amount IS NULL THEN 1 ELSE 0 END) AS net_amount_nulls_count,

		SUM(CASE WHEN foreign_currency_amount IS NULL THEN 1 ELSE 0 END) AS foreign_currency_amount_nulls_count,

		SUM(CASE WHEN currency IS NULL THEN 1 ELSE 0 END) AS currency_nulls_count,

		SUM(CASE WHEN company_code IS NULL THEN 1 ELSE 0 END) AS company_code_nulls_count,

		SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS company_nulls_count,

		SUM(CASE WHEN voucher IS NULL THEN 1 ELSE 0 END) AS voucher_nulls_count,

		SUM(CASE WHEN user_email IS NULL THEN 1 ELSE 0 END) AS user_email_nulls_count,

		SUM(CASE WHEN transfer_account IS NULL THEN 1 ELSE 0 END) AS transfer_account_nulls_count,

		SUM(CASE WHEN invoice_reference IS NULL THEN 1 ELSE 0 END) AS invoice_reference_nulls_count,

		SUM(CASE WHEN credit_note_reference IS NULL THEN 1 ELSE 0 END) AS credit_note_reference_nulls_count,

		SUM(CASE WHEN external_reference IS NULL THEN 1 ELSE 0 END) AS external_reference_nulls_count,

		SUM(CASE WHEN fiscal_signature_number IS NULL THEN 1 ELSE 0 END) AS fiscal_signature_number_nulls_count,

		SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS paymenth_method_nulls_count,

		SUM(CASE WHEN card_brand IS NULL THEN 1 ELSE 0 END) AS card_brand_nulls_count,

		SUM(CASE WHEN card_number IS NULL THEN 1 ELSE 0 END) AS card_number_nulls_count,

		SUM(CASE WHEN electronic_invoice_number IS NULL THEN 1 ELSE 0 END) AS eletronic_invoice_nulls_count,

		SUM(CASE WHEN reservation_number IS NULL THEN 1 ELSE 0 END) AS reservation_number_nulls_count,

		SUM(CASE WHEN reservation_holder IS NULL THEN 1 ELSE 0 END) AS reservation_holder_nulls_count,

		SUM(CASE WHEN external_payment_id IS NULL THEN 1 ELSE 0 END) AS external_payment_id_nulls_count

	FROM bronze.pms
),

nulls_rate AS (
	SELECT
		is_advanced_nulls_count,
		ROUND(is_advanced_nulls_count::numeric
		/
		invoices::numeric,2) AS is_advanced_rate,
		is_cancelled_nulls_count,
		ROUND(is_cancelled_nulls_count::numeric
		/
		invoices::numeric,2) AS is_cancelled_rate,
		is_regularized_nulls_count,
		ROUND(is_regularized_nulls_count::numeric
		/
		invoices::numeric,2) AS is_regularized_rate,
		is_processed_nulls_count,
		ROUND(is_processed_nulls_count::numeric
		/
		invoices::numeric,2) AS is_processed_rate,
		is_fiscal_nulls_count,
		ROUND(is_fiscal_nulls_count::numeric
		/
		invoices::numeric,2) AS is_fiscal_rate,
		document_type_nulls_count,
		ROUND(document_type_nulls_count::numeric
		/
		invoices::numeric,2) AS document_type_rate,
		document_number_nulls_count,
		ROUND(document_number_nulls_count::numeric
		/
		invoices::numeric,2) AS document_number_rate,
		invoice_holder_nulls_count,
		ROUND(invoice_holder_nulls_count::numeric
		/
		invoices::numeric,2) AS invoice_holder_rate,
		tax_number_nulls_count,
		ROUND(tax_number_nulls_count::numeric
		/
		invoices::numeric,2) AS tax_number_rate,
		invoice_date_nulls_count,
		ROUND(invoice_date_nulls_count::numeric
		/
		invoices::numeric,2) AS invoice_date_rate,
		invoice_time_nulls_count,
		ROUND(invoice_time_nulls_count::numeric
		/
		invoices::numeric,2) AS invoice_time_rate,
		gross_amount_nulls_count,
		ROUND(gross_amount_nulls_count::numeric
		/
		invoices::numeric,2) AS gross_amount_rate,
		net_amount_nulls_count,
		ROUND(net_amount_nulls_count::numeric
		/
		invoices::numeric,2) AS net_amount_rate,
		foreign_currency_amount_nulls_count,
		ROUND(foreign_currency_amount_nulls_count::numeric
		/
		invoices::numeric,2) AS foreign_currency_amount_rate,
		currency_nulls_count,
		ROUND(currency_nulls_count::numeric
		/
		invoices::numeric,2) AS currency_rate,
		company_code_nulls_count,
		ROUND(company_code_nulls_count::numeric
		/
		invoices::numeric,2) AS company_code_rate,
		company_nulls_count,
		ROUND(company_nulls_count::numeric
		/
		invoices::numeric,2) AS company_rate,
		voucher_nulls_count,
		ROUND(voucher_nulls_count::numeric
		/
		invoices::numeric,2) AS voucher_rate,
		user_email_nulls_count,
		ROUND(user_email_nulls_count::numeric
		/
		invoices::numeric,2) AS user_email_rate,
		transfer_account_nulls_count,
		ROUND(transfer_account_nulls_count::numeric
		/
		invoices::numeric,2) AS transfer_account_rate,
		invoice_reference_nulls_count,
		ROUND(invoice_reference_nulls_count::numeric
		/
		invoices::numeric,2) AS invoice_reference_rate,
		credit_note_reference_nulls_count,
		ROUND(credit_note_reference_nulls_count::numeric
		/
		invoices::numeric,2) AS credit_note_reference_rate,
		external_reference_nulls_count,
		ROUND(external_reference_nulls_count::numeric
		/
		invoices::numeric,2) AS external_reference_rate,
		fiscal_signature_number_nulls_count,
		ROUND(fiscal_signature_number_nulls_count::numeric
		/
		invoices::numeric,2) AS fiscal_signature_rate,
		paymenth_method_nulls_count,
		ROUND(paymenth_method_nulls_count::numeric
		/
		invoices::numeric,2) AS payment_method_rate,
		card_brand_nulls_count,
		ROUND(card_brand_nulls_count::numeric
		/
		invoices::numeric,2) AS card_brand_rate,
		card_number_nulls_count,
		ROUND(card_number_nulls_count::numeric
		/
		invoices::numeric,2) AS card_number_rate,
		eletronic_invoice_nulls_count,
		ROUND(eletronic_invoice_nulls_count::numeric
		/
		invoices::numeric,2) AS electronic_invoice_number_rate,
		reservation_number_nulls_count,
		ROUND(reservation_number_nulls_count::numeric
		/
		invoices::numeric,2) AS reservation_number_rate,
		reservation_holder_nulls_count,
		ROUND(reservation_holder_nulls_count::numeric
		/
		invoices::numeric,2) AS reservation_holder_rate,
		external_payment_id_nulls_count,
		ROUND(external_payment_id_nulls_count::numeric
		/
		invoices::numeric,2) AS external_payment_id_rate
	FROM nulls_count
)
SELECT *
FROM nulls_rate