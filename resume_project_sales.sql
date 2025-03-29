CREATE TABLE customers (
customer_id int ,
name varchar(30),
email varchar(50),
city varchar(25),
signup_date date 
);



CREATE TABLE products(
product_id int ,
product_name varchar(20),
category varchar(15),
price float ,
stock_quantity int 
);

CREATE TABLE orders (
order_id int ,
customer_id int ,                     
order_date date ,
total_amount float
);

 CREATE TABLE order_detail( 
 order_id int,
 product_id int ,
 quantity int ,
 subtotal float
 );


-- Identify the top 10 customers based on total spending.
select o.customer_id ,c.name , sum(o.total_amount) as total_spend
from orders o
join customers c 
on o.customer_id = c.customer_id
group by o.customer_id , c.name
order by total_spend desc 
limit 10;


-- Find the city with the highest number of customers.
select count(customer_id) as no_of_customers , city from customers
group by city
order by no_of_customers desc 
limit 1;


-- Identify customers who placed the most orders.
select c.name, count(o.customer_id) from orders o 
join customers c
on  o.customer_id = c.customer_id
group by o.customer_id ,c.name
order by 2 desc
limit 1;


-- Calculate total revenue for the last 6 months.
select ROUND(sum(total_amount)::numeric,2) as revenue_of_6_months  from orders 
where order_date >= (current_date - interval '6 months');


-- Find the month with the highest sales.
select extract(month from order_date)as month ,extract (year from order_date) as year,
round(sum(total_amount)::numeric,2) as sales
from orders
group by year ,month
order by  sales desc
limit 1;



-- Determine the average order value

select avg(total_amount) as avrerage_value
from orders;



-- Identify the top-selling products.
select p.product_id, p.product_name , count(o.quantity) as quantity from products p
join order_detail o
on p.product_id = o.product_id
group by p.product_id ,p.product_name
order by quantity desc 
limit 10;


-- Find the least-selling products and suggest a strategy.
select p.product_id, p.product_name , count(o.quantity) as quantity from products p
join order_detail o
on p.product_id = o.product_id
group by p.product_id ,p.product_name
order by quantity  
limit 10;



-- Determine the category contributing the most to sales.

select o.product_id,p.category,  count(p.category) as freqent_category from products p
join order_detail o
on p.product_id = o.product_id
group by o.product_id ,p.category
limit 1;


-- Find the number of orders placed each month.
select  extract(month from order_date) as month,extract (year from order_date) as year ,count(d.order_id) as orders from order_detail d
join orders o
on d.order_id = o.order_id 
group by year , month
order by year;



-- Identify orders where customers bought more than 3 items.
select * from order_detail 
where quantity > 3;



-- Analyze the distribution of small vs. large orders.
with distribution as ( select *,
CASE 
	when subtotal > 2000 then 'large'
	when subtotal  between 1000 and 2000 then 'medium'
	else 'small'
	end as category
	from order_detail 
	)
	select category , count(*)
	from distribution 
	group by category;



-- Calculate the percentage growth in sales compared to the previous year.

-- Growth (%) =(  Current Year Sales − Previous Year Sales / Previous Year Sales)×100

with yearly_revenue as (select extract (year from order_date) as year ,
sum (total_amount) as revenue from orders
group by year)

select year , revenue ,
lag(revenue) over (order by year ) as privious_year ,
(revenue - lag(revenue) over (order by year ) / lag(revenue) over (order by year ))*100  as  growth  from yearly_revenue ;






-- Find the retention rate of customers (repeat buyers).

-- formula for retention rate -->  Retention Rate=(Number of Returning Customers / Total Customers in the Previous Period )×100

select  count(customer_id) - count(distinct(customer_id)) as returning_customer ,
(count(customer_id) - count(distinct(customer_id))/ count (customer_id)) * 100  as retention_rate   from  orders 

