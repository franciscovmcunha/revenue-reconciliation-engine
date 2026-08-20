------------------------------------------------------------------------------
-- CASH REGISTER BRONZE PROFILING
-- Objective:
-- Validate structural consistency, TTM classification logic,
-- inter-property isolation, cross-source document matching,
-- and daily till reconciliation readiness.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- DATABASE SAMPLE
------------------------------------------------------------------------------

SELECT *
FROM bronze.cash_register
LIMIT 10;


------------------------------------------------------------------------------
-- 1. Day coverage per monthly file
-- Objective: identify how many distinct sheet dates are represented
-- per month.
--
-- Limitation:
-- bronze.cash_register currently does not preserve source_file or sheet_name.
-- Therefore this check confirms represented sheet dates, but cannot prove
-- that every calendar day had exactly one physical Excel sheet.
------------------------------------------------------------------------------

SELECT
    DATE_TRUNC('month', sheet_date)::date AS month,
    COUNT(DISTINCT sheet_date::date) AS represented_days,
    MIN(sheet_date::date) AS first_sheet_date,
    MAX(sheet_date::date) AS last_sheet_date
FROM bronze.cash_register
GROUP BY DATE_TRUNC('month', sheet_date)
ORDER BY month;


------------------------------------------------------------------------------
-- 1.1 Duplicate sheet-date occurrence check
-- Objective: inspect how many transaction rows were extracted from each
-- sheet_date.
--
-- Note:
-- Multiple rows per sheet_date are expected because each sheet can contain
-- several transactions. This does not mean the physical sheet itself is
-- duplicated.
------------------------------------------------------------------------------

SELECT
    sheet_date::date AS sheet_date,
    COUNT(*) AS transaction_rows
FROM bronze.cash_register
GROUP BY sheet_date::date
ORDER BY sheet_date::date;


------------------------------------------------------------------------------
-- 2. Month-boundary transaction check
-- Objective: identify transactions whose actual transaction_date belongs
-- to a different month than the sheet in which they were recorded.
--
-- This detects workbook carry-over / late posting behaviour.
------------------------------------------------------------------------------

SELECT
    sheet_date::date AS sheet_date,
    transaction_date::date AS transaction_date,
    "Tipo" AS transaction_type,
    "Descrição / Fornecedor" AS description_supplier,
    "Documento / Nº Factura" AS document_number,
    amount,
    till_category
FROM bronze.cash_register
WHERE transaction_date IS NOT NULL
AND DATE_TRUNC('month', sheet_date)
    <> DATE_TRUNC('month', transaction_date)
ORDER BY
    sheet_date,
    transaction_date;


------------------------------------------------------------------------------
-- 2.1 Potential duplicate transaction detection
-- Objective: identify potentially duplicated transactions based on
-- transaction_date + document_number + amount.
--
-- Limitation:
-- Without source_file, this cannot prove that a transaction occurred in
-- two different monthly workbooks. It only identifies duplicate-looking
-- rows inside the Bronze table.
------------------------------------------------------------------------------

SELECT
    transaction_date::date AS transaction_date,
    "Documento / Nº Factura" AS document_number,
    amount,
    COUNT(*) AS occurrences
FROM bronze.cash_register
WHERE "Documento / Nº Factura" IS NOT NULL
GROUP BY
    transaction_date::date,
    "Documento / Nº Factura",
    amount
HAVING COUNT(*) > 1
ORDER BY occurrences DESC,
         transaction_date;


------------------------------------------------------------------------------
-- 3. Header row position stability
-- Objective: validate whether the Excel "Tipo" header row remains at the
-- same index across sheets/months.
--
-- IMPORTANT:
-- This cannot be validated from bronze.cash_register because header position
-- metadata is not currently persisted.
--
-- Recommended ingestion metadata schema:
--
-- source_file
-- sheet_name
-- sheet_date
-- header_row_index
-- row_count
--
-- Once available, use:
------------------------------------------------------------------------------

-- SELECT
--     source_file,
--     sheet_name,
--     sheet_date,
--     header_row_index
-- FROM bronze.cash_register_ingestion_metadata
-- ORDER BY
--     source_file,
--     sheet_date;


------------------------------------------------------------------------------
-- 3.1 Detect header row drift
--
-- Expected result:
-- zero rows if all sheets use the modal header position.
------------------------------------------------------------------------------

