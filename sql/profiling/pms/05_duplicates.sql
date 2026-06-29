-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------

-------------------------DUPLICATES-----------------------------
--OBJECTIVE: UNDERSTAND IF THERE IS ANY DUPLICATED DATA
-----------------------------------------------------------------

SELECT
	document_number,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

-----------------------------------------------------------------

SELECT
	invoice_holder,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

-----------------------------------------------------------------

SELECT
	tax_number,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

-----------------------------------------------------------------

SELECT
	tax_number,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

-----------------------------------------------------------------

SELECT
	reservation_number,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

-----------------------------------------------------------------

SELECT
	reservation_holder,
	COUNT(*) AS duplication_count
FROM bronze.pms
GROUP BY 1
HAVING COUNT(*) > 1;

