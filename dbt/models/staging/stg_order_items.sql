WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'order_items') }}
),

cleaned_and_typed AS (
    SELECT
        TRIM(order_id) AS order_id,
        CAST(NULLIF(TRIM(order_item_id), '') AS INTEGER)
            AS order_item_id,
        TRIM(product_id) AS product_id,
        TRIM(seller_id) AS seller_id,
        CAST(NULLIF(TRIM(shipping_limit_date), '') AS TIMESTAMP)
            AS shipping_limit_at,
        CAST(NULLIF(TRIM(price), '') AS NUMERIC(12, 2))
            AS item_price,
        CAST(NULLIF(TRIM(freight_value), '') AS NUMERIC(12, 2))
            AS freight_value
    FROM source_data
)

SELECT *
FROM cleaned_and_typed