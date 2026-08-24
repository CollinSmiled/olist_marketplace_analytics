SELECT
    order_id
FROM {{ ref('int_orders_enriched') }}
WHERE has_item_details <> (item_count IS NOT NULL)
   OR has_payment_details <> (payment_record_count IS NOT NULL)
   OR has_review <> (review_record_count IS NOT NULL)