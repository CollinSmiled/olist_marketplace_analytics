WITH orders AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),

order_items AS (
    SELECT *
    FROM {{ ref('int_order_items_by_order') }}
),

order_payments AS (
    SELECT *
    FROM {{ ref('int_order_payments_by_order') }}
),

order_reviews AS (
    SELECT *
    FROM {{ ref('int_order_reviews_by_order') }}
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_status,
    orders.order_purchase_at,
    orders.order_approved_at,
    orders.order_delivered_carrier_at,
    orders.order_delivered_customer_at,
    orders.order_estimated_delivery_at,

    order_items.order_id IS NOT NULL
        AS has_item_details,
    order_items.item_count,
    order_items.distinct_product_count,
    order_items.distinct_seller_count,
    order_items.item_price_total,
    order_items.freight_value_total,
    order_items.item_and_freight_total,
    order_items.earliest_shipping_limit_at,
    order_items.latest_shipping_limit_at,

    order_payments.order_id IS NOT NULL
        AS has_payment_details,
    order_payments.payment_record_count,
    order_payments.distinct_payment_type_count,
    order_payments.payment_value_total,
    order_payments.maximum_payment_installments,
    order_payments.used_credit_card,
    order_payments.used_boleto,
    order_payments.used_voucher,
    order_payments.used_debit_card,
    order_payments.used_not_defined_payment,

    order_reviews.order_id IS NOT NULL
        AS has_review,
    order_reviews.latest_review_score,
    order_reviews.average_review_score,
    order_reviews.review_record_count,
    order_reviews.has_conflicting_review_scores,
    order_reviews.review_message_count,
    order_reviews.latest_review_answered_at,

    CASE
        WHEN orders.order_status = 'delivered'
         AND orders.order_delivered_customer_at IS NOT NULL
            THEN CAST(
                orders.order_delivered_customer_at AS DATE
            ) > CAST(
                orders.order_estimated_delivery_at AS DATE
            )
    END AS is_delivered_late,

    CASE
        WHEN orders.order_delivered_customer_at IS NOT NULL
            THEN ROUND(
                EXTRACT(
                    EPOCH FROM (
                        orders.order_delivered_customer_at
                        - orders.order_purchase_at
                    )
                ) / 86400,
                2
            )
    END AS delivery_time_days,

    CASE
        WHEN orders.order_delivered_customer_at IS NOT NULL
            THEN ROUND(
                EXTRACT(
                    EPOCH FROM (
                        orders.order_delivered_customer_at
                        - orders.order_estimated_delivery_at
                    )
                ) / 86400,
                2
            )
    END AS delivery_delay_days,

    CASE
        WHEN orders.order_status = 'delivered'
         AND orders.order_delivered_customer_at IS NOT NULL
            THEN CAST(
                orders.order_delivered_customer_at AS DATE
            ) - CAST(
                orders.order_estimated_delivery_at AS DATE
            )
    END AS delivery_delay_calendar_days,

    COALESCE(
        orders.order_delivered_carrier_at
            < orders.order_purchase_at,
        FALSE
    )
    OR COALESCE(
        orders.order_delivered_customer_at
            < orders.order_purchase_at,
        FALSE
    )
    OR COALESCE(
        orders.order_delivered_customer_at
            < orders.order_delivered_carrier_at,
        FALSE
    ) AS has_delivery_timeline_anomaly

FROM orders
LEFT JOIN order_items
    ON orders.order_id = order_items.order_id
LEFT JOIN order_payments
    ON orders.order_id = order_payments.order_id
LEFT JOIN order_reviews
    ON orders.order_id = order_reviews.order_id