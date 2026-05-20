{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select
    cast(date as date) as cancellations_date,
    airline as airline_name,
    flight_number,
    origin,
    destination,
    origin_country,
    destination_country,
    aircraft_type,
    passengers_affected,
    reason
from {{ source('raw', 'flight_cancellations') }}