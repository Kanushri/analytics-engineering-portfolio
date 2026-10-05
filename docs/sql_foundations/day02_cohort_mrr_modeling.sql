
-- ===================================================== -- Day 2: Cohort + Net MRR Movement Modeling -- =====================================================
DROP TABLE IF EXISTS customer_monthly_revenue; 
CREATE TABLE customer_monthly_revenue ( 
	customer_id INT, revenue_month DATE, mrr NUMERIC(10,2) 
);

INSERT INTO customer_monthly_revenue VALUES 
-- Customer 201: steady expansion 
(201, '2026-01-01', 100), (201, '2026-02-01', 120), (201, '2026-03-01', 150), (201, '2026-04-01', 150), 
-- Customer 202: contraction then churn 
(202, '2026-01-01', 200), (202, '2026-02-01', 180), (202, '2026-03-01', 0), 
-- Customer 203: churn then reactivation 
(203, '2026-02-01', 80), (203, '2026-03-01', 0), (203, '2026-05-01', 90), 
-- Customer 204: new customer in March 
(204, '2026-03-01', 300), (204, '2026-04-01', 350), 
-- Customer 205: stable customer 
(205, '2026-01-01', 250), (205, '2026-02-01', 250), (205, '2026-03-01', 250), (205, '2026-04-01', 250);

SELECT * FROM 
customer_monthly_revenue 
ORDER BY customer_id, revenue_month;

-- Build the Customer Revenue History. This is the core pattern used in subscription analytics.

WITH revenue_history AS (

    SELECT
        customer_id,
        revenue_month,
        mrr,

        LAG(mrr) OVER (
            PARTITION BY customer_id
            ORDER BY revenue_month
        ) AS previous_mrr

    FROM customer_monthly_revenue
),

-- SELECT *
-- FROM revenue_history
-- ORDER BY customer_id, revenue_month;
classified as(
SELECT 
customer_id, revenue_month, previous_mrr, mrr, 
CASE 
WHEN previous_mrr IS NULL AND mrr > 0 THEN 'NEW' 
WHEN previous_mrr = 0 AND mrr > 0 THEN 'REACTIVATION' 
WHEN mrr > previous_mrr THEN 'EXPANSION' WHEN mrr < previous_mrr AND mrr > 0 THEN 'CONTRACTION' 
WHEN previous_mrr > 0 AND mrr = 0 THEN 'CHURN' ELSE 'NO_CHANGE' 
END AS movement_type 
FROM revenue_history ORDER BY customer_id, revenue_month)

select 
revenue_month, 
SUM(CASE WHEN movement_type = 'NEW' THEN mrr ELSE 0 END) AS new_mrr, 
SUM(CASE WHEN movement_type = 'EXPANSION' THEN mrr - previous_mrr ELSE 0 END) AS expansion_mrr, 
SUM(CASE WHEN movement_type = 'CONTRACTION' THEN previous_mrr - mrr ELSE 0 END) AS contraction_mrr, 
SUM(CASE WHEN movement_type = 'CHURN' THEN previous_mrr ELSE 0 END) AS churn_mrr, 
SUM(CASE WHEN movement_type = 'REACTIVATION' THEN mrr ELSE 0 END) AS reactivation_mrr 
FROM classified 
GROUP BY revenue_month 
ORDER BY revenue_month;


-- Customer First Revenue Month
WITH first_purchase AS (

    SELECT
        customer_id,
        MIN(revenue_month) AS cohort_month

    FROM customer_monthly_revenue
    WHERE mrr > 0

    GROUP BY customer_id
),

-- SELECT *
-- FROM first_purchase
-- ORDER BY customer_id;
cohort_data AS ( 
SELECT 
r.customer_id, f.cohort_month, r.revenue_month, 
age(r.revenue_month, f.cohort_month) as diff,
( EXTRACT(YEAR FROM age(r.revenue_month, f.cohort_month)) * 12 
+ EXTRACT(MONTH FROM age(r.revenue_month, f.cohort_month)) ) 
AS cohort_age_months, 
r.mrr 
FROM customer_monthly_revenue r JOIN first_purchase f 
ON r.customer_id = f.customer_id 
WHERE r.mrr > 0 
) 
-- SELECT * 
-- FROM cohort_data 
-- ORDER BY customer_id, revenue_month;

SELECT 
cohort_month, 
cohort_age_months, 
COUNT(DISTINCT customer_id) AS active_customers 
FROM cohort_data 
GROUP BY cohort_month, cohort_age_months 
ORDER BY cohort_month, cohort_age_months;








