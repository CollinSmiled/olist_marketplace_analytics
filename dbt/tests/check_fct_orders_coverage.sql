WITH intermediate_orders AS (
    SELECT
        order_id
    FROM {{ ref('int_orders_enriched') }}
),

fact_orders AS (
    SELECT
        order_id
    FROM {{ ref('fct_orders') }}
)

SELECT
    COALESCE(
        intermediate_orders.order_id,
        fact_orders.order_id
    ) AS order_id
FROM intermediate_orders
FULL OUTER JOIN fact_orders
    ON intermediate_orders.order_id = fact_orders.order_id
WHERE intermediate_orders.order_id IS NULL
   OR fact_orders.order_id IS NULL