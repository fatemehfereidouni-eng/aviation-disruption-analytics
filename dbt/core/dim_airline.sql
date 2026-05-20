{{ config(
    schema='core_airline',
    materialized='table'
) }}

with airlines as (

    select
        airline_name,
        airline_country,
        airline_region,
        airline_type,
        1 as priority   -- loss مهم‌تر
    from {{ ref('stg_airline_losses') }}

    union all

    select
        airline_name,
        airline_country,
        null,
        null,
        2 as priority   -- estimate کم‌اهمیت‌تر
    from {{ ref('stg_airline_losses_estimate') }}

),

ranked as (

    select *,
        row_number() over(
            partition by airline_name
            order by priority
        ) as rn
    from airlines
    where airline_name is not null

)

select
    row_number() over(order by airline_name) as airline_id,
    airline_name,
    airline_country,
    airline_region,
    airline_type
from ranked
where rn = 1