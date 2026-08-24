WITH order_items AS (
    SELECT
        order_id,
        product_id,
        seller_id,
        shipping_limit_at,
        item_price,
        freight_value
    FROM {{ ref('stg_order_items') }}
),

order_item_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        COUNT(DISTINCT product_id) AS distinct_product_count,
        COUNT(DISTINCT seller_id) AS distinct_seller_count,
        SUM(item_price) AS item_price_total,
        SUM(freight_value) AS freight_value_total,
        SUM(item_price) + SUM(freight_value)
            AS item_and_freight_total,
        MIN(shipping_limit_at) AS earliest_shipping_limit_at,
        MAX(shipping_limit_at) AS latest_shipping_limit_at
    FROM order_items
    GROUP BY order_id
)

SELECT *
FROM order_item_summary