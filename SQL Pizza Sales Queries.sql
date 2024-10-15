
-- Basic

--Q1. Retrieve the total number of orders placed.

select count(distinct order_id) as Total_Orders from order_details;


--Q2. Calculate the total revenue generated from pizza sales.

select sum(order_details.quantity*pizzas.prize) as Total_Revenue from order_details 
join pizzas on pizzas.pizza_id=order_details.pizza_id;


--Q3. Identify the highest-priced pizza.

select pizza_types.name as Pizza_Name,pizzas.prize as Price from pizzas 
join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id order by prize desc limit 1;


--Q4. Identify the most common pizza size ordered.

select pizzas.size, count(distinct order_id) as No_of_Orders, sum(quantity) as Total_Quantity_Ordered 
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(distinct order_id) desc;


--Q5. List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name as Pizza, sum(quantity) as Total_Ordered
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name 
order by sum(quantity) desc limit 5;

-- Intermediate

--Q1. Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(quantity) as Total_Quantity_Ordered
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc;


--Q2. Determine the distribution of orders by hour of the day.

select time as Hour_of_the_day, count(distinct order_id) as No_of_Orders
from orders
group by time 
order by No_of_Orders desc;


--Q3. find the category-wise distribution of pizzas

select category, count(distinct pizza_type_id) as No_of_pizzas
from pizza_types
group by category
order by No_of_pizzas desc;


--Q4. Calculate the average number of pizzas ordered per day.

select avg(Total_Pizza_Ordered_that_day) as Avg_Number_of_pizzas_ordered_per_day from 
(
	select orders.date as Date, sum(order_details.quantity) as Total_Pizza_Ordered_that_day
	from order_details
	join orders on order_details.order_id = orders.order_id
	group by orders.date
) as pizzas_ordered;


--Q5. Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity*pizzas.prize) as Revenue_from_pizza
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by Revenue_from_pizza desc limit 5;



-- Advanced:

--Q1. Calculate the percentage contribution of each pizza type to total revenues

select pizza_types.category, 
concat(sum(order_details.quantity*pizzas.prize) /
(select sum(order_details.quantity*pizzas.prize) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
)*100)
as Revenue_contribution_from_pizza
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;


--Q2. Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)

with cte as (
select date as Date, sum(quantity*prize) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
order by Revenue desc
)
select Date, Revenue, sum(Revenue) over (order by date) as Cumulative_Sum
from cte 
group by date, Revenue;


--Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name, sum(quantity*prize) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
order by category, name, Revenue desc
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue


