{{ config(
    schema='core_airline',
    materialized='table'
) }}

with events as (

    -- 1️⃣ DISRUPTION
    select 
        'Disruption' as event_type,
        coalesce(disruption_type, 'Unknown') as event_subtype,
        coalesce(severity_level, 'Unknown') as severity_level

    from {{ ref('stg_airport_disruptions') }}


    union all


    -- 2️⃣ CONFLICT
    select
        'Conflict' as event_type,
        coalesce(conflict_type, 'Unknown') as event_subtype,
        coalesce(severity_level, 'Unknown') as severity_level

    from {{ ref('stg_conflict_events') }}


    union all


    -- 3️⃣ CLOSURE
    select
        'Closure' as event_type,
        coalesce(airspace_zone, 'Unknown') as event_subtype,
        'Unknown' as severity_level

    from {{ ref('stg_airspace_closures') }}


    union all


    -- 4️⃣ CANCELLATION
    select
        'Cancellation' as event_type,
        coalesce(reason, 'Unknown') as event_subtype,
        'Unknown' as severity_level

    from {{ ref('stg_flight_cancellations') }}

),

deduplicated as (

    select distinct
        event_type,
        event_subtype,
        severity_level

    from events

)

select
    row_number() over(
        order by event_type, event_subtype, severity_level
    ) as event_detail_id,

    event_type,
    event_subtype,
    severity_level

from deduplicated