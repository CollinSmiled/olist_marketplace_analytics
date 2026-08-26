WITH staging_products AS (
    SELECT
        product_id
    FROM {{ ref('stg_products') }}
),

dimension_products AS (
    SELECT
        product_id
    FROM {{ ref('dim_products') }}
)

SELECT
    COALESCE(
        staging_products.product_id,
        dimension_products.product_id
    ) AS product_id
FROM staging_products
FULL OUTER JOIN dimension_products
    ON staging_products.product_id = dimension_products.product_id
WHERE staging_products.product_id IS NULL
   OR dimension_products.product_id IS NULL