-- Gold layer: sales fact table (Star Schema).
-- Translated from ddl_gold.sql (gold.fact_sales view).
--
-- Note: this model depends on gold_dim_products and gold_dim_customers
-- (not directly on silver models), because it needs the surrogate keys
-- generated in those dimension models. This dependency is exactly what
-- ref() makes visible in the dbt DAG.

with sales as (

    select * from {{ ref('silver_crm_sales_details') }}

),

products as (

    select * from {{ ref('gold_dim_products') }}

),

customers as (

    select * from {{ ref('gold_dim_customers') }}

),

final as (

    select
        sales.sls_ord_num  as order_number,
        prod.product_key   as product_key,
        cust.customer_key  as customer_key,
        sales.sls_order_dt as order_date,
        sales.sls_ship_dt  as shipping_date,
        sales.sls_due_dt   as due_date,
        sales.sls_sales    as sales_amount,
        sales.sls_quantity as quantity,
        sales.sls_price    as price

    from sales
    left join products prod
        on sales.sls_prd_key = prod.product_number
    left join customers cust
        on sales.sls_cust_id = cust.customer_id

)

select * from final