{{ config(
    schema='core_airline',
    materialized='table'
) }}

with locations as (

    -- 1️⃣ airport (دقیق‌ترین)
    select
        trim(airport_name) as location_name,
        country,
        region
    from {{ ref('stg_airport_disruptions') }}
    where airport_name is not null

    union all

    -- 2️⃣ airline_losses (country + region)
    select
        airline_country,
        airline_country,
        airline_region
    from {{ ref('stg_airline_losses') }}
    where airline_country is not null

    union all

    -- 3️⃣ airspace_closures
    select
        country,
        country,
        region
    from {{ ref('stg_airspace_closures') }}
    where country is not null

    union all

    -- 4️⃣ cancellations
    select
        origin_country,
        origin_country,
        null
    from {{ ref('stg_flight_cancellations') }}
    where origin_country is not null

    union all

    select
        destination_country,
        destination_country,
        null
    from {{ ref('stg_flight_cancellations') }}
    where destination_country is not null

    union all

    -- 5️⃣ conflict (clean only)
    select
        trim(location_name),
        null,
        null
    from {{ ref('stg_conflict_events') }}
    where location_name is not null
      and location_name not like '%/%'
      and location_name not like '%Global%'
      and location_name not like '%multiple%'
      and location_name not like '%corridor%'
      and location_name not like '%border%'

),

-- 🔥 مهم‌ترین بخش: تمیز کردن country
base as (

    select
        location_name,

        case 
            -- City, Country
            when location_name like '%,%' 
                then trim(split_part(location_name, ',', 2))

            -- Persian Gulf & Hormuz fix
            when location_name ilike '%Persian Gulf%' then 'Iran'
            when location_name ilike '%Hormuz%' then 'Iran'

            else country
        end as clean_country,

        region

    from locations
    where location_name is not null
      and location_name not like '%/%'
      and location_name not like '%Global%'
      and location_name not like '%multiple%'
      and location_name not like '%corridor%'
      and location_name not like '%market%'
      and location_name not like '%airspace%'

),

-- 🎯 نهایی سازی
dedup as (

    select
        location_name,
        max(clean_country) as country,

        max(
            case 
                when clean_country = 'Iraq' then 'Middle East'
                when clean_country = 'Australia' then 'Asia Pacific'
                when clean_country = 'China' then 'Asia Pacific'
                when clean_country = 'Switzerland' then 'Europe'
                when clean_country = 'Iran' then 'Middle East'
                when clean_country = 'Pakistan' then 'South Asia'
                when clean_country = 'Bahrain' then 'Middle East'
                when clean_country = 'Canada' then 'North America'
                when clean_country = 'Oman' then 'Middle East'
                when clean_country = 'USA' then 'North America'
                when clean_country = 'Qatar' then 'Middle East'
                when clean_country = 'Saudi Arabia' then 'Middle East'
                when clean_country = 'Russia' then 'Europe'
                else region
            end
        ) as region

    from base
    group by location_name
)

select
    row_number() over(order by location_name) as location_id,
    location_name,
    country,
    region
from dedup