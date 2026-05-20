{{ config(
    schema='core_airline',
    materialized='table'
) }}

with all_dates as (
    select disruptions_date as full_date
    from{{ ref('stg_airport_disruptions')}}

    union 

    select closure_start_date
    from {{ ref('stg_airspace_closures') }}

    union

    select closure_end_date
    from {{ ref('stg_airspace_closures') }}

    union
    select conflict_date
    from{{ref('stg_conflict_events') }}

    union

    select cancellations_date
    from {{ ref('stg_flight_cancellations') }}

    union

    select reroutes_date
    from {{ ref('stg_flight_reroutes') }}
)
select distinct
    to_char(full_date, 'YYYYMMDD')::int as date_id,
    full_date,
    extract(year from full_date) as year,
    extract(month from full_date) as month,
    extract(day from full_date) as day

from all_dates
where full_date is not null


    
