
CREATE OR REFRESH MATERIALIZED VIEW silver_flights_clean
COMMENT 'Silver layer: Cleaned and deduplicated airline flight records'
AS

WITH ranked_flights AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY flight_id
            ORDER BY loaded_at DESC, source_file DESC
        ) AS row_num
    FROM workspace.default.bronze_airline_flights
),

cleaned AS (
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
    FROM ranked_flights
    WHERE row_num = 1
      AND flight_id IS NOT NULL
      AND TRIM(flight_id) <> ''
      AND airline IS NOT NULL
      AND TRIM(airline) <> ''
      AND flight_date IS NOT NULL
      AND origin_city IS NOT NULL
      AND TRIM(origin_city) <> ''
      AND destination_city IS NOT NULL
      AND TRIM(destination_city) <> ''
      AND distance_km > 0
      AND seat_capacity > 0
      AND passengers >= 0
      AND passengers <= seat_capacity
      AND avg_fare >= 0
      AND ticket_revenue >= 0
      AND fuel_cost >= 0
)

SELECT * FROM cleaned;



CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected
COMMENT 'Silver layer: Invalid and duplicate airline flight records with rejection reasons'
AS

WITH ranked_flights AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY flight_id
            ORDER BY loaded_at DESC, source_file DESC
        ) AS row_num
    FROM workspace.default.bronze_airline_flights
),

classified AS (
    SELECT
        *,
        CONCAT_WS(' | ',

            CASE WHEN flight_id IS NULL OR TRIM(flight_id) = ''
                THEN 'Missing Flight ID' END,

            CASE WHEN airline IS NULL OR TRIM(airline) = ''
                THEN 'Missing Airline' END,

            CASE WHEN flight_date IS NULL
                THEN 'Missing Flight Date' END,

            CASE WHEN origin_city IS NULL OR TRIM(origin_city) = ''
                THEN 'Missing Origin City' END,

            CASE WHEN destination_city IS NULL OR TRIM(destination_city) = ''
                THEN 'Missing Destination City' END,

            CASE WHEN distance_km <= 0 OR distance_km IS NULL
                THEN 'Invalid Distance' END,

            CASE WHEN seat_capacity <= 0 OR seat_capacity IS NULL
                THEN 'Invalid Seat Capacity' END,

            CASE WHEN passengers < 0 OR passengers IS NULL
                THEN 'Invalid Passenger Count' END,

            CASE WHEN passengers > seat_capacity
                THEN 'Passengers Exceed Seat Capacity' END,

            CASE WHEN avg_fare < 0 OR avg_fare IS NULL
                THEN 'Invalid Average Fare' END,

            CASE WHEN ticket_revenue < 0 OR ticket_revenue IS NULL
                THEN 'Invalid Ticket Revenue' END,

            CASE WHEN fuel_cost < 0 OR fuel_cost IS NULL
                THEN 'Invalid Fuel Cost' END,

            CASE WHEN row_num > 1
                THEN 'Duplicate Flight ID' END

        ) AS rejection_reason

    FROM ranked_flights
)

SELECT *
FROM classified
WHERE rejection_reason <> '';


