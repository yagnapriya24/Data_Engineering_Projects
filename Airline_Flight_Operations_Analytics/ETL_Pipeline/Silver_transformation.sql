
CREATE OR REFRESH MATERIALIZED VIEW silver_flights_clean
COMMENT 'Silver layer: Valid, cleaned and deduplicated airline flight records'
AS

WITH ranked_flights AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY flight_id
            ORDER BY loaded_at DESC, source_file DESC
        ) AS row_num
    FROM workspace.default.bronze_airline_flights
),

unique_flights AS (
    SELECT *
    FROM ranked_flights
    WHERE row_num = 1
),

classified AS (
    SELECT *,
        CASE
            WHEN passengers > seat_capacity
              OR passengers < 0
              OR avg_fare < 0
            THEN 1
            ELSE 0
        END AS is_invalid
    FROM unique_flights
)

SELECT
    flight_id,
    TRIM(flight_number) AS flight_number,
    TRIM(airline) AS airline,
    TRIM(aircraft_id) AS aircraft_id,
    TRIM(aircraft_type) AS aircraft_type,
    flight_date,
    TRIM(day_of_week) AS day_of_week,
    TRIM(origin_city) AS origin_city,
    TRIM(destination_city) AS destination_city,
    TRIM(origin_region) AS origin_region,
    distance_km,
    scheduled_departure,
    actual_departure,
    delay_minutes,
    TRIM(delay_reason) AS delay_reason,
    seat_capacity,
    passengers,
    avg_fare,
    ticket_revenue,
    fuel_cost,
    _rescued_data,
    source_file,
    loaded_at
FROM classified
WHERE is_invalid = 0;



CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected
COMMENT 'Silver layer: Invalid unique airline flight records with rejection reasons'
AS

WITH ranked_flights AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY flight_id
            ORDER BY loaded_at DESC, source_file DESC
        ) AS row_num
    FROM workspace.default.bronze_airline_flights
),

unique_flights AS (
    SELECT *
    FROM ranked_flights
    WHERE row_num = 1
),

classified AS (
    SELECT *,
        CONCAT_WS(' | ',

            CASE WHEN passengers > seat_capacity
                THEN 'Passengers Exceed Seat Capacity' END,

            CASE WHEN passengers < 0
                THEN 'Negative Passenger Count' END,

            CASE WHEN avg_fare < 0
                THEN 'Negative Average Fare' END

        ) AS rejection_reason
    FROM unique_flights
)

SELECT *
FROM classified
WHERE rejection_reason <> '';

