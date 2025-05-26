/*
Data Segmentation
- Group the data based on a specific range.
- Helps understand the correlation between two measures.

How: [Measure] By [Measure]
Use CASE WHEN statement

E.g., Total Products By Sales Range; Total Customers By Age.

*/


/*Task 1: Segment products into cost ranges and count how many products fall into each segment*/


WITH product_segment AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)

SELECT cost_range, 
COUNT(product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC



/*Task 2: Group customers into three segments based on their spending behavior:
- VIP: Customers with at least 12 months of history and spending more than 5000 euros.
- Regular: Customers with at least 12 months of history but spending no more than 5000 euros.
- New: Customers with a lifespan less than 12 months. (life span is the time between the first order and the last order)
And find the total number of customers by each group.
*/

WITH customer_statistics AS(
SELECT
c.customer_key,
DATEDIFF(month,MIN(s.order_date),MAX(s.order_date)) AS lifespan,
SUM(s.sales_amount) as spending
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
GROUP BY c.customer_key),
customer_segment AS(
SELECT
*,
CASE WHEN lifespan >= 12 AND spending > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND spending <= 5000 THEN 'Regular'
     WHEN lifespan < 12 THEN 'New'
     ELSE 'TBD' -- we have order records that have NULL values for order_date
END customer_type
FROM customer_statistics)


SELECT
customer_type,
COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_type
ORDER BY total_customers DESC

