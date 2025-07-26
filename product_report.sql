/* Report-2
=========================================================================
Product Report
=========================================================================
Purpose:
- This report consolidates key product metrics and behaviors.
Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost. •
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics:
- total orders
- total sales
- total quantity sold
- total customers (unique)
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last sale)
- average order revenue (AOR)
- average monthly revenue
===========================================================================*/
create view report_products as 
WITH
base_query AS
/*1) Base Query: Retrieves core columns from fact sales and dim_products*/
(SELECT
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL),    --only consider valid sales dates

product_aggregation as 
/* summarizes key metrics at the product level */

(SELECT
product_key, product_name, category, subcategory, cost,
DATEDIFF (MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND (AVG (CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
group by 
product_key, product_name, category, subcategory, cost)

/* final query - Combines all product results into one output */

SELECT
product_key, product_name, category, subcategory, cost, last_sale_date,
DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
CASE WHEN total_sales > 50000 THEN 'High-Performer'
WHEN total_sales >= 10000 THEN 'Mid-Range'
ELSE 'Low-Performer'
END AS product_segment, lifespan, total_orders, total_sales, total_quantity, total_customers, avg_selling_price,
-- Average Order Revenue (AOR)
case when total_orders = 0 then 0
 else total_sales/total_orders 
end as avg_order_revenue,
--Average monthly revenue
case when lifespan = 0 then total_sales
 else total_sales/lifespan 
end as avg_monthly_revenue
from product_aggregation
