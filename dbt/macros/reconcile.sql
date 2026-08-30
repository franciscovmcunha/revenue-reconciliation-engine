{#
    Matches one PMS-side CTE against one other-side CTE (card terminal or
    cash register) and classifies every row into matched/mismatch/missing,
    per docs/reconciliation_rules.md. Used twice by int_reconciliation.sql
    (once per source pairing) so the matching logic itself lives in one
    place rather than being duplicated per pairing.

    Matching, in order of preference:
      1. transaction_ref, when both sides have one -- the strongest
         evidence available.
      2. transaction_date + closest amount, for whatever's left unmatched
         by (1) -- one-to-one, via row_number, so one row on either side
         is never claimed by two rows on the other.

    A pair found either way is "matched" if amounts agree within
    reconciliation_tolerance, "mismatch" otherwise. A row on either side
    with no pair at all is "missing" -- except a PMS row, when
    `report_missing_pms_side` is false: for the cash/TTM pairing, `pms_cte`
    is every Dinheiro-paid invoice (there's no per-invoice "includes TTM"
    flag to filter on more precisely -- see
    docs/reconciliation_rules.md), and most of those were never expected to
    have a TTM cash_register counterpart at all. Flagging all of them as
    "missing" would bury the real exceptions in noise from ordinary cash
    stays that have nothing to do with TTM. The card pairing keeps this on
    (the default): every card-paid invoice IS expected to have a terminal
    slip, so a PMS row with no counterpart there is a real exception.
#}
{% macro match_block(pms_cte, other_cte, other_source_label, report_missing_pms_side=true) %}

    ref_matches as (
        select
            p.raw_ref as pms_raw_ref,
            o.raw_ref as other_raw_ref,
            p.transaction_date as pms_date,
            o.transaction_date as other_date,
            p.amount as pms_amount,
            o.amount as other_amount,
            'transaction_ref' as match_method
        from {{ pms_cte }} p
        inner join {{ other_cte }} o
            on p.transaction_ref = o.transaction_ref
            and p.transaction_ref is not null
    ),

    date_amount_candidates as (
        select
            p.raw_ref as pms_raw_ref,
            o.raw_ref as other_raw_ref,
            p.transaction_date as pms_date,
            o.transaction_date as other_date,
            p.amount as pms_amount,
            o.amount as other_amount,
            row_number() over (
                partition by p.raw_ref
                order by abs(p.amount - o.amount)
            ) as pms_rank,
            row_number() over (
                partition by o.raw_ref
                order by abs(p.amount - o.amount)
            ) as other_rank
        from {{ pms_cte }} p
        inner join {{ other_cte }} o
            on p.transaction_date = o.transaction_date
        where p.raw_ref not in (select pms_raw_ref from ref_matches)
          and o.raw_ref not in (select other_raw_ref from ref_matches)
    ),

    date_amount_matches as (
        select
            pms_raw_ref, other_raw_ref, pms_date, other_date,
            pms_amount, other_amount,
            'date_amount' as match_method
        from date_amount_candidates
        where pms_rank = 1 and other_rank = 1
    ),

    all_matches as (
        select * from ref_matches
        union all
        select * from date_amount_matches
    ),

    matched_and_mismatched as (
        select
            pms_raw_ref,
            other_raw_ref,
            coalesce(pms_date, other_date) as transaction_date,
            pms_amount,
            other_amount,
            abs(pms_amount - other_amount) as amount_difference,
            case
                when abs(pms_amount - other_amount) <= {{ var('reconciliation_tolerance') }}
                    then 'matched'
                else 'mismatch'
            end as outcome,
            match_method,
            'pms' as source_a,
            '{{ other_source_label }}' as source_b
        from all_matches
    ),

    missing_on_other_side as (
        select
            p.raw_ref as pms_raw_ref,
            null as other_raw_ref,
            p.transaction_date,
            p.amount as pms_amount,
            null::numeric as other_amount,
            null::numeric as amount_difference,
            'missing' as outcome,
            null as match_method,
            'pms' as source_a,
            '{{ other_source_label }}' as source_b
        from {{ pms_cte }} p
        where p.raw_ref not in (select pms_raw_ref from all_matches)
    ),

    missing_on_pms_side as (
        select
            null as pms_raw_ref,
            o.raw_ref as other_raw_ref,
            o.transaction_date,
            null::numeric as pms_amount,
            o.amount as other_amount,
            null::numeric as amount_difference,
            'missing' as outcome,
            null as match_method,
            'pms' as source_a,
            '{{ other_source_label }}' as source_b
        from {{ other_cte }} o
        where o.raw_ref not in (select other_raw_ref from all_matches)
    )

    select * from matched_and_mismatched
    {% if report_missing_pms_side %}
    union all
    select * from missing_on_other_side
    {% endif %}
    union all
    select * from missing_on_pms_side

{% endmacro %}
