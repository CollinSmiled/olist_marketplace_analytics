WITH staging_totals AS (
    SELECT
        COUNT(*) AS item_quantity,
        SUM(item_price) AS item_price_total,
        SUM(freight_value) AS freight_value_total,
        SUM(item_price + freight_value)
            AS item_and_freight_total
    FROM {{ ref('stg_order_items') }}
),

fact_totals AS (
    SELECT
        SUM(item_quantity) AS item_quantity,
        SUM(item_price) AS item_price_total,
        SUM(freight_value) AS freight_value_total,
        SUM(item_and_freight_value)
            AS item_and_freight_total
    FROM {{ ref('fct_order_items') }}
)

SELECT
    staging_totals.item_quantity AS staging_item_quantity,
    fact_totals.item_quantity AS fact_item_quantity,
    staging_totals.item_price_total AS staging_item_price_total,
    fact_totals.item_price_total AS fact_item_price_total,
    staging_totals.freight_value_total AS staging_freight_value_total,
    fact_totals.freight_value_total AS fact_freight_value_total,
    staging_totals.item_and_freight_total
        AS staging_item_and_freight_total,
    fact_totals.item_and_freight_total
        AS fact_item_and_freight_total
FROM staging_totals
CROSS JOIN fact_totals
WHERE staging_totals.item_quantity
        IS DISTINCT FROM fact_totals.item_quantity
   OR staging_totals.item_price_total
        IS DISTINCT FROM fact_totals.item_price_total
   OR staging_totals.freight_value_total
        IS DISTINCT FROM fact_totals.freight_value_total
   OR staging_totals.item_and_freight_total
        IS DISTINCT FROM fact_totals.item_and_freight_total