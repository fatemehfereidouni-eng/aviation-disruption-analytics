{{ config(
    schema='core_airline',
    materialized='table'
) }}

select
    row_number() over(order by event_type) as event_id,
    event_type
from (
    select 'Loss' as event_type
    union
    select 'Loss Estimate'
    union
    select 'Cancellation'
    union
    select 'Reroute'
    union
    select 'Disruption'
    union
    select 'Conflict'
    union
    select 'Closure'
) t