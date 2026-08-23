WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'product_category_translation') }}
),

cleaned AS (
    SELECT
        TRIM(product_category_name) AS product_category_name,
        TRIM(product_category_name_english)
            AS product_category_name_english
    FROM source_data
)

SELECT *
FROM cleaned