/* PART - TO - WHOLE ANALYSIS OF THE DATA 
COMPARING WHICH CATEGORY HAS THE GREATEST IMPACT ON THE BUSINESS*/

with category_sales as (SELECT p.category , sum(f.sales_amount) as total_sales
FROM fact_sales as f
left join dim_products as p
on f.product_key = p.product_key
group by p.category)

select category , total_sales, 
sum(total_sales) over () as overall_sales,
concat(round(cast (total_sales as float)/(sum(total_sales) over ())*100,2 ),'%')as percent_total
from category_sales
order by total_sales desc
