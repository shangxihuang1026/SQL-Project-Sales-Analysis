/*
Cumulative Analysis
- Aggregate the data progressively over time.
- Helps to understand whether our business is growing or declining.

How: aggregate cumulative measure by date dimension (use Window Functions)

E.g., Running Total Sales By Year, Moving Average of Sales by Month
*/

/* Task: 
- Calculate the total sales per month and the running total of sales over time
- Calculate the average price and moving average price over month*/

SELECT
order_date,
total_sales,
-- window function: note that by default the frame is ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- SUM(total_sales) OVER(ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) as running_total,
avg_price,
AVG(avg_price) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as moving_avg_price
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) t
ORDER BY DATETRUNC(month, order_date)