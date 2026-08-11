-- =====================================================
-- Day 1: Window Functions + Revenue Movement Foundations
-- PostgreSQL Compatible
-- =====================================================

DROP TABLE IF EXISTS customer_revenue;

CREATE TABLE customer_revenue (
    customer_id INT,
    revenue_month DATE,
    mrr NUMERIC(10,2)
);

INSERT INTO customer_revenue VALUES
(101, '2026-01-01', 100),
(101, '2026-02-01', 120),
(101, '2026-03-01', 120),
(101, '2026-04-01', 150),

(102, '2026-01-01', 200),
(102, '2026-02-01', 180),
(102, '2026-03-01', 0),
(102, '2026-05-01', 220),

(103, '2026-02-01', 80),
(103, '2026-03-01', 90),
(103, '2026-04-01', 70),

(104, '2026-03-01', 300),
(104, '2026-04-01', 350),
(104, '2026-05-01', 400);

SELECT *
FROM customer_revenue
ORDER BY customer_id, revenue_month;


-- Task 1 — Latest Revenue Record
select 
customer_id,
revenue_month,
mrr
from (
	select *, row_number() over(partition by customer_id order by revenue_month desc) as rn
	from customer_revenue
)
where rn=1;

-- Task 2 — Previous Month MRR
SELECT customer_id,
       revenue_month,
       mrr,
       LAG(mrr) OVER (
           PARTITION BY customer_id
           ORDER BY revenue_month
       ) AS previous_mrr
FROM customer_revenue
ORDER BY customer_id, revenue_month;

-- Task 3 — MRR Delta
SELECT customer_id,
       revenue_month,
       mrr,
       LAG(mrr) OVER (
           PARTITION BY customer_id
           ORDER BY revenue_month
       ) AS previous_mrr,

       mrr - LAG(mrr) OVER (
           PARTITION BY customer_id
           ORDER BY revenue_month
       ) AS mrr_delta

FROM customer_revenue
ORDER BY customer_id, revenue_month;

-- Task 4 — Running Total
SELECT customer_id,
       revenue_month,
       mrr,

       SUM(mrr) OVER (
           PARTITION BY customer_id
           ORDER BY revenue_month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total_mrr

FROM customer_revenue
ORDER BY customer_id, revenue_month;

-- Task 5
WITH revenue_history AS (
    SELECT customer_id,
           revenue_month,
           mrr,
           LAG(mrr) OVER (
               PARTITION BY customer_id
               ORDER BY revenue_month
           ) AS previous_mrr
    FROM customer_revenue
)

SELECT customer_id,
       revenue_month,
       previous_mrr,
       mrr,

       CASE
           WHEN previous_mrr IS NULL AND mrr > 0
               THEN 'NEW'

           WHEN previous_mrr = 0 AND mrr > 0
               THEN 'REACTIVATION'

           WHEN mrr > previous_mrr
               THEN 'EXPANSION'

           WHEN mrr < previous_mrr AND mrr > 0
               THEN 'CONTRACTION'

           WHEN previous_mrr > 0 AND mrr = 0
               THEN 'CHURN'

           ELSE 'NO_CHANGE'
       END AS revenue_movement

FROM revenue_history
ORDER BY customer_id, revenue_month;



