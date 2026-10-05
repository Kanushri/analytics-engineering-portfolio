select
    p.payment_id,
    p.subscription_id,
    p.customer_id,
    c.customer_name,
    c.country,
    s.plan_name,
    s.monthly_price,
    p.payment_date,
    p.amount,
    p.payment_status
from "analytics_engineering"."analytics"."stg_payments" p
left join "analytics_engineering"."analytics"."stg_customers" c
    on p.customer_id = c.customer_id
left join "analytics_engineering"."analytics"."stg_subscriptions" s
    on p.subscription_id = s.subscription_id