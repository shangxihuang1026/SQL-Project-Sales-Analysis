/*
Performance Analysis
- Compare the current value to a target value.
- Help measure success and compare performance.

How: find the difference of the current measure and the target measure

E.g., Current Sales - Average Sales; Current Year Sales - Previous Year Sales (Year-Over-Year Analysis); Current Sales - Lowest Sales

Usually use Window Functions, Aggregate Functions, LEAD(), LAG()
*/


/* Task: Analyze the yearly performance of products by comparing each product's sales 
to both its average sales performance and the previous year's sales*/
WITH yearly_product_sales AS(
SELECT
p.product_name,
YEAR(s.order_date) AS order_year,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY p.product_name, YEAR(s.order_date)),
current_target_diff AS(
SELECT
product_name,
order_year,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_yearly_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS avg_diff,
LAG(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year) AS pre_year_sales,
current_sales - LAG(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_year) AS pre_diff
FROM yearly_product_sales)

SELECT
*,
CASE WHEN avg_diff > 0 THEN 'Above Avg'
     WHEN avg_diff < 0 THEN 'Below Avg'
     ELSE 'Avg' 
     END AS avg_performance,
CASE WHEN pre_diff > 0 THEN 'Increase'
     WHEN pre_diff < 0 THEN 'Decrease'
     ELSE 'No Change'
     END AS pre_year_performance
FROM current_target_diff
ORDER BY product_name, order_year


-- Monthly Analysis
WITH monthly_product_sales AS(
SELECT
p.product_name,
DATETRUNC(month,s.order_date) AS order_date,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY p.product_name, DATETRUNC(month,s.order_date)),

current_target_diff AS(
SELECT
product_name,
order_date,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_monthly_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS avg_diff,
LAG(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_date) AS pre_month_sales,
current_sales - LAG(current_sales,1) OVER(PARTITION BY product_name ORDER BY order_date) AS pre_diff
FROM monthly_product_sales)

SELECT
*,
CASE WHEN avg_diff > 0 THEN 'Above Avg'
     WHEN avg_diff < 0 THEN 'Below Avg'
     ELSE 'Avg' 
     END AS avg_performance,
CASE WHEN pre_diff > 0 THEN 'Increase'
     WHEN pre_diff < 0 THEN 'Decrease'
     ELSE 'No Change'
     END AS pre_year_performance
FROM current_target_diff
ORDER BY product_name, order_date