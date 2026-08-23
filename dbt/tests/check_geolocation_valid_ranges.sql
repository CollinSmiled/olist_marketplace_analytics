SELECT
    geolocation_zip_code_prefix,
    geolocation_latitude,
    geolocation_longitude
FROM {{ ref('stg_geolocation') }}
WHERE geolocation_latitude NOT BETWEEN -90 AND 90
   OR geolocation_longitude NOT BETWEEN -180 AND 180