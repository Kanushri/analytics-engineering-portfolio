select
    payment_id,
    subscription_id,
    customer_id,
    payment_date,
    amount,
    payment_status
from {{ source('raw', 'raw_payments') }}