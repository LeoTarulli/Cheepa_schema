-- ============================================================
-- CHEEPÁ SYSTEM: ANALYTICAL & BUSINESS INTELLIGENCE QUERIES
-- This script contains business logic calculations, performance
-- aggregations, and advanced window functions.
-- ============================================================

-- ============================================================
-- SECTION 1: DATA PREPARATION & VIEWS
-- Creating a unified master view to simplify downstream metrics
-- ============================================================

CREATE OR REPLACE VIEW info AS 
SELECT 
    o.orderID,
    o.date,
    o.customerName AS customer,
    p.ProductName AS product,
    o.discount,
    o2.quantity AS quantity,
    o2.PriceApplied AS price,
    o2.CostApplied AS cost,
    c2.Category AS category
FROM orders o 
INNER JOIN orderdetails o2 ON o.orderID = o2.orderID
INNER JOIN products p ON p.productID = o2.productID
INNER JOIN categories c2 ON c2.CategoryID = o.Category
INNER JOIN contact c ON c.RedID = o.Contacto;


-- ============================================================
-- SECTION 2: BUSINESS PERFORMANCE & FINANCIAL METRICS
-- Revenue, Cost, and Profit margins calculations
-- ============================================================

-- Q1: Financial performance per individual order
WITH info_per_order AS (
    SELECT 
        i.orderID,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) AS Rev,
        ROUND(SUM(i.quantity * i.cost), 2) AS Cost,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)) - SUM(i.quantity * i.cost), 2) AS Net_Rev
    FROM info i 
    GROUP BY i.orderID
)
SELECT * FROM info_per_order;

-- Q2: Monthly financial trends (Revenue vs Cost vs Net Profit)
WITH info_per_month AS (
    SELECT 
        CONCAT(MONTHNAME(i.date), "-", YEAR(i.date)) AS billing_month,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) AS Rev,
        ROUND(SUM(i.quantity * i.cost), 2) AS Cost,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)) - SUM(i.quantity * i.cost), 2) AS Net_Rev
    FROM info i 
    GROUP BY YEAR(i.date), MONTHNAME(i.date) -- Grouping by components avoids sorting bugs
)
SELECT * FROM info_per_month;


-- ============================================================
-- SECTION 3: ADVANCED ANALYTICS & CTEs
-- Identifying high-value entities and benchmarking
-- ============================================================

-- Q3: Orders that beat the average order value benchmark
WITH avg_rev_per_order AS (
    SELECT 
        ROUND(AVG(total_orden), 2) AS avg_rev_per_order
    FROM (
        SELECT SUM(i.quantity * (i.price * (100 - i.discount) / 100)) AS total_orden
        FROM info i
        GROUP BY i.orderID
    ) AS info_2
),
rev_per_order AS (
    SELECT 
        i.orderID,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) AS Rev
    FROM info i 
    GROUP BY i.orderID
)
SELECT r.orderID, r.Rev, a.avg_rev_per_order
FROM rev_per_order r
CROSS JOIN avg_rev_per_order a
WHERE r.Rev > a.avg_rev_per_order;

-- Q4: Top 5 products by revenue generated
WITH top_5_product_rev AS (
    SELECT 
        i.product,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) AS revenue,
        RANK() OVER(ORDER BY ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) DESC) AS position
    FROM info i 
    GROUP BY i.product
)
SELECT * FROM top_5_product_rev LIMIT 5;


-- ============================================================
-- SECTION 4: ADVANCED WINDOW FUNCTIONS
-- Row numbering, ranking partitions, and behavioral analytics
-- ============================================================

-- Q5: Chronological purchase history sequence per customer
SELECT 
    i.customer,
    i.orderID,
    DATE(i.date) AS purchase_date,
    ROW_NUMBER() OVER(PARTITION BY i.customer ORDER BY i.date ASC) AS order_sequence_number
FROM info i
ORDER BY i.customer, purchase_date;

-- Q6: Top revenue-generating customers within the "Individual" segment
WITH client_ranking_by_category AS (
    SELECT 
        i.customer,
        i.category,
        ROUND(SUM(i.quantity * (i.price * (100 - i.discount) / 100)), 2) AS Total_Spent,
        DENSE_RANK() OVER(PARTITION BY i.category ORDER BY SUM(i.quantity * (i.price * (100 - i.discount) / 100)) DESC) AS ranking_position
    FROM info i
    GROUP BY i.customer, i.category
)
SELECT customer, Total_Spent, category, ranking_position
FROM client_ranking_by_category
WHERE category = 'Individual'
LIMIT 5;

-- Q7: Dynamic generation of masked customer IDs for security
SELECT DISTINCT
    o.CustomerName,
    CONCAT("Cxtm_", DENSE_RANK() OVER (ORDER BY o.CustomerName ASC)) AS masked_customer_id
FROM orders o
ORDER BY o.CustomerName ASC;