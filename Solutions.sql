/* --------------------
   Case Study Questions
   --------------------*/

-- 1.  What is the total amount each customer spent at the restaurant?
       SELECT A.Customer_id ,SUM(B.price) AS TotalAmt FROM sales A JOIN menu B ON A.product_id = B.product_id GROUP BY A.Customer_id

-- 2.  How many days has each customer visited the restaurant?
       SELECT Customer_id , COUNT(DISTINCT order_date) VisitedTime FROM sales
       GROUP BY Customer_id
-- 3.  What was the first item from the menu purchased by each customer?
		WITH CTE AS(
		SELECT A.customer_id,A.order_date,B.product_name,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) rn  FROM sales A JOIN menu B ON A.product_id = B.product_id)
		SELECT customer_id,order_date,product_name FROM CTE
		WHERE rn=1
-- 4.  What is the most purchased item on the menu and how many times was it purchased by all customers?

		SELECT A.customer_id,B.product_name,COUNT(A.product_id) AS MostPurchasedItem FROM sales A INNER JOIN menu B ON A.product_id = B.product_id
		WHERE A.product_id = (SELECT product_id FROM
		(SELECT top 1 product_id,COUNT(*) AS  cnt  FROM sales 
		GROUP BY product_id
		ORDER BY 2 DESC)A)
		GROUP BY A.customer_id,B.product_name

-- 5.  Which item was the most popular for each customer?
		WITH CTE AS(
		SELECT A.customer_id,B.product_name, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(A.product_id) DESC) AS DR
		FROM sales A INNER JOIN menu B ON A.product_id = B.product_id
		GROUP BY A.customer_id,B.product_name )
		SELECT customer_id,product_name FROM CTE
		WHERE DR = 1

-- 6.  Which item was purchased first by the customer after they became a member?

		WITH CTE AS(
		SELECT A.customer_id,A.order_date,C.Join_date,B.Product_name , DENSE_RANK() OVER(PARTITION BY A.customer_id ORDER BY A.order_date) as rn FROM sales A 
		JOIN menu B 
		ON A.product_id = B.product_id 
		JOIN members C 
		ON A.customer_id = C.customer_id AND A.order_date > C.join_date
		)
		SELECT customer_id,order_date,join_date,product_name FROM CTE
		WHERE rn = 1

-- 7.  Which item was purchased just before the customer became a member?

		WITH CTE AS(
		SELECT A.customer_id,A.order_date,C.Join_date,B.Product_name , DENSE_RANK() OVER(PARTITION BY A.customer_id ORDER BY A.order_date DESC) as rn 
		FROM sales A 
		JOIN menu B 
		ON A.product_id = B.product_id 
		JOIN members C 
		ON A.customer_id = C.customer_id AND A.order_date < C.join_date
		)
		SELECT customer_id,order_date,join_date,product_name FROM CTE
		WHERE rn = 1

-- 8.  What is the total items and amount spent for each member before they became a member?

		SELECT A.customer_id,COUNT(B.Product_name) TotalItem, SUM(B.price) AS TotalAmt
		FROM sales A 
		JOIN menu B 
		ON A.product_id = B.product_id 
		JOIN members C 
		ON A.customer_id = C.customer_id AND A.order_date < C.join_date
		GROUP BY A.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
		SELECT A.customer_id, 
		SUM(CASE WHEN product_name = 'sushi' THEN price*10*2 WHEN product_name = 'curry' THEN price*10 WHEN product_name = 'ramen' THEN price*10 END) AS RewardPoint
		FROM sales A 
		JOIN menu B 
		ON A.product_id = B.product_id 
		GROUP BY A.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--     not just sushi - how many points do customer A and B have at the end of January?
		WITH CTE AS(
		SELECT A.customer_id,LEFT(A.order_date,7) As Date,SUM(2*10*B.Price )AS RewarPoints
		FROM sales A 
		JOIN menu B 
		ON A.product_id = B.product_id 
		JOIN members C 
		ON A.customer_id = C.customer_id AND A.order_date >= C.join_date
		GROUP BY A.customer_id,LEFT(A.order_date,7))
		SELECT * FROM CTE 
		WHERE Date = '2021-01'





