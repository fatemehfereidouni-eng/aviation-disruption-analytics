{{ config(
    schema='stg_airline',
    materialized='table'
) }}

select 
airline as airline_name,
country as airline_country,
estimated_daily_loss_usd,
cancelled_flights,
rerouted_flights,
additional_fuel_cost_usd,
passengers_impacted



from {{ source('raw', 'airline_losses_estimate') }}