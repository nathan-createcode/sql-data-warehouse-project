-- Translated from quality_checks_silver.sql
-- Expectation: this query returns 0 rows (test PASSES if empty).

select *
from {{ ref('silver_crm_sales_details') }}
where sls_order_dt > sls_ship_dt
   or sls_order_dt > sls_due_dt