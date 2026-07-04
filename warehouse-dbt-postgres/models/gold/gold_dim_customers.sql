-- Gold layer: customer dimension (Star Schema).
-- Translated from ddl_gold.sql (gold.dim_customers view).

with crm as (

    select * from {{ ref('silver_crm_cust_info') }}

),

erp_demographics as (

    select * from {{ ref('silver_erp_cust_az12') }}

),

erp_location as (

    select * from {{ ref('silver_erp_loc_a101') }}

),

final as (

    select
        row_number() over (order by crm.cst_id) as customer_key,  -- surrogate key
        crm.cst_id                               as customer_id,
        crm.cst_key                              as customer_number,
        crm.cst_firstname                        as first_name,
        crm.cst_lastname                         as last_name,
        loc.cntry                                as country,
        crm.cst_marital_status                   as marital_status,

        -- CRM is the primary source for gender; fall back to ERP data
        -- when CRM doesn't have it.
        case
            when crm.cst_gndr != 'n/a' then crm.cst_gndr
            else coalesce(dem.gen, 'n/a')
        end                                       as gender,

        dem.bdate                                as birthdate,
        crm.cst_create_date                      as create_date

    from crm
    left join erp_demographics dem
        on crm.cst_key = dem.cid
    left join erp_location loc
        on crm.cst_key = loc.cid

)

select * from final