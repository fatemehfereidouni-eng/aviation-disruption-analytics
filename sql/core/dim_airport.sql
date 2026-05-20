{{ config(
    schema='core_airline',
    materialized='table'
) }}

with ranked as (

    select
        airport_name,
        iata_code,
        country,
        region,
        row_number() over(
            partition by airport_name
            order by iata_code desc nulls last
        ) as rn
    from {{ ref('stg_airport_disruptions') }}
    where airport_name is not null

)

select
    row_number() over(order by airport_name) as airport_id,
    airport_name,
    iata_code,
    country,
    region
from ranked
where rn = 1