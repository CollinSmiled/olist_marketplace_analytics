WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'products') }}
),

cleaned_and_typed AS (
    SELECT
        TRIM(product_id) AS product_id,
        NULLIF(TRIM(product_category_name), '')
            AS product_category_name,
        CAST(NULLIF(TRIM(product_name_lenght), '') AS INTEGER)
            AS product_name_length,
        CAST(NULLIF(TRIM(product_description_lenght), '') AS INTEGER)
            AS product_description_length,
        CAST(NULLIF(TRIM(product_photos_qty), '') AS INTEGER)
            AS product_photos_quantity,
        CAST(NULLIF(TRIM(product_weight_g), '') AS INTEGER)
            AS product_weight_g,
        CAST(NULLIF(TRIM(product_length_cm), '') AS INTEGER)
            AS product_length_cm,
        CAST(NULLIF(TRIM(product_height_cm), '') AS INTEGER)
            AS product_height_cm,
        CAST(NULLIF(TRIM(product_width_cm), '') AS INTEGER)
            AS product_width_cm
    FROM source_data
)

SELECT *
FROM cleaned_and_typed