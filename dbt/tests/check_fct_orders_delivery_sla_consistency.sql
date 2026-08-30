WITH expected_calendar_delays AS (
    SELECT
        order_id,
        order_status,
        order_delivered_customer_at,
        order_estimated_delivery_at,
        is_delivered_late,
        delivery_delay_calendar_days,
        delivery_delay_band,
        delivery_delay_band_sort,

        CASE
            WHEN order_status = 'delivered'
             AND order_delivered_customer_at IS NOT NULL
                THEN CAST(
                    order_delivered_customer_at AS DATE
                ) - CAST(
                    order_estimated_delivery_at AS DATE
                )
        END AS expected_calendar_days
    FROM {{ ref('fct_orders') }}
),

expected_delivery_rules AS (
    SELECT
        *,

        CASE
            WHEN expected_calendar_days IS NOT NULL
                THEN expected_calendar_days > 0
        END AS expected_is_delivered_late,

        CASE
            WHEN expected_calendar_days <= 0
                THEN 'On time or early'
            WHEN expected_calendar_days <= 3
                THEN '1-3 days late'
            WHEN expected_calendar_days <= 7
                THEN '4-7 days late'
            WHEN expected_calendar_days > 7
                THEN '8+ days late'
        END AS expected_delivery_delay_band,

        CASE
            WHEN expected_calendar_days <= 0
                THEN 1
            WHEN expected_calendar_days <= 3
                THEN 2
            WHEN expected_calendar_days <= 7
                THEN 3
            WHEN expected_calendar_days > 7
                THEN 4
        END AS expected_delivery_delay_band_sort
    FROM expected_calendar_delays
)

SELECT
    order_id,
    delivery_delay_calendar_days,
    expected_calendar_days,
    is_delivered_late,
    expected_is_delivered_late,
    delivery_delay_band,
    expected_delivery_delay_band,
    delivery_delay_band_sort,
    expected_delivery_delay_band_sort
FROM expected_delivery_rules
WHERE delivery_delay_calendar_days
        IS DISTINCT FROM expected_calendar_days
   OR is_delivered_late
        IS DISTINCT FROM expected_is_delivered_late
   OR delivery_delay_band
        IS DISTINCT FROM expected_delivery_delay_band
   OR delivery_delay_band_sort
        IS DISTINCT FROM expected_delivery_delay_band_sort