-- Gold layer: product dimension (Star Schema).
-- Translated from ddl_gold.sql (gold.dim_products view).

with products as (

    select * from {{ ref('silver_crm_prd_info') }}

),

categories as (

    select * from {{ ref('silver_erp_px_cat_g1v2') }}

),

final as (

    select
        row_number() over (
            order by prod.prd_start_dt, prod.prd_key
        )                              as product_key,  -- surrogate key
        prod.prd_id                    as product_id,
        prod.prd_key                   as product_number,
        prod.prd_nm                    as product_name,
        prod.cat_id                    as category_id,
        cat.cat                        as category,
        cat.subcat                     as subcategory,
        cat.maintenance                as maintenance,
        prod.prd_cost                  as cost,
        prod.prd_line                  as product_line,
        prod.prd_start_dt              as start_date

    from products prod
    left join categories cat
        on prod.cat_id = cat.id
    where prod.prd_end_dt is null  -- keep current products only, filter out history

)

select * from final