WITH staging_sellers AS (
    SELECT seller_id
    FROM {{ ref('stg_sellers') }}
),

dimension_sellers AS (
    SELECT seller_id
    FROM {{ ref('dim_sellers') }}
)

SELECT
    COALESCE(
        staging_sellers.seller_id,
        dimension_sellers.seller_id
    ) AS seller_id
FROM staging_sellers
FULL OUTER JOIN dimension_sellers
    ON staging_sellers.seller_id
        = dimension_sellers.seller_id
WHERE staging_sellers.seller_id IS NULL
   OR dimension_sellers.seller_id IS NULL