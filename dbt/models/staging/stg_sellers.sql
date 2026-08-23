WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'sellers')}}
),

cleaned AS (
    SELECT
        TRIM(seller_id) AS seller_id,
        TRIM(seller_zip_code_prefix) AS seller_zip_code_prefix,
        LOWER(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state
    FROM source_data
)

SELECT *
FROM cleaned