{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select
    cast(date as date) as conflict_date,
    event_type as conflict_type,
    event_description,
    severity as severity_level,
    aviation_impact,
    location as location_name

from {{ source('raw', 'conflict_events') }}