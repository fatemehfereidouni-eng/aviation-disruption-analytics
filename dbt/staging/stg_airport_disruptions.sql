{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select
    airport_name,
    iata_code,
    country,
    region,
    disruption_type,
    severity_level,
    flights_affected,
    duration_hours,
    cast(date as date) as disruptions_date
from {{ source('raw', 'airport_disruptions') }}