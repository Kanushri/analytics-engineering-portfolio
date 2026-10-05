
  create view "analytics_engineering"."analytics"."stg_subscriptions__dbt_tmp"
    
    
  as (
    select
    subscription_id,
    customer_id,
    plan_name,
    monthly_price,
    start_date,
    end_date,
    status
from "analytics_engineering"."public"."raw_subscriptions"
  );