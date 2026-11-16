
CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_bookings AS

SELECT

    DATE_TRUNC('MONTH', check_in_date) AS stay_month,

    COUNT(*) AS bookings,

    SUM(
        CASE
            WHEN booking_status = 'Cancelled'
            THEN 1
            ELSE 0
        END
    ) AS cancelled_bookings,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN nights
            ELSE 0
        END
    ) AS room_nights,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN total_amount - discount_amount
            ELSE 0
        END
    ) AS net_revenue

FROM silver_bookings_clean

GROUP BY DATE_TRUNC('MONTH', check_in_date);


CREATE OR REFRESH MATERIALIZED VIEW gold_hotel_summary AS

SELECT

    region,
    city,
    hotel_name,

    COUNT(*) AS bookings,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN nights
            ELSE 0
        END
    ) AS room_nights,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN total_amount - discount_amount
            ELSE 0
        END
    ) AS net_revenue,

    ROUND(
        SUM(
            CASE
                WHEN booking_status = 'Completed'
                THEN total_amount - discount_amount
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN booking_status = 'Completed'
                    THEN nights
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS avg_daily_rate

FROM silver_bookings_clean

GROUP BY
    region,
    city,
    hotel_name;


CREATE OR REFRESH MATERIALIZED VIEW gold_room_type_summary AS

SELECT

    room_type,

    COUNT(*) AS bookings,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN nights
            ELSE 0
        END
    ) AS room_nights,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN total_amount - discount_amount
            ELSE 0
        END
    ) AS net_revenue,

    ROUND(AVG(guest_rating), 2) AS avg_rating

FROM silver_bookings_clean

GROUP BY room_type;


CREATE OR REFRESH MATERIALIZED VIEW gold_channel_summary AS

SELECT

    booking_channel,

    COUNT(*) AS bookings,

    SUM(
        CASE
            WHEN booking_status = 'Cancelled'
            THEN 1
            ELSE 0
        END
    ) AS cancelled_bookings,

    ROUND(
        SUM(
            CASE
                WHEN booking_status = 'Cancelled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct,

    SUM(
        CASE
            WHEN booking_status = 'Completed'
            THEN total_amount - discount_amount
            ELSE 0
        END
    ) AS net_revenue

FROM silver_bookings_clean

GROUP BY booking_channel;



CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY booking_id
            ORDER BY loaded_at
        ) AS rn
    FROM bronze_hotel_bookings
),

bronze_stats AS (
    SELECT
        COUNT(*) AS bronze_rows,
        COUNT(DISTINCT booking_id) AS unique_bookings,
        COUNT(*) - COUNT(DISTINCT booking_id) AS duplicate_rows
    FROM bronze_hotel_bookings
),

source_quality AS (
    SELECT
        SUM(CASE WHEN check_out_date <= check_in_date
                 THEN 1 ELSE 0 END) AS invalid_date_rows,

        SUM(CASE WHEN room_rate < 0
                 THEN 1 ELSE 0 END) AS negative_rate_rows,

        SUM(CASE WHEN NULLIF(TRIM(city), '') IS NULL
                 THEN 1 ELSE 0 END) AS missing_city_rows,

        SUM(CASE WHEN NULLIF(TRIM(booking_channel), '') IS NULL
                 THEN 1 ELSE 0 END) AS missing_channel_rows,

        SUM(CASE WHEN NULLIF(TRIM(guest_id), '') IS NULL
                 THEN 1 ELSE 0 END) AS missing_guest_id_rows,

        SUM(CASE WHEN nights IS NULL
                 THEN 1 ELSE 0 END) AS missing_nights_rows,

        SUM(CASE WHEN total_amount IS NULL
                 THEN 1 ELSE 0 END) AS missing_amount_rows

    FROM deduplicated
    WHERE rn = 1
),

silver_stats AS (
    SELECT
        COUNT(*) AS clean_rows
    FROM silver_bookings_clean
),

rejected_stats AS (
    SELECT
        COUNT(*) AS rejected_rows
    FROM silver_bookings_rejected
)

SELECT
    b.bronze_rows,
    b.unique_bookings,
    b.duplicate_rows,
    s.clean_rows,
    r.rejected_rows,

    q.invalid_date_rows,
    q.negative_rate_rows,
    q.missing_city_rows,
    q.missing_channel_rows,
    q.missing_guest_id_rows,
    q.missing_nights_rows,
    q.missing_amount_rows,

    (s.clean_rows + r.rejected_rows + b.duplicate_rows)
        AS reconciled_rows,

    CASE
        WHEN b.bronze_rows =
             s.clean_rows + r.rejected_rows + b.duplicate_rows
        THEN 'Yes'
        ELSE 'No'
    END AS reconciliation_passed

FROM bronze_stats b
CROSS JOIN source_quality q
CROSS JOIN silver_stats s
CROSS JOIN rejected_stats r;

