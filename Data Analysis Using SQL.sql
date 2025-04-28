create database pizza_sales;
 use pizza_sales;
 select * from pizzas;
 select * from pizza_types;
 select * from orders;
 select * from order_details;
 
 
 -- basic
 -- Q1 reterive total number of order placed
 select count(*) from orders;
 
 -- Q2 Calculate the total revenue generated from pizza sales.
 select round(sum(t1.price*t2.quantity),2)  as 'total price 'from pizzas t1;
 
 -- Q3 Identify the highest-priced pizza.
 select t2.name,t1.price from pizzas as t1
 join pizza_types t2
 on t1.pizza_type_id=t2.pizza_type_id order by t1.price desc limit 1
 ;
 
 select * from (select t2.name,t1.price from pizzas as t1
 join pizza_types t2
 on t1.pizza_type_id=t2.pizza_type_id ) t
 where t.price=(
 select max(price) from pizzas);
 
 -- Q4 Identify the most common pizza size ordered.
 select t1.size,count(t2.quantity) from pizzas t1
 join order_details t2
 on t1.pizza_id=t2.pizza_id group by size order by count(t2.quantity) desc limit 1;
 
 -- List the top 5 most ordered pizza types along with their quantities.
 select t3.pizza_type_id,sum(t1.quantity) from order_details t1
 join
 pizzas t2 on t1.pizza_id=t2.pizza_id
 join 
 pizza_types t3 on t2.pizza_type_id=t3.pizza_type_id 
 group by t3.pizza_type_id 
 order by sum(t1.quantity) desc limit 5;
 ;
 
 --  --Intermediate:
 -- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.
 select t2.category,sum(t3.quantity) from pizzas t1
 join 
 pizza_types t2
 on t1.pizza_type_id=t2.pizza_type_id
 join order_details t3
 on t3.pizza_id=t1.pizza_id
 group by t2.category;
 
 -- Q7 Determine the distribution of orders by hour of the day.
 select hour(time),count(order_id) from orders group by hour(time);
 
 -- Q8 Join relevant tables to find the category-wise distribution of pizzas.
 select category,count(name) from pizza_types group by category;
 
 -- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.
 select round(avg(no_of_quantity),0) from(
 select t1.date,sum(t2.quantity) as 'no_of_quantity' from orders t1
 join 
 order_details t2
 on t1.order_Id=t2.order_id
 group by t1.date) t
 ;
 -- Q10 Determine the top 3 most ordered pizza types based on revenue.
 select t1.pizza_type_id,sum(t1.price * t2.quantity) as 'revenue' from pizzas t1
 join 
 order_details t2
 on t1.pizza_id=t2.pizza_id
 group by t1.pizza_type_id
 order by revenue desc limit 3;
 
 
 -- Advanced:
 -- Q11 Calculate the percentage contribution of each pizza type to total revenue.
 select t3.category,sum(t1.price * t2.quantity) as 'revenue',
 sum(sum(t1.price*t2.quantity)) over() as 'total_revenue',round((sum(t1.price * t2.quantity)/sum(sum(t1.price*t2.quantity)) over())*100,2) as 'per'
 from pizzas t1
 join order_details t2
 on t1.pizza_id=t2.pizza_id
 join pizza_types t3
 on t1.pizza_type_id=t3.pizza_type_id
 group by t3.category;
 
 -- Q12 Analyze the cumulative revenue generated over time.
 select date,sum(t3.price*t2.quantity) as 'revenue',
 sum(sum(t3.price*t2.quantity)) over(rows between unbounded preceding and current row) as 'cumulative revenue'
  from orders t1
 join order_details t2
 on t1.order_id=t2.order_id
 join pizzas t3
 on t2.pizza_id=t3.pizza_id group by date;
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select * from 
 (select t2.category,t2.pizza_type_id,sum(t1.price*t3.quantity) as revenue,
 dense_rank() over(partition by category order by sum(t1.price*t3.quantity) desc) as 'top_pizza' from pizzas t1
 join 
 pizza_types t2
 on t1.pizza_type_id=t2.pizza_type_id
 join 
 order_details t3
 on t3.pizza_id=t1.pizza_id
 group by t2.category,t2.pizza_type_id) t
 where t.top_pizza<=3;