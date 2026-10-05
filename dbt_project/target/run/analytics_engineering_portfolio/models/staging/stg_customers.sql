
  create view "analytics_engineering"."analytics"."stg_customers__dbt_tmp"
    
    
  as (
    select
    customer_id,
    customer_name,
    country,
    signup_date
from "analytics_engineering"."public"."raw_customers"
  );