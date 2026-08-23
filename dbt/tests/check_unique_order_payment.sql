SELECT
    order_id,
    payment_sequence,
    COUNT(*) AS row_count
FROM {{ ref('stg_order_payments') }}
GROUP BY
    order_id,
    payment_sequence
HAVING COUNT(*) > 1