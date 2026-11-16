
CREATE OR REFRESH STREAMING TABLE bronze_hotel_bookings AS

SELECT
    *,
    _metadata.file_name AS source_file,
    current_timestamp() AS loaded_at

FROM STREAM read_files(
    '/Volumes/hotel_booking_analytics/default/hotel_bookings/',
    format => 'csv',
    header => true
);
