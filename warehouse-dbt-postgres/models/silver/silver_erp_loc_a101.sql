-- Silver layer: cleansed customer location data from ERP.
-- Translated from proc_load_silver.sql (erp_loc_a101 section).

with source as (

    -- Same case-sensitivity issue as erp_cust_az12: source columns are
    -- uppercase (CID, CNTRY), so we alias them to lowercase here.
    select
        "CID" as cid,
        "CNTRY" as cntry
    from {{ source('bronze', 'erp_loc_a101') }}

),

cleaned as (

    select
        -- Remove hyphens so this cid can match the format used elsewhere.
        replace(cid, '-', '') as cid,

        -- Normalize country codes/names, and handle missing or blank values.
        case
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US', 'USA') then 'United States'
            when trim(cntry) = '' or cntry is null then 'n/a'
            else trim(cntry)
        end as cntry

    from source

)

select * from cleaned