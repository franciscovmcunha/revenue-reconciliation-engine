-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------


-------------------------DATASET OVERVIEW-----------------------
-- OBJECTIVE: INSPECT RAW RECORDS AND COLUMN STRUCTURE
-- SOURCE: PMS
-----------------------------------------------------------------



-----------------------------------------------------------------

SELECT
    pg_size_pretty(pg_total_relation_size('bronze.pms')) AS table_size,
	COUNT(*) AS rows_count,
	(SELECT COUNT(*)
	FROM information_schema.columns
	WHERE table_schema = 'bronze'
  	AND table_name = 'pms') AS columns_count,
	MAX(invoice_date) AS max_invoice_date,
	MIN(invoice_date) AS min_invoice_date,
    COUNT(DISTINCT invoice_date) AS distinct_days,
    COUNT(DISTINCT document_type) AS distinct_document_types,
    COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM bronze.pms;

-----------------------------------------------------------------
--COLUMNS DATE TYPE
-----------------------------------------------------------------

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'bronze'
AND table_name = 'pms'
ORDER BY ordinal_position;



-----------------------------------------------------------------
-- SAMPLE DATASET
-----------------------------------------------------------------
SELECT *
FROM bronze.pms
LIMIT 5;

-----------------------------------------------------------------
-- SAMPLE LAST ROWS
-----------------------------------------------------------------
SELECT *
FROM bronze.pms
ORDER BY invoice_date DESC
LIMIT 5;






