WITH order_items AS (
    SELECT *
    FROM {{ ref('stg_order_items') }}
),

orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_at
    FROM {{ ref('stg_orders') }}
)

SELECT
    order_items.order_id,
    order_items.order_item_id,
    orders.customer_id,
    order_items.product_id,
    order_items.seller_id,

    CAST(
        TO_CHAR(orders.order_purchase_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_purchase_date_key,

    CAST(
        TO_CHAR(order_items.shipping_limit_at, 'YYYYMMDD')
        AS INTEGER
    ) AS shipping_limit_date_key,

    orders.order_status,
    orders.order_purchase_at,
    order_items.shipping_limit_at,

    1 AS item_quantity,
    order_items.item_price,
    order_items.freight_value,
    order_items.item_price
        + order_items.freight_value
        AS item_and_freight_value

FROM order_items
INNER JOIN orders
    ON order_items.order_id = orders.order_id