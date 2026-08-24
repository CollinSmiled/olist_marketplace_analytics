WITH staging_zip_prefixes AS (
    SELECT DISTINCT
        geolocation_zip_code_prefix
    FROM {{ ref('stg_geolocation') }}
),

intermediate_zip_prefixes AS (
    SELECT
        geolocation_zip_code_prefix
    FROM {{ ref('int_geolocation_by_zip') }}
)

SELECT
    COALESCE(
        staging_zip_prefixes.geolocation_zip_code_prefix,
        intermediate_zip_prefixes.geolocation_zip_code_prefix
    ) AS geolocation_zip_code_prefix
FROM staging_zip_prefixes
FULL OUTER JOIN intermediate_zip_prefixes
    ON staging_zip_prefixes.geolocation_zip_code_prefix
        = intermediate_zip_prefixes.geolocation_zip_code_prefix
WHERE staging_zip_prefixes.geolocation_zip_code_prefix IS NULL
   OR intermediate_zip_prefixes.geolocation_zip_code_prefix IS NULL