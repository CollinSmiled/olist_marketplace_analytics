WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'order_payments') }}
),

cleaned_and_typed AS (
    SELECT
        TRIM(order_id) AS order_id,
        CAST(NULLIF(TRIM(payment_sequential), '') AS INTEGER)
            AS payment_sequence,
        LOWER(TRIM(payment_type)) AS payment_type,
        CAST(NULLIF(TRIM(payment_installments), '') AS INTEGER)
            AS payment_installments,
        CAST(NULLIF(TRIM(payment_value), '') AS NUMERIC(12, 2))
            AS payment_value
    FROM source_data
)

SELECT *
FROM cleaned_and_typed