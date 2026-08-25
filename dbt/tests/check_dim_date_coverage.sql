WITH source_dates AS (
    SELECT order_purchase_at::DATE AS date_day
    FROM {{ ref('stg_orders') }}

    UNION ALL

    SELECT order_approved_at::DATE
    FROM {{ ref('stg_orders') }}

    UNION ALL

    SELECT order_delivered_carrier_at::DATE
    FROM {{ ref('stg_orders') }}

    UNION ALL

    SELECT order_delivered_customer_at::DATE
    FROM {{ ref('stg_orders') }}

    UNION ALL

    SELECT order_estimated_delivery_at::DATE
    FROM {{ ref('stg_orders') }}
),

expected AS (
    SELECT
        MIN(date_day) AS minimum_date,
        MAX(date_day) AS maximum_date
    FROM source_dates
    WHERE date_day IS NOT NULL
),

actual AS (
    SELECT
        MIN(date_day) AS minimum_date,
        MAX(date_day) AS maximum_date,
        COUNT(*) AS date_count
    FROM {{ ref('dim_date') }}
)

SELECT
    expected.minimum_date AS expected_minimum_date,
    actual.minimum_date AS actual_minimum_date,
    expected.maximum_date AS expected_maximum_date,
    actual.maximum_date AS actual_maximum_date,
    actual.date_count
FROM expected
CROSS JOIN actual
WHERE actual.minimum_date IS DISTINCT FROM expected.minimum_date
   OR actual.maximum_date IS DISTINCT FROM expected.maximum_date
   OR actual.date_count
        <> expected.maximum_date - expected.minimum_date + 1