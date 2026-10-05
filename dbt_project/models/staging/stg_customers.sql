select
    customer_id,
    customer_name,
    country,
    signup_date
from {{ source('raw', 'raw_customers') }}