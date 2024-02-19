**1. How many pizzas were ordered?**

```sql
SELECT CUSTOMER_ID,
	SUM(PRICE) 
FROM JOINED
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID 
```
Output:
| customer_id | sum |
|-------------|-----|
| A           | 76  |
| B           | 74  |
| C           | 36  |


***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT customer_id, count(distinct order_date)
FROM JOINED
GROUP BY CUSTOMER_ID
````
Output:
| customer_id | count |
|-------------|-------|
| A           | 4     |
| B           | 6     |
| C           | 2     |

***

**3. What was the first item from the menu purchased by each customer?**

````sql
WITH items AS (
  SELECT 
    customer_id, 
    product_name, 
    order_date,
    Rank() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank
  FROM joined
)
SELECT customer_id, product_name
FROM items
WHERE rank = 1
````
Output:
| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | curry        |
| C           | ramen        |
| C           | ramen        |

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT PRODUCT_NAME,
	COUNT(*) AS AMOUNT_PURCHASED
FROM JOINED
GROUP BY PRODUCT_NAME
ORDER BY AMOUNT_PURCHASED DESC
LIMIT 1
````
Output:
| product_name | amount_purchased |
|--------------|------------------|
| ramen        | 8                |
***

**5. Which item was the most popular for each customer?**

```sql
WITH RANKED_ITEMS AS
	(SELECT CUSTOMER_ID,
			PRODUCT_NAME,
			RANK() OVER (PARTITION BY CUSTOMER_ID ORDER BY COUNT (PRODUCT_ID) DESC) AS RANK
		FROM JOINED
		GROUP BY CUSTOMER_ID,
			PRODUCT_NAME)
SELECT CUSTOMER_ID,
	PRODUCT_NAME
FROM RANKED_ITEMS
WHERE RANK = 1
```
Output:
| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | ramen        |
| B           | curry        |
| B           | sushi        |
| C           | ramen        |

***

**6. Which item was purchased first by the customer after they became a member?**

```sql
WITH RANKED_ITEMS AS
	(SELECT CUSTOMER_ID,
			PRODUCT_NAME,
			ORDER_DATE,
			RANK() OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE ASC) AS RANK
		FROM JOINED
		WHERE ORDER_DATE > JOIN_DATE)
SELECT CUSTOMER_ID,
	PRODUCT_NAME,
	ORDER_DATE
FROM RANKED_ITEMS
WHERE RANK = 1
GROUP BY CUSTOMER_ID,
	ORDER_DATE,
	PRODUCT_NAME
```
Output:
| customer_id | product_name | order_date |
|-------------|--------------|------------|
| A           | ramen        | 2021-01-10 |
| B           | sushi        | 2021-01-11 |
***

**7. Which item was purchased just before the customer became a member?**

````sql
WITH RANKED_ITEMS AS
	(SELECT CUSTOMER_ID,
			PRODUCT_NAME,
			ORDER_DATE,
			JOIN_DATE,
			RANK() OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS RANK
		FROM JOINED
		WHERE ORDER_DATE < JOIN_DATE)
SELECT CUSTOMER_ID,
	PRODUCT_NAME,
	ORDER_DATE,
	JOIN_DATE
FROM RANKED_ITEMS
WHERE RANK = 1
GROUP BY CUSTOMER_ID,
	ORDER_DATE,
	PRODUCT_NAME,
	JOIN_DATE
````
Output:
| customer_id | product_name | order_date | join_date  |
|-------------|--------------|------------|------------|
| A           | curry        | 2021-01-01 | 2021-01-07 |
| A           | sushi        | 2021-01-01 | 2021-01-07 |
| B           | sushi        | 2021-01-04 | 2021-01-09 |
***

**8. What is the total items and amount spent for each member before they became a member?**

```sql
SELECT CUSTOMER_ID,
	COUNT(DISTINCT PRODUCT_NAME) AS NO_OF_ITEMS,
	SUM(PRICE) AS TOTAL_SPENT
FROM JOINED
WHERE ORDER_DATE < JOIN_DATE
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
```
Output:
| customer_id | no_of_items | total_spent |
|-------------|-------------|-------------|
| A           | 2           | 25          |
| B           | 2           | 40          |
***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
SELECT CUSTOMER_ID,
	SUM(CASE
		WHEN PRODUCT_NAME = 'Sushi' THEN PRICE * 20
		ELSE PRICE * 10
		END) AS POINTS
FROM JOINED
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
```
Output:
| customer_id | points |
|-------------|--------|
| A           | 760    |
| B           | 740    |
| C           | 360    |
***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
WITH point_system AS (
  SELECT 
    customer_id,
    SUM(CASE 
          WHEN order_date < DATE_TRUNC('day', join_date) + INTERVAL '7' DAY THEN price * 20 
          WHEN product_name = 'Sushi' THEN price * 20 
          ELSE price * 10 
        END) AS total_points
  FROM joined
  GROUP BY customer_id, join_date
)
SELECT customer_id, total_points
FROM point_system
WHERE customer_id IN ('A', 'B')
ORDER BY customer_id
```
Output:
| customer_id | total_points |
|-------------|--------------|
| A           | 1520         |
| B           | 1240         |
***

**Bonus Question 1: Join All the Things**
```sql
CREATE OR REPLACE VIEW JOINED AS
SELECT menu.product_id, product_name, price, sales.customer_id, sales.order_date, members.join_date
FROM DD1.MENU
FULL JOIN DD1.SALES ON MENU.PRODUCT_ID = SALES.PRODUCT_ID
FULL JOIN DD1.MEMBERS ON SALES.CUSTOMER_ID = MEMBERS.CUSTOMER_ID;
```
Output:
| product_id | product_name | price | customer_id | order_date | join_date  |
|------------|--------------|-------|-------------|------------|------------|
| 2          | curry        | 15    | A           | 2021-01-07 | 2021-01-07 |
| 3          | ramen        | 12    | A           | 2021-01-11 | 2021-01-07 |
| 3          | ramen        | 12    | A           | 2021-01-11 | 2021-01-07 |
| 3          | ramen        | 12    | A           | 2021-01-10 | 2021-01-07 |
| 1          | sushi        | 10    | A           | 2021-01-01 | 2021-01-07 |
| 2          | curry        | 15    | A           | 2021-01-01 | 2021-01-07 |
| 1          | sushi        | 10    | B           | 2021-01-04 | 2021-01-09 |
| 1          | sushi        | 10    | B           | 2021-01-11 | 2021-01-09 |
| 2          | curry        | 15    | B           | 2021-01-01 | 2021-01-09 |
| 2          | curry        | 15    | B           | 2021-01-02 | 2021-01-09 |
| 3          | ramen        | 12    | B           | 2021-01-16 | 2021-01-09 |
| 3          | ramen        | 12    | B           | 2021-02-01 | 2021-01-09 |
| 3	     | ramen        | 12    | C           | 2021-01-01 |	
| 3	     | ramen        | 12    | C           | 2021-01-01 |	
| 3	     | ramen        | 12    | C           | 2021-01-07 |
***

