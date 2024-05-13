/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) as totalamount_spent 
FROM SALES as S
  INNER JOIN MENU as M ON M.product_id = S.product_id 
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) as days_visited 
FROM SALES 
GROUP BY customer_id;
  
-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS (
  SELECT 
    customer_id,
    order_date,
    product_name, 
    RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY order_date) as rnk,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) as rn 
  FROM 
    SALES as S
    INNER JOIN MENU as M on S.product_id = M.product_id
) 
SELECT 
  customer_id,
  product_name
FROM 
  CTE 
WHERE 
  rnk = 1;
  
-- 4. What is the most purchased item on the menu 
-- and how many times was it purchased by all customers?
SELECT 
  product_name, 
  COUNT(order_date) as orders 
FROM 
  SALES as S
  INNER JOIN MENU as M on S.product_id = M.product_id
GROUP BY 
  product_name 
ORDER BY 
  COUNT(order_date) DESC 
LIMIT 1;
  
-- 5. Which item was the most popular for each customer?
WITH CTE AS (
  SELECT 
    product_name, 
    customer_id, 
    COUNT(order_date) as orders,
    RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rn
  FROM 
    SALES as S
    INNER JOIN MENU as M on S.product_id = M.product_id 
  GROUP BY 
    product_name, 
    customer_id
)
SELECT 
  customer_id,
  product_name
FROM 
  CTE
WHERE rnk = 1;
  
-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS (
  SELECT 
    S.customer_id, 
    order_date,
    join_date,
    product_name, 
    RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) as rnk,
    ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date) as rn 
  FROM 
    SALES as S
    INNER JOIN MENU as M on S.product_id = M.product_id
    INNER JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
  WHERE 
    order_date >= join_date 
  ORDER BY 
    order_date ASC
) 
SELECT 
  customer_id,
  product_name
FROM 
  CTE 
WHERE 
  rnk = 1;
  
-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
  SELECT 
    S.customer_id, 
    order_date,
    join_date,
    product_name, 
    RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) as rnk,
    ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date) as rn 
  FROM 
    SALES as S
    INNER JOIN MENU as M on S.product_id = M.product_id
    INNER JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
  WHERE 
    order_date < join_date 
  ORDER BY 
    order_date ASC
) 
SELECT 
  customer_id,
  product_name
FROM 
  CTE 
WHERE 
  rnk = 1;
  
-- 8. What is the total items and amount spent 
-- for each member before they became a member?
SELECT 
  S.customer_id, 
  COUNT(M.product_id) as total_items, 
  SUM(M.price) as amount_spent 
FROM 
  SALES as S
  INNER JOIN MENU as M on S.product_id = M.product_id
  INNER JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
WHERE 
  order_date < join_date 
GROUP BY 
  S.customer_id;
  
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
SELECT 
  customer_id, 
  SUM(
    CASE product_name 
      WHEN 'sushi' THEN price * 10 * 2 
      ELSE price * 10 
    END
  ) as points 
FROM 
  MENU as M 
  INNER JOIN SALES as S ON S.product_id = M.product_id
GROUP BY 
  customer_id;
  
