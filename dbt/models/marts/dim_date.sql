WITH relevant_dates AS (
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

    UNION ALL

    SELECT shipping_limit_at::DATE
    FROM {{ ref('stg_order_items') }}
),

date_bounds AS (
    SELECT
        DATE_TRUNC(
            'year',
            MIN(date_day)
        )::DATE AS minimum_date,

        (
            DATE_TRUNC('year', MAX(date_day))
            + INTERVAL '1 year'
            - INTERVAL '1 day'
        )::DATE AS maximum_date
    FROM relevant_dates
    WHERE date_day IS NOT NULL
),

date_spine AS (
    SELECT
        GENERATE_SERIES(
            minimum_date,
            maximum_date,
            INTERVAL '1 day'
        )::DATE AS date_day
    FROM date_bounds
)

SELECT
    CAST(TO_CHAR(date_day, 'YYYYMMDD') AS INTEGER) AS date_key,
    date_day,
    EXTRACT(YEAR FROM date_day)::INTEGER AS year_number,
    EXTRACT(QUARTER FROM date_day)::INTEGER AS quarter_number,
    'Q' || EXTRACT(QUARTER FROM date_day)::INTEGER AS quarter_name,
    EXTRACT(MONTH FROM date_day)::INTEGER AS month_number,
    TO_CHAR(date_day, 'FMMonth') AS month_name,
    TO_CHAR(date_day, 'Mon') AS month_short_name,
    TO_CHAR(date_day, 'YYYY-MM') AS year_month,
    DATE_TRUNC('month', date_day)::DATE AS month_start_date,
    EXTRACT(ISOYEAR FROM date_day)::INTEGER AS iso_year_number,
    EXTRACT(WEEK FROM date_day)::INTEGER AS week_of_year,
    TO_CHAR(date_day, 'IYYY-IW') AS year_week,
    EXTRACT(DAY FROM date_day)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM date_day)::INTEGER AS day_of_week,
    TO_CHAR(date_day, 'FMDay') AS day_name,
    EXTRACT(ISODOW FROM date_day) IN (6, 7) AS is_weekend
FROM date_spine