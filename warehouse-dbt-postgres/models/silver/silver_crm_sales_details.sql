-- Silver layer: cleansed sales transaction data from CRM.
-- Translated from proc_load_silver.sql (crm_sales_details section).
--
-- Note on date conversion: the original SQL Server logic does
-- CAST(CAST(x AS VARCHAR) AS DATE), which works because SQL Server can
-- interpret an 8-digit number like 20250714 as a date string directly.
-- PostgreSQL's CAST(text AS DATE) expects ISO format (YYYY-MM-DD), so we
-- use to_date(text, 'YYYYMMDD') instead to parse the same raw format.

with source as (

    select *
    from {{ source('bronze', 'crm_sales_details') }}

),

cleaned as (

    select
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        case
            when sls_order_dt = 0 or length(sls_order_dt::text) != 8 then null
            else to_date(sls_order_dt::text, 'YYYYMMDD')
        end as sls_order_dt,

        case
            when sls_ship_dt = 0 or length(sls_ship_dt::text) != 8 then null
            else to_date(sls_ship_dt::text, 'YYYYMMDD')
        end as sls_ship_dt,

        case
            when sls_due_dt = 0 or length(sls_due_dt::text) != 8 then null
            else to_date(sls_due_dt::text, 'YYYYMMDD')
        end as sls_due_dt,

        -- Recalculate sales if the original value is missing, zero/negative,
        -- or inconsistent with quantity * price.
        case
            when sls_sales is null or sls_sales <= 0
                or sls_sales != sls_quantity * abs(sls_price)
                then sls_quantity * abs(sls_price)
            else sls_sales
        end as sls_sales,

        sls_quantity,

        -- Derive price from sales/quantity if the original price is invalid.
        -- NULLIF prevents a division-by-zero error when quantity is 0.
        case
            when sls_price is null or sls_price <= 0
                then sls_sales / nullif(sls_quantity, 0)
            else sls_price
        end as sls_price

    from source

)

select * from cleaned