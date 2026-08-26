WITH products AS (
    SELECT *
    FROM {{ ref('stg_products') }}
),

category_translations AS (
    SELECT *
    FROM {{ ref('stg_product_category_translation') }}
)

SELECT
    products.product_id,
    products.product_category_name
        AS product_category_name_portuguese,
    category_translations.product_category_name_english,
    REPLACE(
        COALESCE(
            category_translations.product_category_name_english,
            products.product_category_name,
            'unknown'
        ),
        '_',
        ' '
    ) AS product_category_name,
    products.product_category_name IS NOT NULL
        AS has_product_category,
    category_translations.product_category_name_english IS NOT NULL
        AS has_english_category_translation,
    products.product_name_length,
    products.product_description_length,
    products.product_photos_quantity,
    products.product_weight_g,
    products.product_length_cm,
    products.product_height_cm,
    products.product_width_cm,
    CAST(products.product_length_cm AS BIGINT)
        * products.product_height_cm
        * products.product_width_cm
        AS product_volume_cm3
FROM products
LEFT JOIN category_translations
    ON products.product_category_name
        = category_translations.product_category_name