WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'customers') }}
),

cleaned AS (
    SELECT
        TRIM(customer_id) AS customer_id,
        TRIM(customer_unique_id) AS customer_unique_id,
        TRIM(customer_zip_code_prefix) AS customer_zip_code_prefix,
        LOWER(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state
    FROM source_data
)

SELECT *
FROM cleaned