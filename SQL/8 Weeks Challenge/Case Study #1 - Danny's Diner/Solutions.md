**1. What is the total amount each customer spent at the restaurant?**

```
SELECT CUSTOMER_ID,
	SUM(PRICE) 
FROM JOINED
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID 
```
Ouput:
<markdown table output here>
"customer_id"	"sum"
"A"	76
"B"	74
"C"	36  
***

**2. How many days has each customer visited the restaurant?**

````
SELECT customer_id, count(distinct order_date)
FROM JOINED
GROUP BY CUSTOMER_ID
````
Output:


***

**3. What was the first item from the menu purchased by each customer?**

````sql

````
Output:


***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql

````
Ouput:

***

**5. Which item was the most popular for each customer?**

```sql
```

utput:


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
