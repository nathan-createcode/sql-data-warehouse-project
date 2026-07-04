-- Silver layer: product category data from ERP.
-- Translated from proc_load_silver.sql (erp_px_cat_g1v2 section).
-- No cleaning needed here - this is a straightforward passthrough,
-- same as the original stored procedure.

-- Source columns are uppercase (ID, CAT, SUBCAT, MAINTENANCE) in Bronze,
-- so we alias them to lowercase here to keep naming consistent with the
-- other Silver models.
select
    "ID" as id,
    "CAT" as cat,
    "SUBCAT" as subcat,
    "MAINTENANCE" as maintenance
from {{ source('bronze', 'erp_px_cat_g1v2') }}