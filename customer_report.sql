/* 
==================================================================================
CUSTOMER REPORT 
==================================================================================
Purpose:
- This report consolidates key customer metrics and behaviors
Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
- total orders
- total sales
- total quantity purchased
- total products
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last order)
- average order value
- average monthly spend

====================================================================================*/
create view report_customers as 
/* base query retrieves core columns from table*/
with base_query as (SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT (c.first_name, '', c.last_name) AS customer_name,
DATEDIFF (year, c.birthdate, GETDATE()) age
FROM fact_sales f
LEFT JOIN dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL),

customer_aggregation as 
/* summarizes key metrics at the customer level */
(select 
customer_key,
customer_number, customer_name , age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity ) as total_quantity,
count(product_key) as total_products,
max(order_date) as last_order_date,
datediff(month, min(order_date) , max(order_date)) as lifespan
from base_query
group by customer_key,customer_number,customer_name , age)

select customer_key,
customer_number, customer_name , age,
case when lifespan >=12 and total_sales > 5000 then 'VIP'
  when lifespan >=12 and total_sales <= 5000 then 'Regular'
  else 'NEW'
 end as customer_segment,
total_orders,total_sales,total_products,
last_order_date,
datediff(month, last_order_date , getdate()) as recency ,lifespan ,
--computing avegrage order value
case when total_orders = 0 then 0 
 else total_sales/total_orders
end as avg_order_value,
--computing avg monthly spend
case when lifespan = 0 then total_sales
   else total_sales/(lifespan)
end as avg_monthly_sales
from customer_aggregation

