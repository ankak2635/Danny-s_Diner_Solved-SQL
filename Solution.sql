-- Author: Ankit Kumar
-- Tool: PostgreSQL

-------------
--SOLUTIONS:
-------------

-- 1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(menu.price) AS amount_spent
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY 1;

 --3. What was the first item from the menu purchased by each customer?
 WITH rank_cte as(
 SELECT sales.customer_id, menu.product_name,
 DENSE_RANK() OVER(PARTITION BY sales.customer_id ORder BY sales.order_date) AS ranking
 FROM sales
 JOIN menu 
 ON sales.product_id = menu.product_id
 )
 SELECT customer_id, product_name
 FROM rank_cte
 WHERE ranking =1 
 GROUP by 1,2;
 
 --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, count(menu.product_id) as times_ordered
FROM menu
JOIN sales
ON menu.product_id = sales.product_id    
GROUP BY 1
order by 2 DESC
LIMIT 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?
WITH points_cte as(        -- cte to assign points
SELECT *,
CASE                                   
	WHEN menu.product_id = 1 THEN price*20
	ELSE price*10 END 
	AS points
FROM menu
JOIN sales
ON menu.product_id = sales.product_id
)
SELECT points_cte.customer_id, SUM(points_cte.points) AS total_points
FROM points_cte
GROUP BY customer_id
ORDER BY customer_id;


--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi how many points do customer A and B have at the end of January?
WITH date_cte as(            -- cte to implement date restrictions 
SELECT *, 
DATE (join_date + INTERVAL '6 DAYS') as valid_date,
DATE ('2021-01-31') as end_date    
FROM members
),
points_cte as(               -- another cte to assign points
SELECT date_cte.customer_id, 
CASE
    WHEN sales.order_date BETWEEN date_cte.join_date AND date_cte.valid_date THEN menu.price *20
    WHEN menu.product_id = 1 then menu.price* 20
    ELSE menu.price*10 END
    AS points
 FROM date_cte
 JOIN sales
 ON sales.customer_id = date_cte.customer_id
 JOIN menu
 ON sales.product_id = menu.product_id
 WHERE sales.order_date <= date_cte.end_date
 )  
 SELECT customer_id, sum(points) AS Points_till_Jan_end
 FROM points_cte
 GROUP BY customer_id
