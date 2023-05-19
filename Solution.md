 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier -how many points would each customer have?
'''sql
WITH points_cte as(
SELECT *,
CASE
	WHEN menu.product_id = 1 THEN price*10
	ELSE price*10 END 
	AS points
FROM menu
JOIN sales
ON menu.product_id = sales.product_id
 	)
SELECT sales.customer_id, SUM(points)
FROM sales
JOIN points_cte
ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
'''
