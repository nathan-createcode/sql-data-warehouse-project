-- Silver layer: cleansed customer demographic data from ERP.
-- Translated from proc_load_silver.sql (erp_cust_az12 section).

with source as (

    -- The source columns are uppercase (CID, BDATE, GEN) because that's how
    -- they appear in the original CSV. PostgreSQL requires double quotes to
    -- reference uppercase column names - we alias them to lowercase here so
    -- the rest of the model can use normal, unquoted lowercase names.
    select
        "CID" as cid,
        cast("BDATE" as date) as bdate,
        "GEN" as gen
    from {{ source('bronze', 'erp_cust_az12') }}

),

cleaned as (

    select
        -- Remove the 'NAS' prefix if present, so this cid can match
        -- the cid format used in the CRM tables.
        case
            when cid like 'NAS%' then substr(cid, 4)
            else cid
        end as cid,

        -- Treat future birthdates as invalid data.
        case
            when bdate > current_date then null
            else bdate
        end as bdate,

        -- Normalize gender values and handle unknown/blank cases.
        case
            when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
            when upper(trim(gen)) in ('M', 'MALE') then 'Male'
            else 'n/a'
        end as gen

    from source

)

select * from cleaned