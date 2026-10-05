
  create view "analytics_engineering"."analytics"."stg_payments__dbt_tmp"
    
    
  as (
    select
    payment_id,
    subscription_id,
    customer_id,
    payment_date,
    amount,
    payment_status
from "analytics_engineering"."public"."raw_payments"
  );