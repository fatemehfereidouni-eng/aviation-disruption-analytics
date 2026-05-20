{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select
    cast(date as date) as reroutes_date,
    airline as airline_name,
    flight_number,
    origin,
    destination,
    original_route,
    new_route,
    original_distance_km,
    new_distance_km,
    additional_distance_km,
    extra_fuel_cost_usd,
    delay_hours

from {{ source('raw', 'flight_reroutes') }}