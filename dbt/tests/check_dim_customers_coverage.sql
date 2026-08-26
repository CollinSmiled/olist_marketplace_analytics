WITH staging_customers AS (
    SELECT customer_id
    FROM {{ ref('stg_customers') }}
),

dimension_customers AS (
    SELECT customer_id
    FROM {{ ref('dim_customers') }}
)

SELECT
    COALESCE(
        staging_customers.customer_id,
        dimension_customers.customer_id
    ) AS customer_id
FROM staging_customers
FULL OUTER JOIN dimension_customers
    ON staging_customers.customer_id
        = dimension_customers.customer_id
WHERE staging_customers.customer_id IS NULL
   OR dimension_customers.customer_id IS NULL