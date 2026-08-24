WITH staging_totals AS (
    SELECT
        COUNT(*) AS payment_record_count,
        SUM(payment_value) AS payment_value_total
    FROM {{ ref('stg_order_payments') }}
),

intermediate_totals AS (
    SELECT
        SUM(payment_record_count) AS payment_record_count,
        SUM(payment_value_total) AS payment_value_total
    FROM {{ ref('int_order_payments_by_order') }}
)

SELECT
    staging_totals.payment_record_count
        AS staging_payment_record_count,
    intermediate_totals.payment_record_count
        AS intermediate_payment_record_count,
    staging_totals.payment_value_total
        AS staging_payment_value_total,
    intermediate_totals.payment_value_total
        AS intermediate_payment_value_total
FROM staging_totals
CROSS JOIN intermediate_totals
WHERE staging_totals.payment_record_count
        <> intermediate_totals.payment_record_count
   OR staging_totals.payment_value_total
        <> intermediate_totals.payment_value_total