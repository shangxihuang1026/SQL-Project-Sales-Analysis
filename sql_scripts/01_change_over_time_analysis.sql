/*
Change-Over-Time Analysis
- Analyze how a measure evolves over time.
- Help tracks and identify seasonality in the data.

How: aggregate a measure by date dimension (e.g., average cost by month, total sales by year)

*/


/*Sales Performance Over Time*/

-- Aggregate on the Day level
SELECT
order_date, 
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date


-- Aggregate on the Year level w/ YEAR()
-- A high-level overview insights that helps with strategic decision-making.
SELECT
YEAR(order_date) as order_year,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)


-- Aggregate on the Month level w/ MONTH()
SELECT
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date)


-- Aggregate on the Year-Month level
-- Method 1: w/ YEAR() and MONTH()
-- Two separate columns that take integer values. ORDER BY works.
SELECT
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)


-- Method 2: w/ DATETRUNC() that rounds a date or timestamp to a specific date part
-- DATETRUNC(year,col) gives date in "yyyy-01-01"; DATETRUNC(month, col) gives date in "yyyy-mm-01"
SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)


-- Method 3: w/ FORMAT()
-- FORMAT(col, 'format_desired'): 
-- 'yyyy-MMM' gives 'yyyy-Jan' which can only be ordered by year but not month; 'yyyy-MM' gives 'yyyy-mm' which can be ordered
SELECT
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')

