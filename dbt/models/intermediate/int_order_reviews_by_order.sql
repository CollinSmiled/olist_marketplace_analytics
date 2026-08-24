WITH order_reviews AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_created_at,
        review_answered_at
    FROM {{ ref('stg_order_reviews') }}
),

ranked_reviews AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                review_answered_at DESC,
                review_created_at DESC,
                review_id DESC
        ) AS review_rank
    FROM order_reviews
),

review_summary AS (
    SELECT
        order_id,
        COUNT(*) AS review_record_count,
        ROUND(AVG(review_score), 2) AS average_review_score,
        MIN(review_score) AS minimum_review_score,
        MAX(review_score) AS maximum_review_score,
        COUNT(DISTINCT review_score) > 1
            AS has_conflicting_review_scores,
        COUNT(review_comment_message) AS review_message_count,
        MIN(review_answered_at) AS first_review_answered_at
    FROM order_reviews
    GROUP BY order_id
),

latest_reviews AS (
    SELECT
        order_id,
        review_id AS latest_review_id,
        review_score AS latest_review_score,
        review_comment_title AS latest_review_comment_title,
        review_comment_message AS latest_review_comment_message,
        review_created_at AS latest_review_created_at,
        review_answered_at AS latest_review_answered_at
    FROM ranked_reviews
    WHERE review_rank = 1
)

SELECT
    review_summary.order_id,
    latest_reviews.latest_review_id,
    latest_reviews.latest_review_score,
    latest_reviews.latest_review_comment_title,
    latest_reviews.latest_review_comment_message,
    latest_reviews.latest_review_created_at,
    latest_reviews.latest_review_answered_at,
    review_summary.review_record_count,
    review_summary.average_review_score,
    review_summary.minimum_review_score,
    review_summary.maximum_review_score,
    review_summary.has_conflicting_review_scores,
    review_summary.review_message_count,
    review_summary.first_review_answered_at
FROM review_summary
INNER JOIN latest_reviews
    ON review_summary.order_id = latest_reviews.order_id