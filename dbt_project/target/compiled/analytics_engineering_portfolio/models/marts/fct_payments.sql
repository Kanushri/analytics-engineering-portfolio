-- select
--     payment_id,
--     subscription_id,
--     customer_id,
--     payment_date,
--     amount,
--     payment_status
-- from "analytics_engineering"."analytics"."stg_payments"


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
from "analytics_engineering"."analytics"."int_payments_enriched"