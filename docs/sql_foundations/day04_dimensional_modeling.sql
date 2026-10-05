
CREATE TABLE raw_customers (
    customer_id INT,
    customer_name VARCHAR(100),
    country VARCHAR(50),
    signup_date DATE
);

CREATE TABLE raw_subscriptions (
    subscription_id INT,
    customer_id INT,
    plan_name VARCHAR(50),
    monthly_price NUMERIC(10,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE raw_payments (
    payment_id INT,
    subscription_id INT,
    customer_id INT,
    payment_date DATE,
    amount NUMERIC(10,2),
    payment_status VARCHAR(20)
);

INSERT INTO raw_customers VALUES
(1, 'Acme Corp', 'India', '2026-01-10'),
(2, 'Bright Ltd', 'USA', '2026-02-05'),
(3, 'Nova Inc', 'India', '2026-02-18');

INSERT INTO raw_subscriptions VALUES
(101, 1, 'Starter', 1000, '2026-01-10', '2026-03-31', 'cancelled'),
(102, 1, 'Pro',     2000, '2026-04-01', NULL, 'active'),
(103, 2, 'Pro',     2000, '2026-02-05', NULL, 'active'),
(104, 3, 'Starter', 1000, '2026-02-18', NULL, 'active');

INSERT INTO raw_payments VALUES
(1001, 101, 1, '2026-01-10', 1000, 'paid'),
(1002, 101, 1, '2026-02-10', 1000, 'paid'),
(1003, 102, 1, '2026-04-10', 2000, 'paid'),
(1004, 103, 2, '2026-02-05', 2000, 'paid'),
(1005, 103, 2, '2026-03-05', 2000, 'paid'),
(1006, 104, 3, '2026-02-18', 1000, 'paid');


CREATE TABLE dim_customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    country,
    signup_date
FROM raw_customers;

CREATE TABLE dim_plans AS
SELECT DISTINCT
    plan_name,
    monthly_price
FROM raw_subscriptions;

CREATE TABLE fct_payments AS
SELECT
    payment_id,
    subscription_id,
    customer_id,
    payment_date,
    amount,
    payment_status
FROM raw_payments;

-- Revenue by country.

SELECT
    c.country,
    SUM(f.amount) AS revenue
FROM fct_payments f
JOIN dim_customers c
    ON f.customer_id = c.customer_id
WHERE f.payment_status = 'paid'
GROUP BY c.country
ORDER BY revenue DESC;


-- safe query
select
c.customer_name,
s.plan_name,
s.Revenue
from
(select
p.customer_id,
s.plan_name,
sum(amount) as Revenue
from fct_payments p join raw_subscriptions s
on p.customer_id=s.customer_id and p.subscription_id = s.subscription_id
group by 1,2) s join dim_customers c on
s.customer_id=c.customer_id;
--improved/optimized query
SELECT
    c.customer_name,
    s.plan_name,
    SUM(p.amount) AS total_revenue
FROM fct_payments p
JOIN raw_subscriptions s
    ON p.subscription_id = s.subscription_id
JOIN dim_customers c
    ON p.customer_id = c.customer_id
WHERE p.payment_status = 'paid'
GROUP BY
    c.customer_name,
    s.plan_name
ORDER BY
    c.customer_name,
    s.plan_name;
