------------------------------------------------------------------------------
-- CARD TERMINAL BRONZE PROFILING
-- Objective: characterize bronze.card_terminal's real shape — each row is
-- one daily slip extracted via OCR + regex, not a structured export, so
-- profiling here is also the main defense against silent extraction drift.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- DATABASE SAMPLE
------------------------------------------------------------------------------

SELECT *
FROM bronze.card_terminal
LIMIT 10;
------------------------------------------------------------------------------
-- 1. Understand the data quality, visualize the the null rate distribution
-- across each column. 
------------------------------------------------------------------------------

WITH occurrence_distribution AS(
SELECT
	COUNT(*) AS general_occurrences,
	SUM(CASE 
		WHEN transaction_date IS NULL
		THEN 1
		ELSE 0
	END) AS transaction_date_null_occurrences,
	SUM(CASE 
		WHEN amount IS NULL
		THEN 1
		ELSE 0
	END) AS amount_occurrences_null_occurrences,
	SUM(CASE 
		WHEN refund_amount IS NULL
		THEN 1
		ELSE 0
	END) AS refund_amount_null_occurrences,
	SUM(CASE 
		WHEN saldo_amount IS NULL
		THEN 1
		ELSE 0
	END) AS saldo_amount_null_occurrences,
	SUM(CASE 
		WHEN extraction_confidence IS NULL
		THEN 1
		ELSE 0
	END) AS extraction_confidence_null_occurrences
FROM bronze.card_terminal
)
SELECT 
	100.0 - (transaction_date_null_occurrences
	* 100.0 / general_occurrences) AS transaction_date_completeness_rate,
	100.0 - (amount_occurrences_null_occurrences
	* 100.0 / general_occurrences )AS amount_completeness_rate,
	100.0 - (refund_amount_null_occurrences
	* 100.0 / general_occurrences) AS refund_amount_completeness_rate,
	100.0 - (saldo_amount_null_occurrences
	* 100.0 / general_occurrences) AS saldo_amount_completeness_rate,
	100.0 - (extraction_confidence_null_occurrences
	* 100.0 / general_occurrences) AS extraction_confidence_completeness_rate
FROM occurrence_distribution;



------------------------------------------------------------------------------
-- 2. Regex coverage gap
-- Objective: identify which source_file values produced zero extracted
-- rows at all — either a genuinely empty day or a slip layout the regex
-- doesn't yet match.
------------------------------------------------------------------------------

SELECT
	source_file,
	amount,
	saldo_amount
FROM bronze.card_terminal
WHERE amount IS NULL
OR saldo_amount IS NULL
OR amount = 0
OR saldo_amount = 0
ORDER BY source_file;


------------------------------------------------------------------------------
-- 3. Internal arithmetic consistency
-- Objective: confirm amount - refund_amount = saldo_amount within
-- tolerance for every valid row, and profile the rows that don't as
-- either missing values or genuine arithmetic mismatches.
------------------------------------------------------------------------------
SELECT
    source_file,
    transaction_date,
    amount,
    refund_amount,
    saldo_amount,
    CASE
        WHEN amount IS NULL
          OR refund_amount IS NULL
          OR saldo_amount IS NULL
            THEN 'missing_value'
        WHEN ABS((amount - refund_amount) - saldo_amount) <= 0.01
            THEN 'correct'
        ELSE 'incorrect'
    END AS amount_status
FROM bronze.card_terminal
ORDER BY transaction_date ASC;

------------------------------------------------------------------------------
-- 4. Cross-source reconciliation readiness (PMS gross_amount vs. card_terminal)
-- Objective: compare bronze.pms's card-paid gross_amount, grouped by day,
-- against bronze.card_terminal's amount for the same day, and quantify how
-- many days reconcile within tolerance versus how many don't.
------------------------------------------------------------------------------
WITH pms_daily AS (
    SELECT
        invoice_date::date AS transaction_date,
        SUM(gross_amount) AS pms_gross_amount,
        SUM(net_amount) AS pms_net_amount
    FROM bronze.pms
    WHERE payment_method ILIKE '%Cartão de Crédito%'
    GROUP BY invoice_date::date
),
card_terminal_daily AS (
    SELECT
        TO_DATE(transaction_date || '/2026', 'DD/MM/YYYY') AS transaction_date,
        amount AS terminal_amount,
        saldo_amount
    FROM bronze.card_terminal
),
reconciliation_readiness AS (
    SELECT
        COALESCE(a.transaction_date, b.transaction_date) AS transaction_date,
        a.pms_gross_amount,
        a.pms_net_amount,
        b.terminal_amount,
        b.saldo_amount
    FROM pms_daily a
    FULL OUTER JOIN card_terminal_daily b
        ON a.transaction_date = b.transaction_date
)
SELECT
    *,
    pms_gross_amount - terminal_amount AS discrepancy_amount,
    CASE
        WHEN pms_gross_amount IS NULL
          OR terminal_amount IS NULL
            THEN TRUE
        WHEN ABS(pms_gross_amount - terminal_amount) > 0.01
            THEN TRUE
        ELSE FALSE
    END AS discrepancy_status
FROM reconciliation_readiness
ORDER BY transaction_date;