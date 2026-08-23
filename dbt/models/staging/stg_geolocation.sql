WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'geolocation') }}
),

cleaned_and_typed AS (
    SELECT
        TRIM(geolocation_zip_code_prefix)
            AS geolocation_zip_code_prefix,
        CAST(NULLIF(TRIM(geolocation_lat), '') AS DOUBLE PRECISION)
            AS geolocation_latitude,
        CAST(NULLIF(TRIM(geolocation_lng), '') AS DOUBLE PRECISION)
            AS geolocation_longitude,
        LOWER(TRIM(geolocation_city))
            AS geolocation_city,
        UPPER(TRIM(geolocation_state))
            AS geolocation_state
    FROM source_data
)

SELECT *
FROM cleaned_and_typed