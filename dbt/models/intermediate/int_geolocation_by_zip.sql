WITH deduplicated_geolocation AS (
    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_latitude,
        geolocation_longitude,
        geolocation_city,
        geolocation_state
    FROM {{ ref('stg_geolocation') }}
),

coordinate_summary AS (
    SELECT
        geolocation_zip_code_prefix,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY geolocation_latitude
        ) AS geolocation_latitude,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY geolocation_longitude
        ) AS geolocation_longitude,
        COUNT(*) AS distinct_observation_count
    FROM deduplicated_geolocation
    GROUP BY geolocation_zip_code_prefix
),

locality_counts AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        COUNT(*) AS locality_observation_count
    FROM deduplicated_geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
),

ranked_localities AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY
                locality_observation_count DESC,
                geolocation_state,
                geolocation_city
        ) AS locality_rank
    FROM locality_counts
)

SELECT
    coordinate_summary.geolocation_zip_code_prefix,
    coordinate_summary.geolocation_latitude,
    coordinate_summary.geolocation_longitude,
    ranked_localities.geolocation_city,
    ranked_localities.geolocation_state,
    coordinate_summary.distinct_observation_count
FROM coordinate_summary
INNER JOIN ranked_localities
    ON coordinate_summary.geolocation_zip_code_prefix
        = ranked_localities.geolocation_zip_code_prefix
WHERE ranked_localities.locality_rank = 1