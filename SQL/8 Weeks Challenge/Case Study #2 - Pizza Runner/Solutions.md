**1. How many pizzas were ordered?**

```sql
select count(order_id) as pizzas_ordered
from joined
```
Output:
| pizzas_ordered |
|----------------|
|       14       |



***

**2. How many unique customer orders were made?**

````sql
select count(distinct order_id) as no_of_orders
from joined
````
Output:
| no_of_orders |
|--------------|
|      10      |


***

**3. How many successful orders were delivered by each runner?**

````sql
select count (distinct pickup_time) as successful_orders from joined
where pickup_time is not null
````
Output:
| successful_orders |
|-------------------|
|         8         |


***

**4. How many of each type of pizza was delivered?**

````sql
select pizza_name, count (pizza_name) as number_delivered from joined
group by pizza_name
````
Output:
| pizza_name  | number_delivered |
|-------------|------------------|
| Meatlovers  | 10               |
| Vegetarian  | 4                |

***

**5. How many Vegetarian and Meatlovers were ordered by each customer?**

```sql
select customer_id, pizza_name, count (pizza_name) as number_delivered from joined
group by customer_id, pizza_name
order by customer_id
```
Output:
| customer_id | pizza_name  | number_delivered |
|-------------|-------------|------------------|
| 101         | Vegetarian  | 1                |
| 101         | Meatlovers  | 2                |
| 102         | Meatlovers  | 2                |
| 102         | Vegetarian  | 1                |
| 103         | Vegetarian  | 1                |
| 103         | Meatlovers  | 3                |
| 104         | Meatlovers  | 3                |
| 105         | Vegetarian  | 1                |


***

**6. What was the maximum number of pizzas delivered in a single order?**

```sql
select customer_id, pizza_name, count (pizza_name) as number_delivered from joined
group by customer_id, pizza_name
order by number_delivered desc
limit 1
```
Output:
| customer_id | pizza_name  | number_delivered |
|-------------|-------------|------------------|
| 103         | Meatlovers  | 3                |

***

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

````sql
SELECT CUSTOMER_ID,
	COUNT(CASE
              WHEN EXCLUSIONS_CLEANED IS NOT NULL OR EXTRAS_CLEANED IS NOT NULL THEN 1
              END) AS CHANGED_PIZZAS,
	COUNT(CASE
              WHEN EXCLUSIONS_CLEANED IS NULL AND EXTRAS_CLEANED IS NULL THEN 1
              END) AS NO_CHANGE
FROM JOINED
WHERE joined.distance_km IS NOT NULL
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
````
Output:
| customer_id | changed_pizzas | no_change |
|-------------|----------------|-----------|
| 101         | 0              | 2         |
| 102         | 0              | 3         |
| 103         | 3              | 0         |
| 104         | 2              | 1         |
| 105         | 1              | 0         |

***

**8. How many pizzas were delivered that had both exclusions and extras?**

```sql

```
Output:

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

