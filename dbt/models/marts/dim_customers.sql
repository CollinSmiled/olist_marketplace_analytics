WITH customers AS (
    SELECT *
    FROM {{ ref('stg_customers') }}
),

geography AS (
    SELECT *
    FROM {{ ref('int_geolocation_by_zip') }}
)

SELECT
    customers.customer_id,
    customers.customer_unique_id,
    customers.customer_zip_code_prefix,
    customers.customer_city,
    customers.customer_state,
    geography.geolocation_latitude AS customer_latitude,
    geography.geolocation_longitude AS customer_longitude,
    geography.distinct_observation_count
        AS geolocation_observation_count,
    geography.geolocation_zip_code_prefix IS NOT NULL
        AS has_geolocation_coordinates
FROM customers
LEFT JOIN geography
    ON customers.customer_zip_code_prefix
        = geography.geolocation_zip_code_prefix