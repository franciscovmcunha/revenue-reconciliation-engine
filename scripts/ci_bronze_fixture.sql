-- Minimal, entirely synthetic bronze.* tables for CI to run `dbt build`
-- against, since CI has no access to real source files or a live Azure
-- endpoint. Covers one example of every outcome the reconciliation logic
-- needs to prove out: a card match, a card mismatch, a card-side miss, a
-- cancelled PMS row (must be excluded), a TTM cash match, and the
-- inter-property TTM exception (must be excluded from cash reconciliation
-- entirely). No real hotel, guest, or financial data of any kind.

create schema if not exists bronze;

create table bronze.pms (
    is_cancelled text,
    document_number text,
    invoice_date timestamp,
    net_amount double precision,
    currency text,
    payment_method text,
    ingestion_run_id text
);

insert into bronze.pms (is_cancelled, document_number, invoice_date, net_amount, currency, payment_method, ingestion_run_id) values
(null,        '1/2026', '2026-01-05', 100.00, 'EUR', 'Cartão de Crédito', 'ci'),  -- matches card slip exactly
(null,        '2/2026', '2026-01-06', 200.00, 'EUR', 'Cartão de Crédito', 'ci'),  -- mismatches card slip
(null,        '3/2026', '2026-01-07', 50.00,  'EUR', 'Cartão de Crédito', 'ci'),  -- no card slip at all -> missing
('Cancelado', '4/2026', '2026-01-08', 999.00, 'EUR', 'Cartão de Crédito', 'ci'),  -- cancelled: must never appear downstream
(null,        '5/2026', '2026-01-09', 30.00,  'EUR', 'Dinheiro',          'ci'),  -- TTM cash payment, matches by ref
(null,        '6/2026', '2026-01-10', 15.00,  'EUR', 'Dinheiro',          'ci');  -- ordinary cash sale, no TTM component -> NOT "missing"

create table bronze.cash_register (
    "Documento / Nº Factura" text,
    transaction_date timestamp,
    amount double precision,
    is_ttm_payment boolean,
    is_inter_property_deposit boolean,
    ingestion_run_id text
);

insert into bronze.cash_register ("Documento / Nº Factura", transaction_date, amount, is_ttm_payment, is_inter_property_deposit, ingestion_run_id) values
('5/2026', '2026-01-09', 30.00, true, false, 'ci'),   -- matches PMS by transaction_ref
(null,     '2026-01-11', 12.00, true, true,  'ci');   -- inter-property deposit: excluded, not "missing"

create table bronze.card_terminal (
    transaction_date text,
    amount double precision,
    extraction_confidence double precision,
    ingestion_run_id text
);

insert into bronze.card_terminal (transaction_date, amount, extraction_confidence, ingestion_run_id) values
('05/01', 100.00, null, 'ci'),  -- matches PMS 1/2026 by date+amount
('06/01', 150.00, null, 'ci');  -- date matches PMS 2/2026, amount is off -> mismatch
