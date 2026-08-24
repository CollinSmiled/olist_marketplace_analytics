WITH staging_totals AS (
    SELECT
        COUNT(*) AS item_count,
        SUM(item_price) AS item_price_total,
        SUM(freight_value) AS freight_value_total
    FROM {{ ref('stg_order_items') }}
),

intermediate_totals AS (
    SELECT
        SUM(item_count) AS item_count,
        SUM(item_price_total) AS item_price_total,
        SUM(freight_value_total) AS freight_value_total
    FROM {{ ref('int_order_items_by_order') }}
)

SELECT
    staging_totals.item_count AS staging_item_count,
    intermediate_totals.item_count AS intermediate_item_count,
    staging_totals.item_price_total AS staging_item_price_total,
    intermediate_totals.item_price_total
        AS intermediate_item_price_total,
    staging_totals.freight_value_total
        AS staging_freight_value_total,
    intermediate_totals.freight_value_total
        AS intermediate_freight_value_total
FROM staging_totals
CROSS JOIN intermediate_totals
WHERE staging_totals.item_count
        <> intermediate_totals.item_count
   OR staging_totals.item_price_total
        <> intermediate_totals.item_price_total
   OR staging_totals.freight_value_total
        <> intermediate_totals.freight_value_total