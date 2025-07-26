/* DATA SEGMENTATION 
GROUPING THE DATA BASED ON SPECIFIC RANGE->  [MEASURE] BY [MEASURE]
USING CASEWHEN STATEMENTS*/

--SEGMENT PRODUCT INTO COST RANGES 

with product_segment as (SELECT product_key , product_name, cost,
case when cost < 100 then 'below 100'
 when cost between 100 and 500 then '100-500'
 when cost between 500 and 1000 then '500-1000'
 else 'above 1000'
end cost_range
FROM dim_products)

select cost_range, count(product_key) as total_products
from product_segment
group by cost_range
order by total_products

--grouping customers based on their spending behaviour 

select * from dim_customers
select * from fact_sales;

with customer_group as (select b.customer_key, sum(a.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff(month, min(order_date) , max(order_date) ) as lifespan,
case when datediff(month, min(order_date) , max(order_date) )  >= 12 and sum(a.sales_amount) > 5000 then 'VIP'
  when datediff(month, min(order_date) , max(order_date) )  >= 12 and sum(a.sales_amount) <= 5000 then 'regular'
  else 'NEW'
END customer_segment
from fact_sales as a
left join dim_customers as b
on a.customer_key = b.customer_key
group by b.customer_key)

select count(customer_key) as total , customer_segment
from customer_group 
group by customer_segment
order by total desc


