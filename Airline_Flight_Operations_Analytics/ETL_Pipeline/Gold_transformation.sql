CREATE OR REFRESH MATERIALIZED VIEW gold_airline_performance
COMMENT 'Gold layer: Airline-wise operational and revenue performance'
AS

SELECT
    INITCAP(TRIM(airline)) AS airline,

    COUNT(*) AS total_flights,

    SUM(passengers) AS total_passengers,

    SUM(ticket_revenue) AS total_ticket_revenue,

    SUM(fuel_cost) AS total_fuel_cost,

    SUM(ticket_revenue - fuel_cost)
        AS revenue_after_fuel_cost,

    ROUND(AVG(avg_fare), 2) AS average_fare,

    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes,

    SUM(
        CASE
            WHEN delay_minutes > 0 THEN 1
            ELSE 0
        END
    ) AS delayed_flights

FROM workspace.default.silver_flights_clean

GROUP BY INITCAP(TRIM(airline));





CREATE OR REFRESH MATERIALIZED VIEW gold_route_performance
COMMENT 'Gold layer: Normalized route-wise airline performance analysis'
AS
SELECT
    INITCAP(TRIM(origin_city)) AS origin_city,
    INITCAP(TRIM(destination_city)) AS destination_city,

    COUNT(*) AS total_flights,
    SUM(passengers) AS total_passengers,
    SUM(ticket_revenue) AS total_revenue,
    SUM(fuel_cost) AS total_fuel_cost,

    ROUND(AVG(distance_km), 2) AS average_distance_km,
    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes

FROM workspace.default.silver_flights_clean

GROUP BY
    INITCAP(TRIM(origin_city)),
    INITCAP(TRIM(destination_city));






CREATE OR REFRESH MATERIALIZED VIEW gold_delay_analysis
COMMENT 'Gold layer: Normalized airline-wise flight delay analysis'
AS
SELECT
    INITCAP(TRIM(airline)) AS airline,

    CASE
        WHEN delay_minutes < 0 THEN 'Early'
        WHEN delay_minutes <= 15 THEN 'On Time'
        WHEN delay_minutes <= 60 THEN 'Minor Delay'
        ELSE 'Major Delay'
    END AS delay_category,

    COUNT(*) AS total_flights,

    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes,

    SUM(passengers) AS total_passengers

FROM workspace.default.silver_flights_clean

GROUP BY
    INITCAP(TRIM(airline)),
    CASE
        WHEN delay_minutes < 0 THEN 'Early'
        WHEN delay_minutes <= 15 THEN 'On Time'
        WHEN delay_minutes <= 60 THEN 'Minor Delay'
        ELSE 'Major Delay'
    END;




    

    CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_flight_trends
COMMENT 'Gold layer: Monthly airline flight operations and revenue trends'
AS
SELECT
    DATE_TRUNC('MONTH', flight_date) AS flight_month,

    COUNT(*) AS total_flights,

    SUM(passengers) AS total_passengers,

    SUM(ticket_revenue) AS total_ticket_revenue,

    SUM(fuel_cost) AS total_fuel_cost,

    ROUND(AVG(delay_minutes), 2) AS average_delay_minutes,

    SUM(
        CASE
            WHEN delay_minutes > 15 THEN 1
            ELSE 0
        END
    ) AS delayed_flights

FROM workspace.default.silver_flights_clean

GROUP BY DATE_TRUNC('MONTH', flight_date);





CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality
COMMENT 'Gold layer: Data quality monitoring and Bronze-Silver reconciliation'
AS

WITH bronze_metrics AS (
    SELECT
        COUNT(*) AS bronze_records
    FROM workspace.default.bronze_airline_flights
),

clean_metrics AS (
    SELECT
        COUNT(*) AS clean_records
    FROM workspace.default.silver_flights_clean
),

rejected_metrics AS (
    SELECT
        COUNT(*) AS rejected_records,

        SUM(
            CASE
                WHEN rejection_reason LIKE '%Duplicate Flight ID%'
                THEN 1
                ELSE 0
            END
        ) AS duplicate_records

    FROM workspace.default.silver_flights_rejected
)

SELECT
    b.bronze_records,
    c.clean_records,
    r.rejected_records,
    r.duplicate_records,

    c.clean_records + r.rejected_records
        AS reconciled_records,

    b.bronze_records -
        (c.clean_records + r.rejected_records)
        AS reconciliation_difference,

    ROUND(
        100.0 * c.clean_records / NULLIF(b.bronze_records, 0),
        2
    ) AS acceptance_percentage,

    ROUND(
        100.0 * r.rejected_records / NULLIF(b.bronze_records, 0),
        2
    ) AS rejection_percentage

FROM bronze_metrics b
CROSS JOIN clean_metrics c
CROSS JOIN rejected_metrics r;