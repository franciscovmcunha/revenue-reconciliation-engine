-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------

-----------------------BUSINESS PROFILING------------------------
-- OBJECTIVE: UNDERSTAND HOW THE COLUMNS AND ROWS ARE SEGMENTED 
-----------------------------------------------------------------



SELECT
    is_advanced,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY is_advanced
ORDER BY invoices DESC;

-----------------------------------------------------------------

SELECT
    is_cancelled,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY is_cancelled
ORDER BY invoices DESC;

-----------------------------------------------------------------
SELECT 
	is_regularized,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY is_regularized
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	is_processed,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY is_processed
ORDER BY invoices DESC;
---------------------------------------------------------------
SELECT
	is_fiscal,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY is_fiscal
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	document_type,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY document_type
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	document_number,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY document_number
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	invoice_holder,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY invoice_holder
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	tax_number,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY tax_number
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	invoice_date,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY invoice_date
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	invoice_time,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY invoice_time
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	gross_amount,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY gross_amount
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	net_amount,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY net_amount
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	foreign_currency_amount,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY foreign_currency_amount
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	currency,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY currency
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	company_code,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY company_code
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	company,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY company
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	voucher,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY voucher
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	user_email,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY user_email
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	transfer_account,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY transfer_account
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	invoice_reference,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY invoice_reference
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	credit_note_reference,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY credit_note_reference
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	external_reference,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY external_reference
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	fiscal_signature_number,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY fiscal_signature_number
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	payment_method,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY payment_method
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	card_brand,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY card_brand
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	card_number,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY card_number
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	reservation_number,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY reservation_number
ORDER BY invoices DESC;
-----------------------------------------------------------------
SELECT
	external_payment_id,
    COUNT(*) AS invoices
FROM bronze.pms
GROUP BY external_payment_id
ORDER BY invoices DESC;
