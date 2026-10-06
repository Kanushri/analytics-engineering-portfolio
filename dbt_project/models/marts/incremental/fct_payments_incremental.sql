{{
    config(
    materialized='incremental',
    unique_key='payment_id'
)
}}

select
    payment_id,
    subscription_id,
    customer_id,
    customer_name,
    country,
    plan_name,
    monthly_price,
    payment_date,
    amount,
    payment_status
from {{ ref('int_payments_enriched') }}

{% if is_incremental() %}
    where payment_date >= (
        select max(payment_date)
        from {{ this }}
    )
{% endif %}
