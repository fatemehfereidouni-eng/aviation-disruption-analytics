{{ config(
    schema='core_airline',
    materialized='table'
) }}

with fact as (

    -- 1️⃣ LOSSES
    select
        a.airline_id,
        null::bigint as airport_id,
        null::bigint as location_id,
        e.event_id,
        null::bigint as aircraft_id,
        null::bigint as date_id,
        null::bigint as reason_id,
        null::bigint as event_detail_id,

        l.estimated_loss_usd,
        null::numeric as estimated_daily_loss_usd,
        null::integer as cancelled_flights,
        null::integer as rerouted_flights,
        l.revenue_loss_pct,
        null::numeric as duration_hours,
        null::numeric as delay_hours,
        null::integer as flights_affected,
        null::integer as passengers_affected,
        null::integer as passengers_impacted,
        null::numeric as additional_fuel_cost_usd,
        null::numeric as additional_distance_km,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_airline_losses') }} l
    left join {{ ref('dim_airline') }} a
        on l.airline_name = a.airline_name
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Loss'


    union all

    -- 2️⃣ LOSS ESTIMATE
    select
        a.airline_id,
        null::bigint as airport_id,
        null::bigint as location_id,
        e.event_id,
        null::bigint as aircraft_id,
        null::bigint as date_id,
        null::bigint as reason_id,
        null::bigint as event_detail_id,

        null::numeric,
        le.estimated_daily_loss_usd,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric,
        null::integer,
        null::integer,
        le.passengers_impacted,
        le.additional_fuel_cost_usd,
        null::numeric,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_airline_losses_estimate') }} le
    left join {{ ref('dim_airline') }} a
        on le.airline_name = a.airline_name
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Loss Estimate'


    union all

    -- 3️⃣ CANCELLATIONS
    select
        a.airline_id,
        null::bigint,
        loc.location_id,
        e.event_id,
        ac.aircraft_id,
        d.date_id,
        r.reason_id,
        ed.event_detail_id,

        null::numeric,
        null::numeric,
        1,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric,
        null::integer,
        c.passengers_affected,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_flight_cancellations') }} c
    left join {{ ref('dim_airline') }} a
        on c.airline_name = a.airline_name
    left join {{ ref('dim_aircraft') }} ac
        on c.aircraft_type = ac.aircraft_type
    left join {{ ref('dim_date') }} d
        on c.cancellations_date = d.full_date
    left join {{ ref('dim_event') }} e
        on e.event_type ='Cancellation'
    left join {{ ref('dim_location') }} loc
        on c.origin_country = loc.location_name
    left join {{ ref('dim_reason') }} r
    on c.reason = r.reason

    left join {{ ref('dim_event_detailed') }} ed
        on ed.event_type = 'Cancellation'
       and ed.event_subtype = c.reason

    union all

    -- 4️⃣ REROUTES
    select
        a.airline_id,
        null::bigint,
        null::bigint,
        e.event_id,
        null::bigint,
        d.date_id,
        null::bigint as reason_id,
        null::bigint as event_detail_id,

        null::numeric,
        null::numeric,
        null::integer,
        1,
        null::numeric,
        null::numeric,
        r.delay_hours,
        null::integer,
        null::integer,
        null::integer,
        null::numeric,
        r.additional_distance_km,
        r.extra_fuel_cost_usd

    from {{ ref('stg_flight_reroutes') }} r
    left join {{ ref('dim_airline') }} a
        on r.airline_name = a.airline_name
    left join {{ ref('dim_date') }} d
        on r.reroutes_date = d.full_date
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Reroute'


    union all

    -- 5️⃣ DISRUPTIONS
    select
        null::bigint,
        ap.airport_id,
        loc.location_id,
        e.event_id,
        null::bigint,
        d.date_id,
        null::bigint as reason_id,
        ed.event_detail_id,

        null::numeric,
        null::numeric,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric,
        dis.flights_affected,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_airport_disruptions') }} dis
    left join {{ ref('dim_airport') }} ap
        on dis.airport_name = ap.airport_name
    left join {{ ref('dim_location') }} loc
        on dis.airport_name = loc.location_name
    left join {{ ref('dim_date') }} d
        on dis.disruptions_date = d.full_date
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Disruption'
    left join {{ ref('dim_event_detailed') }} ed
        on ed.event_type = 'Disruption'
       and ed.event_subtype = dis.disruption_type
       and ed.severity_level = dis.severity_level    


    union all

    -- 6️⃣ CONFLICT EVENTS
    select
        null::bigint,
        null::bigint,
        loc.location_id,
        e.event_id,
        null::bigint,
        d.date_id,
        null::bigint as reason_id,
        ed.event_detail_id,

        null::numeric,
        null::numeric,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric,
        null::integer,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_conflict_events') }} ce
    left join {{ ref('dim_location') }} loc
        on trim(ce.location_name) = loc.location_name
        and ce.location_name not like '%/%'
        and ce.location_name not like '%Global%'
        and ce.location_name not like '%multiple%'
    left join {{ ref('dim_date') }} d
        on ce.conflict_date = d.full_date
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Conflict'
    left join {{ ref('dim_event_detailed') }} ed
        on ed.event_type = 'Conflict'
       and ed.event_subtype = ce.conflict_type
       and ed.severity_level = ce.severity_level

    union all

    -- 7️⃣ AIRSPACE CLOSURES
    select
        null::bigint,
        null::bigint,
        loc.location_id,
        e.event_id,
        null::bigint,
        d.date_id,
        null::bigint as reason_id,
        ed.event_detail_id,

        null::numeric,
        null::numeric,
        null::integer,
        null::integer,
        null::numeric,
        ac.duration_hours,
        null::numeric,
        ac.flights_affected,
        null::integer,
        null::integer,
        null::numeric,
        null::numeric,
        null::numeric as extra_fuel_cost_usd

    from {{ ref('stg_airspace_closures') }} ac
    left join {{ ref('dim_location') }} loc
        on ac.country = loc.location_name
    left join {{ ref('dim_date') }} d
        on ac.closure_start_date = d.full_date
    left join {{ ref('dim_event') }} e
        on e.event_type = 'Closure'
    left join {{ ref('dim_event_detailed') }} ed
        on ed.event_type = 'Closure'
       and ed.event_subtype = ac.airspace_zone
       and ed.severity_level = 'Unknown'    

)

select
    row_number() over() as fact_id,
    *
from fact