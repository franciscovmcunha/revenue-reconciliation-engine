-- Singular test: fails if fact_missing_transactions grows beyond an
-- acceptable volume threshold for a single ingestion run — a spike here
-- usually means a source stopped arriving, not that revenue actually
-- disappeared. See docs/business_problem.md.
-- TODO: implement

select 1 as placeholder where false
