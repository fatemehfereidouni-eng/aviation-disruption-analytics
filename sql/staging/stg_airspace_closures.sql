{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select
    country,
    region,
    cast(closure_start_date as date) as closure_start_date,
    cast(closure_end_date as date) as closure_end_date,
    duration_hours,
    airspace_zone,
    reason,
    flights_affected
from {{ source('raw', 'airspace_closures') }}