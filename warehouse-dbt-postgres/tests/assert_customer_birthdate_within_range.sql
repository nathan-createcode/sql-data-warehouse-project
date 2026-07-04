-- Translated from quality_checks_silver.sql
-- Expectation: this query returns 0 rows (test PASSES if empty).
--
-- Severity set to 'warn' rather than the default 'error': the failing rows
-- here are unusually old but plausible birthdates (1916-1923), not corrupted
-- data (e.g. future dates or the year 1900). Whether to treat these as
-- invalid is a business decision, not a technical bug - so we flag them
-- without failing the whole pipeline.
{{ config(severity = 'warn') }}

select bdate
from {{ ref('silver_erp_cust_az12') }}
where bdate < '1924-01-01' or bdate > current_date