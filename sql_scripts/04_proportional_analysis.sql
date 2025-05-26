/*
Part-to-Whole Analysis (Proportional Analysis)
- Analyze how an individual part is performing compared to the overall.
- Allow us to understand which category has the greatest impact on the business.

How: ([Measure]/Total [Measure])*100 By [Dimension]

E.g., (Sales/Total Sales)*100 By Category; (Quantity/Total Quantity)*100 By Country
*/


/*Task: Which categories contribute the most to overall sales?*/
WITH sales_by_cat AS(
SELECT
DISTINCT p.category,
SUM(s.sales_amount) OVER(PARTITION BY p.category) AS cat_sales
FROM gold.dim_products p
LEFT JOIN gold.fact_sales s ON p.product_key = s.product_key
WHERE p.category IS NOT NULL)

SELECT
category,
CASE WHEN cat_sales IS NULL THEN 0 ELSE cat_sales END AS cat_sales,
CONCAT(ROUND((CAST((CASE WHEN cat_sales IS NULL THEN 0 ELSE cat_sales END) AS FLOAT) / SUM(cat_sales) OVER())*100,2),'%') AS percentage_of_total
FROM sales_by_cat
ORDER BY cat_sales DESC

