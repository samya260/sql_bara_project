--CUMULATIVE ANALYSIS 
-- HELPS TO UNDERSTAND WEHTER THE BUSINESS IS GROWING OR DECLINING


--CALCULATING TOTAL SALES FOR EACH MONTH AND RUNNING TOTAL OF SALES OVER TIME using WINDOW FUNCTION 
select * from fact_sales;

select order_date, total_sales, sum(total_sales) over (order by order_date) as running_total_sales
from (
SELECT DATETRUNC(month , order_date) as order_date, sum(sales_amount) as total_sales 
from fact_sales where order_date is  not null
group by DATETRUNC(month , order_date)) t

--average_running_price per year
select order_date, total_sales, 
sum(total_sales) over (order by order_date) as running_total_sales,
avg(avg_price) over (order by order_date) as avg_running_price
from (
SELECT DATETRUNC(year , order_date) as order_date, sum(sales_amount) as total_sales,
avg(price) as avg_price
from fact_sales where order_date is  not null
group by DATETRUNC(year , order_date)) t