WITH staging_items AS (
    SELECT
        order_id,
        order_item_id
    FROM {{ ref('stg_order_items') }}
),

fact_items AS (
    SELECT
        order_id,
        order_item_id
    FROM {{ ref('fct_order_items') }}
)

SELECT
    COALESCE(staging_items.order_id, fact_items.order_id) AS order_id,
    COALESCE(
        staging_items.order_item_id,
        fact_items.order_item_id
    ) AS order_item_id
FROM staging_items
FULL OUTER JOIN fact_items
    ON staging_items.order_id = fact_items.order_id
   AND staging_items.order_item_id = fact_items.order_item_id
WHERE staging_items.order_id IS NULL
   OR fact_items.order_id IS NULL