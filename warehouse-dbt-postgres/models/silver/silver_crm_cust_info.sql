-- Silver layer: cleansed customer data from CRM.
-- Source logic translated from the original SQL Server stored procedure
-- (proc_load_silver.sql), adapted for PostgreSQL + dbt.

with source as (

    select *
    from {{ source('bronze', 'crm_cust_info') }}
    -- cst_id was inferred as a float column during ingestion (pandas
    -- upgrades an integer column to float when it contains missing values,
    -- since NumPy integers can't represent NaN). This means some "empty"
    -- values are stored as NaN, not SQL NULL - so we filter out both.
    where cst_id is not null
      and cst_id != 'NaN'

),

-- Keep only the most recent record per customer, same as the original
-- ROW_NUMBER() OVER (...) logic in the stored procedure.
deduplicated as (

    select
        *,
        row_number() over (
            partition by cst_id
            order by cst_create_date desc
        ) as flag_last

    from source

),

cleaned as (

    select
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname) as cst_lastname,

        -- Normalize marital status values to a readable format
        case
            when upper(trim(cst_marital_status)) = 'S' then 'Single'
            when upper(trim(cst_marital_status)) = 'M' then 'Married'
            else 'n/a'
        end as cst_marital_status,

        -- Normalize gender values to a readable format
        case
            when upper(trim(cst_gndr)) = 'F' then 'Female'
            when upper(trim(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end as cst_gndr,

        cst_create_date

    from deduplicated
    where flag_last = 1

)

select * from cleaned