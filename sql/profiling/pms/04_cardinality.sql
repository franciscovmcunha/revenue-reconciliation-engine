-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------

-------------------------CARDINALITY-----------------------------
--OBJECTIVE: UNDERSTAND WITH ENTITY CAN BE USED AS A KEY
-----------------------------------------------------------------



WITH key_potential AS (
SELECT 
	COUNT(*) AS general_rows_count,
	COUNT(DISTINCT(document_number)) AS document_number_count,
	ROUND(COUNT(DISTINCT document_number)::numeric
	/
	COUNT(*),2) document_number_rate,
	COUNT(DISTINCT(invoice_holder)) AS invoice_holder_count,
	ROUND(COUNT(DISTINCT invoice_holder)::numeric
	/
	COUNT(*),2) AS invoice_holder_rate,
	COUNT(DISTINCT(tax_number)) AS tax_number_count,
	ROUND(COUNT(DISTINCT tax_number)::numeric
	/
	COUNT(*),2) AS tax_number_rate,
	COUNT(DISTINCT(reservation_number)) AS reservation_number_count,
	ROUND(COUNT(DISTINCT reservation_number)::numeric
	/
	COUNT(*),2) AS reservation_number_rate,
	COUNT(DISTINCT(reservation_holder)) AS reservation_holder_count,
	ROUND(COUNT(DISTINCT reservation_holder)::numeric
	/
	COUNT(*),2) AS reservation_holder_rate
FROM bronze.pms
)
SELECT *
FROM key_potential
