WITH staging_totals AS (

    SELECT
        COUNT(*) AS review_record_count,
        COUNT(review_comment_message) AS review_message_count
    FROM {{ ref('stg_order_reviews') }}

),

intermediate_totals AS (

    SELECT
        SUM(review_record_count) AS review_record_count,
        SUM(review_message_count) AS review_message_count
    FROM {{ ref('int_order_reviews_by_order') }}

)

SELECT
    staging_totals.review_record_count
        AS staging_review_record_count,
    intermediate_totals.review_record_count
        AS intermediate_review_record_count,
    staging_totals.review_message_count
        AS staging_review_message_count,
    intermediate_totals.review_message_count
        AS intermediate_review_message_count
FROM staging_totals
CROSS JOIN intermediate_totals
WHERE staging_totals.review_record_count
        <> intermediate_totals.review_record_count
   OR staging_totals.review_message_count
        <> intermediate_totals.review_message_count