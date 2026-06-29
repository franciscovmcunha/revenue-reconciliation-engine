-----------------------------------------------------------------
--------------------HOSPITALITY ANALYTICS------------------------
----------------------BY FRANCISCO CUNHA-------------------------
-----------------------------------------------------------------



---------------------DATA QUALITY CHECK--------------------------
-- OBJECTIVE: PROFILE THE RAW DATASET BEFORE MODELING
-- SUPPORT SILVER LAYER DESIGN DECISIONS
-----------------------------------------------------------------


--------------PAYMENT AND TIMESTAMPS DATA CONSISTENCY------------
-- OBJECTIVE: ASSESS PAYMENT DATA CONSISTENCY ACROSS THE DATASET
-----------------------------------------------------------------


WITH data_consistency AS (
	SELECT
		SUM(
			CASE 
				WHEN (invoice_holder IS NULL
				OR reservation_holder IS NULL)
				AND net_amount > 0
				AND is_regularized = 'Regularizado'
				THEN 1
				ELSE 0
			END
		) AS invoices_without_name_holder_count,
		SUM(
			CASE 
				WHEN (invoice_holder IS NOT NULL
				OR reservation_holder IS NOT NULL)
				AND (net_amount <= 0 OR net_amount IS NULL)
				AND is_regularized = 'Regularizado'
				THEN 1
				ELSE 0
			END
		) AS invoices_with_invalid_net_amount_count,
		SUM(
			CASE 
				WHEN (invoice_date IS NULL
				OR invoice_time IS NULL)
				AND net_amount > 0
				AND is_regularized = 'Regularizado'
				THEN 1
				ELSE 0
			END
		) AS invoices_without_timestamp_count,
		SUM(
			CASE 
				WHEN (invoice_date IS NOT NULL
				OR invoice_time IS NOT NULL)
				AND net_amount > 0
				AND is_regularized = 'Regularizado'
				AND document_number IS NULL 
				THEN 1
				ELSE 0
			END
		) AS invalid_document_number_count,
		SUM(
			CASE
				WHEN invoice_date > CURRENT_DATE 
				THEN 1
				ELSE 0
			END
		) AS invalid_invoice_date_count,
		SUM(
			CASE
				WHEN gross_amount < net_amount
				THEN 1 
				ELSE 0
			END
		) AS invalid_gross_amount_count,
		SUM(
			CASE
				WHEN document_type IS NULL
				THEN 1
				ELSE 0
			END
		) AS invalid_document_type_count,
		SUM(
			CASE
				WHEN currency <> 'EUR'
				THEN 1
				ELSE 0
			END
		) AS invalid_currency_count 
	FROM bronze.pms
)

SELECT *
FROM data_consistency;





	