-- WITH expected_header_position AS (
--     SELECT
--         MODE() WITHIN GROUP (
--             ORDER BY header_row_index
--         ) AS expected_header_row_index
--     FROM bronze.cash_register_ingestion_metadata
-- )
--
-- SELECT
--     a.source_file,
--     a.sheet_name,
--     a.sheet_date,
--     a.header_row_index,
--     b.expected_header_row_index
-- FROM bronze.cash_register_ingestion_metadata a
-- CROSS JOIN expected_header_position b
-- WHERE a.header_row_index <> b.expected_header_row_index
-- ORDER BY
--     a.source_file,
--     a.sheet_date;


------------------------------------------------------------------------------
-- 4. TTM guest-payment tagging
-- Objective:
-- Count rows where is_ttm_payment = true and cross-reference rows with
-- document_number against bronze.pms.document_number.
------------------------------------------------------------------------------

SELECT
    COUNT(*) AS ttm_payment_count,
    COUNT(*) FILTER (
        WHERE "Documento / Nº Factura" IS NOT NULL
    ) AS ttm_with_document_count,
    COUNT(*) FILTER (
        WHERE "Documento / Nº Factura" IS NULL
    ) AS ttm_without_document_count
FROM bronze.cash_register
WHERE is_ttm_payment = TRUE;


------------------------------------------------------------------------------
-- 4.1 TTM -> PMS exact document matching
------------------------------------------------------------------------------

WITH ttm_payments AS (
    SELECT
        "Tipo" AS transaction_type,
        "Descrição / Fornecedor" AS description_supplier,
        "Documento / Nº Factura" AS document_number,
        sheet_date,
        transaction_date,
        amount,
        till_category,
        is_inter_property_deposit
    FROM bronze.cash_register
    WHERE is_ttm_payment = TRUE
),

ttm_pms_match AS (
    SELECT
        a.*,
        b.document_number AS pms_document_number,

        CASE
            WHEN b.document_number IS NOT NULL
                THEN TRUE
            ELSE FALSE
        END AS pms_document_match

    FROM ttm_payments a

    LEFT JOIN bronze.pms b
        ON a.document_number = b.document_number
)

SELECT *
FROM ttm_pms_match
ORDER BY
    transaction_date,
    document_number;


------------------------------------------------------------------------------
-- 4.2 TTM -> PMS matching coverage rate
------------------------------------------------------------------------------

WITH ttm_payments AS (
    SELECT
        "Documento / Nº Factura" AS document_number
    FROM bronze.cash_register
    WHERE is_ttm_payment = TRUE
    AND "Documento / Nº Factura" IS NOT NULL
),

ttm_match AS (
    SELECT
        a.document_number,

        CASE
            WHEN b.document_number IS NOT NULL
                THEN 1
            ELSE 0
        END AS matched

    FROM ttm_payments a

    LEFT JOIN bronze.pms b
        ON a.document_number = b.document_number
)

