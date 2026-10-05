select
    subscription_id,
    customer_id,
    plan_name,
    monthly_price,
    start_date,
    end_date,
    status
from {{ source('raw', 'raw_subscriptions') }}