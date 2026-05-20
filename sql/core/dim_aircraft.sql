{{ config(
    schema='core_airline',
    materialized='table'
) }}

with cleaned as (
    select
        trim(aircraft_type) as aircraft_type

    from {{ ref('stg_flight_cancellations') }}
    where aircraft_type is not null
),

deduplicated as (
    select
        aircraft_type,
        row_number() over (partition by aircraft_type order by aircraft_type) as rn
    from cleaned
)

select
    row_number() over(order by aircraft_type) as aircraft_id,
    aircraft_type
from deduplicated
where rn = 1   
