WITH order_payments AS (
    SELECT
        order_id,
        payment_type,
        payment_installments,
        payment_value
    FROM {{ ref('stg_order_payments') }}
),

order_payment_summary AS (
    SELECT
        order_id,
        COUNT(*) AS payment_record_count,
        COUNT(DISTINCT payment_type)
            AS distinct_payment_type_count,
        SUM(payment_value) AS payment_value_total,
        MAX(payment_installments) AS maximum_payment_installments,
        BOOL_OR(payment_type = 'credit_card')
            AS used_credit_card,
        BOOL_OR(payment_type = 'boleto')
            AS used_boleto,
        BOOL_OR(payment_type = 'voucher')
            AS used_voucher,
        BOOL_OR(payment_type = 'debit_card')
            AS used_debit_card,
        BOOL_OR(payment_type = 'not_defined')
            AS used_not_defined_payment
    FROM order_payments
    GROUP BY order_id
)

SELECT *
FROM order_payment_summary