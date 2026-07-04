-- Silver layer: cleansed product data from CRM.
-- Translated from proc_load_silver.sql (crm_prd_info section).

with source as (

    select *
    from {{ source('bronze', 'crm_prd_info') }}

),

-- prd_start_dt is stored as text in Bronze (pandas didn't infer it as a
-- date type on load). Cast it to a real date type here, BEFORE using it
-- in LEAD() below - otherwise PostgreSQL can't do date arithmetic on it.
casted as (

    select
        *,
        cast(prd_start_dt as date) as prd_start_dt_casted
    from source

),

cleaned as (

    select
        prd_id,

        -- Extract category ID from the first 5 characters of prd_key
        -- e.g. "CO-RF" -> "CO_RF"
        replace(substr(prd_key, 1, 5), '-', '_') as cat_id,

        -- Extract the actual product key (everything after position 6)
        substr(prd_key, 7, length(prd_key)) as prd_key,

        prd_nm,

        -- COALESCE is PostgreSQL's equivalent of SQL Server's ISNULL
        coalesce(prd_cost, 0) as prd_cost,

        -- Map product line codes to descriptive values
        case
            when upper(trim(prd_line)) = 'M' then 'Mountain'
            when upper(trim(prd_line)) = 'R' then 'Road'
            when upper(trim(prd_line)) = 'S' then 'Other Sales'
            when upper(trim(prd_line)) = 'T' then 'Touring'
            else 'n/a'
        end as prd_line,

        prd_start_dt_casted as prd_start_dt,

        -- End date = one day before the next start date for the same product.
        -- PostgreSQL allows subtracting an integer directly from a date.
        cast(
            lead(prd_start_dt_casted) over (
                partition by prd_key
                order by prd_start_dt_casted
            ) - 1 as date
        ) as prd_end_dt

    from casted

)

select * from cleaned