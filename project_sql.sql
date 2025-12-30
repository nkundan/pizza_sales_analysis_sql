-- 1. Retrieve the total number of orders placed.
select * from orders;
select count(order_id) as total_orders  from orders;
-- 2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
-- 3.Identify the highest-priced pizza.
select * from pizzas;
select * from pizza_types;
SELECT 
   pizza_types.name , pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;
-- 4.Identify the most common pizza size ordered.
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;
select quantity , count(order_details_id) as count from order_details group by quantity;
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC;
-- 5.List the top 5 most ordered pizza types along with their quantities.
select quantity,count(order_details_id) from order_details group by quantity order by quantity ;
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id= order_details.pizza_id group by pizza_types.name order by quantity desc limit 5;
    
    -- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
  SELECT 
    pizza_types.category AS category,
    SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY quantity DESC;
    -- 7.Determine the distribution of orders by hour of the day.
select hour(time),count(order_id) from orders group by hour(time);
-- 8.Join relevant tables to find the category-wise distribution of pizzas
select category , count(name) as distrubuation from pizza_types group by category;
-- 9.Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    round(AVG(quantity),0)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    -- 10.Determine the top 3 most ordered pizza types based on revenue
  SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
-- 11.Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_revenue
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
-- 12.Analyze the cumulative revenue generated over time.
select date,sum(revenue) over(order by date) as cumulative_revenue from
(SELECT 
    orders.date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.date) as sales;
-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from
(select category,name,revenue, rank() over(partition by category order by revenue desc) as rn from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , name) as a) as b
where rn<=3;