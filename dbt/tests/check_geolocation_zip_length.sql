SELECT
    geolocation_zip_code_prefix
FROM {{ ref('stg_geolocation') }}
WHERE LENGTH(geolocation_zip_code_prefix) <> 5