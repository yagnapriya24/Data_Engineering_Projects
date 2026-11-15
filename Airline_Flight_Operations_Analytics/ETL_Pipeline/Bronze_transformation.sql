CREATE OR REFRESH STREAMING TABLE bronze_airline_flights

COMMENT 'Bronze layer: Raw airline flight data ingested from CSV'

AS

SELECT
    *,
    _metadata.file_name AS source_file,
    current_timestamp() AS loaded_at

FROM STREAM read_files(
    '/Volumes/airline_flight_operations/default/airline_schema/',
    format => 'csv',
    header => true
);

