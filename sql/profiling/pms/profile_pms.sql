------------------------------------------------------------------------------
-- PMS BRONZE PROFILING
-- Objective: characterize bronze.pms's real shape and known-good/known-bad
-- value ranges before staging models rely on them.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- DATABASE SAMPLE
------------------------------------------------------------------------------

SELECT * 
FROM bronze.pms
LIMIT 10

------------------------------------------------------------------------------
-- 1. Column completeness
-- Objective: confirm all 31 raw PMS columns landed in bronze.pms
------------------------------------------------------------------------------
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'bronze'
  AND table_name = 'pms'
ORDER BY ordinal_position;

------------------------------------------------------------------------------
-- 2. payment_method distribution
-- Objective: enumerate every distinct payment_method value and its count
------------------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*) AS row_count
FROM bronze.pms
GROUP BY payment_method
ORDER BY row_count DESC;

------------------------------------------------------------------------------
-- 3. Cash-only invoice count
-- Objective: count rows where payment_method = 'Dinheiro' — this is the
-- subset that can ever show up as a tagged TTM row in bronze.cash_register.
------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE payment_method = 'Dinheiro') AS cash_invoices,
    COUNT(*) AS total_invoices
FROM bronze.pms;

------------------------------------------------------------------------------
-- 4. Cancelled document rate
-- Objective: count rows where is_cancelled is non-blank, to size how much
-- volume the staging layer's cancellation exclusion actually removes.
------------------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE COALESCE(TRIM(is_cancelled), '') <> '') AS cancelled_rows,
    COUNT(*) AS total_rows
FROM bronze.pms;

------------------------------------------------------------------------------
-- 5. gross_amount vs. net_amount — which one reconciles
-- Objective: compare card-paid gross_amount and net_amount, grouped by
-- day, against bronze.card_terminal's daily amount, to determine which
-- field is the correct one for downstream reconciliation models.
------------------------------------------------------------------------------
WITH pms_daily AS (
    SELECT
        invoice_date::date AS day,
        SUM(gross_amount) AS pms_gross,
        SUM(net_amount) AS pms_net
    FROM bronze.pms
    WHERE payment_method ILIKE '%Cartão%'
       OR payment_method ILIKE '%Débito%'
    GROUP BY invoice_date::date
),
card_terminal_daily AS (
    SELECT
        TO_DATE(transaction_date || '/2026', 'DD/MM/YYYY') AS day,
        SUM(amount) AS terminal_amount
    FROM bronze.card_terminal
    GROUP BY TO_DATE(transaction_date || '/2026', 'DD/MM/YYYY')
)
SELECT
    p.day,
    ROUND(p.pms_gross::numeric,2),
    ROUND(p.pms_net::numeric,2),
    c.terminal_amount,
    ROUND((p.pms_gross - c.terminal_amount)::numeric, 2) AS gross_diff,
    ROUND((p.pms_net - c.terminal_amount)::numeric, 2) AS net_diff
FROM pms_daily p
JOIN card_terminal_daily c ON c.day = p.day
ORDER BY p.day;

------------------------------------------------------------------------------
-- 6. Amount parsing sanity check
-- Objective: confirm no row has a gross_amount/net_amount that failed to
-- parse, and that no value shows an implausible order-of-magnitude jump
-- relative to similar transactions.
------------------------------------------------------------------------------
SELECT
    document_number,
    invoice_date,
    gross_amount,
    net_amount
FROM bronze.pms
WHERE gross_amount IS NULL
   OR net_amount IS NULL
   OR (net_amount <> 0 AND ABS(gross_amount / net_amount) NOT BETWEEN 0.5 AND 2)
ORDER BY invoice_date;

------------------------------------------------------------------------------
-- 7. document_number uniqueness
-- Objective: confirm document_number is unique per row in bronze — a
-- duplicate here is a genuine data issue, not an expected shape (rebooked/
-- corrected charges are cancellation pairs, not literal duplicates).
------------------------------------------------------------------------------
SELECT
    document_number,
    COUNT(*) AS occurrences
FROM bronze.pms
GROUP BY document_number
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

------------------------------------------------------------------------------
-- 8. invoice_holder - document_number distribution
-- Objective: confirm invoice holder is unique per document_number 
------------------------------------------------------------------------------

SELECT 
	invoice_holder,
	COUNT(document_number) AS occurrences
FROM bronze.pms
GROUP BY 1
HAVING COUNT(document_number) > 1
ORDER BY occurrences DESC
	

