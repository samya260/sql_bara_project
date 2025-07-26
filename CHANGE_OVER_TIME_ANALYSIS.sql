USE DATAWAREHOUSEPROJ;
SELECT * FROM fact_sales;

--CHANGE-OVER-TIME ANALYSIS OVER FACT_SALES DATA--

--using format
SELECT format(order_date,'yyyy-MMM') as order_dates, sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer
from fact_sales
where order_date is not null
group by format(order_date,'yyyy-MMM')
order by format(order_date,'yyyy-MMM');

--using date function -> year
SELECT year(order_date) as order_dates, sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_quantity
from fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);

-- using datetrunc function (truncates a date or time value to the specified date part(like year, month, day, etc.),removing smaller units.)
SELECT DATETRUNC(month, order_date) as order_dates, sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customer,
sum(quantity) as total_quantity
from fact_sales
where order_date is not null
group by DATETRUNC(month, order_date)
order by DATETRUNC(month, order_date);