WITH orders AS (
    SELECT *
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    order_id,
    customer_id,

    CAST(
        TO_CHAR(order_purchase_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_purchase_date_key,

    CAST(
        TO_CHAR(order_approved_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_approved_date_key,

    CAST(
        TO_CHAR(order_delivered_carrier_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_delivered_carrier_date_key,

    CAST(
        TO_CHAR(order_delivered_customer_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_delivered_customer_date_key,

    CAST(
        TO_CHAR(order_estimated_delivery_at, 'YYYYMMDD')
        AS INTEGER
    ) AS order_estimated_delivery_date_key,

    order_status,
    order_purchase_at,
    order_approved_at,
    order_delivered_carrier_at,
    order_delivered_customer_at,
    order_estimated_delivery_at,

    has_item_details,
    item_count,
    distinct_product_count,
    distinct_seller_count,
    item_price_total,
    freight_value_total,
    item_and_freight_total,
    earliest_shipping_limit_at,
    latest_shipping_limit_at,

    has_payment_details,
    payment_record_count,
    distinct_payment_type_count,
    payment_value_total,
    maximum_payment_installments,
    used_credit_card,
    used_boleto,
    used_voucher,
    used_debit_card,
    used_not_defined_payment,

    has_review,
    latest_review_score,
    average_review_score,
    review_record_count,
    has_conflicting_review_scores,
    review_message_count,
    latest_review_answered_at,

    is_delivered_late,
    delivery_time_days,
    delivery_delay_days,
    delivery_delay_calendar_days,

    CASE
        WHEN delivery_delay_calendar_days <= 0
            THEN 'On time or early'
        WHEN delivery_delay_calendar_days <= 3
            THEN '1-3 days late'
        WHEN delivery_delay_calendar_days <= 7
            THEN '4-7 days late'
        WHEN delivery_delay_calendar_days > 7
            THEN '8+ days late'
    END AS delivery_delay_band,

    CASE
        WHEN delivery_delay_calendar_days <= 0
            THEN 1
        WHEN delivery_delay_calendar_days <= 3
            THEN 2
        WHEN delivery_delay_calendar_days <= 7
            THEN 3
        WHEN delivery_delay_calendar_days > 7
            THEN 4
    END AS delivery_delay_band_sort,

    has_delivery_timeline_anomaly
FROM orders