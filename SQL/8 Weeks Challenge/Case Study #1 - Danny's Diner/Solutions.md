**1. What is the total amount each customer spent at the restaurant?**

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

```
Output:

***

**7. Which item was purchased just before the customer became a member?**

````sql

````
Ouput:

***

**8. What is the total items and amount spent for each member before they became a member?**

```sql

```
Output:

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql

```
Ouput:

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
```
Ouput:

***

**Bonus Question 1: Join All the Things**
```sql

```
Output:

***

**Bonus Question 2: Rank All the Things**
```sql

```
Ouput:


***
