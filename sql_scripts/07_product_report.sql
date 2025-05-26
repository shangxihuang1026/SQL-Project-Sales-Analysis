/* Reporting
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
       - average selling price
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
CREATE VIEW gold.product_report AS
/* ----------------------------------------------------------------------------
1) Base Query: Retrive core columns from tables
------------------------------------------------------------------------------*/
WITH base_query AS(
SELECT
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost,
p.start_date,
s.order_number,
s.customer_key,
s.order_date,
s.sales_amount,
s.quantity
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL),

/* ----------------------------------------------------------------------------
2) Product Aggregation: Summarizes key metrics at the product level
------------------------------------------------------------------------------*/
aggregate_metrics AS(
SELECT
product_key,
product_name,
category,
subcategory,
cost,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers,
MAX(order_date) AS last_sale_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
product_name,
category,
subcategory,
cost)


/* ----------------------------------------------------------------------------
3) Final query: combines all product results into one output
------------------------------------------------------------------------------*/
SELECT
product_key,
product_name,
category,
subcategory,
cost,
total_orders,
total_sales,
total_quantity,
total_customers,
last_sale_date,
DATEDIFF(month,last_sale_date,GETDATE()) AS recency,
CASE WHEN total_sales > 50000 THEN 'High-Performer'
     WHEN total_sales >= 10000 THEN 'Mid_Range'
     ELSE 'Low_Performer'
END AS product_segment,
lifespan,
avg_selling_price,
-- Calculate Average Order Revenue (AOR)
CASE WHEN total_orders = 0 THEN 0
     ELSE total_sales/total_orders
END AS avg_order_rev,
-- Calculate Average Monthly Revenue
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales/lifespan
END AS avg_monthly_rev
FROM aggregate_metrics
