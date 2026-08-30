-- Applies the matching keys and tolerance from docs/reconciliation_rules.md
-- across both source pairings this project reconciles: PMS vs card
-- terminal, and PMS vs cash-register TTM payments. The
-- `reconciliation_tolerance` var (dbt_project.yml) is the single source of
-- truth for the amount-comparison tolerance. See macros/reconcile.sql for
-- the shared matching logic both pairings below reuse.

with pms_card as (
    select *
    from {{ ref('int_revenue') }}
    where source_system = 'pms' and payment_method ilike '%cart%'

),

card as (

    select * from {{ ref('int_card_payments') }}

),

pms_cash as (

    -- Restricted to cash-paid PMS invoices, per
    -- docs/reconciliation_rules.md: matching a cash TTM entry against a
    -- card-paid PMS invoice would never be correct regardless of how
    -- close the amount is.
    select *
    from {{ ref('int_revenue') }}
    where source_system = 'pms' and payment_method ilike '%dinheiro%'

),

cash as (

    select * from {{ ref('int_cash_payments') }}

)

select * from (
    with {{ match_block('pms_card', 'card', 'card_terminal') }}
) card_reconciliation

union all

select * from (
    with {{ match_block('pms_cash', 'cash', 'cash_register', report_missing_pms_side=false) }}
) cash_reconciliation
