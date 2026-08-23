WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'orders')}}
),

cleaned_and_typed AS (
    SELECT
        TRIM(order_id) AS order_id,
        TRIM(customer_id) AS customer_id,
        LOWER(TRIM(order_status)) AS order_status,
        CAST(NULLIF(TRIM(order_purchase_timestamp), '') AS TIMESTAMP)
            AS order_purchase_at,
        CAST(NULLIF(TRIM(order_approved_at), '') AS TIMESTAMP)
            AS order_approved_at,
        CAST(NULLIF(TRIM(order_delivered_carrier_date), '') AS TIMESTAMP)
            AS order_delivered_carrier_at,
        CAST(NULLIF(TRIM(order_delivered_customer_date), '') AS TIMESTAMP)
            AS order_delivered_customer_at,
        CAST(NULLIF(TRIM(order_estimated_delivery_date), '') AS TIMESTAMP)
            AS order_estimated_delivery_at
    FROM source_data
)

SELECT *
FROM cleaned_and_typed