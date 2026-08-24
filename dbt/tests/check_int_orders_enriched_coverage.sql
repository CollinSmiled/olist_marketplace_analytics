WITH staging_orders AS (
    SELECT order_id
    FROM {{ ref('stg_orders') }}
),

enriched_orders AS (
    SELECT order_id
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    COALESCE(
        staging_orders.order_id,
        enriched_orders.order_id
    ) AS order_id
FROM staging_orders
FULL OUTER JOIN enriched_orders
    ON staging_orders.order_id = enriched_orders.order_id
WHERE staging_orders.order_id IS NULL
   OR enriched_orders.order_id IS NULL