/* yearly performance analysis of products comparing their sales to both 
avg sale performance and previous year sales*/

select * from fact_sales;
select * from dim_products;

with yearly_product_sales as ( select year(f.order_date) as order_year , sum(f.sales_amount) as current_sales , p.product_name
from fact_sales as f
left join dim_products as p 
on f.product_key = p.product_key
where f.order_date is not null
group by p.product_name , year(f.order_date))

select order_year, product_name, current_sales,
AVG(current_sales) over (partition by product_name ) as avg_sales,
current_sales - AVG(current_sales) over (partition by product_name ) as diff_avg,
case when current_sales - AVG(current_sales) over (partition by product_name ) > 0 then 'ABOVE AVG'
    WHEN current_sales - AVG(current_sales) over (partition by product_name ) <0 THEN 'BELOW AVG'
    ELSE 'AVG'
END avg_change,
-- year-over-year analysis
lag(current_sales) over (partition by product_name order by order_year) as prev_sales,
case when current_sales -  lag(current_sales) over (partition by product_name order by order_year) > 0 then 'INCREASED'
    WHEN current_sales - lag(current_sales) over (partition by product_name order by order_year) <0 THEN 'DECREASED'
    ELSE 'NO CHANGE'
END prev_change
from yearly_product_sales
order by product_name, order_year 



