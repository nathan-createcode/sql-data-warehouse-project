-- Translated from quality_checks_silver.sql
-- Expectation: this query returns 0 rows (test PASSES if empty).

select *
from {{ ref('silver_crm_prd_info') }}
where prd_end_dt < prd_start_dt