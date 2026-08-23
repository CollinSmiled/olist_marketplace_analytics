WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'order_reviews') }}
),

cleaned_and_typed AS (
    SELECT
        TRIM(review_id) AS review_id,
        TRIM(order_id) AS order_id,
        CAST(NULLIF(TRIM(review_score), '') AS INTEGER)
            AS review_score,
        NULLIF(
            BTRIM(review_comment_title, E' \t\r\n'),
            ''
        ) AS review_comment_title,
        NULLIF(
            BTRIM(review_comment_message, E' \t\r\n'),
            ''
        ) AS review_comment_message,
        CAST(NULLIF(TRIM(review_creation_date), '') AS TIMESTAMP)
            AS review_created_at,
        CAST(NULLIF(TRIM(review_answer_timestamp), '') AS TIMESTAMP)
            AS review_answered_at
    FROM source_data
)

SELECT *
FROM cleaned_and_typed