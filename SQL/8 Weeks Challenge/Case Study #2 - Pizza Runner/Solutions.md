**Creating the joined view**

```sql
Create or replace VIEW JOINED AS
SELECT CO.ORDER_ID,
	CO.CUSTOMER_ID,
	PN.PIZZA_NAME,
	PR.TOPPINGS,
	CASE
            WHEN CO.EXCLUSIONS = '' OR CO.EXCLUSIONS = 'null' THEN NULL
            ELSE CAST(REGEXP_REPLACE(CO.EXCLUSIONS,'[ ,]+','','g') AS INTEGER)
	END AS EXCLUSIONS_CLEANED,
	CASE
            WHEN CO.EXTRAS = ''	OR CO.EXTRAS = 'null' THEN NULL
            ELSE CAST(REGEXP_REPLACE(CO.EXTRAS,'[ ,]+','','g') AS INTEGER)
	END AS EXTRAS_CLEANED,
	CO.ORDER_TIME,
	RO.RUNNER_ID,
	R.REGISTRATION_DATE,
	CAST(NULLIF(RO.PICKUP_TIME,'null') AS TIMESTAMP WITHOUT TIME ZONE) AS PICKUP_TIME,
	CASE
            WHEN RO.DISTANCE = '' OR RO.DISTANCE = 'null' THEN NULL
            ELSE CAST(REGEXP_REPLACE(RO.DISTANCE,'[^0-9\.]','','g') AS DECIMAL(7,2))
	END AS DISTANCE_KM,
	CASE
            WHEN RO.DURATION = '' OR RO.DURATION = 'null' THEN NULL
            ELSE CAST(REGEXP_REPLACE(RO.DURATION,'[^0-9]','','g') AS INTEGER)
	END AS DURATION_MINS,
	CASE
             WHEN RO.CANCELLATION = '' OR RO.CANCELLATION = 'null' THEN NULL
             ELSE RO.CANCELLATION
	END AS CANCELS
FROM PR2.CUSTOMER_ORDERS CO
JOIN PR2.PIZZA_NAMES PN ON CO.PIZZA_ID = PN.PIZZA_ID
JOIN PR2.PIZZA_RECIPES PR ON CO.PIZZA_ID = PR.PIZZA_ID
JOIN PR2.RUNNER_ORDERS RO ON CO.ORDER_ID = RO.ORDER_ID
JOIN PR2.RUNNERS R ON RO.RUNNER_ID = R.RUNNER_ID
```
Output:
Data will be cleaned and all tables will be joined together into 1 view

***


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
SELECT COUNT(*) AS NU_PIZZAS
FROM JOINED
WHERE EXCLUSIONS_CLEANED IS NOT NULL
	AND EXTRAS_CLEANED IS NOT NULL
```
Output:
| nu_pizzas |
|-----------|
|     2     |

***

**9. What was the total volume of pizzas ordered for each hour of the day?**

```sql
SELECT DATE_TRUNC('hour',ORDER_TIME),
	COUNT(*)AS NU_PIZZAS
FROM JOINED
GROUP BY ORDER_TIME
ORDER BY ORDER_TIME
```
Output:
| date_trunc           | nu_pizzas |
|----------------------|-----------|
| 2020-01-01 18:00:00  | 1         |
| 2020-01-01 19:00:00  | 1         |
| 2020-01-02 23:00:00  | 2         |
| 2020-01-04 13:00:00  | 3         |
| 2020-01-08 21:00:00  | 1         |
| 2020-01-08 21:00:00  | 1         |
| 2020-01-08 21:00:00  | 1         |
| 2020-01-09 23:00:00  | 1         |
| 2020-01-10 11:00:00  | 1         |
| 2020-01-11 18:00:00  | 2         |
***

**10. What was the volume of orders for each day of the week?**

```sql
SELECT to_char(order_time, 'DAY') AS day, COUNT(*) AS nu_orders
FROM joined
GROUP BY to_char(order_time, 'DAY')
```
Output:
| day       | nu_orders |
|-----------|-----------|
| WEDNESDAY | 5         |
| THURSDAY  | 3         |
| FRIDAY    | 1         |
| SATURDAY  | 5         |
***


**B. Runner and Customer Experience**

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```sql
SELECT DATE_TRUNC('week', REGISTRATION_DATE) AS REGISTRATION_WEEK,
	COUNT(DISTINCT RUNNER_ID) AS COUNT
FROM JOINED
WHERE REGISTRATION_DATE > '2021-01-01 00:00:00+08'
GROUP BY REGISTRATION_WEEK
```
Output:
| registration_week      | count |
|------------------------|-------|
| 2020-12-28 00:00:00+08 | 1     |
| 2021-01-04 00:00:00+08 | 1     |
***

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
SELECT RUNNER_ID,
	AVG(DURATION_MINS) AS TIME
FROM JOINED
WHERE joined.DURATION_MINS IS NOT NULL
GROUP BY RUNNER_ID
ORDER BY RUNNER_ID
```
Output:
| runner_id | time  |
|-----------|-------|
| 1         | 19.83 |
| 2         | 32.00 |
| 3         | 15.00 |

***

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
SELECT ORDER_ID,
	COUNT(ORDER_ID) AS NU_PIZZAS,
	AVG(PICKUP_TIME - ORDER_TIME) AS TIME_TAKEN
FROM JOINED
GROUP BY ORDER_ID
ORDER BY NU_PIZZAS
```
Output:
| order_id | nu_pizzas | time_taken |
|----------|-----------|------------|
| 8        | 1         | 00:20:29   |
| 7        | 1         | 00:10:16   |
| 1        | 1         | 00:10:32   |
| 9        | 1         |            |
| 5        | 1         | 00:10:28   |
| 6        | 1         |            |
| 2        | 1         | 00:10:02   |
| 3        | 2         | 00:21:14   |
| 10       | 2         | 00:15:31   |
| 4        | 3         | 00:29:17   |

There is a relationship, we can see a trend of more pizzas = more time taken
***

**4. What was the average distance travelled for each customer?**
```sql
SELECT CUSTOMER_ID,
	AVG(DISTANCE_KM) AS AVG_DIST
FROM JOINED
WHERE DISTANCE_KM IS NOT NULL
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
```
Output:
| customer_id | avg_dist  |
|-------------|-----------|
| 101         | 20.00     |
| 102         | 16.73     |
| 103         | 23.40     |
| 104         | 10.00     |
| 105         | 25.00     |

***

**5. What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT MAX(DURATION_MINS) - MIN(DURATION_MINS) AS DIFFERENCE
FROM JOINED
WHERE DURATION_MINS IS NOT NULL
```
Output:
| difference |
|------------|
|     30     |

***

**6. What was the average speed for each runner for each delivery?**
```sql
SELECT DISTINCT RUNNER_ID, AVG(DISTANCE_KM / DURATION_MINS) AS SPEED
FROM JOINED
WHERE CANCELS IS NULL
GROUP BY RUNNER_ID
ORDER BY SPEED DESC
```
Output:
| runner_id | speed |
|-----------|-------|
| 2         | 0.86  |
| 1         | 0.78  |
| 3         | 0.67  |

***

**7. What is the successful delivery percentage for each runner?**
```sql
SELECT RUNNER_ID,
	COUNT(CASE
              WHEN CANCELS IS NULL THEN 1
              END)
         / COUNT(DISTINCT ORDER_ID) * 100 AS SUCCESS_PERCENT
FROM JOINED
GROUP BY RUNNER_ID
```
Output:
| runner_id | success_percent |
|-----------|-----------------|
| 1         | 100             |
| 2         | 100             |
| 3         | 0               |

***
