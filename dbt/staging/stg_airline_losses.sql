{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select 
airline as airline_name,
country as airline_country,
airline_type,
estimated_loss_usd,
cancellations_count,
reroutes_count,
revenue_loss_pct,
region as airline_region

from {{ source('raw', 'airline_losses') }}