SELECT
    COUNT(*) AS ttm_documents,
    SUM(matched) AS matched_documents,
    COUNT(*) - SUM(matched) AS unmatched_documents,

    ROUND(
        SUM(matched) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS match_rate

FROM ttm_match;


------------------------------------------------------------------------------
-- 4.3 Show only unmatched TTM documents
------------------------------------------------------------------------------

SELECT
    a.transaction_date,
    a."Descrição / Fornecedor" AS description_supplier,
    a."Documento / Nº Factura" AS document_number,
    a.amount,
    a.till_category
FROM bronze.cash_register a

LEFT JOIN bronze.pms b
    ON a."Documento / Nº Factura" = b.document_number

WHERE a.is_ttm_payment = TRUE
AND a."Documento / Nº Factura" IS NOT NULL
AND b.document_number IS NULL

ORDER BY a.transaction_date;


------------------------------------------------------------------------------
-- 5. TTM internal-transfer exclusion
-- Objective:
-- Confirm internal transfers such as "Reforço" / "desde TTM" are never
-- classified as real TTM guest payments.
--
-- Expected result:
-- zero rows.
------------------------------------------------------------------------------

SELECT
    "Tipo" AS transaction_type,
    "Descrição / Fornecedor" AS description_supplier,
    "Documento / Nº Factura" AS document_number,
    sheet_date,
    transaction_date,
    amount,
    till_category,
    is_ttm_payment,
    is_inter_property_deposit

FROM bronze.cash_register

WHERE (
       "Descrição / Fornecedor" ILIKE '%reforço%'
    OR "Descrição / Fornecedor" ILIKE '%desde TTM%'
)
AND is_ttm_payment = TRUE

ORDER BY transaction_date;


------------------------------------------------------------------------------
-- 5.1 Internal-transfer invalid tagging count
--
-- Expected result:
-- 0
------------------------------------------------------------------------------

SELECT
    COUNT(*) AS invalid_ttm_transfer_tags
FROM bronze.cash_register
WHERE (
       "Descrição / Fornecedor" ILIKE '%reforço%'
    OR "Descrição / Fornecedor" ILIKE '%desde TTM%'
)
AND is_ttm_payment = TRUE;


------------------------------------------------------------------------------
-- 5.2 Boolean data-quality flag
------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 0
            THEN TRUE
        ELSE FALSE
    END AS internal_transfer_tagging_ok

FROM bronze.cash_register

WHERE (
       "Descrição / Fornecedor" ILIKE '%reforço%'
    OR "Descrição / Fornecedor" ILIKE '%desde TTM%'
)
AND is_ttm_payment = TRUE;


------------------------------------------------------------------------------
-- 6. Inter-property deposit isolation
-- Objective:
-- Confirm every inter-property deposit is also recognised as a TTM payment.
--
-- Expected result:
-- zero rows.
------------------------------------------------------------------------------

SELECT
    "Descrição / Fornecedor" AS description_supplier,
    "Documento / Nº Factura" AS document_number,
    sheet_date,
    transaction_date,
    amount,
    till_category,
    is_ttm_payment,
    is_inter_property_deposit

FROM bronze.cash_register

WHERE is_inter_property_deposit = TRUE
AND is_ttm_payment = FALSE

ORDER BY transaction_date;


------------------------------------------------------------------------------
-- 6.1 Inter-property invalid classification count
--
-- Expected result:
-- 0
------------------------------------------------------------------------------

SELECT
    COUNT(*) AS invalid_inter_property_classifications
FROM bronze.cash_register
WHERE is_inter_property_deposit = TRUE
AND is_ttm_payment = FALSE;


------------------------------------------------------------------------------
-- 6.2 Inter-property classification quality flag
------------------------------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 0
            THEN TRUE
        ELSE FALSE
    END AS inter_property_classification_ok

FROM bronze.cash_register

WHERE is_inter_property_deposit = TRUE
AND is_ttm_payment = FALSE;


------------------------------------------------------------------------------
-- 6.3 Inter-property deposits isolated from own-property TTM totals
------------------------------------------------------------------------------

SELECT
    transaction_date::date AS transaction_date,
    SUM(amount) AS own_property_ttm_amount
FROM bronze.cash_register

WHERE is_ttm_payment = TRUE
AND is_inter_property_deposit = FALSE

GROUP BY transaction_date::date
ORDER BY transaction_date;


------------------------------------------------------------------------------
-- 6.4 Inter-property totals separately
------------------------------------------------------------------------------

SELECT
    transaction_date::date AS transaction_date,
    SUM(amount) AS inter_property_ttm_amount
FROM bronze.cash_register

WHERE is_ttm_payment = TRUE
AND is_inter_property_deposit = TRUE

GROUP BY transaction_date::date
ORDER BY transaction_date;


------------------------------------------------------------------------------
-- 6.5 Full TTM split
-- Objective:
-- Compare own-property and inter-property amounts without mixing them.
------------------------------------------------------------------------------

SELECT
    transaction_date::date AS transaction_date,

    SUM(amount) FILTER (
        WHERE is_ttm_payment = TRUE
        AND is_inter_property_deposit = FALSE
    ) AS own_property_ttm_amount,

    SUM(amount) FILTER (
        WHERE is_ttm_payment = TRUE
        AND is_inter_property_deposit = TRUE
    ) AS inter_property_ttm_amount

FROM bronze.cash_register

WHERE is_ttm_payment = TRUE

GROUP BY transaction_date::date
ORDER BY transaction_date;


------------------------------------------------------------------------------
-- 7. Daily till movement profiling
-- Objective:
-- Aggregate parsed CRÉDITO and DÉBITO movements per sheet and till.
--
-- This calculates daily movement totals but cannot yet reconcile against
-- printed Saldo inicial / Saldo final because those values are not currently
-- persisted in bronze.cash_register.
------------------------------------------------------------------------------

SELECT
    sheet_date::date AS sheet_date,
    till_category,

    SUM(
        COALESCE("CRÉDITO", 0)
    ) AS total_credit,

    SUM(
        COALESCE("DÉBITO", 0)
    ) AS total_debit,

    SUM(
        COALESCE("CRÉDITO", 0)
        -
        COALESCE("DÉBITO", 0)
    ) AS net_movement

FROM bronze.cash_register

GROUP BY
    sheet_date::date,
    till_category

ORDER BY
    sheet_date,
    till_category;


------------------------------------------------------------------------------
-- 7.1 Daily till-balance self-consistency
--
-- REQUIRED METADATA:
--
-- opening_balance
-- closing_balance
--
-- Once those values are persisted in an ingestion metadata table:
------------------------------------------------------------------------------

-- WITH daily_movements AS (
--
--     SELECT
--         sheet_date::date AS sheet_date,
--         till_category,
--
--         SUM(
--             COALESCE("CRÉDITO", 0)
--         ) AS total_credit,
--
--         SUM(
--             COALESCE("DÉBITO", 0)
--         ) AS total_debit
--
--     FROM bronze.cash_register
--
--     GROUP BY
--         sheet_date::date,
--         till_category
-- )
--
-- SELECT
--     a.sheet_date,
--     a.till_category,
--
--     b.opening_balance,
--     a.total_credit,
--     a.total_debit,
--     b.closing_balance,
--
--     b.opening_balance
--         + a.total_credit
--         - a.total_debit
--         AS calculated_closing_balance,
--
--     (
--         b.opening_balance
--         + a.total_credit
--         - a.total_debit
--         - b.closing_balance
--     ) AS balance_difference,
--
--     CASE
--         WHEN ABS(
--             (
--                 b.opening_balance
--                 + a.total_credit
--                 - a.total_debit
--             )
--             - b.closing_balance
--         ) <= 0.01
--         THEN TRUE
--         ELSE FALSE
--     END AS balance_ok
--
-- FROM daily_movements a
--
-- LEFT JOIN bronze.cash_register_ingestion_metadata b
--     ON a.sheet_date = b.sheet_date
--     AND a.till_category = b.till_category
--
-- ORDER BY
--     a.sheet_date,
--     a.till_category;


------------------------------------------------------------------------------
-- 8. Stray header-column check
-- Objective:
-- Verify unexpected / unnamed Excel columns do not contain data.
--
-- IMPORTANT:
-- This must primarily happen during Python ingestion because PostgreSQL
-- cannot detect Excel columns that were discarded before loading.
--
-- SQL can still validate the schema that actually landed in PostgreSQL.
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- 8.1 PostgreSQL landed-column inspection
------------------------------------------------------------------------------

SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns

WHERE table_schema = 'bronze'
AND table_name = 'cash_register'

ORDER BY ordinal_position;


------------------------------------------------------------------------------
-- 8.2 Detect unexpected landed columns
-- Expected result:
-- zero rows.
------------------------------------------------------------------------------

SELECT
    column_name
FROM information_schema.columns

WHERE table_schema = 'bronze'
AND table_name = 'cash_register'

AND column_name NOT IN (
    'Tipo',
    'Descrição / Fornecedor',
    'Documento / Nº Factura',
    'Data do 
Documento',
    'Valor do 
Documento',
    'CRÉDITO',
    'DÉBITO',
    'sheet_date',
    'amount',
    'transaction_date',
    'till_category',
    'source_system',
    'is_ttm_payment',
    'is_inter_property_deposit',
    'ingestion_run_id'
)

ORDER BY column_name;


------------------------------------------------------------------------------
-- 8.3 Expected-column completeness
-- Objective:
-- Confirm all expected columns actually exist.
--
-- Expected result:
-- zero rows.
------------------------------------------------------------------------------

WITH expected_columns AS (

    SELECT *
    FROM (
        VALUES
            ('Tipo'),
            ('Descrição / Fornecedor'),
            ('Documento / Nº Factura'),
            ('Data do ' || CHR(10) || 'Documento'),
            ('Valor do ' || CHR(10) || 'Documento'),
            ('CRÉDITO'),
            ('DÉBITO'),
            ('sheet_date'),
            ('amount'),
            ('transaction_date'),
            ('till_category'),
            ('source_system'),
            ('is_ttm_payment'),
            ('is_inter_property_deposit'),
            ('ingestion_run_id')
    ) AS expected(column_name)

),

actual_columns AS (

    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'bronze'
    AND table_name = 'cash_register'
)

SELECT
    e.column_name AS missing_column

FROM expected_columns e

LEFT JOIN actual_columns a
    ON e.column_name = a.column_name

WHERE a.column_name IS NULL;


------------------------------------------------------------------------------
-- 9. Core classification distribution
-- Objective:
-- Profile the distribution of till categories and classification flags.
------------------------------------------------------------------------------

SELECT
    till_category,
    COUNT(*) AS occurrences,

    COUNT(*) FILTER (
        WHERE is_ttm_payment = TRUE
    ) AS ttm_payment_occurrences,

    COUNT(*) FILTER (
        WHERE is_inter_property_deposit = TRUE
    ) AS inter_property_occurrences,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS occurrence_rate

FROM bronze.cash_register

GROUP BY till_category

ORDER BY occurrences DESC;


------------------------------------------------------------------------------
-- 10. Transaction date vs sheet date lag
-- Objective:
-- Understand how long transactions can remain unregistered before being
-- entered into a later cash-register sheet.
------------------------------------------------------------------------------

SELECT
    sheet_date::date AS sheet_date,
    transaction_date::date AS transaction_date,

    sheet_date::date
        - transaction_date::date AS posting_lag_days,

    "Descrição / Fornecedor" AS description_supplier,
    "Documento / Nº Factura" AS document_number,
    amount,
    till_category

FROM bronze.cash_register

WHERE transaction_date IS NOT NULL
AND sheet_date::date <> transaction_date::date

ORDER BY posting_lag_days DESC;


------------------------------------------------------------------------------
-- 10.1 Posting lag distribution
------------------------------------------------------------------------------

SELECT
    sheet_date::date - transaction_date::date AS posting_lag_days,
    COUNT(*) AS occurrences

FROM bronze.cash_register

WHERE transaction_date IS NOT NULL

GROUP BY
    sheet_date::date - transaction_date::date

ORDER BY posting_lag_days;


------------------------------------------------------------------------------
-- 11. Null profiling
-- Objective:
-- Measure completeness of key reconciliation fields.
------------------------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,

    ROUND(
        COUNT(*) FILTER (
            WHERE transaction_date IS NULL
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS transaction_date_null_rate,

    ROUND(
        COUNT(*) FILTER (
            WHERE amount IS NULL
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS amount_null_rate,

    ROUND(
        COUNT(*) FILTER (
            WHERE "Documento / Nº Factura" IS NULL
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS document_number_null_rate,

    ROUND(
        COUNT(*) FILTER (
            WHERE till_category IS NULL
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS till_category_null_rate

FROM bronze.cash_register;


------------------------------------------------------------------------------
-- 12. TTM reconciliation-ready dataset
-- Objective:
-- Produce the clean subset of TTM payments eligible for downstream
-- reconciliation.
--
-- Excludes inter-property deposits and internal transfers.
------------------------------------------------------------------------------

WITH reconciliation_ready_ttm AS (

    SELECT
        transaction_date::date AS transaction_date,
        sheet_date::date AS sheet_date,

        "Descrição / Fornecedor" AS description_supplier,
        "Documento / Nº Factura" AS document_number,

        amount,
        till_category,
        source_system,
        ingestion_run_id

    FROM bronze.cash_register

    WHERE is_ttm_payment = TRUE
    AND is_inter_property_deposit = FALSE

    AND NOT (
           "Descrição / Fornecedor" ILIKE '%reforço%'
        OR "Descrição / Fornecedor" ILIKE '%desde TTM%'
    )
)

SELECT *
FROM reconciliation_ready_ttm
ORDER BY
    transaction_date,
    document_number;