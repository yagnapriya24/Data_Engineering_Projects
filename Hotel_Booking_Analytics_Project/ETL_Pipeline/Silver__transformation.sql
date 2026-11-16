
CREATE OR REFRESH MATERIALIZED VIEW silver_bookings_rejected AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_id
            ORDER BY loaded_at
        ) AS rn
    FROM bronze_hotel_bookings
)

SELECT
    *,
    CASE
        WHEN check_out_date <= check_in_date
             AND room_rate < 0
            THEN 'Invalid dates and negative room rate'

        WHEN check_out_date <= check_in_date
            THEN 'Check-out is not after check-in'

        WHEN room_rate < 0
            THEN 'Negative room rate'
    END AS reject_reason

FROM deduplicated

WHERE rn = 1
AND (
    check_out_date <= check_in_date
    OR room_rate < 0
);


CREATE OR REFRESH MATERIALIZED VIEW silver_bookings_clean AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_id
            ORDER BY loaded_at
        ) AS rn
    FROM bronze_hotel_bookings
)

SELECT
    booking_id,

    NULLIF(TRIM(guest_id), '') AS guest_id,

    booking_date,
    check_in_date,
    check_out_date,

    COALESCE(
        nights,
        DATEDIFF(check_out_date, check_in_date)
    ) AS nights,

    INITCAP(TRIM(hotel_name)) AS hotel_name,

    COALESCE(
        INITCAP(NULLIF(TRIM(city), '')),
        'Unknown'
    ) AS city,

    INITCAP(TRIM(region)) AS region,
    INITCAP(TRIM(room_type)) AS room_type,

    COALESCE(
        INITCAP(NULLIF(TRIM(booking_channel), '')),
        'Unknown'
    ) AS booking_channel,

    guests,
    room_rate,

    COALESCE(
        total_amount,
        COALESCE(
            nights,
            DATEDIFF(check_out_date, check_in_date)
        ) * room_rate
    ) AS total_amount,

    COALESCE(discount_amount, 0) AS discount_amount,

    INITCAP(TRIM(meal_plan)) AS meal_plan,
    INITCAP(TRIM(payment_method)) AS payment_method,
    INITCAP(TRIM(payment_status)) AS payment_status,
    INITCAP(TRIM(booking_status)) AS booking_status,

    guest_rating,

    source_file,
    loaded_at

FROM deduplicated

WHERE rn = 1
AND check_out_date > check_in_date
AND room_rate >= 0;

