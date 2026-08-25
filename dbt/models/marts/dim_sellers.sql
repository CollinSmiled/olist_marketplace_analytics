WITH sellers AS (
    SELECT *
    FROM {{ ref('stg_sellers') }}
),

geography AS (
    SELECT *
    FROM {{ ref('int_geolocation_by_zip') }}
)

SELECT
    sellers.seller_id,
    sellers.seller_zip_code_prefix,
    sellers.seller_city,
    sellers.seller_state,
    geography.geolocation_latitude AS seller_latitude,
    geography.geolocation_longitude AS seller_longitude,
    geography.distinct_observation_count AS geolocation_observation_count,
    geography.geolocation_zip_code_prefix IS NOT NULL AS has_geolocation_coordinates
FROM sellers
LEFT JOIN geography 
    ON sellers.seller_zip_code_prefix 
        = geography.geolocation_zip_code_prefix