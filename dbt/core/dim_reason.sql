{{ config(
    schema='core_airline',
    materialized='table'
) }}

with reasons as (

    select distinct
        trim(reason) as reason
    from {{ ref('stg_flight_cancellations') }}
    where reason is not null

)

select
    row_number() over(order by reason) as reason_id,
    reason
from reasons